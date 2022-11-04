#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Apply region filters to vcf"

baseCommand: ["/usr/bin/python3", "/usr/bin/region-filter.py"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
      coresMin: 1
    - class: StepInputExpressionRequirement

inputs:
    vcf:
       type: File
       inputBinding:
           position: 2
           prefix: "-v"
    target:
       type: File
       inputBinding:
           position: 3
           prefix: "-t"
    notboth_region:
       type: File?
       inputBinding:
           position: 4
           prefix: "-l"
    neither_region:
       type: File?
       inputBinding:
           position: 5
           prefix: "-b"

outputs:
   filtered_vcf:
       type: stdout

stdout: region-filtered.vcf
       
