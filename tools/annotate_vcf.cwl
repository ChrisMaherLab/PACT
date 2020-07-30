#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Annotate SVs in VCF"

baseCommand: ["snpEff"]

requirements:
    - class: DockerRequirement
      dockerPull: "biocontainers/snpeff:v4.1k_cv3"
    - class: InitialWorkDirRequirement
      listing:
       - $(inputs.genome)
    - class: InlineJavascriptRequirement

inputs:
 genome:
  type: Directory
 genome_name:
  type: string
  inputBinding:
   position: 3
 vcf:
  type: File
  inputBinding:
   position: 4

arguments:
 - valueFrom: "-nodownload"
   position: 1
 - valueFrom: | 
       ${return inputs.genome.path.split('/').slice(0,-1).join('/')}
   prefix: "-dataDir"
   position: 2

outputs:
 annotated_vcf:
  type: stdout

stdout: annotated.vcf
