#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
baseCommand: ["SURVIVOR", "merge"]
label: "Run SURVIVOR to merge consensus calls"

requirements:
    - class: DockerRequirement
      dockerPull: "mgibio/survivor-cwl:1.0.6.2"
    - class: InitialWorkDirRequirement
      listing:
        - $(inputs.dataDir)

inputs:
 sample_list:
  type: File
  inputBinding:
   position: 1
 survivor_merge_distance:
  type: int
  inputBinding:
   position: 2
 req_con:
  type: int
  inputBinding:
   position: 3
 same_type:
  type: int
  inputBinding:
   position: 4
 same_strand:
  type: int
  inputBinding:
   position: 5
 not_sure:
  type: int
  inputBinding:
   position: 6
 min_bp:
  type: int
  inputBinding:
   position: 7
 survivor_output:
  type: string
  inputBinding:
   position: 8
 dataDir:
  type: Directory


outputs:
 consensus_vcf:
  type: File
  outputBinding:
   glob: consensus.vcf


