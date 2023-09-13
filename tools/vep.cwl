#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Ensembl Variant Effect Predictor"
baseCommand: ["/usr/bin/perl", "-I", "/opt/VEP/Plugins", "/usr/local/bin/ensembl-vep/vep"]
requirements:
    - class: InlineJavascriptRequirement
    - class: ResourceRequirement
      coresMin: 4
      ramMin: 64000
      tmpdirMin: 25000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
arguments:
    ["--format", "vcf",
    "--vcf",
    "--fork", "4",
    "--term", "SO",
    "--transcript_version",
    "--offline",
    "--cache",
    "--symbol",
    "-o", { valueFrom: $(runtime.outdir)/$(inputs.vcf.nameroot)_annotated.vcf }]
inputs:
    vcf:
        type: File
        inputBinding:
            prefix: "-i"
            position: 1
    cache_dir:
        type: Directory
        inputBinding:
            prefix: "--dir"
            position: 4
    synonyms_file:
        type: File?
        inputBinding:
            prefix: "--synonyms"
            position: 2
    coding_only:
        type: boolean
        inputBinding:
            prefix: "--coding_only"
            position: 3
        default: false
    pick:
        type:
            - "null"
            - type: enum
              symbols: ["pick", "flag_pick", "pick_allele", "per_gene", "pick_allele_gene", "flag_pick_allele", "flag_pick_allele_gene"]
        default: "flag_pick"
        inputBinding:
            prefix: '--'
            separate: false
            position: 6
    reference:
        type: File
        secondaryFiles: [.fai, ^.dict]
        inputBinding:
            prefix: "--fasta" 
            position: 7
    plugins:
        type:
            type: array
            items: string
            inputBinding:
                prefix: "--plugin"
        inputBinding:
            position: 8
    everything:
        type: boolean?
        default: true
        inputBinding:
            prefix: "--everything"
            position: 9
    ensembl_assembly:
        type: string
        inputBinding:
            prefix: "--assembly"
            position: 10
        doc: "genome assembly to use in vep. Examples: 'GRCh38' or 'GRCm38'"
    ensembl_version:
        type: string
        inputBinding:
            prefix: "--cache_version"
            position: 11
        doc: "ensembl version - Must be present in the cache directory. Example: '95'"
    ensembl_species:
        type: string
        inputBinding:
            prefix: "--species"
            position: 12
        doc: "ensembl species - Must be present in the cache directory. Examples: 'homo_sapiens' or 'mus_musculus'"
outputs:
    annotated_vcf:
        type: File
        outputBinding:
            glob: "$(inputs.vcf.nameroot)_annotated.vcf"
    vep_summary:
        type: File
        outputBinding:
            glob: "$(inputs.vcf.nameroot)_annotated.vcf_summary.html"
