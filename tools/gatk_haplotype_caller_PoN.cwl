#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "HaplotypeCaller (GATK4)"
baseCommand: ["gatk", "HaplotypeCaller", "--java-options", "-Xmx16g"]
requirements:
    - class: ResourceRequirement
      ramMin: 18000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"

inputs:
    reference:
        type:
            - string
            - File
        secondaryFiles: [.fai, ^.dict]
        inputBinding:
            position: 1
            prefix: "-R"
    bams:
        type:
            type: array
            items: string
            inputBinding:
                prefix: "-I"
        inputBinding:
            position: 2
    vcf:
        type: File
        secondaryFiles: [.idx]
        inputBinding:
            position: 3
            prefix: "--alleles"
    intervals:
        type: File
        inputBinding:
            position: 4
            prefix: "-L"
    output:
        type: string
        inputBinding:
            position: 6
            prefix: "-O"

outputs:
    PoN_vcf:
        type: File
        outputBinding:
            glob: "PoN.vcf"
