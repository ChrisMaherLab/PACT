#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create VCF index using VariantFiltration (GATK)"
baseCommand: ["/gatk/gatk", "VariantFiltration"]
requirements:
    - class: ResourceRequirement
      ramMin: 9000
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: "broadinstitute/gatk:4.1.2.0"


inputs:
    reference:
        type:
            - string
            - File
        inputBinding:
            position: 1
            prefix: "-R"
    vcf:
        type: File
        secondaryFiles: [.idx]
        inputBinding:
            position: 2
            prefix: "-V"
    mask:
        type: File
        secondaryFiles: [.idx]
        inputBinding:
            position: 3
            prefix: "--mask"
    mask_name:
        type: string
        inputBinding:
            position: 4
            prefix: "--mask-name"
    output:
        type: string
        inputBinding:
            position: 5
            prefix: "-O"
    

outputs:
    filtered:
        type: File
#        secondaryFiles: [.tbi]
        outputBinding:
            glob: $(inputs.output)
