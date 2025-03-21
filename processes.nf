process FAST5_TO_POD5 {
    tag {sample}
    cpus 10

    label 'short'

    publishDir "${params.outDir}/output_pod5s/${batch}/", mode: 'copy'

    input:
    tuple val(sample), val(batch), path('reads.fast5')

    output:
    tuple val(sample), val(batch), path("${sample}.pod5"), emit: pod5, optional: true

    script:
    """
    pod5 convert fast5 reads.fast5 --output ${sample}.pod5 
    # --one-to-one ./input/  # Don't need this are we are running in parallel
    """ 
    stub:
    """
    touch ${sample}.pod5
    """
}

process DOWNLOAD_BINARIES {
    label 'online'
    cache true

    output:
    path("dorado*")

    script:
    """
    wget ${params.binaries}
    tar -xzf *.tar.gz
    rm -rf *.tar.gz
    """
    
    stub:
    """
    mkdir -p dorado-0.8.1-linux-x64
    """

}

process DOWNLOAD_MODEL {
        label 'online'

    input:
    path(dorado)

    output:
    path('dorado_models/')

    script:
    """
    mkdir -p dorado_models
    
    ${dorado}/bin/dorado download --model ${params.model_4000hz} --models-directory dorado_models
    ${dorado}/bin/dorado download --model ${params.model_5000hz} --models-directory dorado_models
    
    # For more general use, use this instead
    # ${dorado}/bin/dorado download --model all --models-directory dorado_models
    """

    stub:
    """
    mkdir -p dorado_models/dna_r10.4.1_e8.2_400bps_sup@v4.1.0
    mkdir -p dorado_models/dna_r10.4.1_e8.2_400bps_sup@v5.0.0
    """
}



process BASECALL {
    tag {sample}
    label 'gpu'

    publishDir "${params.outDir}/output_fastqs/${batch}/", mode: 'copy'

    input:
    tuple val(sample), val(batch), path('reads.pod5')
    path('dorado_models')
    path(dorado)

    output:
    tuple val(sample), val(batch), path("${sample}.fastq.gz"), emit: fastq

    script:
    """
    # Find out what sample rate we have 
    sample_rate=\$(pod5 view --include "sample_rate" reads.pod5 | head -2 | tail -1)
    echo "Sample rate is: \$sample_rate"

    ${dorado}/bin/dorado basecaller sup reads.pod5 --models-directory dorado_models --verbose --emit-fastq | gzip > ${sample}.fastq.gz

    if [ ! -s "${sample}.fastq.gz" ]; then
        echo "Error: Fastq file is empty or does not exist."
        exit 1
    fi
    """ 
    
    stub:
    """
    touch ${sample}.fastq.gz
    """
}
