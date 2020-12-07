#!/usr/bin/env python3
# Requires Python 2.7 or greater

#############################
# Modify Survivor output file by adjusting formatting
# and adding some dummy values for tags so that the VCF
# can be used with downstream tools
#############################


import sys
import re
import argparse

def addDummyTags(line):
# Add tags required by downstream tools
	fields = line.split("\t")
	info_field = fields[7]
	if info_field[-1] != ";":
		info_field += ";"
	info_field += "PRPOS=1;"
	info_field += "PREND=1;"
	# Since not all tools report CIPOS/CIEND related values,
	# reduce them all to dummy values
	if re.search("CIPOS=", info_field) is not None:
		info_field = re.sub("CIPOS=[-\d]+,[-\d]+;", "CIPOS=0,0;", info_field)
	else:
		info_field += "CIPOS=0,0;"	
	if re.search("CIEND=", info_field) is not None:
		info_field = re.sub("CIEND=[-\d]+,[-\d]+;", "CIEND=0,0;", info_field)
	else:
		info_field += "CIEND=0,0;"
	info_field += "CIPOS95=0,0;"
	info_field += "CIEND95=0,0;"
	# More dummy values. Don't rely on these for filtering, etc.
	info_field += "SU=2;"
	info_field += "PE=1;"
	info_field += "SR=1;"
	info_fields = info_field.split(";")
	# Index should be a list of len 1
	index = [i for i, s in enumerate(info_fields) if 'STRANDS=' in s]
	info_fields[index[0]] = info_fields[index[0]] + ":1"	
	info_field = ";".join(info_fields)	
	fields[7] = info_field

	return "\t".join(fields)

def validateAlt(line):
# Validate the alt allele info for DEL, DUP, and INV calls
	try:
		svtype = re.findall("SVTYPE=[A-Za-z]+", line)[0]
		svtype = svtype.split("=")[1]
		if svtype in ["DEL", "DUP", "INV"]:
			fields = line.split("\t")
			fields[4] = "<" + svtype + ">"
			line = "\t".join(fields)
		elif "DUP" in line: # For the rare case where Manta calls something both an insertion and a duplication
			fields = line.split("\t")
			fields[4] = "<DUP>"
			line = "\t".join(fields)
			line = re.sub("SVTYPE=[A-Za-z]+", "SVTYPE=DUP", line) # Change svtype from INS to DUP
		return line
	except:
		return line

# Return False if end < pos
# For some reason, SURVIVOR converts some BND calls into INV calls, but introduces errors
# when it does so. 
def isValidInv(line):
	fields = line.split("\t")
	pos = int(fields[1])
	end_info = re.findall("END=[\d]+;", line)[0]
	end = int(re.findall("[\d]+", end_info)[0])
	if pos >= end:
		return False
	return True	
		

def generateKey(line):
	# Generate a key based on the ID provided by each caller that called the SV.
	# Append the key(s) together to make one long key. 
	# For two calls to be mates, they must have been mates in each of the callers
	# that called the SV.
	# May need to be modified if any of the callers modify how they format their IDs.
	# Using multiple keys appended together  ensures that callers agree fully on a call.
	fields = line.split("\t")
	format_field = fields[8].split(":")
	index = format_field.index("ID")
	long_key = ""
	for i in range(9, len(fields)):
		sample = fields[i].split(":")
		sample_id_info = sample[index].split("_")
		if "manta" in sample_id_info[0].lower():
			key = "_".join(sample_id_info[1:-1])
			if key != "nan":
				long_key += key
		else: 
			id_prefix = sample_id_info[0]	
			key = id_prefix.lower()
			if key != "nan":
				long_key += key
	
	return long_key
	
	
def extractID(line):
	return line.split("\t")[2]	
			

def updateMate(call, mateid, event, is_secondary):
        # Change TRA to BND for SVTYPES, and MATEID and EVENT ID,
        # as well as the SECONDARY tag if necessary
	call = re.sub("SVTYPE=TRA", "SVTYPE=BND", call)
	fields = call.split("\t")
	info_field = fields[7]
	info_field += "MATEID=" + mateid + ";"
	info_field += "EVENT=" + str(event) + ";"
	if is_secondary:
		info_field += "SECONDARY;"
	fields[7] = info_field
	return "\t".join(fields)

def main(args):
	parser = argparse.ArgumentParser(description="Modify Survivor output")
	required = parser.add_argument_group('required arguments')
	required.add_argument("-i", "--input_file", action="store", dest="input_file", help="Path to input vcf", required=True)
	args = parser.parse_args()

	infile = args.input_file
	bnd_dict = {}	
	need_to_add_info = True
	with open(infile, "r") as f1:
		for line in f1:
			if line[0] is "#":
				if "##INFO" in line and need_to_add_info:
					# Add info fields for dummy tags
					need_to_add_info = False
					prpos_string = '##INFO=<ID=PRPOS,Number=.,Type=String,Description="LUMPY probability curve of the POS breakend (dummy)">'
					prend_string = '##INFO=<ID=PREND,Number=.,Type=String,Description="LUMPY probability curve of the END breakend (dummy)">'
					cipos95_string = '##INFO=<ID=CIPOS95,Number=2,Type=Integer,Description="Confidence interval (95%) around POS for imprecise variants (dummy)">'
					ciend95_string = '##INFO=<ID=CIEND95,Number=2,Type=Integer,Description="Confidence interval (95%) around END for imprecise variants (dummy)">'	
					event_string = '##INFO=<ID=EVENT,Number=1,Type=String,Description="ID of event associated to breakend">'
					mateid_string = '##INFO=<ID=MATEID,Number=.,Type=String,Description="ID of mate breakends">'
					secondary_string = '##INFO=<ID=SECONDARY,Number=0,Type=Flag,Description="Secondary breakend in a multi-line variant">'
					su_string = '##INFO=<ID=SU,Number=1,Type=Integer,Description="Number of pieces of evidence supporting the variant (dummy)">'
					pe_string = '##INFO=<ID=PE,Number=1,Type=Integer,Description="Number of paired-end reads supporting the variant (dummy)">'
					sr_string = '##INFO=<ID=SR,Number=1,Type=Integer,Description="number of split reads supporting the variant (dummy)">'

					print (prpos_string)
					print (prend_string)
					print (cipos95_string)
					print (ciend95_string)
					print (event_string)
					print (mateid_string)
					print (secondary_string)
					print (su_string)
					print (pe_string)
					print (sr_string)
				if "##INFO=<ID=STRANDS" in line:
					# Modify strands info line to point out that it contains a dummy value
					new_strands_line = '##INFO=<ID=STRANDS,Number=1,Type=String,Description="Indicating the direction of the reads with respect to the type and breakpoint. Followed by a dummy integer.">'
					print(new_strands_line)
				else:
					print(line.strip())
			else:
				line = addDummyTags(line) # Add dummy values to the SV call
				line = validateAlt(line) # Ensure that the alt allele will be considered valid
				# For TRA calls, split the 1-line SV call into a 2-line SV call by connecting two TRA calls that describe different sides of the same event
				if "SVTYPE=TRA" in line:
					key = generateKey(line)	
					if key not in bnd_dict.keys():
						bnd_dict[key] = line
					else:
						call1 = bnd_dict[key]
						calls = [call1, line]
						calls.sort()
						new_call1 = updateMate(calls[0], extractID(calls[1]), key, False)
						new_call2 = updateMate(calls[1], extractID(calls[0]), key, True)
						print(new_call1.strip())
						print(new_call2.strip())
						bnd_dict.pop(key) # For memory
				elif "SVTYPE=INV" in line:
					if isValidInv(line):
						print(line.strip())
					
				else:
					print(line.strip())
	f1.close()


if __name__ == '__main__':
	sys.exit(main(sys.argv))
