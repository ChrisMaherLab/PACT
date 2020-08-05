#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Download snpEff reference database"

baseCommand: ["java", "-jar", "/snpEff/snpEff.jar"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snpeff_docker"
    - class: ResourceRequirement
      outdirMin: 1000

inputs:
 db:
  type: string
  inputBinding:
   position: 1
   prefix: download

arguments:
 - prefix: "-dataDir"
   valueFrom: $(runtime.outdir)
   position: 2

outputs:
 database:
  type: Directory
  outputBinding:
   glob: $(inputs.db)


