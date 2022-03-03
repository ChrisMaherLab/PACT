#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Detect whitelisted variants"
requirements:
    - class: SubworkflowFeatureRequirement
inputs:
    reference:
        type:
            - string
            - File
        secondaryFiles: [.fai, ^.dict]
    tumor_bam:
        type: string
    normal_bam:
        type: string
    whitelist_vcf:
        type: File
        secondaryFiles: [.tbi]
    interval_list:
        type: File
    filter_whitelist_variants:
        type: boolean
    min_var_freq:
        type: float
    min_coverage:
        type: int
outputs:
    whitelist_variants_vcf:
        type: File
        outputSource: index2/indexed_vcf
        secondaryFiles: [.tbi]
steps:
    GATK_haplotype_caller:
        run: ../tools/whitelist_gatk_haplotype_caller.cwl
        in:
            reference: reference
            bam: tumor_bam
            normal_bam: normal_bam
            whitelist_vcf: whitelist_vcf
            interval_list: interval_list
        out:
            [whitelist_raw_variants]

    bgzip:
        run: ../tools/bgzip.cwl
        in:
            file: GATK_haplotype_caller/whitelist_raw_variants
        out:
            [bgzipped_file]

    index:
        run: ../tools/index_vcf.cwl
        in:
            vcf: bgzip/bgzipped_file
        out:
            [indexed_vcf]

    decompose:
        run: ../tools/vt_decompose.cwl
        in:
            vcf: index/indexed_vcf
        out:
            [decomposed_vcf]

    whitelist_filter:
        run: ../tools/filter_vcf_whitelist.cwl
        in:
            whitelist_raw_variants: decompose/decomposed_vcf
            normal_bam: normal_bam
            tumor_bam: tumor_bam
            filter_whitelist_variants: filter_whitelist_variants
            min_var_freq: min_var_freq
            min_coverage: min_coverage
        out:
            [whitelist_filtered_variants]

    bgzip2:
        run: ../tools/bgzip.cwl
        in:
            file: whitelist_filter/whitelist_filtered_variants
        out:
            [bgzipped_file]

    index2:
        run: ../tools/index_vcf.cwl
        in:
            vcf: bgzip2/bgzipped_file
        out:
            [indexed_vcf]
