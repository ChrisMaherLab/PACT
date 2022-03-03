#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Delly"

baseCommand: ["delly", "call"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      coresMin: 12
      ramMin: 15000

inputs:
 ref:
  type: 
      - string
      - File
  secondaryFiles: [.fai]
  inputBinding:
   prefix: -g
   position: 1
  doc: "Reference genome .fa"
 sample_bam:
  type: string
  inputBinding:
   position: 3
 normal_bam:
  type: string
  inputBinding:
   position: 4
  secondaryFiles: [.bai]

arguments:
 - prefix: -o
   valueFrom: $(runtime.outdir)/$(inputs.sample_bam.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).bcf
   position: 2

outputs:
 delly_output:
  type: File
  secondaryFiles: .csi
  outputBinding:
   glob: $(inputs.sample_bam.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).bcf


