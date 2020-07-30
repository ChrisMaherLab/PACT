#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a sorted VCF from input VCF(s) using svtools lmerge"

baseCommand: ["svtools", "lmerge"]

requirements:
    - class: DockerRequirement
      dockerPull: "halllab/svtools:v0.5.1"
#      dockerPull: "ernfrid/svtools:develop"

inputs:
 sorted_vcf:
  type: File
  inputBinding:
   position: 1
   prefix: -i
 breakpoint_confidence_interval:
  type: int
  inputBinding:
   position: 2
   prefix: -f

outputs:
 merged_vcf:
  type: stdout

stdout: merged.vcf
