# i2b2ComputationalPhenotypes
Computational phenotype pipeline for i2b2 based on KESER and KOMAP algorithms.

We have previously found that half of patients with an ICD-9 or ICD-10 diagnosis code in the electronic health record (EHR) for Type 2 Diabetes (T2DM) do not actually have the disease. The code for T2DM thus has low "precision" for predicting the patient's true condition or "phenotype". Most diagnosis codes have this problem to varying degrees. One consequence of this is that clinical trials overestimate the number of eligible patients from the EHR. As a result, the trials have low yield in recruiting patients and are slow or unable to meet enrollment targets. 

Various phenotyping approaches ("algorithms") are used to filter the patients to increase precision. However, these can introduce biases and unintentionally remove patients who truly have the phenotype, thereby lowering the "recall". 

Rule-based algorithms leverage clinical knowledge to develop a set of inclusion and exclusion criteria for selecting the correct patients. However, these can be expensive and labor intensive to create and implement because of the amount of manual patient chart review involved. The rules-based approach also often overlooks the complexities, data quality problems, and biases of EHR data that are unique to each organization. 

Computational phenotypes use machine learning algorithms to assign a probability to patients that estimates the likelihood that they have a phenotype. This can be done in a scalable way, which minimizes the amount of manual work, enables fine-tuning at each site, and provides more control over the tradeoff between precision and recall.

This repository contains code, based on algorithms called KESER and KOMAP, for a validated computational phenotyping pipeline for i2b2. Detailed documentation can be found at

https://docs.google.com/document/d/1Th98QZimCQ4w-cj_15lDc6zYUiwypLs7sQ0dioBsY-M/edit?usp=sharing


