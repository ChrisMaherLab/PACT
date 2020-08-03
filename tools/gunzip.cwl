#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Unzip a zipped file"

baseCommand: ["gunzip", "-c"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InlineJavascriptRequirement

inputs:
 in_file:
  type: File
  inputBinding:
   position: 1
  doc: "Zipped file"

outputs:
 unzipped_file:
  type: File
  outputBinding:
   glob: "$(inputs.in_file.path.split('/').slice(-1)[0].split('.').slice(0,-1).join('.'))"

stdout: "$(inputs.in_file.path.split('/').slice(-1)[0].split('.').slice(0,-1).join('.'))"
