
use strict;
use warnings;

package InstanceTests;

sub blessed($) {
  require Scalar::Util;
  { no warnings 'redefine'; *blessed = \&Scalar::Util::blessed }
  goto &Scalar::Util::blessed;
}

sub refaddr($) {
  require Scalar::Util;
  { no warnings 'redefine'; *refaddr = \&Scalar::Util::refaddr }
  goto &Scalar::Util::refaddr;
}

sub fail(;$) {
  require Test::More;
  { no warnings 'redefine'; *fail = \&Test::More::fail }
  goto &Test::More::fail;

}

sub pass(;$) {
  require Test::More;
  { no warnings 'redefine'; *pass = \&Test::More::pass }
  goto &Test::More::pass;

}

sub ok ($;$) {
  require Test::More;
  { no warnings 'redefine'; *ok = \&Test::More::ok }
  goto &Test::More::ok;
}

sub is($$;$) {
  require Test::More;
  { no warnings 'redefine'; *is = \&Test::More::is }
  goto &Test::More::is;
}

sub subtest {
  require Test::More;
  { no warnings 'redefine'; *subtest = \&Test::More::subtest }
  goto &Test::More::subtest;
}

sub new_ok {
  require Test::More;
  { no warnings 'redefine'; *new_ok = \&Test::More::new_ok }
  goto &Test::More::new_ok;
}

sub pp {
  no warnings 'once';
  require Data::Dumper;
  local $Data::Dumper::Indent   = 0;
  local $Data::Dumper::Purity   = 0;
  local $Data::Dumper::Useqq    = 0;
  local $Data::Dumper::Terse    = 1;
  local $Data::Dumper::Maxdepth = 0;
  return Data::Dumper::Dumper(@_);
}

my $ids  = {};
my $g_id = 0;

sub class_short {
  my $class   = $_[0];
  my $blessed = blessed( $_[0] );
  $class = $blessed if defined $blessed;
  $class =~ s/^.*(::[^:]+)$/$1/;
  return $class;
}

sub blessed_short {
  return unless blessed( $_[0] );
  return class_short( $_[0] );
}

sub instanceid {
  my $class = blessed( $_[0] );
  my $addr  = refaddr( $_[0] );
  my $id;
  if ( exists $ids->{$class}->{$addr} ) {
    $id = $ids->{$class}->{$addr};
  }
  else {
    $ids->{$class}->{$addr} = $g_id;
    $g_id++;
    $id = $ids->{$class}->{$addr};
  }
  return '(' . blessed_short( $_[0] ) . "=" . $id . ')';

}

sub ppargs {
  return join q[,], map { pp($_) } @_;
}

sub UNIVERSAL::call_ok {
  my ( $self, $method, $args ) = @_;

  if ( not $self->can($method) ) {
    fail("cant ->$method() to call");
    return;
  }
  my $result = $self->$method(@$args);
  return ok( $result, instanceid($self) . "->$method(" . ppargs(@$args) . ") returned true" );
}

sub UNIVERSAL::call_is {
  my ( $self, $method, $args, $is ) = @_;
  if ( not $self->can($method) ) {
    fail("cant ->$method() to call");
    return;
  }
  return is( $self->$method(@$args), $is, instanceid($self) . "->$method(" . ppargs(@$args) . ') is ' . ppargs($is) );
}

sub UNIVERSAL::instance_test {
  my ( $self, $args, $code ) = @_;
  my $tn = ppargs( @{$args} );
  subtest class_short($self) . "->new($tn)" => sub {
    my $instance = new_ok( $self, [@$args], "Create instance " . $self . "->new($tn)" )
      or return;
    return $code->($instance);
  };
}

sub UNIVERSAL::method_test {
  my ( $self, $method, $args, $code ) = @_;
  my $tn = ppargs( @{$args} );

  my $name;

  if ( blessed($self) ) {
    $name = instanceid($self);
  }
  else {
    $name = class_short($self);
  }
  subtest $name. '->' . $method . "($tn)" => sub {
    if ( not $self->can($method) ) {
      fail("cant ->$method() to call");
      return;
    }
    my $result = $self->$method( @{$args} );
    pass( "value = " . $name . "->" . $method . "($tn)" );
    return $code->($result);
  };
}
1;
