#!/usr/bin/env cwl-runner

##########################


# TO DO
# Make compatible with SV caller workflow
# Update to use tumor_bams and control_bams
# like the other workflow, so they work together better
# and are more intuitive

##########################



cwlVersion: v1.0
class: Workflow
label: "Ongoing"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: MultipleInputFeatureRequirement

inputs:
 bedpe:
  type: File[]

outputs: []

steps:
 bedtools_neither:
  run: ../Tools/aggregate_healthy_bedpe.cwl
  in:
   bedpe: bedpe
  out: [aggregate_bedpe]

