#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Convert bcf file to vcf"

baseCommand: ["bcftools", "view"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 6000

inputs:
 bcf:
  type: File
  inputBinding:
   position: 1

outputs:
 vcf:
  type: stdout

stdout: $(inputs.bcf.nameroot).vcf
