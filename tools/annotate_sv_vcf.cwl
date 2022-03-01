#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Annotate SVs in VCF"

baseCommand: ["java", "-Xmx4G", "-jar", "/snpEff/snpEff.jar"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
       - $(inputs.genome)
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      ramMin: 8000

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
