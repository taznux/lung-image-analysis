Lung Image Analysis Framework
====================================================
**Note: Here is a full system for lung cancer screening radiomics. https://github.com/taznux/LungCancerScreeningRadiomics**

> **Status: Superseded — use [qradiomics](https://github.com/choilab-jefferson/qradiomics) for all new work.**
>
> The MATLAB nodule detection / segmentation / characterization pipelines
> here have been re-implemented as atomic Python primitives in
> qradiomics (PyRadiomics + ITK Python bindings, scikit-learn, lifelines).
> The shape-descriptor / spiculation work (AHSN 2014, Spiculation 2021)
> is now `qr extract -p ahsn-shape` / `qr extract -p spiculation`.
> This repo is kept for the published MATLAB reproductions; all ongoing
> work happens in qradiomics.
>
> ```bash
> pip install -e ~/gitRepos/qradiomics   # or: git clone https://github.com/choilab-jefferson/qradiomics
> qr workflow plan -t dicom_to_ml -d lidc -c clinical.csv -o plan.json
> ```

A basic framework for pulmonary nodule detection and characterization in CT

Tested on LIDC-IDRI dataset (https://wiki.cancerimagingarchive.net/display/Public/LIDC-IDRI)
  - LIDC xml parsing
  - Evaluation of nodule segmentation, detection and characterization by LIDC xml annotations

written in Matlab (tested in v2013b and v2016a, and required Image Processing Toolbox)
by Wookjin Choi and Ji-Seok Yoon
