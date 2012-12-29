use strict;
use warnings;

package CPAN::Module::Resolver::Result;

# ABSTRACT: A Resolution Result from CPAN::Module::Resolver

=head1 DESCRIPTION

This is mostly a proxy wrapper around L<CPAN::DistnameInfo>, with a few utility functions and extra fields.

	my $result = CPAN::Module::Resolver::Result->new( module => "Moose", dist => "D/DO/DOY/Moose-2.0604.tar.gz" , version => "2.0604" );
	Data::Dump::pp( $result->as_hash() );
	# {
	#   '_dist' => 'D/DO/DOY/Moose-2.0604.tar.gz',
	#   '_distname_info' => bless( {
	#     'cpanid' => 'DOY',
	#     'dist' => 'Moose',
	#     'distvname' => 'Moose-2.0604',
	#     'extension' => 'tar.gz',
	#     'filename' => 'Moose-2.0604.tar.gz',
	#     'maturity' => 'released',
	#     'pathname' => 'D/DO/DOY/Moose-2.0604.tar.gz',
	#     'version' => '2.0604'
	#   }, 'CPAN::DistnameInfo' ),
	#   '_mirrors' => [
	#     'http://www.cpan.org'
	#   ],
	#   '_uris' => [
	#     'http://www.cpan.org/authors/id/D/DO/DOY/Moose-2.0604.tar.gz'
	#   ],
	#   'cpanid' => 'DOY',
	#   'dist' => 'Moose',
	#   'distvname' => 'Moose-2.0604',
	#   'extension' => 'tar.gz',
	#   'filename' => 'Moose-2.0604.tar.gz',
	#   'maturity' => 'released',
	#   'module' => 'Moose',
	#   'module_version' => '2.0604',
	#   'pathname' => 'D/DO/DOY/Moose-2.0604.tar.gz',
	#   'source' => 'cpan',
	#   'version' => '2.0604'
	# }

All properties listed above can be accessed via accessors.

ie:

	$result->cpanid . '/' . $result->distvname # DOY/Moose-2.0604

=cut



use Moo;

my (@_distname_info_properties) = qw(dist version maturity filename cpanid distvname extension pathname);
my (@_own_properties)           = qw(module _dist module_version _uris _mirrors _distname_info source);

=method module

Returns the argument specified via C<< ->new( module => >>

	my $module = $result->module();

=carg module

The name of the module this result set is a result for.


=method has_module_version

Returns wether or not a module version was detected upstream for the specified module.

ie: Presently, this returns false for Moo::Role, because Moo::Role does not define $VERSION

=cut

=method module_version

Returns the argument specified via C<< ->new( version => >>

	my $module_version = $result->module_version();

=carg version

The "latest" version of the module requested, as defined by the resolution service.

=cut

has module => ( is => rwp => required => 1 );
has module_version => ( is => rwp => init_arg => version =>, predicate => has_module_version => );

=pmethod _dist

Returns the argument specified via C<< ->new( dist => >>

	my $distname = $result->_dist();

=carg dist

A distribution name in either the form 

	A/AA/AAARGUMENTS/Foo-1.2.3.tar.gz

or

	AAARGUMENTS/Foo-1.2.3.tar.gz


=pmethod _uris 

An Array of URI's this distribution can be found at.

( Expanded with C<_mirrors> ) 

=carg uris

An array of URI's this distribution can be found at.

By default, you should not provide this value, and instead rely on mirror expansion.

ie:

	->new(
		uris => [ 'path/to/foo.tar.gz' ],
	);

=pmethod _mirrors 

An array of CPAN Mirrors to use for URI generation.

=carg mirrors

An array of CPAN Mirrors to use for URI generation.

ie:

	->new(
		mirrors => [ 'www.cpan.org', 'cpan.metacpan.org' ]
	);

=pmethod _distname_info 

=cut

has _dist => ( is => rwp => required => 1, init_arg => dist => );
has _uris    => ( is => lazy =>, init_arg => uris    => );
has _mirrors => ( is => lazy =>, init_arg => mirrors => );
has _distname_info => ( is => lazy => handles => [@_distname_info_properties] );

=method source

Always returns 'cpan'

=method uris

Returns L</_uris> as a list

	for my $uri ( $result->uris ) {
	}

=cut

sub source { 'cpan' }
sub uris   { @{ $_[0]->_uris } }

=pmethod _build__mirrors

	['http://www.cpan.org']
	
=cut

sub _build__mirrors { return ['http://www.cpan.org'] }

=pmethod _build__uris

=cut

sub _build__uris {
  my $self = shift;
  my $id   = $self->cpanid;
  my $fn   = substr( $id, 0, 1 ) . "/" . substr( $id, 0, 2 ) . "/" . $id . "/" . $self->filename;
  return [ map { "$_/authors/id/$fn" } @{ $self->_mirrors } ];
}

=pfunc _expand_authorpath

	_expand_authorpath('ABCDEF/Foo.gz') => 'A/AB/ABCDEF/Foo.gz'

=cut

sub _expand_authorpath {
  my ($authorpath) = shift;
  return sprintf '%s/%s/%s', substr( $authorpath, 0, 1 ), substr( $authorpath, 0, 2 ), $authorpath;
}

=pmethod _build__distname_info

=cut

sub _build__distname_info {
  my $self = shift;
  my $dist = $self->_dist;
  $dist = _expand_authorpath($dist) if $dist =~ /^[A-Z]{3}/;
  require CPAN::DistnameInfo;
  return CPAN::DistnameInfo->new($dist);
}
=method as_hash

Returns all useful properties as values in an hash

=cut
sub as_hash {
  my $self = shift;
  return { ( map { $_, $self->$_() } @_distname_info_properties ), ( map { $_, $self->$_() } @_own_properties ), };
}

1;

