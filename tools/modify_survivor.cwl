#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Make modifications to VCF files so they work well with downstream tools"

baseCommand: ["python"]

requirements:
      - class: DockerRequirement
        dockerPull: "python"

inputs:
 helper_script:
  type: File
  inputBinding:
   position: 1
 vcf:
  type: File
  inputBinding:
   position: 2
   prefix: -i

outputs:
 modified_vcf:
  type: stdout

stdout: corrected.vcf
