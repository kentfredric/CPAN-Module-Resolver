use strict;
use warnings;

package CPAN::Module::Resolver;

# ABSTRACT: Resolve module names to the dists they are contained in

=head1 DESCRIPTION

There are many ways to resolve what package a module is contained in, and this is a primary feature of any CPAN Client.

This module simply aims to unify all the different ways of doing it via one simple interface:

	use CPAN::Module::Resolver;

	my $resolver = CPAN::Module::Resolver->new();
	my $result   = $resolver->resolve('Moose');

	for my $uri ( $result->uris  ){
		print "$uri\n";
	}

And this does a many things automatically to make life easier:

=item * Automatically uses available web services to query the results, using one of

=over 6

=item * cpanmetadb

=item * metacpan api

=item * searching search.cpan.org

=back

=back

And additionally, you can choose which HTTP backend to use, and which query interface to call.

	my $resolver = CPAN::Module::Resolver->new(
		backend_http_order    => [qw( LWP wget curl fake )],   						# uses the first one that works
		backend_resolve_order => [qw( metacpan cpanmetadb search_cpan_org )],		# uses first successful result.
	);


Most the code at present is stolen from bits of the ever popular L<< C<cpanm>|App::cpanminus >>

=cut

use Moo;
use Module::Runtime qw();
use Carp qw( carp croak );
use Scalar::Util qw( blessed );
use File::Fetch;
use File::Temp;

use CPAN::Module::Resolver::BackendIterator;

has order => ( is => lazy =>, isa => \&_array_ref );
has _iterator => ( is => lazy => isa => \&_blessed_ref );

sub _build_order { return [qw( cpanmetadb search_cpan_org )]; }

my $tempdir;

sub tempdir {
  return $tempdir if $tempdir;
  return $tempdir =
    File::Temp::tempdir( 'CPAN_Module_Resolver.XXXX', CLEANUP => 1, DIR => File::Spec->rel2abs( File::Spec->tmpdir() ) );
}

sub _fetch {
  my ($uri) = @_;
  my $fetch = File::Fetch->new( uri => $uri );
  my $where = $fetch->fetch( to => tempdir() );
  my $error = $fetch->error();
  return ( undef,  $error ) if $error;
  return ( $where, undef )  if $where;
  return ( undef,  "No Where returned" );
}

sub _get {
  my ($uri) = @_;
  my ( $file, $error ) = _fetch($uri);
  return if $error;
  open my $fh, '<', $file;
  local $/;
  return <$fh>;
}

sub _mirror {
  my ( $uri,  $target ) = @_;
  my ( $file, $error )  = _fetch($uri);
  return $error if $error;
  File::Copy::copy( $file, $target );
}

sub _build__iterator {
  my $self = shift;
  return CPAN::Module::Resolver::BackendIterator->new(
    order       => $self->order,
    common_args => [
      _backend_get    => \&_get,
      _backend_mirror => \&_mirror,
    ],
    label          => 'resolver',
    backend_prefix => 'CPAN::Module::Resolver::Backend',
  );
}

sub resolve {
  my ( $self, $module ) = @_;
  return $self->_iterator->each_usable_backend( sub { return $_->resolve($module) } );
}

sub _array_ref { ref $_[0] eq 'ARRAY' or croak('must be an array ref') }
sub _module_name { Module::Runtime::check_module_name( $_[0] ) }
sub _hash_ref    { ref $_[0] eq 'HASH' or croak('must be a hash ref') }
sub _blessed_ref { ref $_[0] and blessed( $_[0] ) or croak('must be an object') }

1;
