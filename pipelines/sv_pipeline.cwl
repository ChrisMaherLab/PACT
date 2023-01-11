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
  type: 
      - string
      - File
  secondaryFiles: [.fai, ^.dict]
  doc: "Absolute path to reference.fa. Should have reference.dict and .fai files in the same directory"
 ref_genome:
  type: string
  doc: "Name of genome, eg: hg19. Should match snpEff db"
 snpEff_data:
  type: Directory
  doc: "snpEff db. Example: /location/of/database/hg19"
 sample_bams:
  type: string[]
  doc: "Array of absolute paths to bam files. Contains cfDNA/plasma samples. Should have .bai files in same directory"
 matched_control_bams:
  type: string[]
  doc: "Array of absolute paths to bam files. Should be in the same order as sample_bams (ie the nth sample in each array are matches). Should have .bai files in same directory"
 panel_of_normal_bams:
  type: string[]
  doc: "Array of absolute paths to bams used as an unmatched, panel of normals.  Should have accompanying .bai files"
 max_distance_to_merge:
  type: int?
  default: 100
  doc: "Parameter for SURVIVOR - merging distance of SVs"
 minimum_sv_calls:
  type: int?
  default: 2
  doc: "Minimum number of callers that must call an SV for it to be considered a consensus call. Range 1-3."
 minimum_sv_size:
  type: int?
  default: 200
  doc: "Minimum bp length to be considered. Used by SURVIVOR"
 same_strand:
  type: boolean?
  default: false 
  doc: "Require that SVs be reported on the same strand from different callers. Used by SURVIVOR"
 same_type:
  type: boolean?
  default: true
  doc: "Require that SVs be reported as the same type of event from different callers. Used by SURVIVOR"
 target_regions:
  type: File
  doc: "Bed file of target regions from targeted sequencing"
 neither_region:
  type: File
  doc: "Bed file. Neither end of SV should fall in these regions"
 notboth_region:
  type: File
  doc: "Bed file. Max of one end of SV is allowed to be in these regions"
 read_support:
  type: int
  default: 2
  doc: "Minimum required number of total split-reads + paired-end reads that support a variant."
 sv_whitelist:
  type: File?
  doc: "Tab-delimited bed file of SV hotspots. Each line in the bed file should describe a likely breakpoint region. For example, if one end of a suspect structural variant is expected to be around chr1:5000, the bed file might include 'chr1 4000 6000'."
 minwt:
  type: int
  default: 3
  doc: "Minimum weight parameter for lumpy."

outputs: 
 somatic_svs_bedpe:
  type: File
  outputSource: identify_somatic_calls/somatic_svs_bedpe
  doc: "Final list of all SVs called"
 
steps:
 sv_calling:
  run: ../subworkflows/sv_caller.cwl
  in:
   reference: reference
   sample_bams: sample_bams
   matched_control_bams: matched_control_bams
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
   sample_bams: sample_bams
   matched_control_bams: matched_control_bams
   panel_of_normal_bams: panel_of_normal_bams
   target_regions: target_regions
   neither_region: neither_region
   notboth_region: notboth_region
   ref_genome: ref_genome
   snpEff_data: snpEff_data
   read_support: read_support
   sv_whitelist: sv_whitelist
  out: 
   [somatic_svs_bedpe]

