#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Lumpy"

baseCommand: ["lumpyexpress"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/lumpy_docker"
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      coresMin: 12
      ramMin: 15000

inputs:
 bams:
  type: string[]
  inputBinding:
   prefix: -B
   position: 1
   itemSeparator: ","
 splitters:
  type: File[]
  secondaryFiles: [".bai"]
  inputBinding:
   prefix: -S
   position: 2
   itemSeparator: ","
 discordants:
  type: File[]
  secondaryFiles: [".bai"]
  inputBinding:
   prefix: -D
   position: 3
   itemSeparator: ","
  

arguments:
 - valueFrom: -P
   position: 0
 - prefix: -o
   valueFrom: $(runtime.outdir)/$(inputs.bams[0].split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).vcf
   position: 4
     

outputs:
 vcf:
  type: File
  outputBinding:
   glob: "*.vcf"


