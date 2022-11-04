#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Genotype SVs using svtyper"

baseCommand: ["bash", "/usr/bin/svtyper_helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 16000

inputs:
 vcf:
  type: File
  inputBinding:
   position: 2
  doc: "VCF file of SVs to genotype"
 bam_one:
  type: string
 bam_two:
  type: string

arguments:
 - valueFrom: |
    ${
      var x = inputs.bam_one;
      x = x + "," + inputs.bam_two;
      return(x)
    }
   position: 3

outputs:
 genotyped:
  type: stdout

stdout: "$(inputs.vcf.nameroot).geno.vcf"
