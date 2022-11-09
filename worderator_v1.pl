#!/usr/bin/perl
#
# USAGE: worderator.pl inputfile.tbl
#
use strict;
use warnings;
use Data::Dumper;
use Benchmark;

#
## VARS section

# "global" vars for the script
my %pairs = ();
my @timestamp = new Benchmark;

# start program by reading and checking
# arguments provided by user at command-line
scalar(@ARGV) == 1 ||
    die("### ARGV ERROR ### USAGE: worderator.pl inputfile.tbl\n");

print STDERR "# Input file is: $ARGV[0]\n";

# reading arguments
my $inputfile = shift @ARGV;

# other vars
my $fileprefix = $inputfile;
$fileprefix =~ s/\.tbl$//;

print STDERR "# Output files prefix is: $fileprefix\n";

#
## MAIN PROGRAM
#

print STDERR "## Running $0 -- $ENV{USER} -- PID $$\n";

#
# STEP 1.- Reading the pairs form a file into a graph.
#          We will use a hash to build the grpah data structure.

if (-e $inputfile) {
    print STDERR "$inputfile is there!!!\n";
} else {
    print STDERR "### ERROR ### $inputfile NOT FOUND!!!\n";
    exit(1);
};

open(WORDS, $inputfile) ||
    die("### ERROR ### Cannot open file $inputfile\n");

print STDERR "## Reading data from $inputfile\n";

my @words;
while (<WORDS>) {
    # when using diamond operator lines are stored
    # in the anonymous scalar variable $_

    chomp;                     # 'enough power\n' -> 'enough power'
    @words = split /\s+/, $_;  # 'enough power'   -> ( 'enough', 'power' )
    
    print STDERR "$. : $words[0] -> $words[1]\n";
    
    $pairs{$words[0]} = $words[1];
        
}; # while WORDS

close(WORDS);

# print STDERR Data::Dumper->Dump([ \%pairs ],[ qw/ *PAIRS / ]),"\n";

#
# STEP 2.- Processing the graph (hash-based data structure)

#
# saving word pairs relations as a graph
# we will use the DOT language notation
# as defined by the GraphViz project:
#    https://graphviz.org/documentation/
#

my $dotfile = $fileprefix . ".dot";

print STDERR "# Saving word pairs as graph elements into dot file $dotfile\n";

open(DOTFILE, "> $dotfile") ||
    die("### ERROR ### Cannot open dot file: $dotfile\n");

print DOTFILE "digraph G {\n".
              "\tnode [ style=filled fillcolor=\"white\" ];\n";

##NOTE## I have added some styles/labels to nodes and edges
my %colored = ();
my $p = 0;
foreach my $word (keys %pairs) {

    if (($word =~ /^\./ || $word =~ /\.\.\.$/)
        && !exists($colored{$word})) {
            $colored{$word} = 1;
            print DOTFILE "\t\"$word\" [fillcolor=\"darkolivegreen1\"];\n";
    };
    if (($pairs{$word} =~ /^\./ || $pairs{$word} =~ /\.\.\.$/)
        && !exists($colored{$pairs{$word}})) {
            $colored{$pairs{$word}} = 1;
            print DOTFILE "\t\"$pairs{$word}\" [fillcolor=\"darkolivegreen1\"];\n";
    };
    if ($word =~ /[^\.]\.\.$/
        && !exists($colored{$word})) {
            $colored{$word} = 1;
            print DOTFILE "\t\"$word\" [fillcolor=\"palegoldenrod\"];\n";
    };

    # printing the edge relationship (now labeled)
    print DOTFILE "\t\"$word\" -> \"$pairs{$word}\" [label=\"".++$p."\"]\n";
    
}; # foreach $word

print DOTFILE "}\n";

close(DOTFILE);

#
# STEP 3.- Run another tool to plot the graph

#
# Now, we are going to run the command-line program
# from the GraphViz distribution to convert
# the dot file in a graphical representation
# of the pairs of words graph as a PNG image.
#
# If you do not have graphviz installed
# you can run this on Linux:
#
#    sudo apt-get install graphviz
#
# Or the following on a MacOS with brew:
#
#    brew install graphviz
# 
# Further details to install from source
# or other into systems can be found at:
#    https://graphviz.org/download/
#
# On the command-line one should run something like this:
#
#   dot -v -Tpng pairs_of_words_short.dot \
#              > pairs_of_words_short.png
#
# In Perl we can run other programs with system function...

print STDERR "# Drawing graph structure with GraphViz dot\n";

system("dot -v -Tpng $dotfile " .
                  "> $fileprefix.png " .
                 "2> $dotfile.log");
    
#

push @timestamp, new Benchmark;

print STDERR "## $0 has finished - took ",
             timestr(timediff($timestamp[1], $timestamp[0])),
             "\n";

exit(0);

### END OF PROGRAM ###
