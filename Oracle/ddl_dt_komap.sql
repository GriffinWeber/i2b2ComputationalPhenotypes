--##############################################################################
--##############################################################################
--### KOMAP - Create Tables
--### Date: May 8, 2024
--### Database: Oracle
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- Drop existing tables.
--------------------------------------------------------------------------------

BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_feature_dict'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_patient_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_base_cohort'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_sample'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_sample_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_sample_feature_temp'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_covar_inner'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_covar'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_feature_coef'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_sample_results'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_gmm'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_gold_standard'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_komap_phenotype_patient'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
-- BEGIN EXECUTE IMMEDIATE 'DROP TABLE DERIVED_FACT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;


--------------------------------------------------------------------------------
-- Create new tables to list the phenotypes and their features.
--------------------------------------------------------------------------------

create table dt_komap_phenotype (
	phenotype varchar(50) not null,
	phenotype_name varchar(50) not null,
	threshold float,
	gmm_mean1 float,
	gmm_mean2 float,
	gmm_stdev1 float,
	gmm_stdev2 float,
	ppv float,
	recall float,
	recall_base_cohort float,
	recall_has_feature float,
	frac_feature_in_base_cohort float,
	generate_facts int,
	primary key (phenotype)
);

create table dt_komap_phenotype_feature_dict (
	phenotype varchar(50) not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250),
	primary key (phenotype, feature_cd)
);

--------------------------------------------------------------------------------
-- Create new tables to generate the input data for KOMAP.
--------------------------------------------------------------------------------

create table dt_komap_patient_feature (
	patient_num int not null,
	feature_cd varchar(50) not null,
	num_dates int not null,
	log_dates float not null,
	primary key (feature_cd, patient_num)
);

create table dt_komap_base_cohort (
	patient_num int not null,
	primary key (patient_num)
);

create table dt_komap_phenotype_sample (
	phenotype varchar(50) not null,
	patient_num int not null,
	primary key (phenotype, patient_num)
);

create table dt_komap_phenotype_sample_feature (
	phenotype varchar(50) not null,
	patient_num int not null,
	feature_cd varchar(50) not null,
	num_dates int not null,
	log_dates float not null,
	primary key (phenotype, feature_cd, patient_num)
);

create table dt_komap_phenotype_sample_feature_temp (
    phenotype varchar(50) not null,
    patient_num int not null,
    feature_cd varchar(50) not null,
    num_dates int not null,
    log_dates float not null,
    primary key (patient_num, feature_cd)
);

create table dt_komap_phenotype_covar_inner (
	phenotype varchar(50) not null,
	feature_cd1 varchar(50) not null,
	feature_cd2 varchar(50) not null,
	num_patients int,
	sum_log_dates float,
	primary key (phenotype, feature_cd1, feature_cd2)
);

create table dt_komap_phenotype_covar (
	phenotype varchar(50) not null,
	feature_cd1 varchar(50) not null,
	feature_cd2 varchar(50) not null,
	covar float,
	primary key (phenotype, feature_cd1, feature_cd2)
);

create table dt_komap_phenotype_feature_coef (
	phenotype varchar(50) not null,
	feature_cd varchar(50) not null,
	coef float not null,
	primary key (phenotype, feature_cd)
);

--------------------------------------------------------------------------------
-- Create new tables to store and process the results of KOMAP.
--------------------------------------------------------------------------------

create table dt_komap_phenotype_sample_results (
	phenotype varchar(50) not null,
	patient_num int not null,
	score float,
	phecode_dates int,
	utilization_dates int,
	phecode_score float,
	utilization_score float,
	other_positive_feature_score float,
	other_negative_feature_score float,
	primary key (phenotype, patient_num)
);

create table dt_komap_phenotype_gmm (
	phenotype varchar(50) not null,
	score_percentile int not null,
	score float,
	m1 float,
	m2 float,
	s1 float,
	s2 float,
	g1 float,
	g2 float,
	p1 float,
	p2 float,
	primary key (phenotype, score_percentile)
);

create table dt_komap_phenotype_gold_standard (
	phenotype varchar(50) not null,
	patient_num int not null,
	has_phenotype int,
	score float null,
	primary key (phenotype, patient_num)
);

create table dt_komap_phenotype_patient (
	phenotype varchar(50) not null,
	patient_num int not null,
	score float,
	primary key (phenotype, patient_num)
);

--------------------------------------------------------------------------------
-- Create a DERIVED_FACT table if one does not alreay exist.
--------------------------------------------------------------------------------

/*
create table DERIVED_FACT(
	ENCOUNTER_NUM int NOT NULL,
	PATIENT_NUM int NOT NULL,
	CONCEPT_CD varchar(50) NOT NULL,
	PROVIDER_ID varchar(50) NOT NULL,
	START_DATE date NOT NULL,
	MODIFIER_CD varchar(100) NOT NULL,
	INSTANCE_NUM int NOT NULL,
	VALTYPE_CD varchar(50),
	TVAL_CHAR varchar(255),
	NVAL_NUM number(18,5),
	VALUEFLAG_CD varchar(50),
	QUANTITY_NUM number(18,5),
	UNITS_CD varchar(50),
	END_DATE date NULL,
	LOCATION_CD varchar(50),
	OBSERVATION_BLOB clob NULL,
	CONFIDENCE_NUM number(18,5),
	UPDATE_DATE date NULL,
	DOWNLOAD_DATE date NULL,
	IMPORT_DATE date NULL,
	SOURCESYSTEM_CD varchar(50),
	UPLOAD_ID int
);
alter table DERIVED_FACT add primary key (CONCEPT_CD,PATIENT_NUM,ENCOUNTER_NUM,START_DATE,PROVIDER_ID,INSTANCE_NUM,MODIFIER_CD);
create index DF_IDX_CONCEPT_DATE_PATIENT on DERIVED_FACT  (CONCEPT_CD, START_DATE, PATIENT_NUM);
create index DF_IDX_ENCOUNTER_PATIENT_CONCEPT_DATE on DERIVED_FACT  (ENCOUNTER_NUM, PATIENT_NUM, CONCEPT_CD, START_DATE);
create index DF_IDX_PATIENT_CONCEPT_DATE on DERIVED_FACT  (PATIENT_NUM, CONCEPT_CD, START_DATE);
*/


--------------------------------------------------------------------------------
-- Truncate tables.
--------------------------------------------------------------------------------

/*
truncate table dt_komap_phenotype;
truncate table dt_komap_phenotype_feature_dict;
truncate table dt_komap_patient_feature;
truncate table dt_komap_base_cohort;
truncate table dt_komap_phenotype_sample;
truncate table dt_komap_phenotype_sample_feature;
truncate table dt_komap_phenotype_sample_feature_temp;
truncate table dt_komap_phenotype_covar_inner;
truncate table dt_komap_phenotype_covar;
truncate table dt_komap_phenotype_feature_coef;
truncate table dt_komap_phenotype_sample_results;
truncate table dt_komap_phenotype_gmm;
truncate table dt_komap_phenotype_gold_standard;
truncate table dt_komap_phenotype_patient;
--truncate table DERIVED_FACT;
*/
