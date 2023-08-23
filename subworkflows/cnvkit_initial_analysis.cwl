#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Initial CNVkit analysis"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement
    - class: ScatterFeatureRequirement

inputs:
 bams:
  type: string[]
 targets: 
   type: 
       - string
       - File
 anti_targets:
   type:
       - string
       - File
 reference_coverage:
   type: File

outputs:
  target_coverage:
   type: File[]
   outputSource: target_sample_coverage/coverage
  antitarget_coverage:
   type: File[]
   outputSource: antitarget_sample_coverage/coverage
  fixed_cnr:
   type: File[]
   outputSource: fix_coverage/ratios
  segmented:
   type: File[]
   outputSource: cna_segments/cna_segmented

steps:
 target_sample_coverage:
  run: ../tools/cnvkit_coverage.cwl
  scatter: [bam]
  in:
   bam: bams
   bed: targets
   istarget:
    default: true
  out:
   [coverage]

 antitarget_sample_coverage:
  run: ../tools/cnvkit_coverage.cwl
  scatter: [bam]
  in:
   bam: bams
   bed: anti_targets
   istarget:
    default: false
  out:
   [coverage]

 fix_coverage:
  run: ../tools/cnvkit_fix.cwl
  scatter: [target_coverage, antitarget_coverage]
  scatterMethod: "dotproduct"
  in:
   target_coverage: target_sample_coverage/coverage
   antitarget_coverage: antitarget_sample_coverage/coverage
   reference_coverage: reference_coverage
  out:
   [ratios]

 cna_segments:
  run: ../tools/cnvkit_segment.cwl
  scatter: [coverage]
  in:
   coverage: fix_coverage/ratios
  out:
   [cna_segmented]

