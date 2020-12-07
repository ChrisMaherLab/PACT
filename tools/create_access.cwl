#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create accessible regions file"

baseCommand: ["cnvkit.py", "access"]

requirements:
    - class: DockerRequirement
      dockerPull: "etal/cnvkit:0.9.7"
    - class: ResourceRequirement
      ramMin: 6000

inputs:
 reference_fasta:
  type: string
  inputBinding:
   position: 1

outputs:
 vcf:
  type: stdout

stdout: access.bed
