#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Download snpEff reference database"

baseCommand: ["snpEff"]

requirements:
    - class: DockerRequirement
      dockerPull: biocontainers/snpeff:v4.1k_cv3

inputs:
 db:
  type: string
  inputBinding:
   position: 1
   prefix: download

arguments:
 - prefix: "-dataDir"
   valueFrom: $(runtime.outdir)
   position: 2

outputs:
 database:
  type: Directory
  outputBinding:
   glob: $(inputs.db)


