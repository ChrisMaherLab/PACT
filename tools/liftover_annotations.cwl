#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Liftover annotations from a vcf file to a corresponding bedpe file"

baseCommand: ["/usr/bin/python3", "/usr/bin/ann_liftover.py"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 annotated_vcf:
  type: File
  inputBinding:
   position: 1
   prefix: -v
 unannotated_bedpe:
  type: File
  inputBinding:
   position: 2
   prefix: -b

outputs:
 annotated:
  type: stdout

stdout: "aggregate.annotated.filtered.bedpe"
