#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Filter variants from the whitelist detector"
baseCommand: ["/usr/bin/perl", "whitelist_filter.pl"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'whitelist_filter.pl'
        entry: |
            #!/usr/bin/perl

            use strict;
            use warnings;

            use feature qw(say);

            die("Wrong number of arguments. Provide min_coverage, var_freq, whitelist_vcf, normal_cram, tumor_cram, output_vcf_file, set_filter_flag") unless scalar(@ARGV) == 7;
            my ($min_cov, $var_freq, $whitelist_vcf, $normal_cram, $tumor_cram, $output_vcf_file, $set_filter_flag) = @ARGV;

            my $samtools = '/usr/bin/samtools';
            my $normal_header_str = `$samtools view -H $normal_cram`;
            my $tumor_header_str  = `$samtools view -H $tumor_cram`;

            my ($normal_name) = $normal_header_str =~ /SM:([ -~]+)/;
            my ($tumor_name)  = $tumor_header_str =~ /SM:([ -~]+)/;

            unless ($normal_name and $tumor_name) {
                die "Failed to get normal_name: $normal_name from $normal_cram AND tumor_name: $tumor_name from $tumor_cram";
            }

            my $whitelist_vcf_fh;
            if($whitelist_vcf =~ /.gz$/){
                open($whitelist_vcf_fh, "gunzip -c $whitelist_vcf |") or die("couldn't open $whitelist_vcf to read");
            } else {
                open($whitelist_vcf_fh, $whitelist_vcf) or die("couldn't open $whitelist_vcf to read");
            }
            open(my $whitelist_out_fh, ">", "$output_vcf_file") or die("couldn't open $output_vcf_file for write");

            my ($normal_index, $tumor_index);

            while (<$whitelist_vcf_fh>) {
                chomp;
                if (/^##/) {
                    say $whitelist_out_fh $_;
                }
                elsif (/^#CHROM/) {
                    if ($set_filter_flag) {
                        say $whitelist_out_fh '##FILTER=<ID=WHITELIST_ONLY,Description="ignore whitelist variants">';
                    } else {
                        say $whitelist_out_fh '##FILTER=<ID=whitelist,Description="Found in provided whitelist">';
                    }
                    say $whitelist_out_fh '##FILTER=<ID=.,Description="Other">';
                    my @columns = split /\t/, $_;
                    my %index = (
                        $columns[9]  => 9,
                        $columns[10] => 10,
                    );
                    ($normal_index, $tumor_index) = map{$index{$_}}($normal_name, $tumor_name);
                    unless ($normal_index and $tumor_index) {
                        die "Failed to get normal_index: $normal_index for $normal_name AND tumor_index: $tumor_index for $tumor_name";
                    }
                    $columns[9]  = $normal_name;
                    $columns[10] = $tumor_name;
                    my $header = join "\t", @columns;
                    say $whitelist_out_fh $header;
                }
                else {
                    my @columns = split /\t/, $_;
                    my $quality = $columns[5]; #QualityScore. Error in parsing when "inf"
                    my @tumor_info = split /:/, $columns[$tumor_index];
                    my ($AD, $DP) = ($tumor_info[1], $tumor_info[2]);
                    next unless $AD;
                    my @AD = split /,/, $AD;
                    shift @AD; #the first one is ref count
                    
                    for my $ad (@AD) {
                        if ($ad > $min_cov and $ad/$DP > $var_freq and $quality != "inf") {
                            my ($normal_col, $tumor_col) = map{$columns[$_]}($normal_index, $tumor_index);
                            $columns[9]  = $normal_col;
                            $columns[10] = $tumor_col;
                            if ($set_filter_flag) {
                                $columns[6] = 'WHITELIST_ONLY';
                            }
                            else {
                                $columns[6] = 'whitelist';
                            }
                            my $new_line = join "\t", @columns;
                            say $whitelist_out_fh $new_line;
                            last;
                        }
                    }
                }
            }

            close($whitelist_vcf_fh);
            close($whitelist_out_fh);


arguments: [
    $(runtime.outdir)/whitelist_filtered_variants.vcf
]
inputs:
    whitelist_raw_variants:
        type: File
        inputBinding:
            position: -4
    normal_bam:
        type: File
        secondaryFiles: [.bai]
        inputBinding:
            position: -3
    tumor_bam:
        type: File
        secondaryFiles: [.bai]
        inputBinding:
            position: -2
    filter_whitelist_variants:
        type: boolean
        inputBinding:
            position: 1
            valueFrom: |
                ${
                  if(inputs.filter_whitelist_variants){
                    return "1";
                  } else {
                    return "0";
                  }
                }
    min_var_freq:
        type: float
        inputBinding:
            position: -5
    min_coverage:
        type: int
        inputBinding:
            position: -6
outputs:
    whitelist_filtered_variants:
        type: File
        outputBinding:
            glob: "whitelist_filtered_variants.vcf"

