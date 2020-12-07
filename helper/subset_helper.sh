vcf=$1
sample_of_interest=$2
sample_names=$3
tumor_names=$4
extracted_sample_names=$5
extracted_tumor_names=$6
outdir=$7

if [ -z $outdir ]; then
        outdir=$6
fi

tmp=$(basename -- "$sample_of_interest")
sample_of_interest="${tmp%.*}"

IFS="," read -r -a sample_array <<< "$sample_names"
IFS="," read -r -a tumor_array <<< "$tumor_names"
IFS="," read -r -a extracted_sample <<< "$extracted_sample_names"
IFS="," read -r -a extracted_tumor <<< "$extracted_tumor_names"

for ((i=0; i< ${#sample_array[@]}; i++ )); do
	tmp=${sample_array[$i]}
	tmp_filename=$(basename -- "$tmp")
	tmp_rootname="${tmp_filename%.*}"
	sample_array[$i]=$tmp_rootname
	tmp=${tumor_array[$i]}
	tmp_filename=$(basename -- "$tmp")
	tmp_rootname="${tmp_filename%.*}"
	tumor_array[$i]=$tmp_rootname
done

count=0
for ((i=0; i< ${#sample_array[@]}; i++ )); do
	if [ ${tumor_array[$i]} == "NA" ]; then
		if [ ${sample_array[$i]} == ${sample_of_interest} ]; then
			pattern=(${extracted_sample[$i]})
		fi
	else
		count=$((count+1))
		if [ ${sample_array[$i]} == ${sample_of_interest} ]; then
			pattern=("${extracted_sample[$i]}""|""${extracted_tumor[$count]}")
		fi
	fi
done
grep "#" $vcf > $outdir/$sample_of_interest.vcf
grep -v "#" $vcf | egrep $pattern >> $outdir/$sample_of_interest.vcf
