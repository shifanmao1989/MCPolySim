#!/usr/bin/perl -w

#use strict;
#require 'calcVecs.pl';

# Converts coordinate into properly formatted pdb files
# Written by Andy Spakowitz 5-20-05

my $total=100;         # Total number of snapshots
my $skip=10;            # Skip number of snapshots

my $radius=1;           # Radius of chain
my $ratio=1;            # Resize ratio
my $snapcount=1;        # File count for output
my $filecount=1;        # File count for input

my $ratviz=0.2; # Ratio of visualization
my $lbox=10; # Box edge length

my $nbpbead=1;         # Number of bp per bead
my $nbpturn=10;         # Number of bp per turn
my $phidna=135;         # Rotation angle for the double helix
my $pi=3.14159265359;   # Value of pi
my $gamma=2*$pi*$nbpbead/$nbpturn; # Twist angle per bead

my $filein1;            # File with bead coordinates
my $fileout1;           # Output file for pdb

while($snapcount<=$total){

   if ($snapcount < 10)
   {
       $filein1="../../data/r$filecount";
       $fileout1=">pdb/snap00$snapcount.pdb";
   }
   elsif (($snapcount >= 10) && ($snapcount < 100))
   {
       $filein1="../../data/r$filecount";
       $fileout1=">pdb/snap0$snapcount.pdb";
   }
   else
   {
       $filein1="../../data/r$filecount";
       $fileout1=">pdb/snap$snapcount.pdb";
   }
   open(COORD1, $filein1) || die('cannot open file:'. $!);
   open(PDB1, $fileout1) || die('cannot open file:'. $!);

   my $count=1;

   # Array to hold positions of backbone
   my @atomx1;
   my @atomy1;
   my @atomz1;
   my @atomx4;
   my @atomy4;
   my @atomz4;
   my @ab;
   my @viz;

   while(<COORD1>){
      my @info = split;
      $atomx1[$count] = $ratio*$info[0];
      $atomy1[$count] = $ratio*$info[1];
      $atomz1[$count] = $ratio*$info[2];
      $ab[$count]=$info[3];
      
      $viz[$count]=0;
      if (($atomx1[$count] > $ratviz*$lbox) || ($atomx1[$count] < (1-$ratviz)*$lbox))
      {	 
	  $viz[$count]=1;
      }
      if (($atomy1[$count] > $ratviz*$lbox) || ($atomy1[$count] < (1-$ratviz)*$lbox))
      {
	  $viz[$count]=1;
      }
      if (($atomz1[$count] > $ratviz*$lbox) || ($atomz1[$count] < (1-$ratviz)*$lbox))
      { 
	  $viz[$count]=1;
      } 
      
      $count++;
	
   }
   my $nbead = $count-1;          # Index of last element in atomx1


   ##############################################################
   # Assemble single PDB file
   ##############################################################

   my $atomname1 = "A1";           # Chain atom type
   my $atomname2 = "A2";           # Ribbon atom type
   my $atomname3 = "A3";           # Extra atom type
   my $atomname4 = "A4";           # Extra atom type
   my $atomname5 = "A5";           # Extra atom type
   my $atomname6 = "A6";           # Extra atom type
   my $atomname7 = "A7";           # Extra atom type
   my $atomname8 = "A8";           # Extra atom type
   my $resname = "SSN";           # Type of residue (UNKnown/Single Stranded Nucleotide)
   my $chain = "A";               # Chain identifier
   my $resnum = "1";
   my $numresidues = $nbead;
   my $descrip = "Pseudo atom representation of DNA";
   my $chemicalname = "Body and ribbon spatial coordinates";
   
   # Het Header info
   printf PDB1 "HET    %3s  %1s%4d   %5d     %-38s\n",$resname,$chain,$resnum, $numresidues,$descrip ;
   printf PDB1 "HETNAM     %3s %-50s\n",$resname, $chemicalname;
   printf PDB1 "FORMUL  1   %3s    C20 N20 P21\n",$resname;

   $count=1;
   $ii=1;
   while ($ii <= $nbead) {
       if ($ab[$ii]==1 && $viz[$ii]==1) {
	   printf PDB1 "ATOM%7d %4s %3s %1s        %8.3f%8.3f%8.3f%6.2f%6.2f           C\n",$count,$atomname1,$resname,$chain,$atomx1[$ii],$atomy1[$ii],$atomz1[$ii],1.00,1.00;
       }
       if ($ab[$ii]==0 && $viz[$ii]==1) {
	   printf PDB1 "ATOM%7d %4s %3s %1s        %8.3f%8.3f%8.3f%6.2f%6.2f           C\n",$count,$atomname2,$resname,$chain,$atomx1[$ii],$atomy1[$ii],$atomz1[$ii],1.00,1.00;
       }

       $ii++;
       $count++;
   }

#   $ii=1;
#   my $color=0;
#   while ($ii <= $bp) {
#       $color=0*($ii-1)/($bp-1);
#       printf PDB1 "ATOM%7d %4s %3s %1s        %8.3f%8.3f%8.3f%6.2f%6.2f           C\n",$count,$atomname2,$resname,$chain,$atomx2[$ii],$atomy2[$ii],$atomz2[$ii],$color,$color;
#       $ii++;
#       $count++;
#   }

#   $ii=1;
#   while ($ii <= $bp) {
#       $color=0*($ii-1)/($bp-1);
#       printf PDB1 "ATOM%7d %4s %3s %1s        %8.3f%8.3f%8.3f%6.2f%6.2f           C\n",$count,$atomname3,$resname,$chain,$atomx3[$ii],$atomy3[$ii],$atomz3[$ii],$color,$color;
#       $ii++;
#       $count++;
#   }

# Connect up the ribbon

#   $ii=1;
#   $con=1;
#   while ($ii <= $nbead) {
#       if ($ii == 1) {
#           printf PDB1 "CONECT%5d%5d\n",$con,$con + 1;
#       } elsif (($ii > 1) && ($ii < $nbead)) {
#           printf PDB1 "CONECT%5d%5d%5d\n",$con,$con - 1, $con + 1;
#       } else {
#           printf PDB1 "CONECT%5d%5d\n",$con,$con - 1;
#       }
#       $con++;
#       $ii++;
#   }


#   $ii=1;
#   $con=1+$nbead;
#   while ($ii <= $bp) {
#       if ($ii == 1) {
#           printf PDB1 "CONECT%5d%5d%5d\n",$con,$con + 1,$con+$bp;
#       } elsif (($ii > 1) && ($ii < $bp)) {
#           printf PDB1 "CONECT%5d%5d%5d%5d\n",$con,$con - 1, $con + 1,$con+$bp;
#       } else {
#           printf PDB1 "CONECT%5d%5d%5d\n",$con,$con - 1,$con+$bp;
#       }
#       $con++;
#       $ii++;
#   }


#   $ii=1;
#   $con=1+$nbead+$bp;
#   while ($ii <= $bp) {
#       if ($ii == 1) {
#           printf PDB1 "CONECT%5d%5d%5d\n",$con,$con + 1,$con-$bp;
#       } elsif (($ii > 1) && ($ii < $bp)) {
#           printf PDB1 "CONECT%5d%5d%5d%5d\n",$con,$con - 1, $con + 1,$con-$bp;
#       } else {
#           printf PDB1 "CONECT%5d%5d%5d\n",$con,$con - 1,$con-$bp;
#       }
#       $con++;
#       $ii++;
#   }

   printf PDB1 "END";
   # Clean up and close files

   close(PDB1);
   close(COORD1);
   $snapcount++;
   $filecount=$filecount+$skip;
}

###########################################################################
sub arccos
{
    atan2( sqrt(1.0 - $_[0] * $_[0]), $_[0] );
}

###########################################################################

