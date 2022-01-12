#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a VCF that contains onlys SNVs/INDELs supported by x% of the samples in a panel of normals"
baseCommand: ["/usr/bin/python3.5", "/usr/bin/identify_PoN_support.py"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/helper_docker"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement

inputs:
    vcf:
      type: File
      inputBinding:
       position: 1
       prefix: -v
    percent:
      type: int
      inputBinding:
       position: 2
       prefix: -p

outputs:
 PoN_vcf:
  type: stdout

stdout: PoN_supported.vcf
