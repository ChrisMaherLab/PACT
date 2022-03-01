#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Add useful comments to table output"
baseCommand: ["bash", "add_comments_to_table.sh"]
requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'add_comments_to_table.sh'
        entry: |
            #!/usr/bin/bash
            table=$1
            vcf=$2
            outfile=$3

            echo '##INFO=<ID=set,Number=.,Type=String,Description="Orginal source of call. May include variant caller(s) or whitelist as a source"' > $outfile          
            zgrep "##FILTER=<ID=" $vcf >> $outfile
            head -n 1 $table | awk 'BEGIN{FS=OFS="\t"}{print "#"$0}' | tr -d $'\r' >> $outfile
            tail -n +2 $table | tr -d $'\r' >> $outfile


arguments:
 - valueFrom: $(runtime.outdir)/variants.annotated.comments.tsv
   position: 3

inputs:
    table:
      type: File
      inputBinding:
       position: 1
    vcf:
      type: File
      inputBinding:
       position: 2

outputs:
    commented_table:
        type: File
        outputBinding:
            glob: "variants.annotated.comments.tsv"

