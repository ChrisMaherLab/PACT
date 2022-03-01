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
   type:
       - string
       - File
   secondaryFiles: [".bai"]
  normal_bam:
   type:
       - string
       - File
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
  

arguments:
 - valueFrom: |
    ${
      var x = "";
      if (inputs.sample_bam.path) {
         x = x + String(inputs.sample_bam.path);
      } else {
         x = x + inputs.sample_bam;
      }
      if (inputs.normal_bam.path) {
        x = x + "," + String(inputs.normal_bam.path);
      } else {
        x = x + "," + inputs.normal_bam;
      }
      return(x)
    }
   position: 2
   prefix: -B
 - valueFrom: -P
   position: 1
 - prefix: -o
   valueFrom: |
    ${
      var x = "";
      if (inputs.sample_bam.path) {
         x = String(runtime.outdir) + "/" + String(inputs.sample_bam.path).split('/').slice(-1)[0].split('.').slice(0,-1).join('.') + ".vcf";
      } else {
         x = String(runtime.outdir) + "/" + String(inputs.sample_bam).split('/').slice(-1)[0].split('.').slice(0,-1).join('.') + ".vcf";
      }
      return(x)
    }
   position: 5
     

outputs:
 vcf:
  type: File
  outputBinding:
   glob: "*.vcf"


