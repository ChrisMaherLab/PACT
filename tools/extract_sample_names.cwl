#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Extract sample name from vcf"

baseCommand: ["bash", "helper_script.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper_script.sh"
        entry: |
            vcf=$1
            grep "#CHROM" $vcf | awk -F "\t" '{printf $10}'

inputs:
 vcf:
  type: File
  inputBinding:
   position: 1

outputs:
 sample_name:
  type: string
  outputBinding:
    glob: sample_name.txt
    loadContents: true
    outputEval: $(self[0].contents)

stdout: sample_name.txt
