--##############################################################################
--##############################################################################
--### KESER - Create Tables
--### Date: September 1, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- Drop existing tables.
--------------------------------------------------------------------------------

if OBJECT_ID(N'dbo.dt_keser_import_concept_feature', N'U') is not null drop table dbo.dt_keser_import_concept_feature;
if OBJECT_ID(N'dbo.dt_keser_feature', N'U') is not null drop table dbo.dt_keser_feature;
if OBJECT_ID(N'dbo.dt_keser_concept_feature', N'U') is not null drop table dbo.dt_keser_concept_feature;
if OBJECT_ID(N'dbo.dt_keser_concept_children', N'U') is not null drop table dbo.dt_keser_concept_children;
if OBJECT_ID(N'dbo.dt_keser_patient_partition', N'U') is not null drop table dbo.dt_keser_patient_partition;
if OBJECT_ID(N'dbo.dt_keser_patient_period_feature', N'U') is not null drop table dbo.dt_keser_patient_period_feature;
if OBJECT_ID(N'dbo.dt_keser_feature_count', N'U') is not null drop table dbo.dt_keser_feature_count;
if OBJECT_ID(N'dbo.dt_keser_feature_cooccur_temp', N'U') is not null drop table dbo.dt_keser_feature_cooccur_temp;
if OBJECT_ID(N'dbo.dt_keser_feature_cooccur', N'U') is not null drop table dbo.dt_keser_feature_cooccur;
if OBJECT_ID(N'dbo.dt_keser_embedding', N'U') is not null drop table dbo.dt_keser_embedding;
if OBJECT_ID(N'dbo.dt_keser_phenotype', N'U') is not null drop table dbo.dt_keser_phenotype;
if OBJECT_ID(N'dbo.dt_keser_phenotype_feature', N'U') is not null drop table dbo.dt_keser_phenotype_feature;


--------------------------------------------------------------------------------
-- Create tables for mapping features to local concepts.
--------------------------------------------------------------------------------

create table dbo.dt_keser_import_concept_feature (
	concept_cd varchar(50) not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null
);

create table dbo.dt_keser_feature (
	feature_num int not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null,
	primary key (feature_num)
);
create nonclustered index idx_feature_cd on dbo.dt_keser_feature(feature_cd);

create table dbo.dt_keser_concept_feature (
	concept_cd varchar(50) not null,
	feature_num int not null,
	primary key (concept_cd, feature_num)
);
create unique nonclustered index idx_feature_concept on dbo.dt_keser_concept_feature(feature_num, concept_cd);

create table dbo.dt_keser_concept_children (
	concept_cd varchar(50) not null,
	child_cd varchar(50) not null,
	primary key (concept_cd, child_cd)
)

--------------------------------------------------------------------------------
-- Create tables for patient data.
--------------------------------------------------------------------------------

create table dbo.dt_keser_patient_partition (
	patient_num int not null,
	patient_partition tinyint not null,
	primary key (patient_num)
);

create table dbo.dt_keser_patient_period_feature (
	patient_partition tinyint not null,
	patient_num int not null,
	time_period int not null,
	feature_num int not null,
	min_offset smallint not null,
	max_offset smallint not null,
	feature_dates smallint,
	concept_dates int,
	primary key (patient_partition, patient_num, time_period, feature_num)
);

create table dbo.dt_keser_feature_count (
	cohort tinyint not null,
	feature_num int not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null,
	feature_count int not null,
	primary key (cohort, feature_num)
);

create table dbo.dt_keser_feature_cooccur_temp (
	cohort tinyint not null,
	feature_num1 int not null,
	feature_num2 int not null,
	num_patients int not null
);

create table dbo.dt_keser_feature_cooccur (
	cohort tinyint not null,
	feature_num1 int not null,
	feature_num2 int not null,
	coocur_count int not null,
	primary key (cohort, feature_num1, feature_num2)
);

--------------------------------------------------------------------------------
-- Create table to store embeddings.
--------------------------------------------------------------------------------

create table dbo.dt_keser_embedding (
	cohort tinyint not null,
	feature_cd varchar(50) not null,
	dim int not null,
	val float not null,
	primary key (cohort, feature_cd, dim)
);

--------------------------------------------------------------------------------
-- Create tables for embedding regression (map phenotypes to features).
--------------------------------------------------------------------------------

create table dbo.dt_keser_phenotype (
	phenotype varchar(50) not null
	primary key (phenotype)
);

create table dbo.dt_keser_phenotype_feature (
	phenotype varchar(50) not null,
	feature_cd varchar(50) not null,
	feature_rank int,
	feature_beta float,
	feature_cosine float,
	primary key (phenotype, feature_cd)
);


--------------------------------------------------------------------------------
-- Truncate tables.
--------------------------------------------------------------------------------

/*
truncate table dbo.dt_keser_import_concept_feature;
truncate table dbo.dt_keser_feature;
truncate table dbo.dt_keser_concept_feature;
truncate table dbo.dt_keser_concept_children;
truncate table dbo.dt_keser_patient_partition;
truncate table dbo.dt_keser_patient_period_feature;
truncate table dbo.dt_keser_feature_count;
truncate table dbo.dt_keser_feature_cooccur_temp;
truncate table dbo.dt_keser_feature_cooccur;
truncate table dbo.dt_keser_embedding;
truncate table dbo.dt_keser_phenotype;
truncate table dbo.dt_keser_phenotype_feature;
*/

