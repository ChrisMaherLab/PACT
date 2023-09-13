#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Lumpy"

baseCommand: ["lumpyexpress"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      coresMin: 12
      ramMin: 15000

inputs:
  sample_bam:
   type: File
   secondaryFiles: [".bai"]
  normal_bam:
   type: File
   secondaryFiles: [".bai"]
  splitters:
   type: File[]
   secondaryFiles: [".bai"]
   inputBinding:
    prefix: -S
    position: 3
    itemSeparator: ","
  discordants:
   type: File[]
   secondaryFiles: [".bai"]
   inputBinding:
    prefix: -D
    position: 4
    itemSeparator: ","
  minwt:
   type: int
   inputBinding:
    prefix: -m
  

arguments:
 - valueFrom: |
    ${
      var x = inputs.sample_bam.path;
      x = x + "," + inputs.normal_bam.path;
      return(x)
    }
   position: 2
   prefix: -B
 - valueFrom: -P
   position: 1
 - prefix: -o
   valueFrom: |
    ${
        var x = String(runtime.outdir) + "/" + inputs.sample_bam.nameroot + ".vcf";
        return(x);
    }
   position: 5
     

outputs:
 vcf:
  type: File
  outputBinding:
   glob: "*.vcf"


