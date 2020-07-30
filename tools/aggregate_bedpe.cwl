#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Aggregate multiple bedpe files into a single file"

baseCommand: ["bash"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"

inputs:
 script:
  type: File
  inputBinding:
   position: 1
 bedpe:
  type: File[]
  inputBinding:
   position: 2
   itemSeparator: " "

outputs:
 aggregate_bedpe:
  type: stdout

stdout: aggregate.bedpe
