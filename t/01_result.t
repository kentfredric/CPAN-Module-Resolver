
use strict;
use warnings;

use Test::More;
use lib 't/tlib';

use_ok('InstanceTests');
my $class = 'CPAN::Module::Resolver::Result';
use_ok($class);

$class->instance_test( [] => sub { $_[0]->call_is( 'dist_uri', [], undef ) } );
$class->instance_test( [ module => 'Foo::Bar' ] => sub { $_[0]->call_is( 'module', [], 'Foo::Bar' ); } );
$class->instance_test(
  [ dist_author => 'KENTNL' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], "KENTNL",      'dist_author is KENTNL' );
    $instance->call_is( 'cpan_author_id',   [], "KENTNL",      'cpan_author_id is KENTNL' );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', 'cpan_author_path is K/KE/KENTNL' );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', 'cpan_dist_dir is    K/KE/KENTNL' );
    $instance->call_is( 'cpan_path',        [], undef,         'cpan_dist_dir is undef' );
  }
);

$class->instance_test(
  [ dist_author => 'KENTNL', dist_filename => 'Foo-Bar-Baz-1.90.tar.gz' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_path',        [], 'K/KE/KENTNL/Foo-Bar-Baz-1.90.tar.gz', );
    $instance->call_is( 'dist_uri',         [], undef, );
  }
);
$class->instance_test(
  [ dist_author => 'KENTNL', dist_filename => 'Foo-Bar-Baz-1.90.tar.gz', cpan_mirror => 'example.org/path/to/cpan' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_path',        [], 'K/KE/KENTNL/Foo-Bar-Baz-1.90.tar.gz', );
    $instance->call_is( 'dist_uri',         [], 'example.org/path/to/cpan/K/KE/KENTNL/Foo-Bar-Baz-1.90.tar.gz', );
  }
);
$class->instance_test(
  [ dist_author => 'KENTNL', dist_name => 'Foo-Bar-Baz' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_path',        [], undef );
    $instance->call_is( 'dist_uri',         [], undef );
    $instance->call_is( 'dist_filename',    [], undef );

  }
);
$class->instance_test(
  [ dist_author => 'KENTNL', dist_name => 'Foo-Bar-Baz', dist_version => '1.5' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_path',        [], 'K/KE/KENTNL/Foo-Bar-Baz-1.5.tar.gz' );
    $instance->call_is( 'dist_uri',         [], undef );
    $instance->call_is( 'dist_filename',    [], 'Foo-Bar-Baz-1.5.tar.gz' );
  }
);
$class->instance_test(
  [ dist_author => 'KENTNL', dist_name => 'Foo-Bar-Baz', dist_version => '1.5', dist_extension => 'tar.bz2' ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_path',        [], 'K/KE/KENTNL/Foo-Bar-Baz-1.5.tar.bz2' );
    $instance->call_is( 'dist_uri',         [], undef );
    $instance->call_is( 'dist_filename',    [], 'Foo-Bar-Baz-1.5.tar.bz2' );
  }
);
$class->instance_test(
  [
    dist_author    => 'KENTNL',
    dist_name      => 'Foo-Bar-Baz',
    dist_version   => '1.5',
    dist_extension => 'tar.bz2',
    cpan_dir       => 'project'
  ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'KENTNL', );
    $instance->call_is( 'cpan_author_id',   [], 'KENTNL', );
    $instance->call_is( 'cpan_author_path', [], 'K/KE/KENTNL', );
    $instance->call_is( 'cpan_dist_dir',    [], 'K/KE/KENTNL/project', );
    $instance->call_is( 'cpan_path',        [], 'K/KE/KENTNL/project/Foo-Bar-Baz-1.5.tar.bz2' );
    $instance->call_is( 'dist_uri',         [], undef );
    $instance->call_is( 'dist_filename',    [], 'Foo-Bar-Baz-1.5.tar.bz2' );
  }
);
$class->instance_test(
  [
    dist_author    => 'kentnl',
    dist_name      => 'Foo-Bar-Baz',
    dist_version   => '1.5',
    dist_extension => 'tar.bz2',
    cpan_dir       => 'project'
  ] => sub {
    my ($instance) = shift;
    $instance->call_is( 'dist_author',      [], 'kentnl', );
    $instance->call_is( 'cpan_author_id',   [], undef );
    $instance->call_is( 'cpan_author_path', [], undef );
    $instance->call_is( 'cpan_dist_dir',    [], undef );
    $instance->call_is( 'cpan_path',        [], undef );
    $instance->call_is( 'dist_uri',         [], undef );
    $instance->call_is( 'dist_filename',    [], 'Foo-Bar-Baz-1.5.tar.bz2' );
  }
);

done_testing;

