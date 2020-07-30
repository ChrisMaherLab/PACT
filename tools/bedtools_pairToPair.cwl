#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Use bedtools pairToPair to compare two bedpe files"

baseCommand: ["pairToPair"]

requirements:
    - class: DockerRequirement
      dockerPull: "biocontainers/bedtools:v2.27.1dfsg-4-deb_cv1"

inputs:
 type_parameter:
  type: string
  inputBinding:
   prefix: -type
   position: 1
 in_file:
  type: File
  inputBinding:
   prefix: -a
   position: 2
 comparison_file:
  type: File
  inputBinding:
   prefix: -b
   position: 3

outputs:
 filtered_bedpe:
  type: stdout

stdout: pairToPair_out.bedpe
