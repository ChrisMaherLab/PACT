#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Use bedtools pairToBed to compare a bedpe file to a bed file. If no bed file is provide, just output the unedited bedpe."

baseCommand: ["bash", "bedtools_script.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "biocontainers/bedtools:v2.27.1dfsg-4-deb_cv1"
    - class: ResourceRequirement
      ramMin: 4000
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "bedtools_script.sh"
        entry: |
            if [ $# -eq 3 ]; then
             pairToBed -type $1 -a $2 -b $3
            else
             cat $2
            fi

inputs:
 command:
  type: string
  inputBinding:
   position: 1 
 bedpe:
  type: File
  inputBinding:
   position: 2
 bed:
  type: File?
  inputBinding:
   position: 3

outputs:
 filtered_bedpe:
  type: stdout

stdout: pairToBed_result.bedpe
