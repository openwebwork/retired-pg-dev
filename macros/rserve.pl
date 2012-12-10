=head1 NAME

rserve.pl - Macros for querying an Rserve server (see R-project.org)

=head1 SYNPOSIS

Example: generate a normally distributed vector of 15 elements,
with mean 1, standard deviation 2, rounded to 4 decimal places.

 $m = 1;
 $sd = 2;
 @rnorm = rserve_query(EV2(<<END_RCODE));
   data1=rnorm(15,mean=$m,sd=$sd)
   round(data1,4)
 END_RCODE

=head1 DESCRIPTION

The macros in this file set up a connection to the R server and
pass a string parameter to R for evaluation.  The resulting
vector is returned as a perl array object.

=cut

use Rserve::Connection;
#use strict;
#use warnings;

# Rserve connection
my $cnx;

sub _rserve_init {
};

sub rserve_start {
    if (!defined $cnx or ref($cnx) != "Rserve::Connection") {
	$cnx = Rserve::Connection->new('localhost');
    }

    # Ensure R's random number generation is given a well-defined seed.
    # $problemSeed is the environmental variable defined by WeBWorK which
    # gives the random seed associated to a given problem/user assignment.

    my $query = "set.seed($problemSeed)\n";
    $cnx->evalString($query);
}

sub rserve_finish {
    if (ref($cnx)=="Rserve::Connection") {
	$cnx->close();
    }
}

sub rserve_eval { 
  my $query = shift; 

  if (ref($cnx) != "Rserve::Connection") {
      $cnx = Rserve::Connection->new('localhost');
  }
  my @res = $cnx->evalString($query);
  return @res;
}


sub rserve_query {
  my $query = shift; 
  $query = "set.seed($problemSeed)\n" . $query;
  my $rserve_client = Rserve::Connection->new('localhost');
  my @res = $rserve_client->evalString($query);
  #print ("result = $res");
  return @res;
}

sub rserve_start_plot ($) {
    my $imgtype = shift;
    my $rand = sprintf("%05d", random(0, 99999, 1));

    my $filename = "tmpfile".$rand;

    if ($imgtype == 'png') {
	$suffix = ".png";
	$filename .=  $suffix;
	rserve_eval("png(filename='/tmp/$filename')");
    }
    elsif ($imgtype = 'jpg') {
	$suffix = ".jpg";
	$filename .=  $suffix;
	rserve_eval("jpeg(filename='/tmp/$filename')");
    }
    elsif ($imgtype = 'pdf') {
	$suffix = ".pdf";
	$filename .=  $suffix;
	rserve_eval("pdf(filename='/tmp/$filename')");
    }
    else {
	warn "unknown/unsupported image type '$imgtype'\n";
    }

    return $filename;
}

sub rserve_finish_plot ($) {
    my $file = shift;
    my $filename = $tempDirectory . "/$file";

    rserve_eval("dev.off()");
    @stream = rserve_eval("readBin('/tmp/$file', what='raw', n=1e6)");

    open BINARY, ">:raw", $filename;
    foreach (@stream) { print BINARY $_}
    close BINARY;
    
    return $filename;
}

1;
