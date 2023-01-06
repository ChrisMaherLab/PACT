#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Make CNA calls"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement

inputs:
 sample_gene_overlaps:
  type: File
 control_gene_overlaps:
  type: File
 target_genes:
  type:
      - string
      - File

outputs:


steps:
 

steps:
1. Create a version of samples.info.tsv (columns: sample name, type[plasma or normal])
2. 
