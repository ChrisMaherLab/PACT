#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform an awk command given a file and pattern"

baseCommand: ["awk"]

requirement:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"

inputs:
 pattern:
  type: string
  inputBinding:
   position: 1
  doc: "Command to give awk"
 in_file:
  type: File
  inputBinding:
   position: 2


outputs:
 awk_out:
  type: stdout

stdout: awk_out
