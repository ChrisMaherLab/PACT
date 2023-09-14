#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "SNV background error suppression using panel of normals"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement

inputs:
    vcf:
        type: File
    reference:
        type: File
        secondaryFiles: [.fai, ^.dict, .amb, .ann, .bwt, .pac, .sa]
    panel_of_normal_bams:
        type: File[]
        secondaryFiles: [.bai]
    roi_intervals:
        type: File

outputs:
    filtered_vcf:
        type: File
        outputSource: suppress_noise/filtered

steps:
    prep:
        run: ../tools/prep_for_PoN.cwl
        in:
           vcf: vcf
           intervals: roi_intervals
        out:
           [prepared_vcf, mod_interval_list]

    index:
        run: ../tools/gatk_IndexFeatureFile.cwl
        in:
          vcf: prep/prepared_vcf
        out:
           [indexed_vcf]

    genotype_PoN:
        run: ../tools/gatk_haplotype_caller_PoN.cwl
        in:
            vcf: index/indexed_vcf
            reference: reference
            bams: panel_of_normal_bams
            intervals: prep/mod_interval_list
            output:
             default: "PoN.vcf"
        out:
            [PoN_vcf]

    identify_noise:
        run: ../tools/identify_PoN_support.cwl
        in:
            vcf: genotype_PoN/PoN_vcf
            percent:
             default: 10            
        out:
            [PoN_vcf]

    index2:
        run: ../tools/gatk_IndexFeatureFile.cwl
        in:
          vcf: identify_noise/PoN_vcf
        out:
           [indexed_vcf]

    index3:
        run: ../tools/gatk_IndexFeatureFile.cwl
        in:
          vcf: vcf
        out:
           [indexed_vcf]

    suppress_noise:
        run: ../tools/gatk_VariantFiltration.cwl
        in:
            vcf: index3/indexed_vcf
            mask: index2/indexed_vcf
            reference: reference  
            mask_name:
              default: "PoN"
            output:
              default: "PoN.vcf.gz"
        out:
            [filtered]
