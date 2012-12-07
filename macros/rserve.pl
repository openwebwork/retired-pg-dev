use Rserve::Connection;
#use strict;
#use warnings;

# Rserve connection
my $cnx;

sub _rserve_init {};

#sub rserve_start {
#   $cnx = Rserve::Connection->new('localhost');
#}

#sub rserve_finish {
#    if (ref($cnx)=="Rserve::Connection") {
#	$cnx->close();
#    }
#}

#sub rserve_eval { 
#  my $query = shift; 
#  my @res = $cnx->evalString($query);
#  return @res;
#}

#sub rserve_query {
#  my $query = shift; 
#  my $rserve_client = Rserve::Connection->new('localhost');
#  my @res = $rserve_client->evalString($query);
#  #print ("result = $res");
#  return @res;
#}

#sub rserve_plot_png {
#}

1;
