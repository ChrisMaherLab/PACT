#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Perform SV calling of sample vs matched control using Delly, Lumpy, and Manta"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement

inputs:
 reference:
  type: string
 sample_bams:
  type: string[]
 control_bams:
  type: string[]
 tumor_bams:
  type: string[]
 sample_helper:
  type: File
  default:
   class: File
   path: ../helper/get_sample.sh

outputs:
 vcf_files:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: wrap_output/merged_array
 tumor_vcf_files:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: wrap_tumor_output/merged_array


steps:
 # Remove NAs from solid tumor list
 create_tumor_subset:
  run: ../tools/create_subset.cwl
  in:
   tumor_array: tumor_bams
   control_array: control_bams
  out:
   [tumor_subset, control_subset]

 ########
 # DELLY 
 delly_calls:
  run: ../tools/delly_caller.cwl
  scatter: [sample_bam, control_bam]
  scatterMethod: "dotproduct"
  in:
   ref: reference
   sample_bam: sample_bams
   control_bam: control_bams
  out:
   [delly_output]

 #extract_sample_names:
 # run: ../tools/get_delly_samples.cwl
 # scatter: bcf
 # in:
 #  helper: sample_helper
 #  bcf: delly_calls/delly_output
 # out:
 #  [samples]

 #somatic_filter:
 # run: ../tools/delly_filter.cwl
 # scatter: [samples, input_bcf]
 # scatterMethod: "dotproduct"
 # in:
 #  samples: extract_sample_names/samples
 #  input_bcf: delly_calls/delly_output
 #  command:
 #   default: "somatic"
 # out:
 #  [delly_output]

 convert_delly_to_vcf:
  run: ../tools/bcftovcf.cwl
  scatter: bcf
  in:
   #bcf: somatic_filter/delly_output
   bcf: delly_calls/delly_output
  out:
   [vcf]

 tumor_delly_calls:
  run: ../tools/delly_caller.cwl
  scatter: [sample_bam, control_bam]
  scatterMethod: "dotproduct"
  in:
    ref: reference
    sample_bam: create_tumor_subset/tumor_subset
    control_bam: create_tumor_subset/control_subset
  out:
   [delly_output]

 #tumor_extract_sample_names:
 # run: ../tools/get_delly_samples.cwl
 # scatter: bcf
 # in:
 #  helper: sample_helper
 #  bcf: tumor_delly_calls/delly_output
 # out:
 #  [samples]

 #tumor_somatic_filter:
 # run: ../tools/delly_filter.cwl
 # scatter: [input_bcf, samples]
 # scatterMethod: "dotproduct"
 # in:
 #  samples: tumor_extract_sample_names/samples
 #  input_bcf: tumor_delly_calls/delly_output
 #  command:
 #   default: "somatic"
 # out:
 #  [delly_output]

 convert_tumor_delly_to_vcf:
  run: ../tools/bcftovcf.cwl
  scatter: bcf
  in:
   #bcf: tumor_somatic_filter/delly_output
   bcf: tumor_delly_calls/delly_output
  out:
   [vcf]

 ########

 ########
 # LUMPY
 lumpy_prep:
  run: ../tools/lumpy_prep.cwl
  scatter: [sample_bam, control_bam, tumor_bam]
  scatterMethod: "dotproduct"
  in:
   sample_bam: sample_bams
   control_bam: control_bams
   tumor_bam: tumor_bams
  out:
   [sample_split, control_split, sample_discordant, control_discordant, tumor_split, tumor_discordant]

 merged_array_bams:
  run: ../tools/create_array_of_string_arrays.cwl
  in:
   array1: sample_bams
   array2: control_bams
  out:
   [array_of_arrays]

 merged_tumor_array_bams:
  run: ../tools/create_array_of_string_arrays.cwl
  in:
   array1: create_tumor_subset/tumor_subset
   array2: create_tumor_subset/control_subset
  out:
   [array_of_arrays]
 
 merged_splitters:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: lumpy_prep/sample_split
   array2: lumpy_prep/control_split
  out:
   [array_of_arrays]
 
 merged_discordant:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: lumpy_prep/sample_discordant
   array2: lumpy_prep/control_discordant
  out:
   [array_of_arrays]

 prep_tumor_samples_for_lumpy:
  run: ../tools/prep_tumor_samples_for_lumpy.cwl
  in:
   tumor_bams: tumor_bams
   control_bams: control_bams
   tumor_splitters: lumpy_prep/tumor_split
   control_splitters: lumpy_prep/control_split
   tumor_discordant: lumpy_prep/tumor_discordant
   control_discordant: lumpy_prep/control_discordant
  out:
   [tumor_split_subset, control_split_subset, tumor_disc_subset, control_disc_subset]

 merged_tumor_splitters:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: prep_tumor_samples_for_lumpy/tumor_split_subset
   array2: prep_tumor_samples_for_lumpy/control_split_subset
  out:
   [array_of_arrays]

 merged_tumor_discordant:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: prep_tumor_samples_for_lumpy/tumor_disc_subset
   array2: prep_tumor_samples_for_lumpy/control_disc_subset
  out:
   [array_of_arrays]
 
 lumpy_calls:
  run: ../tools/lumpy_caller.cwl
  scatter: [bams, splitters, discordants]
  scatterMethod: "dotproduct"
  in:
   bams: merged_array_bams/array_of_arrays
   splitters: merged_splitters/array_of_arrays
   discordants: merged_discordant/array_of_arrays
  out:
   [vcf]

 tumor_lumpy_calls:
  run: ../tools/lumpy_caller.cwl
  scatter: [bams, splitters, discordants]
  scatterMethod: "dotproduct"
  in:
   bams: merged_tumor_array_bams/array_of_arrays
   splitters: merged_tumor_splitters/array_of_arrays
   discordants: merged_tumor_discordant/array_of_arrays
  out:
   [vcf]

 ########

 ########
 # MANTA 
 manta_caller:
  run: ../tools/manta_caller.cwl
  scatter: [sample_bam, normal_bam]
  scatterMethod: "dotproduct"
  in:
   sample_bam: sample_bams
   normal_bam: control_bams
   ref: reference
  out:
   [diploid_variants, somatic_variants, all_candidates, small_candidates, sample_only_variants]

 gunzip_manta:
  run: ../tools/gunzip.cwl
  scatter: [in_file]
  in:
   in_file: manta_caller/all_candidates
   #in_file: manta_caller/somatic_variants
  out:
   [unzipped_file]

 tumor_manta_caller:
  run: ../tools/manta_caller.cwl
  scatter: [sample_bam, normal_bam]
  scatterMethod: "dotproduct"
  in:
   sample_bam: create_tumor_subset/tumor_subset
   normal_bam: create_tumor_subset/control_subset
   ref: reference
  out:
   [diploid_variants, somatic_variants, all_candidates, small_candidates, sample_only_variants]

 gunzip_tumor_manta:
  run: ../tools/gunzip.cwl
  scatter: [in_file]
  in:
   in_file: tumor_manta_caller/all_candidates
   #in_file: tumor_manta_caller/somatic_variants
  out:
   [unzipped_file]
 
 #########

 wrap_output:
  run: ../tools/three_way_merge.cwl
  in:
    array1: convert_delly_to_vcf/vcf
    array2: gunzip_manta/unzipped_file
    array3: lumpy_calls/vcf
  out:
   [merged_array]

 wrap_tumor_output:
  run: ../tools/three_way_merge.cwl
  in:
   array1: convert_tumor_delly_to_vcf/vcf
   array2: gunzip_tumor_manta/unzipped_file
   array3: tumor_lumpy_calls/vcf
  out:
   [merged_array]
