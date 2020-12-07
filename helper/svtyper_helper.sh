vcf=$1
bams=$2
IFS="," read -r -a bam_array <<< "$bams"
if [ ${bam_array[-1]} != "NA" ]; then
	foo=$(IFS=, ; echo "${bam_array[*]}")
        /opt/hall-lab/python-2.7.15/bin/svtyper -i $vcf -B $foo
else	
	unset bam_array[-1]
	foo=$(IFS=, ; echo "${bam_array[*]}")
	/opt/hall-lab/python-2.7.15/bin/svtyper -i $vcf -B $foo
fi
