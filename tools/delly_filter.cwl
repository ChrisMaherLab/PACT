#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Delly"

baseCommand: ["delly", "filter"]

requirements:
    - class: DockerRequirement
      dockerPull: jbwebster/delly_docker
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      coresMin: 8
      ramMin: 15000

inputs:
 samples:
  type: File
  inputBinding:
   position: 2
   prefix: -s
 input_bcf:
  type: File
  inputBinding:
   position: 4
  secondaryFiles: .csi
 command:
  type: string
  inputBinding:
   position: 1
   prefix: -f
 

arguments:
 - prefix: -o
   #valueFrom: $(runtime.outdir)/$(inputs.input_bcf.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).bcf
   valueFrom: $(runtime.outdir)/$(inputs.input_bcf.basename).bcf
   position: 3
 

outputs:
 delly_output:
  type: File
  outputBinding:
   glob: "*.bcf"


