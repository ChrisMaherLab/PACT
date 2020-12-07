#!/usr/bin/bash

# Aggregate multiple bedpe files with sample and control data into a single bedpe file

echo -e "chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tsolid_tumor_pe_reads\tsolid_tumor_split_reads\tsolid_tumor_pe_sr_reads\tinfo1\tinfo2"

for i; do
	for filepath in $i; do
		sample_name="$(grep "#CHROM" $filepath | awk -F "\t" '{print $23}' )"
		export PATIENT=$sample_name
		#cat $filepath | grep -v "#"  | perl -ane '$pt=$ENV{PATIENT}; $id="$pt/$F[10]";  @tt=split(/:/, $F[22]); @nn=split(/:/, $F[21]); $tpe = $tt[13]; $tsr = $tt[10]; $npe = $nn[13]; $nsr = $nn[10]; $F[3] =~ s/(CHR)/chr/ ; print join("\t", $F[0], $F[1], $F[2], $F[3], $F[4], $F[5], $id, $F[7], $F[8], $F[9], $tpe, $tsr, $tpe+$tsr, $npe, $nsr, $npe+$nsr, $F[18], $F[19]), "\n"';

		cat $filepath | grep -v "#"  | perl -ane '$pt=$ENV{PATIENT}; $id="$pt/$F[10]"; @st=split(/:/, $F[23]);  @tt=split(/:/, $F[22]); @nn=split(/:/, $F[21]); $stpe = $st[13]; $stsr = $st[10]; $tpe = $tt[13]; $tsr = $tt[10]; $npe = $nn[13]; $nsr = $nn[10]; $F[3] =~ s/(CHR)/chr/ ; print join("\t", $F[0], $F[1], $F[2], $F[3], $F[4], $F[5], $id, $F[7], $F[8], $F[9], $tpe, $tsr, $tpe+$tsr, $npe, $nsr, $npe+$nsr, $stpe, $stsr, $stpe+$stsr, $F[18], $F[19]), "\n"';
	done
done
