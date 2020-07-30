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
 tumor_bams:
  type: File[]
 control_bams:
  type: File[]

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
  scatter: [tumor_bam, control_bam]
  scatterMethod: "dotproduct"
  in:
   ref: reference
   tumor_bam: tumor_bams
   control_bam: control_bams
  out: [delly_output]

 convert_delly_to_vcf:
  run: ../tools/bcftovcf.cwl
  scatter: bcf
  in:
   bcf: delly_calls/delly_output
  out: [vcf]

 ########

 ########
 # LUMPY
 lumpy_prep:
  run: ../tools/lumpy_prep.cwl
  scatter: [tumor_bam, control_bam]
  scatterMethod: "dotproduct"
  in:
   tumor_bam: tumor_bams
   control_bam: control_bams
   extractSplitReads_script:
    default:
     class: File
     path: ../helper/extractSplitReads_BwaMem  
  out: [tumor_split, control_split, tumor_discordant, control_discordant]

 merged_array_bams:
  run: ../tools/create_array_of_arrays.cwl
  in:
   array1: tumor_bams
   array2: control_bams
  out: [array_of_arrays]
 
 merged_splitters:
  run: ../tools/create_array_of_arrays.cwl
  in:
   array1: lumpy_prep/tumor_split
   array2: lumpy_prep/control_split
  out: [array_of_arrays]
 
 merged_discordant:
  run: ../tools/create_array_of_arrays.cwl
  in:
   array1: lumpy_prep/tumor_discordant
   array2: lumpy_prep/control_discordant
  out: [array_of_arrays]
 
 lumpy_calls:
  run: ../tools/lumpy_caller.cwl
  scatter: [bams, splitters, discordants]
  scatterMethod: "dotproduct"
  in:
   bams: merged_array_bams/array_of_arrays
   splitters: merged_splitters/array_of_arrays
   discordants: merged_discordant/array_of_arrays
  out: [vcf]

 ########

 ########
 # MANTA 
 manta_caller:
  run: ../tools/manta_caller.cwl
  scatter: [tumor_bam, normal_bam]
  scatterMethod: "dotproduct"
  in:
   tumor_bam: tumor_bams
   normal_bam: control_bams
   ref: reference
  out: [diploid_variants, somatic_variants, all_candidates, small_candidates, tumor_only_variants]

 gunzip_manta:
  run: ../tools/gunzip.cwl
  scatter: [in_file]
  in:
   in_file: manta_caller/all_candidates
  out: [unzipped_file]
 
 #########

 wrap_output:
  run: ../tools/three_way_merge.cwl
  in:
    array1: convert_delly_to_vcf/vcf
    array2: lumpy_calls/vcf
    array3: gunzip_manta/unzipped_file
  out: [merged_array]

