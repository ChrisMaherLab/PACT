#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Aggregate final calls"

baseCommand: ["bash", "helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: ResourceRequirement
      ramMin: 12000
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
           cat $1
           tail -n +2 $2

inputs:
 original:
  type: File
  inputBinding:
   position: 1
 rescued:
  type: File
  inputBinding:
   position: 2


outputs:
 aggregated:
  type: stdout

stdout: "aggregate.final_result.bedpe"


