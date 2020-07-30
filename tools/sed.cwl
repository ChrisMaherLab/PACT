#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform a sed command given a file and pattern"

baseCommand: sed

requirement:
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

outputs:
 sed_out:
  type: stdout

stdout: sed_out
