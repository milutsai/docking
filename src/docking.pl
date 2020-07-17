#!/usr/bin/perl
use strict;
use warnings;
my $input = $ARGV[0];
if(@ARGV < 1){
    print STDERR "perl docking.pl input\n";die;
}
my $output = $input."_docking_results.txt";
my $receptor = "/mnt/Storage1/docking/docking/src/1TMP_1O5E_H.pdb";
open OUT,">",$output;
print OUT "Receptor\tLigand\tCenter_x\tCenter_y\tCenter_z\tsize_x\tsize_y\tsize_z\tdocking_score\n";
open IN,"<",$input;
my $line=<IN>;
while($line=<IN>){
    chomp $line;
    my @ele = split(/\t/,$line);
    my $cmpd_id = $ele[4];
    my $pubchem_id = $ele[5];
    my $ligand = "/mnt/Storage1/docking/tmprss2_structure/".$pubchem_id.".sdf";
    if(!-e $ligand){
        print OUT $ligand." does not exist\n";
    }
    my $outdir = "1TMP_1O5E_H_".$cmpd_id;
    my $cmd = "perl /mnt/Storage1/docking/docking/src/QVinaBlindDock.pl ".$receptor." ".$ligand." 5 ".$outdir;
    print STDERR $cmd."\n";
    `$cmd`;
    my $results = "/mnt/Storage1/docking/docking/docking_results/".$outdir."/docking_results.txt";
    my %results;
    my $min = 1;
    open RES,"<",$results;
    while(my $res_line=<RES>){
	if($res_line =~ /^Cavities/){
	    next;
	}
        my @res_ele = split(/\s+/,$res_line);
	my $score = $res_ele[8];
	if($score < $min){
	    $min = $score;
	}else{
	    next;
	}
	my $cen_x = $res_ele[2];
	my $cen_y = $res_ele[3];
	my $cen_z = $res_ele[4];
	my $size_x = $res_ele[5];
	my $size_y = $res_ele[6];
	my $size_z = $res_ele[7];
        $results{$score} = $cen_x."\t".$cen_y."\t".$cen_z."\t".$size_x."\t".$size_y."\t".$size_z;
    }
    close RES;
    print OUT $receptor."\t".$ligand."\t".$results{$min}."\t".$min."\n";
}
close IN;
