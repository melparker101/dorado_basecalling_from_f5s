# dorado_basecalling_from_f5s
Basecalling using [Dorado](https://github.com/nanoporetech/dorado): f5s to fqs. 

This is a simple Nextflow pipeline which uses Dorado to perform basecalling. 
- It takes **fast5** files as input and outputs **fastq** files. 
- It runs on BMRC computer cluster.
- It does not perform merging of files and instead runs each smaller file in parallel. Merging of fastq files can be performed manually afterwards if required.
- Some BMRC GPUs are outdated and are not compatible with Dorado - for Dorado v0.8.1, a constraint of v100 or a100 is used in the [nextflow.config](https://github.com/oxfordmmm/dorado_basecalling_from_f5s/blob/main/nextflow.config) file (see [BMRC GPU resources](https://www.medsci.ox.ac.uk/for-staff/resources/bmrc/gpu-resources) for more information on BMRC GPUs).

### Steps of the pipeline:
1. Converts fast5 files to pod5 files
2. Downloads Dorado binaries
3. Downloads the chosen Dorado models
4. Performs basecalling on the pod5 files, producing fastq files

## Example
The example provided is from the ESBL neonatal outbreak project. The original samples were basecalled with the model speed HAC (high accuracy), which provides a good balance between accuracy and computational cost. However, for this project, SUP (super accurate), which provides the highest accuracy, was required. Therefore, the data was rebasecalled to ensure optimal accuracy. 

### Batches
The samples from the outbreak were sequenced over five runs. The CSV file in `data/metadata` provides the necessary information on batch names and barcodes to collect the correct files. The batch names are as follows:
- outbreak_sequencing_batch_1
- ESBL_outbreak_batch_2
- ESBL_outbreak_batch_3
- Outbreak_Sequencing_Batch4
- outbreak_141223

### Models
Two different SUP models were selected because the batches were sequenced at different data sampling frequencies:
- 	dna_r10.4.1_e8.2_400bps_sup@v5.0.0
- 	dna_r10.4.1_e8.2_400bps_sup@v4.1.0

For more models, see [dna_models](https://github.com/nanoporetech/dorado?tab=readme-ov-file#dna-models). Currently the pipeline only allows the use of one or both of these two models and manual editing of [processes.nf](https://github.com/oxfordmmm/dorado_basecalling_from_f5s/blob/main/processes.nf) will be required to use any other models (`DOWNLOAD_MODEL{}` process).


## Running the pipeline with the ESBL data
- Nextflow needs to be installed (see [assembly tutorial](https://gitlab.com/ModernisingMedicalMicrobiology/bioinformatics-onboarding/-/blob/main/tutorials/assembly/README.md) for help on setting up the Nextflow config). 
- Clone this repository.
- Then either run the pipeline from within this directory or create a new project directory and copy over the data and misc subdirectories.

### Collect the data
```
bash misc/collect_all_f5s.sh
```
This should create `data/fqs/<batch_names>` containing all fq files per batch.

### Run the basecalling pipeline
```
bash misc/run_main.sh
```

Results (fqs and pod5s) will be in the `output` directory.
