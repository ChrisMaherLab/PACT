#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Combine variants from multiple vcfs"
baseCommand: ["python", "/usr/bin/combine_variants.py"]
requirements:
    - class: ResourceRequirement
      ramMin: 9000
      tmpdirMin: 25000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"

arguments: ["-o", { valueFrom: $(runtime.outdir)/combined.vcf }]

inputs:
    mutect_vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 2
        secondaryFiles: [.tbi]
    varscan_vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 3
        secondaryFiles: [.tbi]
    strelka_vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 4
        secondaryFiles: [.tbi]
    pindel_vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 5
        secondaryFiles: [.tbi]
    whitelist_vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 6
outputs:
    combined_vcf:
        type: File
        outputBinding:
            glob: "combined.vcf"

