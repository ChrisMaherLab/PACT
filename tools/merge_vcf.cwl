#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "vcf merge"
baseCommand: ["/usr/bin/bcftools", "concat"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
arguments:
    - "--allow-overlaps"
    - "--remove-duplicates"
    - "--output-type"
    - "z"
    - "-o"
    - { valueFrom: $(runtime.outdir)/$(inputs.merged_vcf_basename).vcf.gz }
inputs:
    vcfs:
        type: File[]
        inputBinding:
            position: 1
        secondaryFiles: [.tbi]
    merged_vcf_basename:
        type: string?
        default: 'merged'
outputs:
    merged_vcf:
        type: File
        outputBinding:
            glob: $(inputs.merged_vcf_basename).vcf.gz
