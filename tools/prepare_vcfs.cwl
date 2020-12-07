#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Make modifications to VCF files so they work well with downstream tools"

baseCommand: ["python"]

requirements:
    - class: DockerRequirement
      dockerPull: "python"

inputs:
 helper_script:
  type: File
  inputBinding:
   position: 1
 vcfs:
  type: File[]
  inputBinding:
   position: 2
   itemSeparator: ","
   prefix: -i

arguments:
 - valueFrom: $(runtime.outdir)
   prefix: -o
   position: 3

outputs:
 modified_vcfs:
  type:
   type: array
   items: File
  outputBinding:
   glob: "*.mod.vcf"


