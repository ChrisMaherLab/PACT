#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Make modifications to VCF files so they work well with downstream tools"

baseCommand: ["/usr/bin/python3.5", "/usr/bin/modify_SURVIVOR.py"]

requirement:
    - class: DockerRequirement
      dockerPull: "jbwebster/sv_helper_docker"

inputs:
 vcf:
  type: File
  inputBinding:
   position: 1
   prefix: -i

outputs:
 modified_vcf:
  type: stdout

stdout: corrected.vcf
