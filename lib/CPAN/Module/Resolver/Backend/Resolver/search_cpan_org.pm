
use strict;
use warnings;

package CPAN::Module::Resolver::Backend::Resolver::search_cpan_org;

use Moo;
with 'CPAN::Module::Resolver::Role::Resolver';

sub resolve {
    my ( $self, $modname ) = @_;

    my $uri  = "http://search.cpan.org/perldoc?$modname";
    my $html = $self->backend_http->get($uri);
    $html =~ m!<a href="/CPAN/authors/id/(.*?\.(?:tar\.gz|tgz|tar\.bz2|zip))">!
      and return $self->_cpan_module( $modname, $1 );
    return;
}

1;
