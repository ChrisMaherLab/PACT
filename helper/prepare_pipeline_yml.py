#!bin/usr/python3

import sys
import re
import argparse


def createTumorAndSampleStrings(args):
	sample_file = args.samples_file
	samples_and_controls = []
	# Throws unhandled error if file does not exist
	with open(sample_file, "r") as f:
		for line in f:
			line = line.strip()
			bams = line.split("\t")
			samples_and_controls.append(bams)
	f.close()
	tumor_string = "tumor_bams:\n"
	control_string = "control_bams:\n"
	for i in range(0, len(samples_and_controls)):
		bams = samples_and_controls[i]
		tumor_string += " - " + bams[0] + "\n"
		control_string += " - " + bams[1] + "\n"
	return tumor_string, control_string

def createHealthyBamString(args):
	healthy_file = args.healthy	
	healthy_bams = []
	with open(healthy_file, "r") as f:
		for line in f:
			healthy_bams.append(line.strip())
	f.close()
	healthy_string = "healthy_bams:\n"
	for i in range(0, len(healthy_bams)):
		bam = healthy_bams[i]
		out = "["+ bam + "]"
		if i == 0:
			out = " [" + out
		else:
			out = " " + out
		if i < len(healthy_bams) - 1:
			out += ",\n"
		else:
			out += "]\n"
		healthy_string += out
	return healthy_string
	

def generateFileInfo(args):
	tumor, control = createTumorAndSampleStrings(args)
	outstring = "reference: " + args.reference + "\n"
	outstring += "ref_genome: " + args.genome + "\n"
	outstring += tumor
	outstring += control
	if args.max_distance is not None:
		outstring += "max_distance_to_merge: " + str(args.max_distance) + "\n"
	if args.num_callers is not None:
		outstring += "minimum_sv_calls: " + str(args.num_callers) + "\n"
	if args.min_size is not None:
		outstring += "minimum_sv_size: " + str(args.min_size) + "\n"
	outstring += "same_strand: " + str(args.same_strand).lower() + "\n"
	outstring += "same_type: " + str(args.same_type).lower() + "\n"
	outstring += "estimate_sv_distance: " + str(args.est_dist).lower() + "\n"
	outstring += createHealthyBamString(args)
	outstring += "target_regions:\n class: File\n path: " + args.target + "\n"
	if args.neither is not None:
		outstring += "neither_region:\n class: File\n path: " + args.neither + "\n"
	if args.notboth is not None:
		outstring += "notboth_region:\n class: File\n path: " + args.notboth + "\n"
	if args.read_support is not None:
		outstring += 'read_support: "' + str(args.read_support) + '"\n'
	return outstring

def main(args):
	
	parser = argparse.ArgumentParser(description="Prepare input yml")
	required = parser.add_argument_group('required arguments')
	required.add_argument("-s", "--samples_file", action="store", help="Tab-delimited file with paths to sample bams in first column, and their matched control in the second column", required=True)
	required.add_argument("-n", "--healthy", action="store", help="File with a list of paths to healthy bam files", required=True)
	required.add_argument("-r", "--reference", action="store", help="Path to reference genome .fa file")
	required.add_argument("-t", "--target", action="store", help="Path to bed file describing target regions used for targeted sequencing")
	required.add_argument("-g", "--genome", action="store", help="Name of reference genome (should correspond to file in -r). Ex: hg19. Should be a genome build supported by SV-HotSpot and SnpEff.")
	parser.add_argument("--max_distance", action="store", type=int, help="Max allowed distance between SVs for merging. See SURVIVOR documentation for more info. Default=100")
	parser.add_argument("--num_callers", action="store",  type=int, help="Number of tools that needed to call an SV for it to be considered a consensus call. See SURVIVOR documentation for more info. Default=2")
	parser.add_argument("--neither", action="store", help="Path to a bed file for use with filtering SVs. Will be used as -b parameter for bedtools pairToBed --neither. Not required, but HIGHLY RECOMMENDED to supply a blacklist file.")
	parser.add_argument("--notboth", action="store", help="Path to a bed file for use with filtering SVs. Will be used as -b parameter for bedtools pairToBed --notboth. Not required, but HIGHLY RECOMMENDED to supply a file of low complexity regions.")
	parser.add_argument("--min_size", action="store", default=30, type=int, help="Minimun size of SV to be considered. See SURVIVOR documentation for more info. Default=30")
	parser.add_argument("--same_strand", action="store_true", help="Flag requiring SVs to be on the same strand in order to be merged. See SURVIVOR documentation for more info. Default=false")
	parser.add_argument("--same_type", action="store_false", help="Flag requiring SVs to be of the same type in order to be merged. Use the flag to turn off this requirement. Default=true")
	parser.add_argument("--est_dist", action="store_true", help="Flag to estimate SV distance. See SURVIVOR for info. Default=false")
	parser.add_argument("--read_support", action="store", help="Number of supporting reads required for a somatic SV. Default=1")

	args = parser.parse_args()

	outstring = generateFileInfo(args)
	print(outstring)
	
		


if __name__ == '__main__':
	sys.exit(main(sys.argv))
