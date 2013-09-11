use strict;
use warnings;

package CPAN::Module::Resolver;
BEGIN {
  $CPAN::Module::Resolver::AUTHORITY = 'cpan:KENTNL';
}
{
  $CPAN::Module::Resolver::VERSION = '0.1.0';
}

# ABSTRACT: Resolve module names to the dists they are contained in


1;

__END__

=pod

=encoding utf-8

=head1 NAME

CPAN::Module::Resolver - Resolve module names to the dists they are contained in

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This module is just a placeholder at present for shared code
that will exist been multiple resolving tools I'm throwing together
by looking at the `cpanm` code, stealing parts that are useful.

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
