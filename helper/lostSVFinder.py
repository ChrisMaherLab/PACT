#!/usr/bin/python

import sys
import re
import glob
import os
import argparse

class Peak:
	def __init__(self, chrm, start, end):
		self.chrm = chrm.lower()
		self.start = start
		self.end = end

	def inPeak(self, chrm, pos):
		chrm = chrm.lower()
		return self.chrm == chrm and pos >= self.start and pos <= self.end
	
	def toString(self):
		s = self.chrm
		s += "\t" + str(self.start)
		s += "\t" + str(self.end)
		return s

def createParser():
	parser = argparse.ArgumentParser(description="Recover lost SVs")
	required = parser.add_argument_group('required arguments')
	required.add_argument("-p", "--peaks", action="store", dest="peaks", required=True)
	required.add_argument("-c", "--consensus", action="store", dest="consensus", required=True)
	required.add_argument("-v", "--vcf", action="store", dest="vcf", required=True)
	required.add_argument("-n", "--n", action="store", dest="threshold", required=True)
	required.add_argument("-o", "--out", action="store", dest="outdir", required=True)
	return parser

def createPeakList(infile, count):
	peaks = []
	counter = 1
	isHeader = True
	with open(infile, "r") as f:
		for line in f:
			if isHeader:
				isHeader = False
			elif counter <= count:
				fields = line.split("\t")
				peak = Peak(fields[1], int(fields[2]), int(fields[3])) # Consider keeping peak ID
				peaks.append(peak)
				counter += 1
	f.close()
	return peaks

def isValidId(curr_id):
	curr_id = curr_id.lower()
	return "na" not in curr_id and "nan" not in curr_id

def addConId(ids, line):
	fields = line.split("\t")
	id_pos = fields[8].split(":").index("ID")
	delly_id = fields[9].split(":")[id_pos]
	lumpy_id = fields[10].split(":")[id_pos]
	manta_id = fields[11].split(":")[id_pos]
	if isValidId(delly_id):
		d = ids["delly"]
		d.append(delly_id)
		ids["delly"] = d
	if isValidId(lumpy_id):
		l = ids["lumpy"]
		l.append(lumpy_id)
		ids["lumpy"] = l
	if isValidId(manta_id):
		mod_id = ":".join(manta_id.split("_"))
		m = ids["manta"]
		m.append(mod_id)
		ids["manta"] = m
	return ids
	
def collectConsensusIds(con_file, peaks):
	con_ids = {}
	con_ids["delly"] = []
	con_ids["lumpy"] = []
	con_ids["manta"] = []
	with open(con_file, "r") as f:
		for line in f:
			if "#" not in line:
				addConId(con_ids, line)	
	f.close()
	return con_ids

def getFilename(vcfs):
	for filename in vcfs:
		if "0.mod.vcf" in filename:
			delly =  filename
		elif "1.mod.vcf" in filename:
			manta =  filename
		elif "2.mod.vcf" in filename:
			lumpy =  filename
	return delly, manta, lumpy

def extractFromAlt(alt):
        chrm = re.findall("[A-Za-z0-9]+:", alt)[0][:-1]
        pos = int(re.findall(":[0-9]+", alt)[0][1:])
        return chrm, pos

def extractDellyBreakend(line):
	fields = line.split("\t")
	chr1 = fields[0]
	pos = fields[1]
	if re.search("BND", line):
		chr2, end = extractFromAlt(fields[4])
	else:
		info = fields[7]
		chr2 = re.findall("CHR2=[A-Za-z0-9]+", info)[0].split("=")[1]
		end = re.findall("END=[0-9]+", info)[0].split("=")[1]
	return chr1, int(pos), chr2, int(end)

def collectLostDelly(infile, consensus, peaks):
	delly = []
	count = 0
	bnd_count = 0
	with open(infile, "r") as f:
		for line in f:
			if "#" not in line:
				fields = line.split("\t")
				if fields[2] not in consensus:
					added = False
					chr1, pos, chr2, end = extractDellyBreakend(line)
					for peak in peaks:
						if (peak.inPeak(chr1, pos) or peak.inPeak(chr2, end)) and not added:
							if chr1 == chr2 and end - pos >= 1000:
								delly.append(line)
								added = True
							elif chr1 != chr2:
								delly.append(line)
								added = True
								bnd_count += 1
							else:
								count += 1
	f.close()
	return delly

def extractMantaBreakend(line):
	fields = line.split("\t")
	chr1 = fields[0]
	pos = fields[1]
	if "BND" in line:
		chr2, end = extractFromAlt(fields[4])
	else:
		chr2 = chr1
		end = re.findall("END=[0-9]+", fields[7])[0].split("=")[1]
	return chr1, int(pos), chr2, int(end)

def collectLostManta(infile, consensus, peaks):
	manta = []
	count = 0
	bnd_count = 0
	with open(infile, "r") as f:
		for line in f:
			if "#" not in line:
				fields = line.split("\t")
				if fields[2] not in consensus:
					added = False
					chr1, pos, chr2, end = extractMantaBreakend(line)
					for peak in peaks:
						if (peak.inPeak(chr1, pos) or peak.inPeak(chr2, end)) and not added:
							if chr1 == chr2 and end - pos >= 1000:
								manta.append(line)
								added = True
							elif chr1 != chr2:
								manta.append(line)
								added = True
								bnd_count += 1
							else:
								count +=  1
	f.close()
	return manta

def extractLumpyBreakend(line):
	fields = line.split("\t")
	chr1 = fields[0]
	pos = fields[1]
	if "BND" in line:
		chr2, end = extractFromAlt(fields[4])
	else:
		chr2 = chr1
		end = re.findall(";END=[0-9]+", fields[7])[0].split("=")[1]
	return chr1, int(pos), chr2, int(end)

def collectLostLumpy(infile, consensus, peaks):
	lumpy = []
	count = 0
	bnd_count = 0
	with open(infile, "r") as f:
		for line in f:
			if "#" not in line:
				fields = line.split("\t")
				if fields[2] not in consensus:
					added = False
					chr1, pos, chr2, end = extractLumpyBreakend(line)
					for peak in peaks:
						if (peak.inPeak(chr1, pos) or peak.inPeak(chr2, end)) and not added:
							if chr1 == chr2 and end - pos >= 1000:
								lumpy.append(line)
								added = True
							elif chr1 != chr2:
								lumpy.append(line)
								added = True
								bnd_count += 1
							else:
								count += 1
	f.close()
	return lumpy

def collectLostSVs(vcfs, consensus_ids, peaks):
	delly, manta, lumpy = getFilename(vcfs)
	lostDelly = collectLostDelly(delly, consensus_ids["delly"], peaks)	
	lostManta = collectLostManta(manta, consensus_ids["manta"], peaks)
	lostLumpy = collectLostLumpy(lumpy, consensus_ids["lumpy"], peaks)
	lostSVs = {}
	lostSVs["delly"] = lostDelly
	lostSVs["manta"] = lostManta
	lostSVs["lumpy"] = lostLumpy
	return lostSVs

def writeOutput(vcf, lostSV_list, filename):
	with open(filename, "w") as out_file:
		with open(vcf, "r") as in_file:
			for line in in_file:
				if "#" in line:
					if "#CHROM" in line:
						out_file.write("##Rescued\n")
						out_file.write(line)
					else:
						out_file.write(line)
		in_file.close()
		for line in lostSV_list:
			out_file.write(line)
	out_file.close()

def writeAllOutput(vcfs, lostSVs, outdir):
	delly, manta, lumpy = getFilename(vcfs)
	writeOutput(delly, lostSVs["delly"], outdir + "/delly_rescued_" + delly.split("/")[-1] )
	writeOutput(manta, lostSVs["manta"], outdir + "/manta_rescued_" + manta.split("/")[-1] )
	writeOutput(lumpy, lostSVs["lumpy"], outdir +"/lumpy_rescued_" + lumpy.split("/")[-1] )
			

def main(args):
	parser = createParser()
	args = parser.parse_args()
	peaks = createPeakList(args.peaks, int(args.threshold))
	consensus_ids = collectConsensusIds(args.consensus, peaks)
	vcf = args.vcf
	vcfs = vcf.split(",")
	lostSVs = collectLostSVs(vcfs, consensus_ids, peaks)
	writeAllOutput(vcfs, lostSVs, args.outdir)


if __name__ == '__main__':
	sys.exit(main(sys.argv))



