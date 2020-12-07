#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Apply read support filter to plasma and solid tumor reads"

baseCommand: ["bash", "helper_script.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper_script.sh"
        entry: |
            rs=$1
            bed=$2
            cat $bed | awk -v rs="$rs" 'BEGIN{FS=OFS="\t"}{if($13>=rs || $19>=rs){print}}'
            #cat $bed | awk -v rs="$rs" 'BEGIN{FS=OFS="\t"}{if(($11>=rs && $12>=rs) || ($17>=rs && $18>=rs){print}}'

inputs:
 read_support:
  type: int
  inputBinding:
   position: 1
 in_file:
  type: File
  inputBinding:
   position: 2
 out_file:
  type: string

outputs:
 filtered:
  type: stdout

stdout: $(inputs.out_file)

