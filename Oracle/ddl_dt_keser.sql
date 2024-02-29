--##############################################################################
--##############################################################################
--### KESER - Create Tables
--### Date: September 1, 2023
--### Database: Oracle
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- Drop existing tables.
--------------------------------------------------------------------------------

BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_import_concept_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_concept_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_concept_children'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_patient_partition'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_patient_period_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_feature_count'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_feature_cooccur_temp'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_feature_cooccur'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_embedding'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_phenotype'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dt_keser_phenotype_feature'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;

--------------------------------------------------------------------------------
-- Create tables for mapping features to local concepts.
--------------------------------------------------------------------------------

create table dt_keser_import_concept_feature (
	concept_cd varchar(50) not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null
);

create table dt_keser_feature (
	feature_num int not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null,
	primary key (feature_num)
);
create index idx_feature_cd on dt_keser_feature(feature_cd);

create table dt_keser_concept_feature (
	concept_cd varchar(50) not null,
	feature_num int not null,
	primary key (concept_cd, feature_num)
);
create unique index idx_feature_concept on dt_keser_concept_feature(feature_num, concept_cd);

create table dt_keser_concept_children (
	concept_cd varchar(50) not null,
	child_cd varchar(50) not null,
	primary key (concept_cd, child_cd)
);

--------------------------------------------------------------------------------
-- Create tables for patient data.
--------------------------------------------------------------------------------

create table dt_keser_patient_partition (
	patient_num int not null,
	patient_partition number(3,0) not null,
	primary key (patient_num)
);

create table dt_keser_patient_period_feature (
	patient_partition number(3,0) not null,
	patient_num int not null,
	time_period int not null,
	feature_num int not null,
	min_offset smallint not null,
	max_offset smallint not null,
	feature_dates smallint,
	concept_dates int,
	primary key (patient_partition, patient_num, time_period, feature_num)
);

create table dt_keser_feature_count (
	cohort number(3,0) not null,
	feature_num int not null,
	feature_cd varchar(50) not null,
	feature_name varchar(250) not null,
	feature_count int not null,
	primary key (cohort, feature_num)
);

create table dt_keser_feature_cooccur_temp (
	cohort number(3,0) not null,
	feature_num1 int not null,
	feature_num2 int not null,
	num_patients int not null
);

create table dt_keser_feature_cooccur (
	cohort number(3,0) not null,
	feature_num1 int not null,
	feature_num2 int not null,
	coocur_count int not null,
	primary key (cohort, feature_num1, feature_num2)
);

--------------------------------------------------------------------------------
-- Create table to store embeddings.
--------------------------------------------------------------------------------

create table dt_keser_embedding (
	cohort number(3,0) not null,
	feature_cd varchar(50) not null,
	dim int not null,
	val float not null,
	primary key (cohort, feature_cd, dim)
);

--------------------------------------------------------------------------------
-- Create tables for embedding regression (map phenotypes to features).
--------------------------------------------------------------------------------

create table dt_keser_phenotype (
	phenotype varchar(50) not null,
	primary key (phenotype)
);

create table dt_keser_phenotype_feature (
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
truncate table dt_keser_import_concept_feature;
truncate table dt_keser_feature;
truncate table dt_keser_concept_feature;
truncate table dt_keser_concept_children;
truncate table dt_keser_patient_partition;
truncate table dt_keser_patient_period_feature;
truncate table dt_keser_feature_count;
truncate table dt_keser_feature_cooccur_temp;
truncate table dt_keser_feature_cooccur;
truncate table dt_keser_embedding;
truncate table dt_keser_phenotype;
truncate table dt_keser_phenotype_feature;
*/

