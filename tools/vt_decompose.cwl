#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "run vt decompose"
baseCommand: ["/usr/local/bin/vt-0.57721/vt", "decompose"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
arguments:
    ["-s",
     "-o", { valueFrom: $(runtime.outdir)/decomposed.vcf.gz }]
inputs:
    vcf:
        type: File
        inputBinding:
            position: 1
        secondaryFiles: [".tbi"]
outputs:
    decomposed_vcf:
        type: File
        outputBinding:
            glob: "decomposed.vcf.gz"
