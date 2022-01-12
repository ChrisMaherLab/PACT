#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Aggregate multiple bedpe files into a single file"

baseCommand: ["bash", "/usr/bin/aggregate_bedpe.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/helper_docker"
    - class: ResourceRequirement
      ramMin: 4000
      coresMin: 1

inputs:
 bedpe:
  type: File[]
  inputBinding:
   position: 1
   itemSeparator: " "

outputs:
 aggregate_bedpe:
  type: stdout

stdout: aggregate.bedpe
