#!/usr/bin/env cwl-runner


cwlVersion: v1.0
class: Workflow
label: "Identify somatic SVs"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: MultipleInputFeatureRequirement

inputs:
 sv_vcfs:
  type:
   type: array
   items:
    type: array
    items: File
 max_distance_to_merge:
  type: int?
  default: 100
 minimum_sv_calls:
  type: int?
  default: 2
 minimum_sv_size:
  type: int?
  default: 100
 same_strand:
  type: boolean?
  default: false
 same_type:
  type: boolean?
  default: true
 sample_bams:
   type: File[]
   secondaryFiles: [.bai]
 matched_control_bams:
   type: File[]
   secondaryFiles: [.bai]
 panel_of_normal_bams:
   type: File[]
   secondaryFiles: [.bai]
 target_regions:
  type: File
 neither_region:
  type: File
 notboth_region:
  type: File
 ref_genome:
  type: string
 snpEff_data:
  type: Directory
 read_support:
  type: int
  default: 2
 sv_whitelist:
  type: File?

outputs:
 somatic_svs_bedpe:
  type: File
  outputSource: clean_output/cleaned_out
  doc: "SVs identified as somatic after applying all filters"

steps:
 survivor_merge:
  run: ../tools/survivor-merge.cwl
  scatter: vcfs
  in:
   vcfs: sv_vcfs
   max_distance_to_merge: max_distance_to_merge
   minimum_sv_calls: minimum_sv_calls
   same_type: same_type
   same_strand: same_strand
   estimate_sv_distance:
    default: false
   minimum_sv_size: minimum_sv_size
   cohort_name:
    default: "SURVIVOR-sv-merged.vcf"
  out:
   [merged_vcf] 

 region_filter:
  run: ../tools/vcf_region_filter.cwl
  scatter: vcf
  in:
   vcf: survivor_merge/merged_vcf
   target: target_regions
   notboth_region: notboth_region
   neither_region: neither_region
  out:
   [filtered_vcf]

 extract_sample_names:
  run: ../tools/extract_sample_name_from_vcf.cwl
  scatter: vcf
  in:
   vcf: survivor_merge/merged_vcf
  out:
   [sample_name]

 first_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bam_one, bam_two]
  scatterMethod: "dotproduct"
  in:
   vcf: region_filter/filtered_vcf
   bam_one:
     source: matched_control_bams
   bam_two:
     source: sample_bams
  out: [genotyped] 

 modify_GT_in_vcf:
  run: ../tools/modify_vcf_GT.cwl
  scatter: vcf
  in:
   vcf: first_genotyping/genotyped
  out:
   [modded_GT]

 create_sort_infile:
  run: ../tools/create_file_list.cwl
  in:
   infiles: modify_GT_in_vcf/modded_GT
  out: [filepath_file]

 sort_vcf:
  run: ../tools/svtools_lsort.cwl
  in:
   filepath_file: create_sort_infile/filepath_file
  out: [sorted_vcf]

 merge_vcf:
  run: ../tools/svtools_lmerge.cwl
  in:
   sorted_vcf: sort_vcf/sorted_vcf
   breakpoint_confidence_interval:
    default: 20
  out: [merged_vcf]

 merged_sample_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [bam_one, bam_two]
  scatterMethod: "dotproduct"
  in:
   vcf: merge_vcf/merged_vcf
   bam_one:
     source: matched_control_bams
   bam_two:
     source: sample_bams
  out: [genotyped]

 healthy_genotyping:
  run: ../tools/single_svtyper_genotyping.cwl
  scatter: bam
  in:
   vcf: merge_vcf/merged_vcf
   bam:
     source: panel_of_normal_bams 
  out: [genotyped]

 annotate_samples:
  run: ../tools/annotate_sv_vcf.cwl
  in:
   vcf: merge_vcf/merged_vcf
   genome: snpEff_data
   genome_name: ref_genome
  out: [annotated_vcf]

 vcf_to_bedpe:
  run: ../tools/vcftobedpe.cwl
  scatter: vcf
  in:
   vcf: merged_sample_genotyping/genotyped
  out: [bedpe]

 healthy_vcf_to_bedpe:
  run: ../tools/vcftobedpe.cwl
  scatter: vcf
  in:
   vcf: healthy_genotyping/genotyped
  out: [bedpe]

 aggregate_samples:
  run: ../tools/aggregate_bedpe.cwl
  in:
   bedpe: vcf_to_bedpe/bedpe
  out: [aggregate_bedpe]

 aggregate_healthy:
  run: ../tools/aggregate_healthy_bedpe.cwl
  in:
   bedpe: healthy_vcf_to_bedpe/bedpe
  out: [aggregate_bedpe]
 
 modify_healthy_intervals:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"} {if(FNR>1){$2=$2-10;$5=$5-10; print $0} else print $0}'
   in_file: aggregate_healthy/aggregate_bedpe
   out_file:
    default: "modifiedIntervals"
  out: [awk_out]

 remove_unsupported:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($13>=1){print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22}}'
   in_file: modify_healthy_intervals/awk_out
   out_file:
    default:  "healthy.removedUnsupported"
  out: [awk_out]

 remove_unknown_regions:
  run: ../tools/egrep_v.cwl
  in:
   pattern:
    default: "chrUn|random|CHRUN|chrUN"
   in_file: aggregate_samples/aggregate_bedpe
  out: [egrep_v_file]

 modify_intervals:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($2==$3){$2=$2-1};if($5==$6){$5=$5-1};print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22}'
   in_file: remove_unknown_regions/egrep_v_file
   out_file:
    default: "modifiedIntervals"
  out: [awk_out]
   
 compare_to_healthy:
  run: ../tools/bedtools_pairToPair.cwl
  in:
   type_parameter:
    default: "notboth" 
   in_file: modify_intervals/awk_out
   comparison_file: remove_unsupported/awk_out
  out: [filtered_bedpe] 

 remove_dummy_variables:
  run: ../tools/sed.cwl
  in:
   command:
    default: 's/PRPOS.*CIPOS=[-0-9]*,[-0-9]*;//g'
   in_file: compare_to_healthy/filtered_bedpe
   out_file:
    default: "aggregate.neither.notboth.target.plasma.cleaned"
  out: [sed_out]

 label_whitelisted_calls:
  run: ../tools/label_whitelisted_svs.cwl
  in:
   sv_whitelist: sv_whitelist
   bedpe: remove_dummy_variables/sed_out
  out: [labeled_bedpe]

 read_support_filter:
  run: ../tools/read_support_filter.cwl
  in:
   read_support: read_support
   in_file: label_whitelisted_calls/labeled_bedpe
   out_file:
    default: "aggregate.neither.notboth.target.plasma.cleaned.readsupport"
  out: [filtered]

 liftover_annotations:
  run: ../tools/liftover_annotations.cwl
  in:
   annotated_vcf: annotate_samples/annotated_vcf
   unannotated_bedpe: read_support_filter/filtered
  out: [annotated]

 clean_output:
  run: ../tools/cleanup.cwl
  in:
   in_file: liftover_annotations/annotated
  out: [cleaned_out]

  
