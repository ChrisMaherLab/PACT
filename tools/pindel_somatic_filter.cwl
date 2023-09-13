#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "pindel somatic filter"
arguments: [
    "/usr/bin/perl", "/usr/bin/write_pindel_filter_config.pl", $(inputs.pindel_output_summary.path), $(inputs.min_var_freq), $(inputs.reference), $(runtime.outdir),
    { valueFrom: " && ", shellQuote: false },
    "/usr/bin/perl", "/usr/bin/somatic_indelfilter.pl", "filter.config"
]
requirements:
    - class: ResourceRequirement
      ramMin: 16000
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"

inputs:
    reference:
        type: File
        secondaryFiles: [.fai, ^.dict]
    pindel_output_summary:
        type: File
    min_var_freq:
        type: float
outputs:
    vcf:
        type: File
        outputBinding:
            glob: "pindel.out.vcf"
