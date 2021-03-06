use strict;
use warnings;

package CPAN::Module::Resolver::Result;

# ABSTRACT: A container for a C<look-up> result

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver::Result",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

=cut

=head1 SYNOPSIS


=cut

=head1 TERMINOLOGY

    A = cpan_author_id
    B = dist_name
    C = dist_version
    D = dist_extension
    E = cpan_dir
    F = cpan_author_path
    G = cpan_dist_dir
    H = dist_filename
    I = cpan_mirror
    J = dist_uri

    KENTNL/MX-H-Foo-1.203.tar.gz
    AAAAAA/HHHHHHHHHHHHHHHHHHHHH
    AAAAAA/BBBBBBBB-CCCCC.DDDDDD

    KENTNL/foo/MX-H-Foo-1.203.tar.gz
    AAAAAA/EEE/HHHHHHHHHHHHHHHHHHHHH
    AAAAAA/EEE/BBBBBBBB-CCCCC.DDDDDD

    K/KE/KENTNL/foo/MX-H-Foo-1.203.tar.gz
    GGGGGGGGGGGGGGG/HHHHHHHHHHHHHHHHHHHHH
    FFFFFFFFFFF/EEE/BBBBBBBB-CCCCC.DDDDDD
     /  /AAAAAA/EEE/BBBBBBBB-CCCCC.DDDDDD

    http://cpan.metacpan.org/authors/id/K/KE/KENTNL/foo/MX-H-Foo-1.203.tar.gz
    JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
    IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/GGGGGGGGGGGGGGG/HHHHHHHHHHHHHHHHHHHHH

You get the idea right?

Though thats not to say you have to provide all, or any of the above, just provide what makes sense.

If a request lookup can produce a C<dist_uri> without needing to be passed a I<cpan_mirror>,
or if your dist resolver has a download URL that doesn't mimic cpan, just pass as much as you have.

End users are to deal with handling what happens when a result as an C<undef> property.

=cut

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

=attr C<module>

The module that this result is a query result for.

    Foo::Bar::Baz

=attr C<dist_author>

Some kind of author identity ( C<CPANID> recommended )

    KENTNL
    foobar@baz.org

=attr C<dist_name>

The basename of the distribution. This should roughly match C<[A-Za-z-]+>

    Foo-Bar-Baz

=attr C<dist_version>

The version component of the distribution.

    1.5
    v1.5
    1.8-TRIAL

=attr C<cpan_dir>

The subdirectory of the CPAN Authors directory that this distribution is stored in.

( Optional, most distributions do not need this, as most distributions reside directly in the top level author directory )

=attr C<cpan_mirror>

A CPAN Mirror prefix to use for creating C<dist_uri>

=attr C<dist_filename>

The filename itself, i.e.:

    Foo-Bar-Baz-v1.5-TRIAL.tar.gz

If not specified, will be optimisically combined from L<< C<dist_name>|/dist_name >> + L<< C<dist_version>|/dist_version >> + L<< C<dist_extension>|/dist_extension >>, assuming all of the above are defined. C<undef> otherwise.

=attr C<cpan_author_id>

the CPAN Author ID of the resolved dist.

If not specified, will attempt to be taken from L<< C<dist_author>|/dist_author >> if it matches C<\p{PosixUpper}>

e.g:

    KENTNL

=attr C<cpan_author_path>

the L<< C<cpan_author_id>|/cpan_author_id >> in CPAN mirror form

    KENTNL → K/KE/KENTNL

=attr C<cpan_dist_dir>

the relative path to where the distribution is stored on a generic C<CPAN> mirror.

Usually this is the same as L<< C<cpan_author_path>|/cpan_author_path >>, except in the case that L<< C<cpan_dir>|/cpan_dir >> is specified, where that value will be added on the end, e.g:

    { cpan_dir => "foo", cpan_author_id => "ABCDE" } -> { cpan_author_path => "A/AB/ABCDE", cpan_dist_dir => "A/AB/ABCDE/foo" }

=attr C<cpan_path>

Complete path to the distribution relative to a generic C<CPAN> mirror.

e.g.

    A/AB/ABCDE/foo/Foo-Bar-1.2.tar.gz
    A/AB/ABCDE/Foo-Bar-1.2.tar.gz

=attr C<dist_uri>

An absolute URI that can be used to fetch the distribution.

If L<< C<cpan_mirror>|/cpan_mirror >> is specified, then this value can be automatically
determined from combining L<< C<cpan_mirror>|/cpan_mirror >> and L<< C<cpan_path>|/cpan_path >>

=attr C<dist_extension>

The file extension on the distribution.

This defaults to C<tar.gz>

=cut

1;
