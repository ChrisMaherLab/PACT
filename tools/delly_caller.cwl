#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Delly"

baseCommand: ["delly", "call"]

requirements:
    - class: DockerRequirement
      dockerPull: jbwebster/delly_docker
    - class: InlineJavascriptRequirement

inputs:
 ref:
  type: File
  inputBinding:
   prefix: -g
   position: 1
  doc: "Reference genome .fa"
 tumor_bam:
  type: File
  secondaryFiles: [".bai"]
  inputBinding:
   position: 3
 control_bam:
  type: File
  secondaryFiles: [".bai"]
  inputBinding:
   position: 4

arguments:
 - prefix: -o
   valueFrom: $(runtime.outdir)/$(inputs.tumor_bam.nameroot).bcf
   position: 2

outputs:
 delly_output:
  type: File
  outputBinding:
   glob: "*.bcf"


