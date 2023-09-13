#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "CNVkit target"

baseCommand: ["cnvkit.py", "target"]

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

 ref_flat:
  type: File
  inputBinding:
   position: 2
   prefix: "--annotate" 

arguments:
 - valueFrom: "--split"
   position: 3
 - valueFrom: $(runtime.outdir)/targets.bed
   position: 4
   prefix: "-o"

outputs:
 targets_bed:
  type: File
  outputBinding:
   glob: "targets.bed"
