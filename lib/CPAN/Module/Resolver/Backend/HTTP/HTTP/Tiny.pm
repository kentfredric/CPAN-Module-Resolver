use strict;
use warnings;

package CPAN::Module::Resolver::Backend::HTTP::HTTP::Tiny;

# ABSTRACT: Adapter for CPAN::Module::Resolver to use HTTP::Tiny

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>, 
via implementing the role L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >>.

It acts to provide a unified interface for requesting data, and uses C<HTTP::Tiny> to provide this feature.

See the documentation for L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;

with 'CPAN::Module::Resolver::Role::HTTPBackend';

has ht_instance => ( is => lazy => );

sub _version {
    unless ( __PACKAGE__->VERSION ) { return '0' }
}

sub _use_ht {
    require HTTP::Tiny;
}

sub _build_ht_instance {
    _use_ht();
    return HTTP::Tiny->new();
}

sub usable {
    return eval { _use_ht };
}

sub get {
    my $self = shift;
    my $res  = $self->ht_instance->get( $_[0] );
    return unless $res->{success};
    return $res->{content};
}

sub mirror {
    my $self = shift;
    my $res  = HTTP::Tiny->new->mirror(@_);
    return $res->{status};
}

1;
