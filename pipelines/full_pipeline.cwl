#!/usr/bin/env cwl-runner

###########################
# Workflow for identifying somatic variants from targeted
# sequencing of cfDNA.
###########################


cwlVersion: v1.0
class: Workflow
label: "Full pipeline"
requirements:
 - class: ScatterFeatureRequirement
 - class: SubworkflowFeatureRequirement
 - class: StepInputExpressionRequirement
 - class: InlineJavascriptRequirement
 - class: SchemaDefRequirement
   types:
       - $import: ../types/vep_custom_annotation.yml
       - $import: ../types/bam_record.yml

inputs:
# General inputs
 reference:
  type: 
      - string
      - File
  secondaryFiles: [.fai, ^.dict]
  doc: "Absolute path to reference.fa. Should have reference.dict and .fai files in the same directory"
 sample_bams:
  type: ../types/bam_record.yml#bam_input[]
  secondaryFiles: [.bai]
  doc: "Array of custom types that allows bam files to be described either as strings or as files. Contains cfDNA/plasma samples."
 matched_control_bams:
  type: ../types/bam_record.yml#bam_input[]
  secondaryFiles: [.bai]
  doc: "Array of custom type string/file bams used as matched controls. Should be in same order as their corresponding matches in the sample_bams array. Each file should have an accompanying .bai file in the given directory"
 panel_of_normal_bams:
  type: ../types/bam_record.yml#bam_input[]
  secondaryFiles: [.bai]
  doc: "Array of custom type string/file bams used as an unmatched, panel of normals.  Should have accompanying .bai files"
 target_regions:
  type: File
  doc: "Bed file of target regions"

# Variables for SNV/Indel calling
 strelka_cpu_reserved:
  type: int?
  default: 8
  doc: "For strelka cpu usage"
 readcount_minimum_base_quality:
  type: int?
  doc: "Minimum base quality filtering"
 readcount_minimum_mapping_quality:
  type: int?
  doc: "Minimum mapping quality filtering"
 scatter_count:
  type: int?
  default: 50
  doc: "Split SNV callers into n parallel jobs"
 varscan_strand_filter:
  type: int?
  default: 0
  doc: "Apply strand filter in Varscan"
 min_var_freq:
  type: float?
  default: 0.001
  doc: "Minimum variant frequency filter in Varscan/Pindel/filters"
 varscan_p_value:
  type: float?
  default: 0.99
  doc: "P value cut-off for Varscan"
 varscan_max_normal_freq:
  type: float?
  doc: "Max normal frequency in Varscan"
 min_coverage:
  type: int?
  default: 8
 pindel_insert_size:
  type: int
  default: 400
  doc: "Insert size parameter for Pindel"
 whitelist_vcf:
  type: File
  secondaryFiles: [.tbi]
  doc: "VCF and accompanying .tbi of whitelisted SNPs/INDELS"
 filter_whitelist_variants:
  type: boolean
  default: false
  doc: "Determines whether variants found only via genotyping of whitelist sites will be filtered (as WHITELIST_ONLY) or passed through as variant calls."
 vep_cache_dir:
  type:
         - string
         - Directory
  doc: "Cache directory downloaded for use with Vep annotation tool"
 vep_ensembl_assembly:
  type: string
  doc: "Name of Vep Ensembl Assembly being used. Example: GRCh38"
 vep_ensembl_version:
  type: string
  doc: "Ensembl version used for Vep. Must be present in cache directory. Example: 95"
 vep_ensembl_species:
  type: string
  default: "homo_sapiens"
  doc: "Ensembl species being used. Example: homo_sapiens"
 synonyms_file:
  type: File?
  doc: "Optional synonyms file for variants"
 vep_pick:
  type:
         - "null"
         - type: enum
           symbols: ["pick", "flag_pick", "pick_allele", "per_gene", "pick_allele_gene", "flag_pick_allele", "flag_pick_allele_gene"]
  doc: "Vep pick paramter"
 vep_plugins:
  type: string[]
  default: [Downstream, Wildtype]
  doc: "Vep plugins"
 filter_gnomADe_maximum_population_allele_frequency:
  type: float
  default: 0.001
  doc: "Maximum population allele frequency cutoff"
 filter_mapq0_threshold:
  type: float
  default: 0.15
  doc: "Mapq0 threshold for filtering"
 filter_minimum_depth:
  type: int
  default: 6
 cle_vcf_filter:
  type: boolean
  default: false
 vep_custom_annotations:
  type: ../types/vep_custom_annotation.yml#vep_custom_annotation[]
  default: []
 known_variants:
  type: File?
  secondaryFiles: [.tbi]
 # Not recommended to modify the following
 variants_to_table_fields:
  type: string[]
  default: [CHROM,POS,ID,REF,ALT,FILTER,set,SPV,SSC]
 variants_to_table_genotype_fields:
  type: string[]
  default: [GT,AD,AF]
 vep_to_table_fields:
  type: string[]
  default: [HGVSc,HGVSp,SYMBOL,Consequence,PolyPhen,SIFT]
 annotate_coding_only:
  type: boolean?

# Variables for SV calling
 ref_genome:
  type: string
  doc: "Name of genome, eg: hg19. Should match snpEff database if used"
 snpEff_data:
  type: Directory
  doc: "snpEff db. Example: /location/of/database/hg19"
 max_distance_to_merge:
  type: int
  default: 100
  doc: "Parameter for SURVIVOR - merging distance of SVs"
 minimum_sv_calls:
  type: int
  default: 2
  doc: "Number of callers that must call an SV for it to be considered a consensus call. Range 1 to 3."
 minimum_sv_size:
  type: int
  default: 200
  doc: "Minimum bp length to be considered."
 same_strand:
  type: boolean
  default: false
  doc: "Require that SVs be reported on the same strand from different callers."
 same_type:
  type: boolean
  default: true
  doc: "Require that SVs be reported as the same type of event from different callers."
 neither_region: 
  type: File?
  doc: "Bed file. Neither end of SV should fall in these regions."
 notboth_region:
  type: File?
  doc: "Bed file. A max of one end of SV is allowed to be in these regions."
 read_support:
  type: int
  default: 2
  doc: "Minimum required number of split-reads and paired-end reads that support a variant."
 sv_whitelist:
  type: File?
  doc: "Tab-delimited bed file of SV hotspots. Each line in the bed file should describe a likely breakpoint region. For example, if one end of a suspect structural variant is expected to be around chr1:5000, the bed file might include 'chr1 4000 6000'."

outputs:
 somatic_svs_bedpe:
  type: File
  outputSource: sv_analysis/somatic_svs_bedpe
 snv_indel_final_tsv:
  type: File
  outputSource: snv_indel_analysis/final_tsv

steps:
 sv_analysis:
  run: sv_pipeline.cwl
  in: 
    reference: reference
    snpEff_data: snpEff_data
    ref_genome: ref_genome
    sample_bams: sample_bams
    matched_control_bams: matched_control_bams
    panel_of_normal_bams: panel_of_normal_bams
    max_distance_to_merge: max_distance_to_merge
    minimum_sv_calls: minimum_sv_calls
    minimum_sv_size: minimum_sv_size
    same_strand: same_strand
    same_type: same_type
    estimate_sv_distance: estimate_sv_distance
    target_regions: target_regions 
    neither_region: neither_region
    notboth_region: notboth_region
    read_support: read_support
    sv_whitelist: sv_whitelist
  out:
    [somatic_svs_bedpe]

 snv_indel_analysis:
  run: snv_indel_pipeline.cwl
  in: 
    reference: reference
    sample_bams: sample_bams
    matched_control_bams: matched_control_bams
    panel_of_normal_bams: panel_of_normal_bams
    strelka_cpu_reserved: strelka_cpu_reserved
    readcount_minimum_base_quality: readcount_minimum_base_quality
    readcount_minimum_mapping_quality: readcount_minimum_mapping_quality
    scatter_count: scatter_count
    varscan_strand_filter: varscan_strand_filter
    min_coverage: min_coverage
    min_var_freq: min_var_freq
    varscan_p_value: varscan_p_value 
    varscan_max_normal_freq: varscan_max_normal_freq
    pindel_insert_size: pindel_insert_size
    whitelist_vcf: whitelist_vcf
    filter_whitelist_variants: filter_whitelist_variants
    vep_cache_dir: vep_cache_dir
    vep_ensembl_assembly: vep_ensembl_assembly
    vep_ensembl_version: vep_ensembl_version
    vep_ensembl_species: vep_ensembl_species
    synonyms_file: synonyms_file
    annotate_coding_only: annotate_coding_only
    vep_pick: vep_pick
    vep_plugins: vep_plugins
    filter_gnomADe_maximum_population_allele_frequency: filter_gnomADe_maximum_population_allele_frequency
    filter_mapq0_threshold: filter_mapq0_threshold
    filter_minimum_depth: filter_minimum_depth
    cle_vcf_filter: cle_vcf_filter
    variants_to_table_fields: variants_to_table_fields
    variants_to_table_genotype_fields: variants_to_table_genotype_fields
    vep_to_table_fields: vep_to_table_fields
    vep_custom_annotations: vep_custom_annotations
    known_variants: known_variants
  out: 
    [ mutect_filtered_vcf, strelka_filtered_vcf, varscan_filtered_vcf, pindel_filtered_vcf,final_filtered_vcf, final_tsv, vep_summary, tumor_snv_bam_readcount_tsv, tumor_indel_bam_readcount_tsv, normal_snv_bam_readcount_tsv, normal_indel_bam_readcount_tsv ]
    
    
    
