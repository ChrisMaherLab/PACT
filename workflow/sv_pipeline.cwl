#!/usr/bin/env cwl-runner

##########################
# Workflow for identifying somatic SVs from cfDNA
# Compares cfDNA sample to a plasma-depleted matched control,
# (optionally to a matched solid tumor sample),
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
 sample_bams:
  type: string[]
 control_bams:
  type: string[]
 tumor_bams:
  type: string[]
 max_distance_to_merge:
  type: int?
  default: 100
 minimum_sv_calls:
  type: int?
  default: 2
 recur_min_sv_calls:
  type: int?
  default: 1
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
  type: int
  default: 1
 svtyper_helper:
  type: File
  default:
   class: File
   path: ../helper/svtyper_helper.sh
 subset_helper:
  type: File
  default:
   class: File
   path: ../helper/subset_helper.sh
 aggregate_sample_helper:
  type: File
  default:
   class: File
   path: ../helper/aggregate_bedpe.sh
 aggregate_healthy_helper:
  type: File
  default:
   class: File
   path: ../helper/aggregate_healthy_bedpe.sh
 modify_survivor_script:
  type: File
  default:
   class: File
   path: ../helper/modify_SURVIVOR.py
 prepare_vcf_script:
  type: File
  default:
   class: File
   path: ../helper/modify_vcf.py
 rescue_helper_script:
  type: File
  default:
   class: File
   path: ../helper/lostSVFinder.py
 liftover_script:
  type: File
  default:
   class: File
   path: ../helper/ann_liftover.py

outputs: 
 vcf:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: sv_calling/vcf_files
  doc: "VCF files from Lumpy, Delly, and Manta for each input sample"
 tumor_vcf:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: sv_calling/tumor_vcf_files
  doc: "VCF files from Lumpy, Delly, and Manta for optional solid tumor samples"
 somatic_svs_bedpe:
  type: File
  #outputSource: aggregate_all_calls/aggregated
  outputSource: identify_somatic_calls/somatic_svs_bedpe
  doc: "Final list of all SVs called"
 default_vis:
  type: Directory
  #outputSource: final_vis/default_plots
  outputSource: basic_sv-hotspot_vis/default_plots
  doc: "Basic, default visualizations and SV hotspots of final output"
 
steps:
 sv_calling:
  run: ../subworkflows/sv_caller.cwl
  in:
   reference: reference
   sample_bams: sample_bams
   control_bams: control_bams
   tumor_bams: tumor_bams
  out:
   [vcf_files, tumor_vcf_files]

 identify_somatic_calls:
  run: ../subworkflows/sv_merge_and_filter.cwl
  in:
   sv_vcfs: sv_calling/vcf_files
   tumor_vcfs: sv_calling/tumor_vcf_files
   max_distance_to_merge: max_distance_to_merge
   minimum_sv_calls: minimum_sv_calls
   minimum_sv_size: minimum_sv_size
   same_strand: same_strand
   same_type: same_type
   estimate_sv_distance: estimate_sv_distance
   sample_bams: sample_bams
   control_bams: control_bams
   tumor_bams: tumor_bams
   healthy_bams: healthy_bams
   target_regions: target_regions
   neither_region: neither_region
   notboth_region: notboth_region
   ref_genome: ref_genome
   read_support: read_support
   svtyper_helper: svtyper_helper
   subset_helper: subset_helper
   aggregate_sample_helper: aggregate_sample_helper
   aggregate_healthy_helper: aggregate_healthy_helper
   modify_survivor_script: modify_survivor_script
   prepare_vcf_script: prepare_vcf_script
   liftover_script: liftover_script
  out: 
   [somatic_svs_bedpe, consensus_vcf, tumor_consensus_vcf, prepared_vcf, tumor_prepared_vcf]

 basic_sv-hotspot_vis:
  run: ../subworkflows/vis.cwl
  in:
   bedpe: identify_somatic_calls/somatic_svs_bedpe
   ref_genome: ref_genome
  out: [default_plots, annotated_peaks]

