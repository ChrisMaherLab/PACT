#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create tumor/control list for filtering somatic Delly calls"

baseCommand: ["bash"]

requirements:
    - class: DockerRequirement
      dockerPull: "biocontainers/bcftools:v1.9-1-deb_cv1"
    - class: ResourceRequirement
      ramMin: 6000

inputs:
 helper:
  type: File
  inputBinding:
   position: 1 
 bcf:
  type: File
  inputBinding:
   position: 2

outputs:
 samples:
  type: stdout

stdout: samples.tsv
