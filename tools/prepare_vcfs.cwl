#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Make modifications to VCF files so they work well with downstream tools"

baseCommand: ["/usr/bin/python3.5", "/usr/bin/modify_VCF.py"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/sv_helper_docker"

inputs:
 vcfs:
  type: File[]
  inputBinding:
   position: 1
   itemSeparator: ","
   prefix: -i

arguments:
 - valueFrom: $(runtime.outdir)
   prefix: -o
   position: 2

outputs:
 modified_vcfs:
  type:
   type: array
   items: File
  outputBinding:
   glob: "*.mod.vcf"


