#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create VCF index using IndexFeatureFile (GATK)"
requirements:
    - class: ResourceRequirement
      ramMin: 9000
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: "broadinstitute/gatk:4.1.2.0"

arguments: [
    "cp", $(inputs.vcf.path), "$(runtime.outdir)/$(inputs.vcf.basename)",
    { valueFrom: " && ", shellQuote: false },
    "/gatk/gatk", "IndexFeatureFile"
]

inputs:
    vcf:
        type: File
        inputBinding:
            valueFrom:
                $(runtime.outdir)/$(inputs.vcf.basename)
            position: 1
            prefix: "-F"

outputs:
    indexed_vcf:
        type: File
        secondaryFiles: [.idx]
        outputBinding:
            glob: $(inputs.vcf.basename)
