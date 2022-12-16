#!/usr/bin/perl
use strict;

my %log;
my %processed;
my $id=0;
my $threshold=.73; #set the percentage of what each line of the file should match before considering it similar enough to roll up

my $arg_val=shift @ARGV; #set the percentage on the command line, overidding the default

$threshold=$arg_val, if (($arg_val > .01) && ($arg_val < 1.01)); #overide the default if command line is within bounds

my $first=1;
my $matched=1;

while (<>) {

   #s/^!.*?>(.*$)/$1/; #Uncomment and modify regex to remove any unnecessary prepended strings for better analysis
   #s/[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\.*\d*\s+//g; #Uncomment and modify regex to remove timestamps for better analysis

chomp(); #remove newline from input
my $logfile=$_;
my $temp=$logfile;

$temp=~s/\s+/ /g; #convert tabs and multiple spaces into a single space for readability
$temp=~s/=/ /g; #replace '=' with spaces to increase fidelity in calculating a percentage
#$temp=~s/\|/ /g; #replace '|' with spaces to increase fidelity in calculating a percentage
#$temp=~s/\// /g; #replace '/' with spaces to increase fidelity in calculating a percentage

my @match= split / /, $temp; #take each "word" and place it in an element of an array
my $element=scalar @match; #count the number of elements i.e. "words"
my $num_match=0;
my $perc;

if ($first) { #store the first log entry for comparison
  $log{$id}[0]=$logfile; #store the entire log file in hashed array [0]
  $first=0; #unset this flag, so that it doesn't keep storing log entries without first performing comparisons
} else {

   foreach my $hashid (keys (%log)) { #iterate over each stored log entry

      unless ($log{$hashid}[2] > 0) { #do this once
	 my $temp2=$log{$hashid}[0]; 
	 $temp2=~s/=/ /g;
	 $temp2=~s/\s+/ /g;
	 my @match2=split / /, $temp2;
	 $log{$hashid}[2]=scalar @match2; #place the number of words that are stored in [0] into hashed array [2] 
      }
	 my $diff = $element - $log{$hashid}[2]; #see if the number of words in the current log matches any of the words (off by 1 acceptable) in stored hash
	 abs ($diff);

      if ($diff <= 1) {
	 foreach my $one (@match) { #if the log entries are close in size, perform content matching
	    $one=~s/[\?\*\{\}\\+\]\[\$\@\(\)]/./g; #switch regex characters with a match all (.)
	    $num_match++, if ($log{$hashid}[0]=~/$one/); #count the number of matches
	 }
      } else {
	 next;
      }

   $perc = $num_match / $element, unless ($element ==0 ); #calculate the percent matched
   $num_match=0; #reset for next iteration

   if ($element < 15) { #if there are only 15 "words" lower the threshold for matching

      if ($perc > ($threshold - .10)) { #check if it meets the threshold
	 $log{$hashid}[1]+=1; #increase the number of similar message count
	 $matched=1; #it matched flag for use below
	 last;
      }
   } else {
      if ($perc > $threshold) { #check if it meets the threshold
	$log{$hashid}[1]+=1;
	$matched=1;
	last;
      }
   }

   }
unless ($matched) { #if it didn't match, move to the next hash element, and assign the next log entry unless it is empty
   $id++;
   $log{$id}[0]=$logfile, unless ("$logfile" eq "");
}
}

$matched=0;

} #End While

#display
foreach (sort Descend (keys (%log))) {
   print "[$log{$_}[1]] Similar Messages\n", if ($log{$_}[1] > 0);
   print "$log{$_}[0]\n\n\n", unless ("$log{$_}[0]" eq "");
}

sub Descend {
   $log{$b}[1] <=> $log{$a}[1];
}
