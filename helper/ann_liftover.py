#!/usr/bin/python

import sys
import argparse
import re

"""
Using a vcf file with snpEff annotations, lift the annotations over to a bedpe
file of the same SVs without annotations
Performed by:
	For each line in bedpe:
		Create key describing the SV
		Read the vcf to find a matching SV
		if a matching SV is found:
			copy the vcf annotation onto the bedpe

In testing, we had several annotated vcfs >10GB. The above strategy is slow in that
repeated reading through the vcf is necessary, but it doesn't require the script to load
the entire vcf/bedpe into memory at a time, which is necessary since we can expect very large
input files.
"""

def createNonBNDKeyFromVCF(line):
	fields = line.split("\t")
	chrm = fields[0].lower()
	pos = int(fields[1])
	end = int(re.findall(";END=([\d]+)", fields[7])[0])
	cipos_upper = int(re.findall(";CIPOS=[-\d]+,([\d]+)", fields[7])[0])
	ciend_upper = int(re.findall(";CIEND=[-\d]+,([\d]+)", fields[7])[0])
	upper_pos = str(pos + cipos_upper)
	upper_end = str(end + ciend_upper)
	key = chrm + "_" + upper_pos + "_" + upper_end
	return key

def createBNDKeyFromVCF(line):
	fields = line.split("\t")
	chrm = fields[0].lower()
	chrm2 = re.findall("(chr[_0-9a-z]+):", fields[4].lower())[0]
	pos = int(fields[1])
	end = int(re.findall(":([0-9]+)", fields[4])[0])
	cipos_upper = int(re.findall(";CIPOS=[-\d]+,([\d]+)", fields[7])[0])
	upper_pos = str(pos + cipos_upper)
	ciend_upper = int(re.findall(";CIEND=[-\d]+,([\d]+)", fields[7])[0])
	upper_end = str(end + ciend_upper)
	key = chrm + "_" + upper_pos + "_" + chrm2 + "_" + upper_end
	return key

def createNonBNDKeyFromBedpe(line):
	fields = line.split("\t")
	chrm = fields[0].lower()
	upper_pos = fields[2]
	upper_end = fields[5]
	key = chrm + "_" + upper_pos + "_" + upper_end
	return key

def createBNDKeyFromBedpe(line):
	key_a = []
	key_b = []
	fields = line.split("\t")
	chrm_a = fields[0].lower()
	upper_a = int(fields[2])
	chrm_b = fields[3].lower()
	upper_b = int(fields[5])
	# Conversion from vcf to bedpe introduces slight modifications to 
	# SV coordinates, which may not be predictable based only on the information
	# in the bedpe file, so creating a list of possible keys helps reconstruct
	# the original coordinates using limited information
	key_a.append(chrm_a + "_" + str(upper_a) + "_" + chrm_b + "_" + str(upper_b))
	key_a.append(chrm_a + "_" + str(upper_a-1) + "_" + chrm_b + "_" + str(upper_b))
	key_a.append(chrm_a + "_" + str(upper_a) + "_" + chrm_b + "_" + str(upper_b-1))
	key_a.append(chrm_a + "_" + str(upper_a-1) + "_" + chrm_b + "_" + str(upper_b-1))
	key_a.append(chrm_a + "_" + str(upper_a+1) + "_" + chrm_b + "_" + str(upper_b))
	key_a.append(chrm_a + "_" + str(upper_a) + "_" + chrm_b + "_" + str(upper_b+1))
	key_a.append(chrm_a + "_" + str(upper_a+1) + "_" + chrm_b + "_" + str(upper_b+1))
	key_b.append(chrm_b + "_" + str(upper_b) + "_" + chrm_a + "_" + str(upper_a))
	key_b.append(chrm_b + "_" + str(upper_b-1) + "_" + chrm_a + "_" + str(upper_a))
	key_b.append(chrm_b + "_" + str(upper_b) + "_" + chrm_a + "_" + str(upper_a-1))
	key_b.append(chrm_b + "_" + str(upper_b-1) + "_" + chrm_a + "_" + str(upper_a-1))
	key_b.append(chrm_b + "_" + str(upper_b+1) + "_" + chrm_a + "_" + str(upper_a))
	key_b.append(chrm_b + "_" + str(upper_b) + "_" + chrm_a + "_" + str(upper_a+1))
	key_b.append(chrm_b + "_" + str(upper_b+1) + "_" + chrm_a + "_" + str(upper_a+1))
	return key_a, key_b

def extractAnn(line):
	try:
		fields = line.split("\t")	
		ann = re.findall("ANN=.*", fields[7])[0]
		return ann
	except:
		return "ANN=None"
	
def findAnn(key, vcf):
	ann = None
	with open(vcf, "r") as f:
		for line in f:
			if "#" in line:
				continue
			elif "SVTYPE=BND" not in line:
				vcf_key = createNonBNDKeyFromVCF(line)
			else: # This function is not used for BND calls
				#vcf_key = createBNDKeyFromVCF(line)
				continue
			if key == vcf_key:
				ann = extractAnn(line)
				break # Quit reading the file
	f.close()
	# Returns None if no annotation found
	return ann

def findAnnBND(key_a, key_b, vcf):
	ann = None
	with open(vcf, "r") as f:
		for line in f:
			if "#" in line:
				continue
			elif "SVTYPE=BND" not in line:
				continue # This function is not used for non-BND calls
			else:
				vcf_key = createBNDKeyFromVCF(line)
				for key in key_a:
					if key == vcf_key:
						ann = extractAnn(line)
				for key in key_b:
					if key == vcf_key:
						ann = extractAnn(line)
			if ann is not None:
				break # Quit reading the file if SV is found
	f.close()
	return ann
			
	

def addAnnotations(bedpe, vcf):
	with open(bedpe, "r") as f:
		for line in f:
			if "#" in line: #None are expected
				print(line.rstrip())
			elif "SVTYPE=BND" not in line:
				key = createNonBNDKeyFromBedpe(line)
				fields = line.split("\t")
				ann = findAnn(key, vcf)
				if ann is not None:
					s = fields[19].rstrip()
					s += ";" + ann
					fields[19] = s
				new_line = "\t".join(fields)
				print(new_line.rstrip())
			else: # Is BND
				key_a, key_b = createBNDKeyFromBedpe(line)
				fields = line.split("\t")
				ann = findAnnBND(key_a, key_b, vcf)
				if ann is not None:
					fields[19] = fields[19].rstrip() + ";" + ann
				new_line = "\t".join(fields)
				print(new_line.rstrip())
					
	f.close()	

def main(args):
	parser = argparse.ArgumentParser(description="Lift annotation from vcf to bedpe file")
	parser.add_argument("-v", dest="vcf", action="store", help="Input vcf file with annotations from snpEff", required=True)
	parser.add_argument("-b", dest="bedpe", action="store", help="Input bedpe file to lift annotations to", required=True)
	args = parser.parse_args()
	
	addAnnotations(args.bedpe, args.vcf)

if __name__ == '__main__':
	sys.exit(main(sys.argv))



