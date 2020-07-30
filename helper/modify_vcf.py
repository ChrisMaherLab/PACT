#!/bin/usr/python3

import sys
import re
import argparse

"""
For use in preparing vcf files to be used as input for SURVIVOR, as the first
step in the SV pipeline, so that SV calls are compatible with downstream tools.
Introduces several dummy values that should not be used for downstream analysis.
Actions taken depend on the source of the SV file
USAGE: python prepare_input.py -i <comma-separated list of VCFs> -o <output directory>
"""

# Change nucleotides in the alt allele to just be "N"
def correctAlt(original_alt):
	new_alt = ""
	nucs = ["T", "A", "C", "G"]
	for i in range(0,len(original_alt)):
		if original_alt[i] in nucs:
			new_alt += "N"
		else:
			new_alt += original_alt[i]
	return new_alt

# Parse and modify info field
def parseInfo(info_field, self_id):
	info = info_field.split(";")
	info_dict = {}
	new_info = ""
	desired_tags = ["PRECISE", "IMPRECISE", "SVTYPE", "SVMETHOD", "PE", "CIPOS", "CIEND", "CT", "PE"]
	for x in info:
		tag_info = x.split("=")
		if tag_info[0] in desired_tags:
			if "PRECISE" in tag_info[0]:
				info_dict["PRECISION"] = tag_info[0]
			else:
				info_dict[tag_info[0]] = tag_info[1]
	for key in info_dict.keys():
		if key is "PRECISION":
			new_info += info_dict[key] + ";"
		elif "CT" in key:
			if info_dict[key] == "5to5":
				new_info += "STRANDS=++:1;"
			elif info_dict[key] == "5to3":
				new_info += "STRANDS=+-:1;"
			elif info_dict[key] == "3to3":
				new_info += "STRANDS=--:1;"
			else:
				new_info += "STRANDS=-+:1;"
		else:
			new_info += key + "=" + info_dict[key] + ";"
	new_info += "MATEID=" + self_id + "_2;"
	return new_info

def createAlt(call):
	alt_string = call["ALT"]
	new_chr = call["CHROM"]
	new_end = call["POS"]
	new_alt = re.sub("chr.+[0-9]+", new_chr + ":" + new_end, alt_string)
	return new_alt

def generateCall2(line, call1):
        # Generate the mate call for BND calls from tools that don't split BND into 2 lines
	call2 = {}
	fields = line.split("\t")
	info = fields[7].split(";")
	for x in info:
		if "CHR2=" in x:
			chrom = x[5:]	
		if "END=" in x[0:4]:
			pos = x[4:]
	call2["CHROM"] = chrom
	call2["POS"] = pos
	call2["ID"] = fields[2] + "_2"
	call2["REF"] = "N"
	call2["ALT"] = re.sub("chr.+[0-9]+", call1["CHROM"] + ":" + call1["POS"], call1["ALT"])
	call2["QUAL"] = call1["QUAL"]
	call2["FILTER"] = call1["FILTER"]
	call2["INFO"] = "SECONDARY;" + re.sub("MATEID=[A-Za-z_0-9:]+;", "MATEID=" + call2["ID"] + ";", call1["INFO"])
	call2["FORMAT_ETC"] = call1["FORMAT_ETC"]
	return call2		
	
def dictToCall(x):
	fields = ["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT_ETC"]
	call = ""
	for field in fields:
		call += str(x[field]) + "\t"
	call.strip()
	call += "\n"
	return call
		

def splitOneLineBND(line):
        # Split a one-line SVTYPE=BND call into a two mate calls
	fields = line.split("\t")
	call1_data = {}
	call2_data = {}
	
	call1_data["CHROM"] = fields[0]
	call1_data["POS"] = fields[1]
	call1_data["ID"] = fields[2] + "_1"
	call1_data["REF"] = "N"
	call1_data["ALT"] = correctAlt(fields[4])
	call1_data["QUAL"] = fields[5]
	call1_data["FILTER"] = fields[6]
	call1_data["INFO"] = parseInfo(fields[7], call1_data["ID"])
	call1_data["FORMAT_ETC"] = "\t".join(fields[8:])
	format_field = fields[8].split(":")
	rv_index = format_field.index("RV")
	dv_index = format_field.index("DV")
	# Add RV value to DV value to get total amount of evidence for the variant.
	# Put that new value into the DV position
	for i in range(9, len(fields)):
		sample = fields[i]
		sample_list = sample.split(":")
		rv = int(sample_list[rv_index])
		dv = int(sample_list[dv_index])
		sample_list[dv_index] = str(rv + dv)
		fields[i] = ":".join(sample_list)
	call2_data = generateCall2(line, call1_data)
	
	call1 = dictToCall(call1_data)
	call2 = dictToCall(call2_data)
	return call1, call2


def modifyLumpy(line):
	"""
	Add DV to format field. Uses SU for first sample. SV workflow won't be relying on SU anyway.
	DV = # of high-quality variant pairs
	SU = # of supporting reads
	May technically differ, but SURVIVOR reports DV, not SU, even though we want SU. Putting
	the SU value into the DV solves our problem - and isn't really used downstream anyway.
	"""
	fields = line.split("\t")
	fields[8] += ":DV"
	format_field = fields[8].split(":")
	index = format_field.index("SU")
	for i in range(9, len(fields)):
		sample = fields[i].strip()
		sample_items = sample.split(":")
		sample_items.append(sample_items[index])
		fields[i] = ":".join(sample_items)
	call = "\t".join(fields)
	call += "\n"
	return call	

def modifyManta(line, has_format):
	if has_format:
		# Copies PR field to DV field
		# PR = Spanning paired-red support for the ref and alt alleles
		fields = line.split("\t")
		fields[8] += ":DV"
		format_field = fields[8].split(":")
		index = format_field.index("PR")
		for i in range(0,len(fields)):
			sample = fields[i].strip()
			sample_items = sample.split(":")
			sample_items.append(sample_items[index])
			fields[i] = ":".join(sample_items)
		call = "\t".join(fields)
		call += "\n"
	else:
		# Uses PAIR_COUNT as DV
		# PAIR_COUNT = read pairs supporting this variant where both reads are confidentally mapped
		# Not sure that the colon is required by VCF format, but SURVIVOR expects to see a colon either on the right or the left of the FORMAT options, so I've included it in the format and in the sample info
		format_string = "DV:"
		pair_count_info = re.findall(";PAIR_COUNT=[\d]+", line)[0]
		count = re.findall("[\d]+", pair_count_info)[0]
		call = line.strip() + "\t" + format_string + "\t" + str(count) + ":\n"
	return call
		

def prepareFile(filename):
	"""
	Make necessary modifications to the input file so that it will work well with SURVIVOR
	and other downstream applications.
	Meant to work with manta, lumpy, delly vcf files.
	Manta candidateSV and Manta somaticSV files have different formats. That needs to be addresed here, though the pipeline uses candidateSV
	"""
	data = []
	bnd_dict = {}
	has_DV = False
	has_mateid = False
	has_format = False
	final_header_line = 0
	counter = 0
	is_lumpy = False
	is_delly = False
	is_manta = False
	with open(filename, "r") as vcf:
		for line in vcf:
			if line[0] is "#":
				if "ID=DV" in line:
					has_DV = True
				elif "ID=MATEID" in line:
					has_mateid = True
				elif "#CHROM" in line:
					final_header_line = counter	
					if "FORMAT" in line:
						has_format = True
				elif "LUMPY" in line:
					is_lumpy = True
				data.append(line)
			else:
				# Delly calls
				# Only prep for Delly is to split BND calls into 2 different calls, rather than keeping them in their 1-line format
				if "DELLY" in line:
					is_delly = True
					if "SVTYPE=BND" in line and "MATEID=" not in line:
						call1, call2 = splitOneLineBND(line)
						data.append(call1)
						data.append(call2)
					else:
						data.append(line) # Update?
				# Lumpy calls
				elif is_lumpy:
					call = modifyLumpy(line)
					data.append(call)
				# Manta calls
				elif len(line) > 1:	
					#has_format = True for manta_SomaticSVs, False for CandidateSVs
					call = modifyManta(line, has_format)
				#	data.append(call)
				else:
					#continue
					data.append(line)
			counter += 1
	vcf.close()

	# Add/Modify necessary header lines
	if not has_format: # Only on manta CandidateSVs
		header = data[final_header_line]
		header.strip()
		header += "\tFORMAT\t" + filename + "\n"
		data[final_header_line] = header
	if not has_DV:
		dv = '##FORMAT=<ID=DV,Number=1,Type=Integer,Description="# high-quality variant pairs">\n'
		data.insert(final_header_line - 1, dv)
	if not has_mateid:
		mateid = '##INFO=<ID=MATEID,Number=.,Type=String,Description="ID of mate breakends">\n'
		data.insert(final_header_line - 2, mateid)


	return data				
				


def main(args):
	parser = argparse.ArgumentParser(description="Modify input vcfs")
	required = parser.add_argument_group('required arguments')
	required.add_argument("-i", "--input_files", action="store", dest="input_files", help="Paths to input vcfs", required=True)
	required.add_argument("-o", "--out_dir", action="store", dest="out_dir", help="Path to output directory", required=True)
	args = parser.parse_args()
	
	input_files = args.input_files
	input_files = input_files.split(",")
	out_dir = args.out_dir

			
	for i in range(0,len(input_files)):
		data = prepareFile(input_files[i])
		outfile_name = out_dir + "/" + str(i) + ".mod.vcf"
		with open(outfile_name, "w") as f:
			for row in data:
				f.write(row)
		f.close()
		


if __name__ == '__main__':
	sys.exit(main(sys.argv))
