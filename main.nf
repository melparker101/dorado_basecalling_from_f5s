#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {FAST5_TO_POD5} from './processes.nf'
include {DOWNLOAD_BINARIES} from './processes.nf'
include {DOWNLOAD_MODEL} from './processes.nf'
include {BASECALL} from './processes.nf'


workflow {

    Channel.fromPath( "${params.input_f5s}/*" )
           .map(file -> tuple(file.simpleName, file.getParent().getName(), file))
           .set{ ch_f5s }


    main:

    FAST5_TO_POD5(ch_f5s)

    DOWNLOAD_BINARIES()

    DOWNLOAD_MODEL(DOWNLOAD_BINARIES.out)

    BASECALL(FAST5_TO_POD5.out.pod5, DOWNLOAD_MODEL.out, DOWNLOAD_BINARIES.out)

}
