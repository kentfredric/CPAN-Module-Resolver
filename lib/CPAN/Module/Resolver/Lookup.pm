
use strict;
use warnings;

package CPAN::Module::Resolver::Lookup;
BEGIN {
  $CPAN::Module::Resolver::Lookup::AUTHORITY = 'cpan:KENTNL';
}
{
  $CPAN::Module::Resolver::Lookup::VERSION = '0.1.0';
}

# ABSTRACT: A container for a lookup query



use Class::Tiny (qw( module )), {};

sub latest_by_module {
  return $_[0]->new( module => $_[1] );
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

CPAN::Module::Resolver::Lookup - A container for a lookup query

=head1 VERSION

version 0.1.0

=head1 SYNOPSIS

    my $lookup = CPAN::Module::Resolver::Lookup->latest_by_module('Moose');
    my $result = SOME_LOOKUP_ENGINE->resolve($lookup);

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver::Lookup",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
