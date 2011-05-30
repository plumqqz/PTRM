use strict;
use DBI;
use PTRM;
my $tmdbh = DBI->connect('dbi:Pg:dbname=ptm', 'postgres','postgres', {AutoCommit=>0, RaiseError=>1});
#PTRM::recover($tmdbh, 'test');
PTRM::recoverdied($tmdbh);
$tmdbh->commit;
$tmdbh->disconnect;