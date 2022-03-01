#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Label whitelisted calls with WHITELISTED=TRUE in info column"
baseCommand: ["/usr/bin/python3", "/usr/bin/labelWhitelistedSVs.py"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement

inputs:
    sv_whitelist:
      type: File?
      inputBinding:
       position: 1
       prefix: -w
    bedpe:
      type: File
      inputBinding:
       position: 2
       prefix: -b

outputs:
 labeled_bedpe:
  type: stdout

stdout: labeled.bedpe
