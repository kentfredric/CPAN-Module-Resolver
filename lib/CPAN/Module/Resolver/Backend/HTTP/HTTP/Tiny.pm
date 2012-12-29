use strict;
use warnings;

package CPAN::Module::Resolver::Backend::HTTP::HTTP::Tiny;

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