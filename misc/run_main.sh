#!/bin/bash

# Define a vector (array) of batch names
batch_list=("outbreak_sequencing_batch_1" "ESBL_outbreak_batch_2" "ESBL_outbreak_batch_3" "Outbreak_Sequencing_Batch4" "outbreak_141223")
#batch_list=("outbreak_sequencing_batch_1")

# Define main project dir 
project_dir=$PWD

# Use a for loop to print batch names
for batch in "${batch_list[@]}"; do
  echo "$batch"

  nextflow run https://github.com/oxfordmmm/dorado_basecalling_from_f5s \
        --input_f5s \
        --batch "$batch" \
        -resume \
        --outDir output \
        --input_f5s "data/f5s/$batch" \
        -with-report -with-trace -profile conda,bmrc
done
 