#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: ['/usr/bin/perl', 'split_interval_list_to_bed_helper.pl']
requirements:
    - class: ResourceRequirement
      ramMin: 6000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'split_interval_list_to_bed_helper.pl'
        entry: |
            use strict;
            use warnings;

            use feature qw(say);

            my ($output, $input, $scattercount) = @ARGV;
            my ($prefix, $count) = split /=/, $scattercount;
            # If > 1, OUTPUT= points to a directory and needs to be handled
            # else point output to a file
            if($count>1) {
              my $retval = system('/usr/bin/java', '-jar', '/usr/picard/picard.jar', 'IntervalListTools', @ARGV);
              exit $retval if $retval != 0;

              my $i = 1;
              for my $interval_list (glob('*/scattered.interval_list')) {
                  my $bed = $i.'.interval.bed';
                  open(my $in_fh, $interval_list) or die "fail to open $interval_list for read";
                  open(my $out_fh, ">$bed") or die "fail to write to $bed";
                  while (<$in_fh>) {
                      next if /^@/;
                      my ($chr, $start, $stop) = split /\t/, $_;
                      $out_fh->say(join("\t", $chr, $start-1, $stop));
                  }
                  close $in_fh;
                  close $out_fh;
                  $i++
              }
            }else{
              $output = "${output}/1.interval_list";
              my $retval = system('/usr/bin/java', '-jar', '/usr/picard/picard.jar', 'IntervalListTools', $output, $input, $scattercount); 
              my $bed = "1.interval.bed";
              open(my $in_fh, "1.interval_list") or die "fail to open 1.interval_list for reading";
              open(my $out_fh, ">$bed") or die "fail to write to $bed";
              while (<$in_fh>) {
                  next if /^@/;
                  my ($chr, $start, $stop) = split /\t/, $_;
                  $out_fh->say(join("\t", $chr, $start-1, $stop));
              }
              close $in_fh;
              close $out_fh; 
            }

arguments:
    [{ valueFrom: OUTPUT=$(runtime.outdir) }]
inputs:
    interval_list:
        type: File
        inputBinding:
            prefix: "INPUT="
            separate: false
            position: 1
    scatter_count:
        type: int
        inputBinding:
            prefix: "SCATTER_COUNT="
            separate: false
            position: 2
outputs:
    split_beds:
        type: File[]
        outputBinding:
            glob: "*.interval.bed"
