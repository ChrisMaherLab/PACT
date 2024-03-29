#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a sorted VCF from input VCF(s) using svtools lsort"

baseCommand: ["svtools", "lsort"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 6000

inputs:
 filepath_file:
  type: File
  inputBinding:
   position: 1
   prefix: -f

outputs:
 sorted_vcf:
  type: stdout

stdout: sorted.vcf
