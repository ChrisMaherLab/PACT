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
  type: File
  secondaryFiles: [.fai, ^.dict]
 sample_bams:
  type: File[]
  secondaryFiles: [.bai]
 matched_control_bams:
  type:
      - File[]
  secondaryFiles: [.bai]
 minwt:
  type: int

outputs:
 vcf_files:
  type:
   type: array
   items:
    type: array
    items: File
  outputSource: wrap_output/merged_array


steps:
 ########
 # DELLY 
 delly_calls:
  run: ../tools/delly_caller.cwl
  scatter: [sample_bam, normal_bam]
  scatterMethod: "dotproduct"
  in:
   ref: reference
   sample_bam:
     source: sample_bams
   normal_bam:
     source: matched_control_bams
  out:
   [delly_output]

 convert_delly_to_vcf:
  run: ../tools/bcftovcf.cwl
  scatter: bcf
  in:
   bcf: delly_calls/delly_output
  out:
   [vcf]
 ########

 ########
 # LUMPY
 lumpy_prep:
  run: ../tools/lumpy_prep.cwl
  scatter: [sample_bam, normal_bam]
  scatterMethod: "dotproduct"
  in:
   sample_bam:
     source: sample_bams
   normal_bam:
     source: matched_control_bams
  out:
   [sample_split, normal_split, sample_discordant, normal_discordant]

 merged_splitters:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: lumpy_prep/sample_split
   array2: lumpy_prep/normal_split
  out:
   [array_of_arrays]
 
 merged_discordant:
  run: ../tools/create_array_of_file_arrays.cwl
  in:
   array1: lumpy_prep/sample_discordant
   array2: lumpy_prep/normal_discordant
  out:
   [array_of_arrays]

 lumpy_calls:
  run: ../tools/lumpy_caller.cwl
  scatter: [sample_bam, normal_bam, splitters, discordants]
  scatterMethod: "dotproduct"
  in:
   sample_bam:
     source: sample_bams
   normal_bam:
     source: matched_control_bams
   splitters: merged_splitters/array_of_arrays
   discordants: merged_discordant/array_of_arrays
   minwt: minwt
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
   sample_bam:
     source: sample_bams
   normal_bam:
     source: matched_control_bams
   ref: reference
  out:
   [diploid_variants, somatic_variants, all_candidates, small_candidates, sample_only_variants]

 gunzip_manta:
  run: ../tools/gunzip.cwl
  scatter: [in_file]
  in:
   in_file: manta_caller/all_candidates
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
