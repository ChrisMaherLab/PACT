#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "SNV background error suppression using panel of normals"
requirements:
    - class: SubworkflowFeatureRequirement
    - class: StepInputExpressionRequirement
    - class: MultipleInputFeatureRequirement
    - class: SchemaDefRequirement
      types:
          - $import: ../types/bam_record.yml

inputs:
    vcf:
        type: File
    reference:
        type:
            - string
            - File
        secondaryFiles: [.fai, ^.dict]
    panel_of_normal_bams:
        type: ../types/bam_record.yml#bam_input[]
        secondaryFiels: [.bai]
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
            bams: 
               source: panel_of_normal_bams
               # This won't work if bams are supplied as a mixture of files and strings
               # Convert from array of custom type to array of string or array of File
               valueFrom: |
                 ${
                   let s = [];
                   if(self[0].as_string) {
                     self.forEach(function(value){
                       s.push(value.as_string);
                     });
                     return s;
                   }
                   self.forEach(function(value){
                     s.push(value.as_file);
                   });
                   return s;
                 }
            intervals: prep/mod_interval_list
            mode:
             default: "GENOTYPE_GIVEN_ALLELES"
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
