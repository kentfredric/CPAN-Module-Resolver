use strict;
use warnings;

package CPAN::Module::Resolver::Role::ShellBackend;

# ABSTRACT: Utility functions used by backends that rely on external processes.

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo::Role;
use Config;
use constant WIN32 => $^O eq 'MSWin32';

my $quote = ( WIN32 ? q/"/ : q/'/ );

=pmethod _shell_quote

	my $quoted = $self->_shell_quote( $stuff );
=cut

sub _shell_quote {
  my ( $self, $stuff ) = @_;
  $stuff =~ /^${quote}.+${quote}$/ ? $stuff : ( $quote . $stuff . $quote );
}

=pmethod _which

	my $path = $self->_which('wget');

=cut

sub _which {
  my ( $self, $name ) = @_;
  require File::Spec;
  my $exe_ext = $Config{_exe};
  for my $dir ( File::Spec->path ) {
    my $fullpath = File::Spec->catfile( $dir, $name );
    if ( -x $fullpath || -x ( $fullpath .= $exe_ext ) ) {
      if ( $fullpath =~ /\s/ && $fullpath !~ /^$quote/ ) {
        $fullpath = $self->_shell_quote($fullpath);
      }
      return $fullpath;
    }
  }
  return;
}

=pmethod _safeexec

	$self->_safeexec( my $fh, 'wget', @args_for_wget ) or die "Bad things! $!";
	local $/;
	print scalar <$fh>;

=cut

sub _safeexec {
  my $self = shift;
  require Symbol;
  my $rdr = $_[0] ||= Symbol::gensym();

  if (WIN32) {
    my $cmd = join q{ }, map { $self->_shell_quote($_) } @_[ 1 .. $#_ ];
    return open( $rdr, "$cmd |" );
  }

  if ( my $pid = open( $rdr, '-|' ) ) {
    return $pid;
  }
  elsif ( defined $pid ) {
    exec( @_[ 1 .. $#_ ] );
    exit 1;
  }
  else {
    return;
  }
}

=pmethod _file_get

Dispatch via a file on disk, not via web call

	my $content = $self->_file_get($path_to_file);

=cut

sub _file_get {
  my ( $self, $uri ) = @_;
  open my $fh, '<', $uri or return;
  return join '', <$fh>;
}

=pmethod _file_mirror

Mirror a file on disk, not via a web call

	$self->_file_mirror( $src, $dest );

=cut

sub _file_mirror {
  my ( $self, $uri, $path ) = @_;
  require File::Copy;
  File::Copy::copy( $uri, $path );
}

