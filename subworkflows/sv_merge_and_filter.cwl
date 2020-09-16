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
 tumor_bams:
  type: string[]
 control_bams:
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
 first_string:
  type: string
  default: 'BEGIN{FS=OFS="\t"}{if($13>='
 second_string:
  type: string
  default: '){print}}'
 read_support:
  type: string
  default: "1"

outputs:
 somatic_svs_bedpe:
  type: File
  outputSource: add_header_somatic/sed_out
  doc: "SVs identified as somatic after applying all filters"
 samples_filtered_blacklist_bedpe:
  type: File
  outputSource: modify_header_blacklisted_outfile/sed_out
  doc: "Sample SVs after removing those in blacklisted regions"
 samples_filtered_blacklist_lowcomp_bedpe:
  type: File
  outputSource: modify_header_complexity_filter/sed_out
  doc: "Sample SVs after removing those in blacklisted regions and low complexity regions"
 samples_filtered_blacklist_lowcomp_targeted_bedpe:
  type: File
  outputSource: add_header_target_region/sed_out
  doc: "Sample SVs after removing those in blacklisted regions, low complexity regions, and that have at least 1 breakend in a target region"
 samples_filtered_blacklist_lowcomp_targeted_plasma_bedpe:
  type: File
  outputSource: add_header_plasma_only/sed_out
  doc: "Sample SVs after removing those in blacklisted regions, low complexity regions, that have at least 1 breakend in a target region, and that do not appear in the matched control"
 healthy_svs_supported_bedpe:
  type: File
  outputSource: remove_unsupported/awk_out
  doc: "All SVs with read support in healthy samples"

steps:
 prepare_vcfs:
  run: ../tools/prepare_vcfs.cwl
  scatter: vcfs
  in:
   vcfs: sv_vcfs
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

 correct_survivor:
  run: ../tools/modify_survivor.cwl
  scatter: vcf
  in:
   vcf: survivor_merge/merged_vcf
  out: [modified_vcf]

 merge_arrays:
  run: ../tools/create_array_of_string_arrays.cwl
  in:
   array1: control_bams
   array2: tumor_bams
  out: [array_of_arrays]

 first_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bams_to_genotype]
  scatterMethod: "dotproduct"
  in:
   vcf: correct_survivor/modified_vcf
   bams_to_genotype: merge_arrays/array_of_arrays
  out: [genotyped] 

 modify_GT_in_vcf:
  run: ../tools/modify_vcf_GT.cwl
  scatter: vcf
  in:
   vcf: first_genotyping/genotyped
  out: [modded_GT]

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

 # Ensures that the SVs that are genotyped against healthy/samples
 # are the same SVs, while reducing the need to genotype (and annotate)
 # SVs reported in "sample 2" against "sample 1". Saves space when running
 # the pipeline with a cohort.
 subset_to_current_sample:
  run: ../tools/subset_merged_svs.cwl
  scatter: sample_of_interest
  in:
   sample_of_interest: merge_arrays/array_of_arrays
   vcf: merge_vcf/merged_vcf
  out: [sv_subset]

 merged_sample_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: [vcf, bams_to_genotype]
  scatterMethod: "dotproduct"
  in:
   vcf: subset_to_current_sample/sv_subset
   bams_to_genotype: merge_arrays/array_of_arrays
  out: [genotyped]

 # Requires that healthy bams are in an array of arrays,
 # though the inner arrays are expected to just contain 1 file
 healthy_genotyping:
  run: ../tools/svtyper_genotyping.cwl
  scatter: bams_to_genotype
  in:
   vcf: merge_vcf/merged_vcf
   bams_to_genotype: healthy_bams 
  out: [genotyped]

 download_db:
  run: ../tools/download_snpEff_db.cwl
  in:
   db: ref_genome
  out: [database]

 annotate_samples:
  run: ../tools/annotate_vcf.cwl
  scatter: vcf
  in:
   vcf: merged_sample_genotyping/genotyped
   genome: download_db/database
   genome_name: ref_genome
  out: [annotated_vcf]

 vcf_to_bedpe:
  run: ../tools/vcftobedpe.cwl
  scatter: vcf
  in:
   vcf: annotate_samples/annotated_vcf
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
   command:
    default: "/usr/bin/aggregate_bedpe.sh"
   bedpe: vcf_to_bedpe/bedpe
  out: [aggregate_bedpe]

 aggregate_healthy:
  run: ../tools/aggregate_bedpe.cwl
  in:
   command:
    default: "/usr/bin/aggregate_healthy_bedpe.sh"
   bedpe: healthy_vcf_to_bedpe/bedpe
  out: [aggregate_bedpe]
 
 remove_unsupported:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($8!=0.00){print}}'
   in_file: aggregate_healthy/aggregate_bedpe
   out_file: "healthy.removedUnsupported"
  out: [awk_out]

 remove_unknown_regions:
  run: ../tools/egrep_v.cwl
  in:
   pattern:
    default: "chrUn|random|CHRUN"
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

 modify_header_blacklisted_outfile:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1s/.*/chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tinfo1\tinfo2/'
   in_file: neither_filter/filtered_bedpe
   out_file: "aggregate.neither"
  out: [sed_out]

 notboth_filter:
  run: ../tools/bedtools_pairToBed.cwl
  in:
   bedpe: neither_filter/filtered_bedpe
   command:
    default: "notboth"
   bed: notboth_region
  out: [filtered_bedpe]

 modify_header_complexity_filter:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1s/.*/chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tinfo1\tinfo2/'
   in_file: notboth_filter/filtered_bedpe
   out_file: "aggregate.neither.notboth"
  out: [sed_out]

 modify_intervals:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($2==$3){$2=$2-1};if($5==$6){$5=$5-1};print}'
   in_file: notboth_filter/filtered_bedpe
   out_file: "modifiedIntervals"
  out: [awk_out]
   
 target_region_filter:
  run: ../tools/bedtools_pairToBed.cwl
  in:
   bedpe: modify_intervals/awk_out
   command:
    default: "either"
   bed: target_regions
  out: [filtered_bedpe]

 add_header_target_region:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1 i\chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tinfo1\tinfo2'
   in_file: target_region_filter/filtered_bedpe
   out_file: "aggregate.neither.notboth.target"
  out: [sed_out]

 plasma_only:
  run: ../tools/awk.cwl
  in:
   pattern:
    default: 'BEGIN{FS=OFS="\t"}{if($13>=1 && $16==0){print}}'
   in_file: target_region_filter/filtered_bedpe
   out_file: "aggregate.neither.notboth.target.plasma.noHeader"
  out: [awk_out]

 add_header_plasma_only:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1 i\chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tinfo1\tinfo2'
   in_file: plasma_only/awk_out
   out_file: "aggregate.neither.notboth.target.plasma"
  out: [sed_out]

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
   out_file: "aggregate.neither.notboth.target.plasma.cleaned"
  out: [sed_out]

 create_awk_string:
  run: ../tools/create_string.cwl
  in:
   in_strings: [first_string, read_support, second_string]
  out: [out_string]
  
 read_support_filter:
  run: ../tools/awk.cwl
  in:
   pattern: create_awk_string/out_string
   in_file: remove_dummy_variables/sed_out 
   out_file: "aggregate.neither.notboth.target.plasma.cleaned.support.noHeader"
  out: [awk_out]

 add_header_somatic:
  run: ../tools/sed.cwl
  in:
   command:
    default: '1 i\chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tinfo1\tinfo2'
   in_file: read_support_filter/awk_out
   out_file: "aggregate.final"
  out: [sed_out]



