#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Convert VCF to bedpe format using svtools vcftobedpe"

baseCommand: ["svtools", "vcftobedpe"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"

inputs:
 vcf:
  type: File
  inputBinding:
   position: 4
   prefix: -i
  doc: "VCF file"

outputs:
 bedpe:
  type: stdout

stdout: $(inputs.vcf.nameroot).bedpe 
