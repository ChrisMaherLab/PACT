#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Run cnvkit access command"

baseCommand: ["cnvkit.py", "access"]

requirements:
    - class: InlineJavascriptRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"

arguments:
 - valueFrom: $(runtime.outdir)/access.bed
   position: 3
   prefix: -o

inputs:
 reference:
  type: File
  secondaryFiles: [.fai, ^.dict]
  inputBinding:
      position: 2


outputs:
 access_bed:
  type:
      - File
  outputBinding:
      glob: "access.bed"     
