
use strict;
use warnings;

package CPAN::Module::Resolver::Role::Resolver;
BEGIN {
  $CPAN::Module::Resolver::Role::Resolver::AUTHORITY = 'cpan:KENTNL';
}
{
  $CPAN::Module::Resolver::Role::Resolver::VERSION = '0.1.0';
}

# ABSTRACT: An interface for module resolving for CPAN::Module::Resolver

use Role::Tiny;

requires 'usable';         # If the class is generally usable
requires 'can_resolve';    # ->can_resolve(lookup) should be useable
requires 'resolve';        # ->resolve(lookup) should return a result

1;

__END__

=pod

=encoding utf-8

=head1 NAME

CPAN::Module::Resolver::Role::Resolver - An interface for module resolving for CPAN::Module::Resolver

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
