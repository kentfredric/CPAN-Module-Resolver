use strict;
use warnings;

package CPAN::Module::Resolver::Result;

# ABSTRACT: A container for a lookup result

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver::Result",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

=cut


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
      return unless $_[0]->dist_author =~ /\A[A-Z]+\z/msx;
      return $_[0]->dist_author;
    },
    cpan_author_path => sub {
      return unless $_[0]->cpan_author_id;
      return sprintf '%s/%s/%s',
        ( substr  $_[0]->cpan_author_id , 0, 1  ),
        ( substr  $_[0]->cpan_author_id , 0, 2 ),
        $_[0]->cpan_author_id;
    },
    cpan_dist_dir => sub {
      return unless $_[0]->cpan_author_path;
      return $_[0]->cpan_author_path unless $_[0]->cpan_dir;
      return sprintf "%s/%s", $_[0]->cpan_author_path, $_[0]->cpan_dir;
    },
    cpan_path => sub {
      return unless $_[0]->cpan_dist_dir;
      return unless $_[0]->dist_filename;
      return sprintf "%s/%s", $_[0]->cpan_dist_dir, $_[0]->dist_filename;
    },
    dist_uri => sub {
      return unless $_[0]->cpan_path and $_[0]->cpan_mirror;
      return sprintf "%s/%s", $_[0]->cpan_mirror, $_[0]->cpan_path;
    },
    dist_extension => sub {
       return 'tar.gz';
    },
  }
);

1;
