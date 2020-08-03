#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "egrep -v"

baseCommand: ["egrep"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InlineJavascriptRequirement

inputs:
 pattern:
  type: string
  inputBinding:
   prefix: -v
   position: 1
 in_file:
  type: File
  inputBinding:
   position: 2


outputs:
 egrep_v_file:
  type: stdout


