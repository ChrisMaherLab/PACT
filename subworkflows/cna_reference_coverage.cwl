#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Calculate reference coverage"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement

inputs:
 panel_of_normal_bams:
  type: File[]
  secondaryFiles: [.bai]
 targets:
  type: File
 anti_targets:
  type: File
 reference:
  type: File

outputs:
  reference_coverage:
   type: File
   outputSource: combine_reference_coverage/reference_coverage

steps:
 target_reference_coverage:
  run: ../tools/cnvkit_coverage.cwl
  scatter: [bam]
  in:
   bam: panel_of_normal_bams
   bed: targets
   istarget: 
    default: true
  out:
   [coverage]

 antitarget_reference_coverage:
  run: ../tools/cnvkit_coverage.cwl
  scatter: [bam]
  in:
   bam: panel_of_normal_bams
   bed: anti_targets
   istarget:
    default: false
  out:
   [coverage]

 combine_reference_coverage:
  run: ../tools/cnvkit_reference.cwl
  in:
   target_cnn: target_reference_coverage/coverage
   antitarget_cnn: antitarget_reference_coverage/coverage
   reference: reference
  out:
   [reference_coverage]  
