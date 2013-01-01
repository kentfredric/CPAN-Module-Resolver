use strict;
use warnings;

package CPAN::Module::Resolver::Backend::mirror;

has mirror_uri => ( is => rwp => required => 1 );

has home_dir => ( is => lazy => );
has _configured_home_dir => is => lazy =>;

sub env {
  my ( $self, $key ) = @_;
  return $ENV{ 'CPAN_MODULE_RESOLVER_' . $key };
}

sub _build_home_dir {
  my $self = shift;
  if ( $self->env('HOME') ) {
    return $self->env('HOME');
  }
  if ( $ENV{'HOME'} ) {
    return File::Spec->catdir( $ENV{'HOME'}, '.cpan_module_resolver' );
  }
}

sub _writable {
  my $dir = shift;
  my @dir = File::Spec->splitdir($dir);
  while (@dir) {
    $dir = File::Spec->catdir(@dir);
    if ( -e $dir ) {
      return -w _;
    }
    pop @dir;
  }

  return;
}

sub _build__configured_home_dir {
  my $self = shift;
  my $home = $self->home_dir;
  unless ( _writable($home) ) {
    die "Can't write to CPAN::Module::Resolver home '$home': You should fix it with chown/chmod first.\n";
  }
  return $home;
}
sub usable { 1; }

sub _02packages {
  my $self = shift;
  return sprintf '%s/modules/02packages.details.txt.gz', $self->mirror_uri;
}

sub source_for {
  my ( $self, $mirror ) = @_;
  $mirror =~ s/[^\w\.\-]+/%/g;

  my $dir = sprintf "%s/sources/%s", $self->_configured_home_dir, $mirror;
  File::Path::mkpath( [$dir], 0, 0777 );

  return $dir;
}

sub package_index_for {
  my ( $self, $mirror ) = @_;
  return $self->source_for($mirror) . "/02packages.details.txt";
}

sub _gzfile {
  my $self = shift;
  return;
}

sub resolve {

}
