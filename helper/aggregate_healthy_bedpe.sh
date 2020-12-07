#!/usr/bin/bash

# Aggregate multiple bedpe files with healthy data into a single bedpe file

echo -e "chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\thealthy_pe_reads\thealthy_split_reads\thealthy_pe_sr_reads"

for i; do
	for filepath in $i; do
		sample_name="$(grep "#CHROM" $filepath | awk -F "\t" '{print $22}')"
		export PATIENT=$sample_name
		cat $filepath | grep -v "#" | perl -ane '$pt=$ENV{PATIENT}; $id="$pt/$F[10]"; @healthy=split(/:/, $F[21]); $pe = $healthy[13]; $sr = $healthy[10]; print join("\t", $F[0], $F[1], $F[2], $F[3], $F[4], $F[5], $id, $F[7], $F[8], $F[9], $pe, $sr, $pe+$sr), "\n"';	
	done
 done
