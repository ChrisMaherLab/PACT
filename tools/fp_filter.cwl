#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "False Positive filter"
baseCommand: ["/usr/bin/perl", "/usr/bin/fpfilter.pl"]
requirements:
    - class: ResourceRequirement
      ramMin: 6000
      tmpdirMin: 25000
    - class: DockerRequirement
      #dockerPull: "jbwebster/helper_docker"
      dockerPull: "mgibio/fp_filter-cwl:1.0.1"
arguments:
    ["--bam-readcount", "/usr/bin/bam-readcount",
    "--samtools", "/opt/samtools/bin/samtools",
    "--output", { valueFrom: $(runtime.outdir)/$(inputs.output_vcf_basename).vcf }]
inputs:
    reference:
        type:
            - string
            - File
        secondaryFiles: [.fai, ^.dict]
        inputBinding:
            prefix: "--reference"
            position: 1
    bam:
        #type: File
        type:
            - string
            - File
        inputBinding:
            prefix: "--bam-file"
            position: 2
    vcf:
        type: File
        inputBinding:
            prefix: "--vcf-file"
            position: 3
    output_vcf_basename:
        type: string?
        default: fpfilter
    sample_name:
        type: string?
        default: 'TUMOR'
        inputBinding:
            prefix: "--sample"
            position: 4
    min_var_freq:
        type: float?
        #default: 0.05
        default: 0.001
        inputBinding:
            prefix: "--min-var-freq"
            position: 5
    min_var_count:
        type: int
        default: 6
        inputBinding:
            prefix: "--min-var-count"
            position: 6
outputs:
    filtered_vcf:
        type: File
        outputBinding:
            glob: $(inputs.output_vcf_basename).vcf

