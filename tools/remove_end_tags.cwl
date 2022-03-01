#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "remove END INFO tags"
baseCommand: ["/usr/bin/bcftools", "annotate"]
arguments: [
    "-x", "INFO/END",
    "-Oz",
    "-o", { valueFrom: $(runtime.outdir)/pindel.noend.vcf.gz }
]
requirements:
    - class: ResourceRequirement
      ramMin: 4000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"

inputs:
    vcf:
        type: File
        inputBinding:
            position: 1
        secondaryFiles: [.tbi]
outputs:
    processed_vcf:
        type: File
        outputBinding:
            glob: "pindel.noend.vcf.gz"
