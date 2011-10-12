package stdsprun;
use JSON;
use Encode qw/decode _utf8_on _utf8_on is_utf8/;
use Data::Dumper;
use utf8;
require Exporter;
@ISA=qw/Exporter/;

@EXPORT=qw/stdspcall/;

#########################################################
############ db utility functions #######################
#########################################################
#{{{
use PHP::Serialization qw/unserialize/;
use List::MoreUtils qw/each_arrayref/;
use Memoize;
use strict;
my %seencrs;

sub get_json {
  my $json = JSON->new;
  return $json->utf8(0);
}
memoize('get_json');

sub unserialize_szd{#{{{
  my($val) = @_;
  return $val if !ref $val;

  if(ref $val eq 'ARRAY'){
   my @rv;
   for (@$val){
     push @rv, unserialize_szd($_);
   }
   return \@rv;
  }
  my $json = get_json();

  for my $k (keys %$val){                   
      $val->{$k} = unserialize $val->{$k} if $k =~ /_szd$/;
      $val->{$k} = $json->decode($val->{$k}) if $k =~ /_js$/;
      $val->{$k} = unserialize_szd($val->{$k}) if(ref $val->{$k});
  }
  return $val;
}#}}}

#}}}

sub handle_cursor{#{{{
    my($dbh, $cr) = @_;

    #return $dbh->selectall_arrayref(qq!fetch all from "$cr"!, {Columns=>{}});

    #$sth->execute;
    my @rv;
    my $passed=undef;
    my @crs;

    my $sth = $dbh->prepare(qq!fetch all from "$cr"!);
    $sth->execute;
    my $names = $sth->{NAME};
    my $types = $sth->{pg_type};

    while ( my $r = $sth->fetchrow_arrayref ){
       my $rh;
       for my $c (0 .. $sth->{NUM_OF_FIELDS}-1){
          if($types->[$c] eq 'refcursor'){
            if($seencrs{$r->[$c]}){
              $rh->{$names->[$c] } = $seencrs{ $r->[$c] };
            }else{
            	$rh->{$names->[$c] } = $seencrs{ $r->[$c] } = handle_cursor($dbh, $r->[$c]);
            }
          }else{
          	$rh->{ $names->[$c] } = $names->[$c]  =~ /_szd$/ ? unserialize_szd($r->[$c]) : $r->[$c];
          }
       }
       push @rv, $rh;
    }
    #$dbh->do(qq!move first in "$cr"!);
    return \@rv;
}#}}}


sub spcall{#{{{
    my($dbh, $str, @param) = @_;

    my %rv;
    my $sth = $dbh->prepare_cached($str);

    my($cr) = $dbh->selectrow_array($str, undef, @param);

    my $sth1 = $dbh->prepare(qq!fetch all from "$cr"!);
    $sth1->execute;
    my($rows) = $sth1->fetchrow_arrayref;
    return $rows if !$rows or !@$rows;
    my($cols) = [ @{ $sth1->{NAME} } ];
    my($types) = [ @{ $sth1->{pg_type} } ];

    my $ea = each_arrayref($cols, $rows, $types);
    while(my($k, $v, $t) = $ea->()){
      if(lc $t ne 'refcursor'){        
      	$rv{$k} = ($k =~ /_szd$/) ? unserialize_szd($v) : $v;
      }else{
        $rv{$k} = handle_cursor $dbh, $v;
        %seencrs=();
      }
    }
    $dbh->commit;

    return unserialize_szd(\%rv);
}#}}}

sub stdspcall{#{{{
  my($dbh, $q, $descr, @restparams) = @_;

  my(@params, @paramstr);

  $q = stdsprun::fakeCGI->new($q) if ref $q eq 'HASH';

  my($procname, $rest) = $descr =~ /^ \s* 
                                      (?:select\s+)?
                                      ([\w._]+)\s*\( #procname
                                      (.*) #rest
                                      \)\s*;?$/x;
  die "DBERR: Cannot parse description sting!" if !$procname;
  my $n = 1;
  for my $p ( map { [ split ' ' ] } split '\s*,\s*', $rest ){
    if(lc $p->[1] eq 'hstore' and lc $p->[0] eq 'cgi'){
      my @pairs;

      for my $p($q->param){
         my @vals = $q->param($p);
         $p =~ s/'/\\'/g;
         push @pairs, qq!('$p'=>\$$n)!;
         if (@vals==1){
          push @params, map{ $_ eq '' ? undef : $_  } @vals;
         }else{            
          #push @params, $dbh->quote(\@vals);
          push @params, \@vals;
         }
         $n++;
      }
      if(@pairs){
        push @paramstr, '(' . join('||', @pairs) . ')';
      }else{
        push @paramstr, q!('_dummy'=>'dummy')!;
      }
    }elsif(lc $p->[1] eq 'hstore'  and $p->[0] =~ /^\$/){
      my @pairs;
      my $hr = shift @restparams;

      for my $p(keys %$hr){
         my @vals = $hr->{$p};
         $p =~ s/'/\\'/g;
         push @pairs, qq!('$p'=>\$$n)!;
         if (@vals==1){
          push @params, @vals;
         }else{            
          push @params, $dbh->quote([@vals]);
         }
         $n++;
      }
      if(@pairs){
        push @paramstr, '(' . join('||', @pairs) . ')';
      }else{
        push @paramstr, q!('_dummy'=>'dummy')!;
      }
    }elsif($p->[0] =~ /^\$/){
      push @params, shift @restparams;
      push @paramstr, "\$$n";
      $n++;
    }elsif($p->[1] =~ /\[\]$/){
      push @params, $dbh->quote( $q->param($p->[0]) );
      push @paramstr, "\$$n";
      $n++;
    }else{
      my $val = $q->param($p->[0]);
      push @params,  $val;
      push @paramstr, "\$$n";
      $n++;
    }
  }
  return spcall($dbh, "select $procname(" . join(',', @paramstr) . ')', @params);
}#}}}


package stdsprun::fakeCGI; #{{{
  sub new{
     my $class = shift;
     return bless { %{ +shift } }, $class;
  }
  sub param{
    my $self = shift;
    my $p = shift;
    return $self->{$p} if $p;
    return keys %$self;
  }
  #}}}

1;
