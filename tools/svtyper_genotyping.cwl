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
  type: File
  secondaryFiles: [.bai]
 bam_two:
  type: File
  secondaryFiles: [.bai]

arguments:
 - valueFrom: |
    ${
      var x = inputs.bam_one.path;
      x = x + "," + inputs.bam_two.path;
      return(x)
    }
   position: 3

outputs:
 genotyped:
  type: stdout

stdout: "$(inputs.vcf.nameroot).geno.vcf"
