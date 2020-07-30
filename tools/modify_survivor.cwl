#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Make modifications to VCF files so they work well with downstream tools"

baseCommand: ["python"]

requirement:
    - class: DockerRequirement
      dockerPull: "python"

inputs:
 script:
  type: File
  inputBinding:
   position: 1
  doc: "Script for modifying VCF files so they are compatible with downstream tools"
 vcf:
  type: File
  inputBinding:
   position: 2
   prefix: -i

outputs:
 modified_vcf:
  type: stdout

stdout: corrected.vcf
