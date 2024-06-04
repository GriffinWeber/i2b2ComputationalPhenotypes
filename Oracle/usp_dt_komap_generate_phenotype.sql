--##############################################################################
--##############################################################################
--### KOMAP - Generate Phenotype
--### Date: May 8, 2024
--### Database: Oracle
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


-- Drop the procedure if it already exists
BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE usp_dt_komap_generate_phenotype'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF; END;


CREATE PROCEDURE usp_dt_komap_generate_phenotype
AS
    proc_start_time timestamp := localtimestamp;
    step_start_time timestamp;
BEGIN



--------------------------------------------------------------------------------
-- Truncate tables to remove old data.
--------------------------------------------------------------------------------

execute immediate 'truncate table dt_komap_phenotype_patient';


-------------------------------------------------------------------------
-- Calculate the phenotype scores for all patients with the PheCode.
-------------------------------------------------------------------------

step_start_time := localtimestamp;
insert into dt_komap_phenotype_patient (phenotype, patient_num, score)
    select c.phenotype, f.patient_num, sum(f.log_dates*c.coef) score
    from dt_komap_phenotype_feature_coef c
         inner join dt_komap_patient_feature s
            on c.phenotype=s.feature_cd
         inner join dt_komap_base_cohort b
            on s.patient_num=b.patient_num
         inner join dt_komap_patient_feature f
            on c.feature_cd=f.feature_cd and f.patient_num=s.patient_num
         inner join dt_komap_phenotype p
            on c.phenotype=p.phenotype and p.generate_facts=1
    where c.coef<>0
        and c.phenotype in (
            select phenotype
            from dt_komap_phenotype_sample
            group by phenotype
            having count(*)>=50000
        )
    group by c.phenotype, f.patient_num;
usp_dt_print(step_start_time, '  insert into dt_komap_phenotype_patient', sql%Rowcount);

-- Next, use the sample results to get the scores for phenotypes with < 50,000 patients
step_start_time := localtimestamp;
insert into dt_komap_phenotype_patient (phenotype, patient_num, score)
    select s.phenotype, s.patient_num, s.score
    from dt_komap_phenotype_sample_results s
         inner join dt_komap_phenotype p
            on s.phenotype=p.phenotype and p.generate_facts=1
    where s.phenotype in (
        select phenotype
        from dt_komap_phenotype_sample
        group by phenotype
        having count(*)<50000
    );
usp_dt_print(step_start_time, '  insert into dt_komap_phenotype_patient', sql%Rowcount);

execute immediate 'analyze table dt_komap_phenotype_patient compute statistics';

-------------------------------------------------------------------------
-- Delete old facts for patients who had the phenotype.
-------------------------------------------------------------------------

step_start_time := localtimestamp;
delete
    from OBSERVATION_FACT -- or DERIVED_FACT if using multiple fact tables
	where concept_cd in (
		select 'DT|' || phenotype
		from dt_komap_phenotype
		where generate_facts=1
	);
usp_dt_print(step_start_time, '  delete from OBSERVATION_FACT', sql%Rowcount);


-------------------------------------------------------------------------
-- Generate new derived facts for patients who now have the phenotype.
-- Here, using a dummy encounter_num = -1, which is assumed not to exist in VISIT_DIMENSION.
-------------------------------------------------------------------------

step_start_time := localtimestamp;
insert into OBSERVATION_FACT -- or DERIVED_FACT if using multiple fact tables
        (encounter_num, patient_num, concept_cd, provider_id, start_date, modifier_cd, instance_num,
            valtype_cd, tval_char, nval_num, valueflag_cd, end_date, location_cd, observation_blob, sourcesystem_cd)
    select -1, s.patient_num, 'DT|' || s.phenotype, '@', sysdate, '@', 1,
        'N', 'E', s.score, '@', sysdate, '@', '', 'phenotype'
    from dt_komap_phenotype_patient s
        inner join dt_komap_phenotype p
            on s.phenotype=p.phenotype
    where s.score >= p.threshold;
usp_dt_print(step_start_time, '  insert into OBSERVATION_FACT', sql%Rowcount);

-------------------------------------------------------------------------
-- Update facts representing the Base Cohort.
-- Here, using a dummy encounter_num = -1, which is assumed not to exist in VISIT_DIMENSION.
-------------------------------------------------------------------------

-- Delete existing facts
step_start_time := localtimestamp;
delete
    from OBSERVATION_FACT -- or DERIVED_FACT if using multiple fact tables
    where concept_cd = 'DT|BaseCohort';
usp_dt_print(step_start_time, '  delete from OBSERVATION_FACT', sql%Rowcount);

-- Insert new facts
step_start_time := localtimestamp;
insert into OBSERVATION_FACT -- or DERIVED_FACT if using multiple fact tables
        (encounter_num, patient_num, concept_cd, provider_id, start_date, modifier_cd, instance_num,
            valtype_cd, tval_char, nval_num, valueflag_cd, end_date, location_cd, observation_blob, sourcesystem_cd)
    select -1, patient_num, 'DT|BaseCohort', '@', sysdate, '@', 1,
        null, null, null, '@', sysdate, '@', '', 'phenotype'
    from dt_komap_base_cohort;
usp_dt_print(step_start_time, '  insert into OBSERVATION_FACT', sql%Rowcount);

execute immediate 'analyze table OBSERVATION_FACT compute statistics';  -- or DERIVED_FACT if using multiple fact tables

usp_dt_print(proc_start_time, 'usp_dt_komap_generate_phenotype', null);

END;
/

