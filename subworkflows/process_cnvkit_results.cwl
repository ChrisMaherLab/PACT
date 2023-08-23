#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Process cnvkit outputs"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement
    - class: ScatterFeatureRequirement

inputs:
 target_coverage:
  type: File[]
 antitarget_coverage:
  type: File[]
 fixed_cnr:
  type: File[]
 segmented:
  type: File[]
 reference_coverage:
  type: File
 genome:
  type: string
 target_genes:
  type:
      - string
      - File
 all_genes:
  type:
      - string
      - File

outputs:
 segmented_beds:
  type: File[]
  outputSource: process_outs/out_bed
 segmented_cov:
  type: File[]
  outputSource: process_outs/out_cov
 gene_overlap:
  type: File
  outputSource: gene_overlap/gene_overlaps

steps:
 process_outs:
  run: ../tools/process_cnvkit_results.cwl
  scatter: [target_coverage, antitarget_coverage, fixed_cnr, segmented]
  scatterMethod: "dotproduct"
  in:
   target_coverage: target_coverage
   antitarget_coverage: antitarget_coverage
   fixed_cnr: fixed_cnr
   segmented: segmented
   reference_cnn: reference_coverage
   genome: genome
   target_genes: target_genes
  out:
   [out_bed, out_cov]

 gene_overlap:
  run: ../tools/gene_overlap.cwl
  in:
   all_genes: all_genes
   segmented_bed: process_outs/out_bed
  out:
   [gene_overlaps]
