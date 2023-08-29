#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
doc: "Run SURVIVOR to merge SV calls from a list of VCF files"

baseCommand: ["/bin/bash", "/usr/bin/survivor_helper.sh"]

requirements:
    - class: InlineJavascriptRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      ramMin: 2000
      coresMin: 1
    - class: StepInputExpressionRequirement

inputs:
    vcfs:
        type: File[]
        inputBinding:
            position: 1
            itemSeparator: ","
    max_distance_to_merge:
        type: int
        inputBinding:
            position: 2
    minimum_sv_calls:
        type: int
        inputBinding:
            position: 3
    same_type:
        type: boolean
        inputBinding:
            position: 4
            valueFrom: |
                ${
                  if(inputs.same_type){
                    return "1";
                  } else {
                    return "0";
                  }
                }
    same_strand:
        type: boolean
        inputBinding:
            position: 5
            valueFrom: |
                ${
                  if(inputs.same_strand){
                    return "1";
                  } else {
                    return "0";
                  }
                }
    estimate_sv_distance:
        type: boolean
        inputBinding:
            position: 6
            valueFrom: |
                ${
                  if(inputs.estimate_sv_distance){
                    return "1";
                  } else {
                    return "0";
                  }
                }
    minimum_sv_size:
        type: int
        inputBinding:
            position: 7
    cohort_name:
        type: string
        inputBinding:
            position: 8

arguments:
 - valueFrom: $(runtime.outdir)
   position: 9    

outputs:
  merged_vcf:
    type: File
    outputBinding:
      glob: "mod.$(inputs.cohort_name)"


