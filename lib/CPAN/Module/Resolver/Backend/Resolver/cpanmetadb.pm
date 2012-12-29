use strict;
use warnings;

package CPAN::Module::Resolver::Backend::Resolver::cpanmetadb;
use Moo;

with 'CPAN::Module::Resolver::Role::Resolver';


sub resolve {
	my ( $self, $module ) = @_;
	my $uri = sprintf 'http://cpanmetadb.plackperl.org/v1.0/package/%s', $module;
	my $yaml = $self->backend_http->get( $uri );
	my $meta = $self->_parse_meta_string( $yaml );
	if ( $meta && $meta->{distfile} ){ 
		return $self->_cpan_module( $module, $meta->{distfile}, $meta->{version} );
	}
	return;
}

1;
