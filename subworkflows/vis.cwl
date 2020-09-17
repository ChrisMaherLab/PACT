#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: Workflow
label: "Create basic visualizations using SV-HotSpot"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: MultipleInputFeatureRequirement

inputs:
 bedpe:
  type: File
 ref_genome:
  type: string

outputs:
 default_plots:
  type: Directory
  outputSource: create_vis/vis

steps:
 create_sv_hotspot_input:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}'
   in_file: bedpe
   out_file:
    default: "aggregate.vis.bedpe"
  out: [awk_out]

 create_vis:
  run: ../tools/sv-hotspot.cwl
  in:
    genome: ref_genome
    bedpe: create_sv_hotspot_input/awk_out
  out: [vis]
