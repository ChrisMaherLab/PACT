#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "HaplotypeCaller (GATK4)"
baseCommand: ["/gatk/gatk", "HaplotypeCaller", "--java-options", "-Xmx16g"]
requirements:
    - class: ResourceRequirement
      ramMin: 18000
    - class: DockerRequirement
      dockerPull: "broadinstitute/gatk:4.1.2.0"

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
# This works
        type:
            - type: array
              items: string
              inputBinding:
                position: 2
                prefix: "-I"
            - type: array
              items: string
              inputBinding:
                position: 2
                prefix: "-I"
        secondaryFiles: [.bai]
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
    mode:
        type: string
        inputBinding:
            position: 5
            prefix: "--genotyping-mode"
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
