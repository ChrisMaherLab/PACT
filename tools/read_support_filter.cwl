#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Apply read support filter to SV calls using plasma and matched control reads. Requires at least 1 split-read and 1 paired-end read, and no support in matched control. Requirements are relaxed for whitelisted variants"

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
            cat $bed | awk -v rs="$rs" 'BEGIN{FS=OFS="\t"}{if($11>=1 && $12 >=1 && $13>=rs && $20==0){print}}'
            grep "WHITELISTED=TRUE" $bed | awk -v rs="$rs" 'BEGIN{FS=OFS="\t"}{if($11>=rs || $12>=rs){print}}' | awk 'BEGIN{FS=OFS="\t"}{if($11==0 || $12==0){print}}' | awk 'BEGIN{FS=OFS="\t"}{if($20==0){print}}'
            grep "WHITELISTED=TRUE" $bed | awk -v rs="$rs" 'BEGIN{FS=OFS="\t"}{if($11==1 && $12==1 && $13<rs && $20==0){print}}'  

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

