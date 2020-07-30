#!/usr/bin/env cwl-runner

##########################


cwlVersion: v1.0
class: Workflow
label: "SV Pipeline"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement

inputs:
 reference:
  type: File
 ref_genome:
  type: string
 tumor_bams:
  type: File[]
 control_bams:
  type: File[]
 max_distance_to_merge:
  type: int
 minimum_sv_calls:
  type: int
 minimum_sv_size:
  type: int
 same_strand:
  type: boolean
 same_type:
  type: boolean
 estimate_sv_distance:
  type: boolean
 healthy_bams:
  type:
   type: array
   items:
    type: array
    items: File
 target_regions:
  type: File
 neither_region:
  type: File?
 notboth_region:
  type: File?


outputs: 
 vcf:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: sv_calling/vcf_files
  doc: "VCF files from Lumpy, Delly, and Manta for each input sample"
 somatic_svs_bedpe:
  type: File
  outputSource: identify_somatic_calls/somatic_svs_bedpe
  doc: "SVs identified as somatic, with region and annotation information"
 

steps:
 sv_calling:
  run: ../subworkflows/caller.cwl
  in:
   reference: reference
   tumor_bams: tumor_bams
   control_bams: control_bams
  out:
   [vcf_files] 

 identify_somatic_calls:
  run: ../subworkflows/sv_merge_and_filter.cwl
  in:
   sv_vcfs: sv_calling/vcf_files
   max_distance_to_merge: max_distance_to_merge
   minimum_sv_calls: minimum_sv_calls
   minimum_sv_size: minimum_sv_size
   same_strand: same_strand
   same_type: same_type
   estimate_sv_distance: estimate_sv_distance
   tumor_bams: tumor_bams
   control_bams: control_bams
   healthy_bams: healthy_bams
   target_regions: target_regions
   neither_region: neither_region
   notboth_region: notboth_region
   ref_genome: ref_genome
  out: 
   [somatic_svs_bedpe, samples_filtered_blacklist_bedpe, samples_filtered_blacklist_lowcomp_bedpe, samples_filtered_blacklist_lowcomp_targeted_bedpe, samples_filtered_blacklist_lowcomp_targeted_plasma_bedpe, healthy_svs_supported_bedpe]
   

 basic_sv-hotspot_vis:
  run: ../subworkflows/vis.cwl
  in:
   bedpe: identify_somatic_calls/somatic_svs_bedpe
   ref_genome: ref_genome
  out: [default_plots]
