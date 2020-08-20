#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Genotype SVs using svtyper"

baseCommand: ["/opt/hall-lab/python-2.7.15/bin/svtyper"]

requirements:
    - class: DockerRequirement
      dockerPull: "halllab/svtyper:v0.7.1-3c5218a"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 vcf:
  type: File
  inputBinding:
   position: 1
   prefix: -i
  doc: "VCF file of SVs to genotype"
 bams_to_genotype:
  type: string[]
  secondaryFiles: [".bai"]
  inputBinding:
   position: 2
   prefix: -B
   itemSeparator: ","
  doc: "Array of bams to use for genotyping"

outputs:
 genotyped:
  type: stdout

stdout: "$(inputs.vcf.nameroot).geno.vcf"
