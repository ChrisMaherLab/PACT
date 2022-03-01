#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "vcf index"
arguments: [
    "cp", $(inputs.vcf.path), "$(runtime.outdir)/$(inputs.vcf.basename)",
    { valueFrom: " && ", shellQuote: false },
    "/usr/local/bin/tabix", "-p", "vcf"
]
requirements:
    - class: ShellCommandRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement
inputs:
    vcf:
        type: File
        inputBinding:
            valueFrom:
                $(self.basename)
            position: 1
outputs:
    indexed_vcf:
        type: File
        secondaryFiles: [.tbi]
        outputBinding:
            glob: $(inputs.vcf.basename)

