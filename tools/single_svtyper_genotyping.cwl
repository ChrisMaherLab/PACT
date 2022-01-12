#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Genotype SVs using svtyper"

baseCommand: ["bash"]

requirements:
    - class: DockerRequirement
      dockerPull: "halllab/svtyper:v0.7.1-3c5218a"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 helper:
  type: File
  inputBinding:
   position: 1
 vcf:
  type: File
  inputBinding:
   position: 2
  doc: "VCF file of SVs to genotype"
 bam:
  type:
      - string
      - File
  secondaryFiles: [".bai"]
  inputBinding:
   position: 3
  doc: "Bam to use for genotyping"

outputs:
 genotyped:
  type: stdout

stdout: "$(inputs.vcf.nameroot).geno.vcf"
