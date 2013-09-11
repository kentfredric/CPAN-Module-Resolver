
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4007"
  },
  "configure_requires" => {
    "Module::Build" => "0.4007"
  },
  "dist_abstract" => "Resolve module names to the distributions they are contained in",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "CPAN-Module-Resolver",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "CPAN::Module::Resolver",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Class::Tiny" => 0,
    "Role::Tiny" => 0,
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Data::Dumper" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Role::Tiny::With" => 0,
    "Scalar::Util" => 0,
    "Test::More" => "0.98",
    "lib" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
