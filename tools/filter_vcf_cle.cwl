#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "cle_annotated_vcf_filter"
baseCommand: ["/usr/bin/perl", "/usr/bin/whitelist_and_coding_indel_selection.pl"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000

arguments: [$(inputs.vcf.path), $(runtime.outdir)]

inputs:
    vcf:
        type: File
    filter:
        type: boolean
        inputBinding:
            prefix: "filter"
            position: 1
outputs:
    cle_filtered_vcf:
        type: File
        outputBinding:
            glob: "annotated_filtered.vcf"
