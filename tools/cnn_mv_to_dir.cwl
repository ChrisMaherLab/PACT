#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Move all files into same dir"
baseCommand: ["/bin/bash", "helper.sh"]

requirements:
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
             #!/bin/bash

             files=( "$@" )
             mkdir cov_dir

             for i in "$@"; do
               x=$(basename "$i")
               mv $i cov_dir/$x
             done

inputs:
 targets:
  type: File[]
  inputBinding:
   position: 1
   seperate: true

 antitargets:
  type: File[]
  inputBinding:
   position: 2
   separate: true

outputs:
 cov_dir:
  type: Directory
  outputBinding:
   glob: "cov_dir"

