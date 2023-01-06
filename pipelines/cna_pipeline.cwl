#!/usr/bin/env cwl-runner

##########################
# Workflow for CNA analysis from cfDNA
##########################

cwlVersion: v1.0
class: Workflow
label: "CNA Pipeline"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement

inputs:
 reference:
  type:
      - string
      - File
  doc: "Reference genome fasta."
 capture_targets:
  type:
      - string
      - File
  doc: "Bed file of probes used to target desired target regions. Can be supplied as file path or File"
 ref_flat:
  type:
      - string
      - File
  doc: "refFlat file for reference genome"
 sample_bams:
  type: string[]
  doc: "Array of absolute paths to bam files. Contains cfDNA/plasma samples. Should have .bai files in same directory"
 matched_control_bams:
  type: string[]
  doc: "Array of absolute paths to bam files. Should be in the same order as sample_bams (ie the nth sample in each array are matched)."
 panel_of_normal_bams:
  type: string[]
  doc: "Array of absolute paths to bams used as unmatched, panel of normals. Should have .bai files in same directory"
 ref_genome:
  type: string
  doc: "hg19 or hg38. Other genomes not supported"
 target_genes:
  type:
      - string
      - File
  doc: "Tab delimited bed file describing genes included in the targeted panel, including controls. Columns should contain: chromosome, start position, end position, gene name, description (can be anything, unless it is a control gene, in which case it should be labeled CN-control)"
 all_genes:
  type:
      - string
      - File
  doc: "Bed file of all genes. Columns: chrom, start, stop, gene name, value (arbitrary), strand (+/-)"
 nsd:
  type: int?
  default: 3
  doc: "A target gene will be called a gain/loss if the log ratio of depth is this number of standard deviations above/below the mean of the copy number controls"
  

outputs:
 cna_calls:
  type: File
  outputSource: make_cna_calls/cna_calls

steps:
 prepare_target_regions:
  run: ../subworkflows/cnvkit_prep_regions.cwl
  in:
   reference: reference
   ref_flat: ref_flat
   capture_targets: capture_targets
  out:
   [targets, anti_targets]

 generate_reference_coverage:
  run: ../subworkflows/cna_reference_coverage.cwl
  in:
   panel_of_normal_bams: panel_of_normal_bams
   targets: prepare_target_regions/targets
   anti_targets: prepare_target_regions/anti_targets
   reference: reference
  out:
   [reference_coverage]

 initial_cna_analysis_samples:
  run: ../subworkflows/cnvkit_initial_analysis.cwl
  in:
   bams: sample_bams
   targets: prepare_target_regions/targets
   anti_targets: prepare_target_regions/anti_targets
   reference_coverage: generate_reference_coverage/reference_coverage
  out:
   [target_coverage, antitarget_coverage, fixed_cnr, segmented]

 initial_cna_analysis_controls:
  run: ../subworkflows/cnvkit_initial_analysis.cwl
  in:
   bams: matched_control_bams
   targets: prepare_target_regions/targets
   anti_targets: prepare_target_regions/anti_targets
   reference_coverage: generate_reference_coverage/reference_coverage
  out:
   [target_coverage, antitarget_coverage, fixed_cnr, segmented]

 process_cnvkit_sample_outputs:
  run: ../subworkflows/process_cnvkit_results.cwl
  in:
   target_coverage: initial_cna_analysis_samples/target_coverage
   antitarget_coverage: initial_cna_analysis_samples/antitarget_coverage
   fixed_cnr: initial_cna_analysis_samples/fixed_cnr
   segmented: initial_cna_analysis_samples/segmented
   reference_coverage: generate_reference_coverage/reference_coverage
   genome: ref_genome
   target_genes: target_genes
   all_genes: all_genes
  out:
   [segmented_beds, segmented_cov, gene_overlap]

 process_cnvkit_control_outputs:
  run: ../subworkflows/process_cnvkit_results.cwl
  in:
   target_coverage: initial_cna_analysis_controls/target_coverage
   antitarget_coverage: initial_cna_analysis_controls/antitarget_coverage
   fixed_cnr: initial_cna_analysis_controls/fixed_cnr
   segmented: initial_cna_analysis_controls/segmented
   reference_coverage: generate_reference_coverage/reference_coverage
   genome: ref_genome
   target_genes: target_genes
   all_genes: all_genes
  out:
   [segmented_beds, segmented_cov, gene_overlap]
 
 make_cna_calls:
  run: ../tools/cna_calls.cwl
  in:
   sample_gene_overlaps: process_cnvkit_sample_outputs/gene_overlap
   control_gene_overlaps: process_cnvkit_control_outputs/gene_overlap
   target_genes: target_genes
   nsd: nsd
  out:
   [cna_calls]
