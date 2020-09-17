#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform a sed command given a file and pattern"

baseCommand: sed

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"

inputs:
 command:
  type: string
  inputBinding:
   position: 1
 in_file:
  type: File
  inputBinding:
   position: 2
 out_file:
  type: string
  default: "sed.out"

outputs:
 sed_out:
  type: stdout

stdout: $(inputs.out_file)
