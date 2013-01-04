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

	my $resolver = CPAN::Module::Resolver->new(
		order => [qw( metacpan cpanmetadb search_cpan_org )],		# uses first successful result.
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

has _fetch_method     => ( is => lazy => isa => \&_code_ref );
has _get_method       => ( is => lazy => isa => \&_code_ref );
has _mirror_method    => ( is => lazy => isa => \&_code_ref );
has _tempdir          => ( is => lazy => isa => \&_scalar );
has _tempdir_basedir  => ( is => lazy => isa => \&_scalar );
has _tempdir_template => ( is => lazy => isa => \&_scalar );

sub _build_order { return [qw( cpanmetadb search_cpan_org )]; }
sub _build__tempdir { return File::Temp::tempdir( $_[0]->_tempdir_template, CLEANUP => 1, DIR => $_[0]->_tempdir_basedir ) }
sub _build__tempdir_basedir  { return File::Spec->rel2abs( File::Spec->tmpdir() ) }
sub _build__tempdir_template { return 'CPAN_Module_Resolver.XXXX' }

sub _build__fetch_method {
  my ( $self, ) = @_;
  return sub {
    my $fetch = File::Fetch->new( uri => $_[0] );
	die unless defined $fetch;
	
    my $where = $fetch->fetch( to => $self->_tempdir() );
    my $error = $fetch->error();
    return ( undef,  $error ) if $error;
    return ( $where, undef )  if $where;
    return ( undef,  "No Where returned" );
    };
}

sub _build__get_method {
  my $self = shift;
  return sub {
    my ($uri) = @_;
    my $fetch_method = $self->_fetch_method();
    my ( $file, $error ) = $fetch_method->($uri);
    return if $error;
    open my $fh, '<', $file;
    local $/;
    return <$fh>;
  };
}

sub _build__mirror {
  my $self = shift;
  return sub {
    my ( $uri, $target ) = @_;
    my $fetch_method = $self->_fetch_method();
    my ( $file, $error ) = $fetch_method->($uri);
    return $error if $error;
	if ( $file  ne $target ) {
	    require File::Copy;
    	File::Copy::copy( $file, $target );
	}
  };
}

sub resolve {
  my ( $self, $module ) = @_;
  for my $backend ( @{ $self->order } ) {
    my $fqmn = Module::Runtime::compose_module_name( 'CPAN::Module::Resolver::Backend', $backend );
    next unless eval { Module::Runtime::require_module($fqmn) };
    my $intance = $fqmn->new(
      _get    => sub { goto $self->_get_method },
      _mirror => sub { goto $self->_mirror_method },
    );
  }
  return $self->_iterator->each_usable_backend( sub { return $_->resolve($module) } );
}

sub _scalar { defined $_[0] and not ref $_[0] or croak('must be a scalar') }
sub _array_ref { ref $_[0] eq 'ARRAY' or croak('must be an array ref') }
sub _module_name { Module::Runtime::check_module_name( $_[0] ) }
sub _hash_ref    { ref $_[0] eq 'HASH' or croak('must be a hash ref') }
sub _blessed_ref { ref $_[0] and blessed( $_[0] ) or croak('must be an object') }
sub _code_ref    { ref $_[0] and ref $_[0] eq 'CODE' or croak('must be a code ref') }
1;
