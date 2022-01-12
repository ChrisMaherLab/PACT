#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Add useful comments to table output"
baseCommand: ["bash", "add_comments_to_table.sh"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/helper_docker"
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

            echo "##set=List of variant callers that reported the mutation. If the variant caller is preceeded by 'filterIn', the call made by that caller did not pass all initial filters. FilteredInAll means it was reported by call callers, but initially filtered by all of them." > $outfile          

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

