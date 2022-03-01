#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create VCF index using IndexFeatureFile (GATK)"
requirements:
    - class: ResourceRequirement
      ramMin: 9000
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"

arguments: [
    "cp", $(inputs.vcf.path), "$(runtime.outdir)/$(inputs.vcf.basename)",
    { valueFrom: " && ", shellQuote: false },
    "gatk", "IndexFeatureFile"
]

inputs:
    vcf:
        type: File
        inputBinding:
            valueFrom:
                $(runtime.outdir)/$(inputs.vcf.basename)
            position: 1
            prefix: "--input"

outputs:
    indexed_vcf:
        type: File
        secondaryFiles: [.idx]
        outputBinding:
            glob: $(inputs.vcf.basename)
