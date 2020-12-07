#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Liftover annotations from a vcf file to a corresponding bedpe file"

baseCommand: ["python"]

requirements:
    - class: DockerRequirement
      dockerPull: "python"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 helper_script:
  type: File
  inputBinding:
   position: 1
 annotated_vcf:
  type: File
  inputBinding:
   position: 2
   prefix: -v
 unannotated_bedpe:
  type: File
  inputBinding:
   position: 3
   prefix: -b

outputs:
 annotated:
  type: stdout

stdout: "aggregate.annotated.filtered.bedpe"
