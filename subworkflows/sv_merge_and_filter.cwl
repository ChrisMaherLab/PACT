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
 tumor_vcfs:
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
 sample_bams:
  type: string[]
 control_bams:
  type: string[]
 tumor_bams:
  type: string[]
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
 ref_genome:
  type: string
 read_support:
  type: int
  default: 1
 svtyper_helper:
  type: File
 subset_helper:
  type: File
 aggregate_sample_helper:
  type: File
 aggregate_healthy_helper:
  type: File
 modify_survivor_script:
  type: File
 prepare_vcf_script:
  type: File
 liftover_script:
  type: File

outputs:
 somatic_svs_bedpe:
  type: File
  outputSource: add_header_final_output/sed_out
  doc: "SVs identified as somatic after applying all filters"
 consensus_vcf:
  type: File[]
  outputSource: survivor_merge/merged_vcf
 tumor_consensus_vcf:
  type: File[]
  outputSource: tumor_survivor_merge/merged_vcf
 prepared_vcf:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: prepare_vcfs/modified_vcfs
 tumor_prepared_vcf:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: prepare_tumor_vcfs/modified_vcfs


steps:
 prepare_vcfs:
  run: ../tools/prepare_vcfs.cwl
  scatter: vcfs
  in:
   helper_script: prepare_vcf_script
   vcfs: sv_vcfs
  out:
   [modified_vcfs]

 prepare_tumor_vcfs:
  run: ../tools/prepare_vcfs.cwl
  scatter: vcfs
  in:
   helper_script: prepare_vcf_script
   vcfs: tumor_vcfs
  out:
   [modified_vcfs]

 survivor_merge:
  run: ../tools/survivor-merge.cwl
  scatter: vcfs
  in:
   vcfs: prepare_vcfs/modified_vcfs
   max_distance_to_merge: max_distance_to_merge
   minimum_sv_calls: minimum_sv_calls
   same_type: same_type
   same_strand: same_strand
   estimate_sv_distance: estimate_sv_distance
   minimum_sv_size: minimum_sv_size
   cohort_name:
    default: "SURVIVOR-sv-merged.vcf"
  out:
   [merged_vcf] 

 tumor_survivor_merge:
  run: ../tools/survivor-merge.cwl
  scatter: vcfs
  in:
   vcfs: prepare_tumor_vcfs/modified_vcfs
   max_distance_to_merge: max_distance_to_merge
   minimum_sv_calls: minimum_sv_calls
   same_type: same_type
   same_strand: same_strand
   estimate_sv_distance: estimate_sv_distance
   minimum_sv_size: minimum_sv_size
   cohort_name:
    default: "SURVIVOR-sv-merged.vcf"
  out:
   [merged_vcf]

 correct_survivor:
  run: ../tools/modify_survivor.cwl
  scatter: vcf
  in:
   helper_script: modify_survivor_script
   vcf: survivor_merge/merged_vcf
  out:
   [modified_vcf]

 extract_sample_names:
  run: ../tools/extract_sample_names.cwl
  scatter: vcf
  in:
   vcf: correct_survivor/modified_vcf
  out:
   [sample_name]

 tumor_correct_survivor:
  run: ../tools/modify_survivor.cwl
  scatter: vcf
  in:
   helper_script: modify_survivor_script
   vcf: tumor_survivor_merge/merged_vcf
  out:
   [modified_vcf]

 extract_tumor_names:
  run: ../tools/extract_sample_names.cwl
  scatter: vcf
  in:
   vcf: tumor_correct_survivor/modified_vcf
  out:
   [sample_name]

 merge_arrays:
  run: ../tools/create_array_of_string_arrays.cwl
  in:
   array1: control_bams
   array2: sample_bams
  out:
   [array_of_arrays]

 create_tumor_subset:
  run: ../tools/create_subset.cwl
  in:
   tumor_array: tumor_bams
   control_array: control_bams
  out:
   [tumor_subset, control_subset]

 merge_subset_arrays:
  run: ../tools/create_array_of_string_arrays.cwl
  in:
   array1: create_tumor_subset/tumor_subset
   array2: create_tumor_subset/control_subset
  out:
   [array_of_arrays]

 first_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bams_to_genotype]
  scatterMethod: "dotproduct"
  in:
   vcf: correct_survivor/modified_vcf
   bams_to_genotype: merge_arrays/array_of_arrays
   helper_script: svtyper_helper
  out: [genotyped] 

 tumor_first_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bams_to_genotype]
  scatterMethod: "dotproduct"
  in:
   vcf: tumor_correct_survivor/modified_vcf
   bams_to_genotype: merge_subset_arrays/array_of_arrays
   helper_script: svtyper_helper
  out:
   [genotyped]

 modify_GT_in_vcf:
  run: ../tools/modify_vcf_GT.cwl
  scatter: vcf
  in:
   vcf: first_genotyping/genotyped
  out:
   [modded_GT]

 tumor_modify_GT_in_vcf:
  run: ../tools/modify_vcf_GT.cwl
  scatter: vcf
  in:
   vcf: tumor_first_genotyping/genotyped
  out: 
   [modded_GT]

 merged_list:
  run: ../tools/append_to_array.cwl
  in:
   array1: modify_GT_in_vcf/modded_GT
   array2: tumor_modify_GT_in_vcf/modded_GT
  out:
   [out_array]

 create_sort_infile:
  run: ../tools/create_file_list.cwl
  in:
   infiles: merged_list/out_array
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

 # Ensures that the SVs that are genotyped against healthy/samples
 # are the same SVs, while reducing the need to genotype (and annotate)
 # SVs reported in "sample 2" against "sample 1". Saves space when running
 # the pipeline with a cohort.
 subset_to_current_sample:
  run: ../tools/subset_merged_svs.cwl
  scatter: [sample_file_of_interest]
  in:
   helper_script: subset_helper
   vcf: merge_vcf/merged_vcf
   sample_file_of_interest: sample_bams
   sample_bams: sample_bams
   tumor_bams: tumor_bams
   extracted_sample_names: extract_sample_names/sample_name
   extracted_tumor_names: extract_tumor_names/sample_name
  out: [sv_subset]

 array_with_tumor:
  run: ../tools/append_to_array_of_arrays.cwl
  in:
   in_array_of_arrays: merge_arrays/array_of_arrays 
   tumor_array: tumor_bams
  out: [ array_of_arrays ]

 # Genotype plasma sample, matched control and optionally, the solid tumor
 merged_sample_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bams_to_genotype]
  scatterMethod: "dotproduct"
  #scatter: bams_to_genotype
  in:
   vcf: subset_to_current_sample/sv_subset
   # Check how not subsetting affects results
   #vcf: merge_vcf/merged_vcf
   bams_to_genotype: array_with_tumor/array_of_arrays
   helper_script: svtyper_helper
  out: [genotyped]

 # Requires that healthy bams are in an array of arrays,
 # though the inner arrays are expected to just contain 1 file
 healthy_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: bams_to_genotype
  in:
   vcf: merge_vcf/merged_vcf
   bams_to_genotype: healthy_bams 
   helper_script: svtyper_helper
  out: [genotyped]

 download_db:
  run: ../tools/download_snpEff_db.cwl
  in:
   db: ref_genome
  out: [database]

 annotate_samples:
  run: ../tools/annotate_vcf.cwl
  #scatter: vcf
  in:
   #vcf: merged_sample_genotyping/genotyped
   vcf: merge_vcf/merged_vcf
   genome: download_db/database
   genome_name: ref_genome
  out: [annotated_vcf]

 vcf_to_bedpe:
  run: ../tools/vcftobedpe.cwl
  scatter: vcf
  in:
   #vcf: annotate_samples/annotated_vcf
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
   aggregate_helper: aggregate_sample_helper
  out: [aggregate_bedpe]

 aggregate_healthy:
  run: ../tools/aggregate_bedpe.cwl
  in:
   bedpe: healthy_vcf_to_bedpe/bedpe
   aggregate_helper: aggregate_healthy_helper
  out: [aggregate_bedpe]
 
 remove_unsupported:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($8!=0.00 && $13>=2){print}}'
   in_file: aggregate_healthy/aggregate_bedpe
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

 neither_filter:
  run: ../tools/bedtools_pairToBed.cwl
  in:
   bedpe: remove_unknown_regions/egrep_v_file
   command:
    default: "neither"
   bed: neither_region
  out: [filtered_bedpe]

 notboth_filter:
  run: ../tools/bedtools_pairToBed.cwl
  in:
   bedpe: neither_filter/filtered_bedpe
   command:
    default: "notboth"
   bed: notboth_region
  out: [filtered_bedpe]

 modify_intervals:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($2==$3){$2=$2-1};if($5==$6){$5=$5-1};print}'
   in_file: notboth_filter/filtered_bedpe
   out_file:
    default: "modifiedIntervals"
  out: [awk_out]
   
 target_region_filter:
  run: ../tools/bedtools_pairToBed.cwl
  in:
   bedpe: modify_intervals/awk_out
   command:
    default: "either"
   bed: target_regions
  out: [filtered_bedpe]

 plasma_only:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($16==0){print}}' 
   in_file: target_region_filter/filtered_bedpe
   out_file:
    default: "aggregate.neither.notboth.target.plasma.noHeader"
  out: [awk_out]

 compare_to_healthy:
  run: ../tools/bedtools_pairToPair.cwl
  in:
   type_parameter:
    default: "neither"
   in_file: plasma_only/awk_out
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

 read_support_filter:
  run: ../tools/read_support_filter.cwl
  in:
   read_support: read_support
   in_file: remove_dummy_variables/sed_out
   out_file:
    default: "aggregate.neither.notboth.target.plasma.cleaned.readsupport"
  out: [filtered]

 liftover_annotations:
  run: ../tools/liftover_annotations.cwl
  in:
   helper_script: liftover_script
   annotated_vcf: annotate_samples/annotated_vcf
   unannotated_bedpe: read_support_filter/filtered
  out: [annotated]

 add_header_final_output:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1 i\chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tsolid_tumor_pe_reads\tsolid_tumor_split_reads\tsolid_tumor_pe_sr_reads\tinfo1\tinfo2'
   #in_file: read_support_filter/filtered
   in_file: liftover_annotations/annotated
   out_file:
    default: "aggregate.final.bedpe"
  out: [sed_out]
  

