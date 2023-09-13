#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Create target and anti-target files for CNA analysis"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: MultipleInputFeatureRequirement


inputs:
 reference:
  type: File
  secondaryFiles: [.fai]
 ref_flat:
  type: File
 capture_targets:
  type: File

outputs:
 targets:
  type: File
  outputSource: create_target_regions/targets_bed
 anti_targets:
  type: File
  outputSource: create_antitarget_regions/anti_targets_bed


steps:
 create_access_regions:
  run: ../tools/cnvkit_access_regions.cwl
  in:
   reference: reference
  out:
   [access_bed]

 create_target_regions:
  run: ../tools/cnvkit_target.cwl
  in:
   capture_targets: capture_targets
   ref_flat: ref_flat
  out:
   [targets_bed]

 create_antitarget_regions:
  run: ../tools/cnvkit_antitarget.cwl
  in:
   capture_targets: capture_targets
   access_bed: create_access_regions/access_bed
  out:
   [anti_targets_bed]
