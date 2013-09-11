use strict;
use warnings;

package CPAN::Module::Resolver::Result;
BEGIN {
  $CPAN::Module::Resolver::Result::AUTHORITY = 'cpan:KENTNL';
}
{
  $CPAN::Module::Resolver::Result::VERSION = '0.1.0';
}

# ABSTRACT: A container for a C<look-up> result


# Terms: KENTNL/MX-H-Foo-1.203.tar.gz
#--------------------------------------
#        | -- | dist_author = KENTNL
#              | ----- |  dist_name = MX-H-Foo
#                        | -- | dist_version = 1.203
#                              | --- | dist_extension = tar.gz
#
#
use Class::Tiny (
  'module',
  'dist_author',
  'dist_name',
  'dist_version',
  'cpan_dir',
  'cpan_mirror',
  {
    dist_filename => sub {
      return unless $_[0]->dist_name;
      return unless $_[0]->dist_version;
      return unless $_[0]->dist_extension;
      return sprintf '%s-%s.%s', $_[0]->dist_name, $_[0]->dist_version, $_[0]->dist_extension;
    },
    cpan_author_id => sub {
      return unless $_[0]->dist_author;
      return unless $_[0]->dist_author =~ /\A\p{PosixUpper}+\z/msx;
      return $_[0]->dist_author;
    },
    cpan_author_path => sub {
      return unless $_[0]->cpan_author_id;
      return sprintf '%s/%s/%s',
        ( substr $_[0]->cpan_author_id, 0, 1 ),
        ( substr $_[0]->cpan_author_id, 0, 2 ),
        $_[0]->cpan_author_id;
    },
    cpan_dist_dir => sub {
      return unless $_[0]->cpan_author_path;
      return $_[0]->cpan_author_path unless $_[0]->cpan_dir;
      return sprintf '%s/%s', $_[0]->cpan_author_path, $_[0]->cpan_dir;
    },
    cpan_path => sub {
      return unless $_[0]->cpan_dist_dir;
      return unless $_[0]->dist_filename;
      return sprintf '%s/%s', $_[0]->cpan_dist_dir, $_[0]->dist_filename;
    },
    dist_uri => sub {
      return unless $_[0]->cpan_path and $_[0]->cpan_mirror;
      return sprintf '%s/%s', $_[0]->cpan_mirror, $_[0]->cpan_path;
    },
    dist_extension => sub {
      return 'tar.gz';
    },
  }
);


1;

__END__

=pod

=encoding utf-8

=head1 NAME

CPAN::Module::Resolver::Result - A container for a C<look-up> result

=head1 VERSION

version 0.1.0

=head1 ATTRIBUTES

=head2 C<module>

The module that this result is a query result for.

    Foo::Bar::Baz

=head2 C<dist_author>

Some kind of author identity ( C<CPANID> recommended )

    KENTNL
    foobar@baz.org

=head2 C<dist_name>

The basename of the distribution. This should roughly match C<[A-Za-z-]+>

    Foo-Bar-Baz

=head2 C<dist_version>

The version component of the distribution.

    1.5
    v1.5
    1.8-TRIAL

=head2 C<cpan_dir>

The subdirectory of the CPAN Authors directory that this distribution is stored in.

( Optional, most distributions do not need this, as most distributions reside directly in the top level author directory )

=head2 C<cpan_mirror>

A CPAN Mirror prefix to use for creating C<dist_uri>

=head2 C<dist_filename>

The filename itself, i.e.:

    Foo-Bar-Baz-v1.5-TRIAL.tar.gz

If not specified, will be optimisically combined from L<< C<dist_name>|/dist_name >> + L<< C<dist_version>|/dist_version >> + L<< C<dist_extension>|/dist_extension >>, assuming all of the above are defined. C<undef> otherwise.

=head2 C<cpan_author_id>

the CPAN Author ID of the resolved dist.

If not specified, will attempt to be taken from L<< C<dist_author>|/dist_author >> if it matches C<\p{PosixUpper}>

e.g:

    KENTNL

=head2 C<cpan_author_path>

the L<< C<cpan_author_id>|/cpan_author_id >> in CPAN mirror form

    KENTNL → K/KE/KENTNL

=head2 C<cpan_dist_dir>

the relative path to where the distribution is stored on a generic C<CPAN> mirror.

Usually this is the same as L<< C<cpan_author_path>|/cpan_author_path >>, except in the case that L<< C<cpan_dir>|/cpan_dir >> is specified, where that value will be added on the end, e.g:

    { cpan_dir => "foo", cpan_author_id => "ABCDE" } -> { cpan_author_path => "A/AB/ABCDE", cpan_dist_dir => "A/AB/ABCDE/foo" }

=head2 C<cpan_path>

Complete path to the distribution relative to a generic C<CPAN> mirror.

e.g.

    A/AB/ABCDE/foo/Foo-Bar-1.2.tar.gz
    A/AB/ABCDE/Foo-Bar-1.2.tar.gz

=head2 C<dist_uri>

An absolute URI that can be used to fetch the distribution.

If L<< C<cpan_mirror>|/cpan_mirror >> is specified, then this value can be automatically
determined from combining L<< C<cpan_mirror>|/cpan_mirror >> and L<< C<cpan_path>|/cpan_path >> 

=head2 C<dist_extension>

The file extension on the distribution.

This defaults to C<tar.gz>

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver::Result",
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
