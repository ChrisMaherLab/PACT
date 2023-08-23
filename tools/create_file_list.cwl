#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a file with paths to the input files when given an array of files"

baseCommand: ["echo"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"

inputs:
 infiles:
  type: File[]
  inputBinding:
   prefix: -e
   position: 1
   itemSeparator: "\n"

outputs:
 filepath_file:
  type: stdout

stdout: filepaths.txt
