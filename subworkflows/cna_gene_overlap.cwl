#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Gene overlap"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement

inputs:
 all_genes_bed:
  type:
      - string
      - File
 cnvkit_seg_bed:
  type: File[]

outputs:

steps:
 
