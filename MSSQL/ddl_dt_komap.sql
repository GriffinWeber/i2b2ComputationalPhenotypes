--##############################################################################
--##############################################################################
--### KOMAP - Create Tables
--### Date: April 23, 2024
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- Drop existing tables.
--------------------------------------------------------------------------------

if OBJECT_ID(N'dbo.dt_komap_phenotype', N'U') is not null drop table dbo.dt_komap_phenotype;
if OBJECT_ID(N'dbo.dt_komap_phenotype_feature_dict', N'U') is not null drop table dbo.dt_komap_phenotype_feature_dict;
if OBJECT_ID(N'dbo.dt_komap_patient_feature', N'U') is not null drop table dbo.dt_komap_patient_feature;
if OBJECT_ID(N'dbo.dt_komap_base_cohort', N'U') is not null drop table dbo.dt_komap_base_cohort;
if OBJECT_ID(N'dbo.dt_komap_phenotype_sample', N'U') is not null drop table dbo.dt_komap_phenotype_sample;
if OBJECT_ID(N'dbo.dt_komap_phenotype_sample_feature', N'U') is not null drop table dbo.dt_komap_phenotype_sample_feature;
if OBJECT_ID(N'dbo.dt_komap_phenotype_sample_feature_temp', N'U') is not null drop table dbo.dt_komap_phenotype_sample_feature_temp;
if OBJECT_ID(N'dbo.dt_komap_phenotype_covar_inner', N'U') is not null drop table dbo.dt_komap_phenotype_covar_inner;
if OBJECT_ID(N'dbo.dt_komap_phenotype_covar', N'U') is not null drop table dbo.dt_komap_phenotype_covar;
if OBJECT_ID(N'dbo.dt_komap_phenotype_feature_coef', N'U') is not null drop table dbo.dt_komap_phenotype_feature_coef;
if OBJECT_ID(N'dbo.dt_komap_phenotype_sample_results', N'U') is not null drop table dbo.dt_komap_phenotype_sample_results;
if OBJECT_ID(N'dbo.dt_komap_phenotype_gmm', N'U') is not null drop table dbo.dt_komap_phenotype_gmm;
if OBJECT_ID(N'dbo.dt_komap_phenotype_gold_standard', N'U') is not null drop table dbo.dt_komap_phenotype_gold_standard;
if OBJECT_ID(N'dbo.dt_komap_phenotype_patient', N'U') is not null drop table dbo.dt_komap_phenotype_patient;
--if OBJECT_ID(N'dbo.DERIVED_FACT', N'U') is not null drop table dbo.DERIVED_FACT;


--------------------------------------------------------------------------------
-- Create new tables to list the phenotypes and their features.
--------------------------------------------------------------------------------

create table dbo.dt_komap_phenotype (
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

create table dbo.dt_komap_phenotype_feature_dict (
	phenotype varchar(50) not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250)
	primary key (phenotype, feature_cd)
);

--------------------------------------------------------------------------------
-- Create new tables to generate the input data for KOMAP.
--------------------------------------------------------------------------------

create table dbo.dt_komap_patient_feature (
	patient_num int not null,
	feature_cd varchar(50) not null,
	num_dates int not null,
	log_dates float not null,
	primary key (feature_cd, patient_num)
);

create table dbo.dt_komap_base_cohort (
	patient_num int not null,
	primary key (patient_num)
);

create table dbo.dt_komap_phenotype_sample (
	phenotype varchar(50) not null,
	patient_num int not null,
	primary key (phenotype, patient_num)
);

create table dbo.dt_komap_phenotype_sample_feature (
	phenotype varchar(50) not null,
	patient_num int not null,
	feature_cd varchar(50) not null,
	num_dates int not null,
	log_dates float not null,
	primary key (phenotype, feature_cd, patient_num)
);

create table dbo.dt_komap_phenotype_sample_feature_temp (
	phenotype varchar(50) not null,
	patient_num int not null,
	feature_cd varchar(50) not null,
	num_dates int not null,
	log_dates float not null,
	primary key (patient_num, feature_cd)
);

create table dbo.dt_komap_phenotype_covar_inner (
	phenotype varchar(50) not null,
	feature_cd1 varchar(50) not null,
	feature_cd2 varchar(50) not null,
	num_patients int,
	sum_log_dates float,
	primary key (phenotype, feature_cd1, feature_cd2)
);

create table dbo.dt_komap_phenotype_covar (
	phenotype varchar(50) not null,
	feature_cd1 varchar(50) not null,
	feature_cd2 varchar(50) not null,
	covar float,
	primary key (phenotype, feature_cd1, feature_cd2)
);

create table dbo.dt_komap_phenotype_feature_coef (
	phenotype varchar(50) not null,
	feature_cd varchar(50) not null,
	coef float not null
	primary key (phenotype, feature_cd)
);

--------------------------------------------------------------------------------
-- Create new tables to store and process the results of KOMAP.
--------------------------------------------------------------------------------

create table dbo.dt_komap_phenotype_sample_results (
	phenotype varchar(50) not null,
	patient_num int not null,
	score float,
	phecode_dates int,
	utilization_dates int,
	phecode_score float,
	utilization_score float,
	other_positive_feature_score float,
	other_negative_feature_score float
	primary key (phenotype, patient_num)
);

create table dbo.dt_komap_phenotype_gmm (
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

create table dbo.dt_komap_phenotype_gold_standard (
	phenotype varchar(50) not null,
	patient_num int not null,
	has_phenotype int,
	score float null
	primary key (phenotype, patient_num)
);

create table dbo.dt_komap_phenotype_patient (
	phenotype varchar(50) not null,
	patient_num int not null,
	score float,
	primary key (phenotype, patient_num)
);

--------------------------------------------------------------------------------
-- Create a DERIVED_FACT table if one does not alreay exist.
--------------------------------------------------------------------------------

/*
create table dbo.DERIVED_FACT(
	ENCOUNTER_NUM int NOT NULL,
	PATIENT_NUM int NOT NULL,
	CONCEPT_CD varchar(50) NOT NULL,
	PROVIDER_ID varchar(50) NOT NULL,
	START_DATE datetime NOT NULL,
	MODIFIER_CD varchar(100) NOT NULL,
	INSTANCE_NUM int NOT NULL,
	VALTYPE_CD varchar(50),
	TVAL_CHAR varchar(255),
	NVAL_NUM decimal(18,5),
	VALUEFLAG_CD varchar(50),
	QUANTITY_NUM decimal(18,5),
	UNITS_CD varchar(50),
	END_DATE datetime NULL,
	LOCATION_CD varchar(50),
	OBSERVATION_BLOB text NULL,
	CONFIDENCE_NUM decimal(18,5),
	UPDATE_DATE datetime NULL,
	DOWNLOAD_DATE datetime NULL,
	IMPORT_DATE datetime NULL,
	SOURCESYSTEM_CD varchar(50),
	UPLOAD_ID int
)
alter table dbo.DERIVED_FACT add primary key (CONCEPT_CD,PATIENT_NUM,ENCOUNTER_NUM,START_DATE,PROVIDER_ID,INSTANCE_NUM,MODIFIER_CD)
create nonclustered index DF_IDX_CONCEPT_DATE_PATIENT on dbo.DERIVED_FACT  (CONCEPT_CD, START_DATE, PATIENT_NUM)
create nonclustered index DF_IDX_ENCOUNTER_PATIENT_CONCEPT_DATE on dbo.DERIVED_FACT  (ENCOUNTER_NUM, PATIENT_NUM, CONCEPT_CD, START_DATE)
create nonclustered index DF_IDX_PATIENT_CONCEPT_DATE on dbo.DERIVED_FACT  (PATIENT_NUM, CONCEPT_CD, START_DATE)
*/


--------------------------------------------------------------------------------
-- Truncate tables.
--------------------------------------------------------------------------------

/*
truncate table dbo.dt_komap_phenotype;
truncate table dbo.dt_komap_phenotype_feature_dict;
truncate table dbo.dt_komap_patient_feature;
truncate table dbo.dt_komap_base_cohort;
truncate table dbo.dt_komap_phenotype_sample;
truncate table dbo.dt_komap_phenotype_sample_feature;
truncate table dbo.dt_komap_phenotype_sample_feature_temp;
truncate table dbo.dt_komap_phenotype_covar_inner;
truncate table dbo.dt_komap_phenotype_covar;
truncate table dbo.dt_komap_phenotype_feature_coef;
truncate table dbo.dt_komap_phenotype_sample_results;
truncate table dbo.dt_komap_phenotype_gmm;
truncate table dbo.dt_komap_phenotype_gold_standard;
truncate table dbo.dt_komap_phenotype_patient;
--truncate table dbo.DERIVED_FACT;
*/
