use strict;
use DBI;
use PTRM;
my $tmdbh = DBI->connect('dbi:Pg:dbname=ptm', 'postgres','postgres', {AutoCommit=>0, RaiseError=>1});
PTRM::recoverdied($tmdbh);
my $tmname = PTRM::gettemptmname($tmdbh);
PTRM::transaction($tmname, $tmdbh,
                  [
                    [ 'dbi:Pg:dbname=db1', 'postgres','postgres', {AutoCommit=>0, RaiseError=>1} ],
                    [ 'dbi:Pg:dbname=db2', 'postgres','postgres', {AutoCommit=>0, RaiseError=>1} ],
                  ],
                  \&dotransfer
                 );
PTRM::deletetemptmname($tmdbh, $tmname);
$tmdbh->commit();
$tmdbh->disconnect;

sub dotransfer{
  my(@dbhs) = @_;
  my $dbh1 = $dbhs[0]{dbh};
  my $dbh2 = $dbhs[1]{dbh};

  for(@{ $dbh1->selectall_arrayref('select * from test', {Columns=>{}}) }){
    $dbh2->do('insert into test(id, value) values($1,$2)', undef, $_->{id}, $_->{value});
  }
  die 'here';
  $dbh1->do('delete from test');
  return 1;
}