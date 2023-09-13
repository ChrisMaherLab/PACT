#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "CNVkit antitarget"

baseCommand: ["cnvkit.py", "antitarget"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"
    - class: ResourceRequirement
      coresMin: 4
      ramMin: 15000

inputs:
 capture_targets:
  type: File
  inputBinding:
   position: 1

 access_bed:
  type: File
  inputBinding:
   position: 2
   prefix: "-g" 

arguments:
 - valueFrom: $(runtime.outdir)/antitargets.bed
   position: 3
   prefix: "-o"

outputs:
 anti_targets_bed:
  type: File
  outputBinding:
   glob: "antitargets.bed"
