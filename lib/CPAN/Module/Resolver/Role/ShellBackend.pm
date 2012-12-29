use strict;
use warnings;

package CPAN::Module::Resolver::Role::ShellBackend;
use Moo::Role;
use constant WIN32 => $^O eq 'MSWin32';

my $quote = ( WIN32 ? q/"/ : q/'/ );

sub _shell_quote {
    my ( $self, $stuff ) = @_;
    $stuff =~ /^${quote}.+${quote}$/ ? $stuff : ( $quote . $stuff . $quote );
}

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

sub _file_get {
    my ( $self, $uri ) = @_;
    open my $fh, '<', $uri or return;
    return join '', <$fh>;
}

sub _file_mirror {
    my ( $self, $uri, $path ) = @_;
    require File::Copy;
    File::Copy::copy( $uri, $path );
}

