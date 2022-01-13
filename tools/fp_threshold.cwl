#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Apply vaf and alt support filters and set all whitelisted SNVs to PASS (--keep)"
baseCommand: ["/usr/bin/python3.5", "/usr/bin/fp_threshold.py"]
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
    sample_names:
      type: string[]
      inputBinding:
       itemSeparator: ","
       position: 2
       prefix: -s
    apply_filter:
        type: boolean
        inputBinding:
            prefix: '--filter'
            position: 3
        defaut: true
    keep:
        type: boolean
        inputBinding:
            prefix: '--keep'
            position: 4
        default: true
    min_var_freq:
        type: float
        inputBinding:
            prefix: "--mvf"
            position: 5
    min_var_count:
        type: int
        default: 6
        inputBinding:
            prefix: "--minalt"
            position: 6

outputs:
 filtered_vcf:
  type: stdout

stdout: fp_filtered.vcf
