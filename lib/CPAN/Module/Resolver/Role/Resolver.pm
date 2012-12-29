
use strict;
use warnings;

package CPAN::Module::Resolver::Role::Resolver;

use Moo::Role;

has resolver => ( is => rwp => required => 1 );

sub backend_http { $_[0]->resolver->backend_http };
sub mirrors { $_[0]->resolver->mirrors };

requires resolve =>;

sub usable {
  return $_[0]->backend_http->usable();
}

sub _parse_meta_string {
  my ( $self, $string ) = @_;
  require Parse::CPAN::Meta;
  return eval { ( Parse::CPAN::Meta::Load($string) )[0] } || undef;
}

sub _cpan_dist {
  my ( $self, $dist, $url ) = @_;

  $dist =~ s!^([A-Z]{3})!substr($1,0,1)."/".substr($1,0,2)."/".$1!e;

  require CPAN::DistnameInfo;
  my $d = CPAN::DistnameInfo->new($dist);

  if ($url) {
    $url = [$url] unless ref $url eq 'ARRAY';
  }
  else {
    my $id = $d->cpanid;
    my $fn = substr( $id, 0, 1 ) . "/" . substr( $id, 0, 2 ) . "/" . $id . "/" . $d->filename;

    my @mirrors = @{ $self->mirrors };
    my @urls = map "$_/authors/id/$fn", @mirrors;

    $url = \@urls,;
  }

  return {
    $d->properties,
    source => 'cpan',
    uris   => $url,
  };
}

sub _cpan_module {
  my ( $self, $module, $dist, $version ) = @_;
  my $dist_obj = $self->_cpan_dist($dist);
  $dist_obj->{module} = $module;
  $dist_obj->{module_version} = $version if $version && $version ne 'undef';
  return $dist_obj;
}



1;
