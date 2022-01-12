#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Custom allele frequency filter"
baseCommand: ["bash", "helper.sh"]
requirements:
    - class: InlineJavascriptRequirement
    - class: DockerRequirement
      dockerPull: "jbwebster/vep_docker"
#      dockerPull: "mgibio/vep_helper-cwl:vep_101.0_v1"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'helper.sh'
        entry: |
            #!/bin/bash
            vcf=$1
            out=$2
            max_freq=$3
            field_name=$4

            /usr/bin/perl /usr/bin/vcf_check.pl ${vcf} ${out}/tmp.vcf /usr/bin/perl /opt/vep/src/ensembl-vep/filter_vep --format vcf --soft_filter -o ${out}/tmp.vcf -i ${vcf} --filter "${field_name} < ${max_freq} or not ${field_name}" 

            grep "#" ${out}/tmp.vcf | grep -v "filter_vep_pass" > ${out}/annotated.af_filtered.vcf
            grep -v "#" ${out}/tmp.vcf | sed 's/;filter_vep_pass//g' >> ${out}/annotated.af_filtered.vcf
            sed -i 's/filter_vep_pass/PASS/g' ${out}/annotated.af_filtered.vcf

            

arguments:
    [{ valueFrom: $(runtime.outdir), position: 2 }]

#    [{ valueFrom: $(inputs.vcf.path) },
#    { valueFrom: $(runtime.outdir) }]

inputs:
    vcf:
        type: File
        inputBinding:
            position: 1
    maximum_population_allele_frequency:
        type: float
        inputBinding:
            position: 3
    field_name:
        type: string
        inputBinding:
           position: 4
outputs:
    filtered_vcf:
        type: File
        outputBinding:
            glob: "annotated.af_filtered.vcf"
