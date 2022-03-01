#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Convert target bed to target interval list using picar BedToIntervalList"

baseCommand: ["java", "-jar", "/opt/picard-2.18.1/picard.jar", "BedToIntervalList"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 6000

inputs:
 bed:
  type: File
  inputBinding:
   position: 1
   prefix: "I="
   separate: false
 sd:
  type:
      - string
      - File
  secondaryFiles: [^.dict, .fai]
  inputBinding:
   position: 3
   prefix: "SD="
   separate: false

outputs:
 roi_intervals:
  type: File
  outputBinding:
      glob: "targets.interval_list"

arguments:
 - valueFrom: O=$(runtime.outdir)/targets.interval_list
   position: 2

