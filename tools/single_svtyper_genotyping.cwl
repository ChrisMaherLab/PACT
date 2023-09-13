#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Genotype SVs using svtyper"

baseCommand: ["bash", "/usr/bin/svtyper_helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 vcf:
  type: File
  inputBinding:
   position: 2
  doc: "VCF file of SVs to genotype"
 bam:
  type: File
  secondaryFiles: [.bai]
  inputBinding:
   position: 3
  doc: "Bam to use for genotyping"

outputs:
 genotyped:
  type: stdout

stdout: "$(inputs.vcf.nameroot).geno.vcf"
