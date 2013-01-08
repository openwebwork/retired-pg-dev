=head1 NAME

RserveClient.pl - Macros for querying an Rserve server (see R-project.org)

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

This file depends on the CPAN module Statistics::RserveClient.

The macros in this file set up a connection to the R server and
pass a string parameter to R for evaluation.  The resulting
vector is returned as a perl array object.

=cut

# This uses Statistics::RserveClient::Connection, but to play nicely
# with the Safe compartment, we load the module and all of its
# dependencies by specifying them in the modules configuration of
# defaults.config.  Hence the following line is commented out.

# Statistics::RserveClient::Connection;

#use strict;
#use warnings;

# Rserve connection
my $cnx;

sub _rserve_init {
};

sub rserve_start {
    if (!defined $cnx or ref($cnx) ne "Rserve::Connection") {
	$cnx = Rserve::Connection->new('localhost');
    }

    # Ensure R's random number generation is given a well-defined seed.
    # $problemSeed is the environmental variable defined by WeBWorK which
    # gives the random seed associated to a given problem/user assignment.
    $cnx->evalString("set.seed($problemSeed)");
}

sub rserve_finish {
    if (ref($cnx) eq "Rserve::Connection") {
	$cnx->close();
    }
}

sub rserve_eval { 
  my $query = shift; 

  if (ref($cnx) ne "Rserve::Connection") {
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

    my $filename = "";

    if ($imgtype eq 'png') {
	@filename_ref = rserve_eval('tempfile("tmpfile", tempdir(), ".png" )');
	$filename = $filename_ref[0];
	rserve_eval("png(filename='$filename')");
    }
    elsif ($imgtype eq 'jpg') {
	@filename_ref = rserve_eval('tempfile("tmpfile", tempdir(), ".jpg" )');
	$filename = $filename_ref[0];
	rserve_eval("jpeg(filename='$filename')");
    }
    elsif ($imgtype eq 'pdf') {
	@filename_ref = rserve_eval('tempfile("tmpfile", tempdir(), ".pdf" )');
	$filename = $filename_ref[0];
	rserve_eval("pdf(filename='$filename')");
    }
    else {
	warn "unknown/unsupported image type '$imgtype'\n";
    }
    return $filename;
}

sub rserve_finish_plot ($) {
    my $filepath = shift;

    @pathcomponents = split "/", $filepath;
    $file = $pathcomponents[@pathcomponents-1];

    my $imgfile = $tempDirectory . $file;

    rserve_eval("dev.off()");

    # $tempDirectory is a WeBWorK "environmental variable";
    $cnx-> evalStringToFile("readBin('$filepath', what='raw', n=1e6)", $imgfile);


    return $imgfile;
}

1;
