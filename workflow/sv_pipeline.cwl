#!/usr/bin/env cwl-runner

##########################
# Workflow for identifying somatic SVs from cfDNA
# Compares cfDNA sample to a plasma-depleted matched control,
# and to a list of provided healthy samples, to report SVs
# that appear somatic and unique to non-healthy patients.
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
  type: string
 ref_genome:
  type: string
 tumor_bams:
  type: string[]
 control_bams:
  type: string[]
 max_distance_to_merge:
  type: int?
  default: 100
 minimum_sv_calls:
  type: int?
  default: 2
 minimum_sv_size:
  type: int?
  default: 30
 same_strand:
  type: boolean?
  default: false 
 same_type:
  type: boolean?
  default: true
 estimate_sv_distance:
  type: boolean?
  default: false
 healthy_bams:
  type:
   type: array
   items:
    type: array
    items: string
 target_regions:
  type: File
 neither_region:
  type: File?
 notboth_region:
  type: File?
 read_support:
  type: string
  default: "1"


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
   read_support: read_support
  out: 
   [somatic_svs_bedpe, samples_filtered_blacklist_bedpe, samples_filtered_blacklist_lowcomp_bedpe, samples_filtered_blacklist_lowcomp_targeted_bedpe, samples_filtered_blacklist_lowcomp_targeted_plasma_bedpe, healthy_svs_supported_bedpe]
   

 basic_sv-hotspot_vis:
  run: ../subworkflows/vis.cwl
  in:
   bedpe: identify_somatic_calls/somatic_svs_bedpe
   ref_genome: ref_genome
  out: [default_plots]
