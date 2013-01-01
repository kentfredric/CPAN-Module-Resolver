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

use CPAN::Module::Resolver::BackendIterator;

sub _array_ref { ref $_[0] eq 'ARRAY' or croak('must be an array ref') }
sub _module_name { Module::Runtime::check_module_name( $_[0] ) }
sub _hash_ref    { ref $_[0] eq 'HASH' or croak('must be a hash ref') }
sub _blessed_ref { ref $_[0] and blessed( $_[0] ) or croak('must be an object') }

has resolve_order => ( is => lazy =>, isa => \&_array_ref );
has resolve_args  => ( is => lazy =>, isa => \&_hash_ref );
has _resolve_iterator => ( is => lazy => isa => \&_blessed_ref );

sub _build_resolve_order { return [qw( cpanmetadb search_cpan_org )]; }
sub _build_resolve_args { return {} }

sub _get {
  my ($uri) = @_;
  my $fetch = File::Fetch->new( uri => $uri );
  if ( not $fetch ){
  	warn "No object";
	return;
  }
  my $output;
  my $where = $fetch->fetch( to => \$output );
  if ( my $error = $fetch->error(1) ) {
    warn $error;
    return;
  }
  return unless $where;
  return unless $output;
   return $output;
}

sub _mirror {
  my ( $uri, $target ) = @_;
  my $fetch = File::Fetch->new( uri => $uri );
  if ( not $fetch ){
  	warn "No object";
	return;
  }
  my $where = $fetch->fetch( to => $target);
  return unless $where;
  if ( my $error = $fetch->error(1) ) {
    warn $error;
    return;
  }
  return 1;
}

sub _build__resolve_iterator {
  my $self = shift;
  return CPAN::Module::Resolver::BackendIterator->new(
    order       => $self->resolve_order,
    args        => $self->resolve_args,
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
  return $self->_resolve_iterator->each_usable_backend( sub { return $_->resolve($module) } );
}
1;
