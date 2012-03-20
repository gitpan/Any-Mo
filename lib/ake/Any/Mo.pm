package ake::Any::Mo;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.30';

use 5.008;
use strict 'vars', 'subs';
no warnings;

sub import
{
	my $class = shift;
	
	my %args;
	$args{name}       = shift if @_;
	$args{mo_lib}     = shift if @_;
	$args{authority}  = shift if @_;
	$args{version}    = shift if @_;
	$args{mo_modules} = \@_ if @_;
	
	print $class->new(%args)->to_string;
	exit(0);
}

sub new
{
	my ($class, %args) = @_;
	
	require Mo;
	$args{name}       ||= 'My::Any::Mo';
	$args{version}    ||= $Mo::VERSION;
	$args{authority}  ||= $AUTHORITY;
	$args{mo_lib}     ||= do { (my $path = $INC{'Mo.pm'}) =~ s/Mo.pm$//; $path };
	$args{mo_modules} ||= [qw/build builder coerce default is required/];
	
	$args{mo_modules} = [qw/build builder coerce default is isa required/]
		if $args{mo_modules}[0] eq 'STD';
	
	bless \%args, $class;
}

foreach my $attr (qw/name version authority mo_lib mo_modules/)
{
	*$attr = sub :lvalue { (shift)->{$attr} };
}

sub to_string
{
	my $self = shift;
	join q{},
		$self->_package,
		$self->_data;
}

sub _package
{
	my $self = shift;
	my $data = do { local $/ = <DATA> };
	
	$data =~ s{ % (NAME|AUTHORITY|VERSION) % }
	          { my $a = lc $1; $self->$a }xeg;
	$data =~ s{ % (MODULES) % }
	          { join q[ ], @{$self->mo_modules} }xeg;
	$data .= "__PACKAGE__\n";
	
	return $data;
}

sub _data
{
	my $self    = shift;
	my $prefix  = $self->name . '::';
	my @modules = ('Mo', map { "Mo::$_" } @{ $self->mo_modules });
	
	my $return = "__DATA__\n";
	
	foreach my $mod (@modules)
	{
		(my $filename = $mod) =~ s{::}{/}g;
		$filename = $self->mo_lib . '/' . $filename . '.pm';
		my $data = do { open my $fh, '<', $filename or die "open $filename: $!"; local $/ = <$fh> };
		$data =~ s{^package Mo}{package ${prefix}Mo};
		$data =~ s{(my|;)\$M=(.+?);}{${1}\$M='${prefix}'.${2};};
		
		if ($mod eq 'Mo')
		{
			$data =~ s{eval"no Mo::\$_",}{};
			$data =~ s{__PACKAGE__}{'Mo'};
		}
				
		$return .= $data . ';';
	}
	
	return $return;
}

=head1 NAME

ake::Any::Mo - make Any::Mo

=head1 SYNOPSIS

 perl -Make::Any::Mo=Monkey::Mo,path/to/Mo/lib

=head1 DESCRIPTION

This module helps you make your own version of Any::Mo, with a name
like maybe "Monkey::Mo", or whatever else you like. You'll need to
have Mo.pm and its friends (Mo/is.pm, Mo/build.pm, etc) somewhere.

Use it from the command line, as shown in the synopsis. After the
equals sign, ake::Any::Mo expects a comma-delimited list of arguments.
In order, these are:

=over

=item * the name of the module to create.
(Default: "My::Any::Mo".)

=item * the path where Mo.pm can be found.
(Default: performs "require Mo" to figure it out.)

=item * a URI identifying the authority making the module.
Pseudo-URIs along the lines of 'cpan:TOBYINK' are often used.
(Default: as per $ake::Any::Mo::AUTHORITY.)

=item * a version number for the module.
(Default: as per $ake::Any::Mo::VERSION.)

=back

Any remaining arguments are a list of Mo plugins to include.

=head1 MOTIVATION

L<Mo> is a nice, dependency-free Moose-lite. If you C<use Mo> then you're
introducing exactly one dependency: Mo itself. (Though Mo comes with a 
mo-inline script to remove this dependency.)

L<Any::Mo> gives you Moose if Moose is already loaded, but falls back to
Mo. L<Any::Mo> actually bundles a version of Mo, so if you C<use Any::Mo>,
you are still only introducing one non-core dependency: Any::Mo itself.

But wouldn't it be nice to have the power of Any::Mo without introducing
a dependency on Any::Mo? Well, you can - you can use ake::Any::Mo to create
a custom version of Any::Mo (which of course includes a version of Mo), then
bundle your custom Any::Mo with your code.

=cut

__PACKAGE__
__DATA__
package %NAME%;

use 5.006;
use strict qw/vars subs/;
no warnings;

our $Mo        = __PACKAGE__.'::Mo';
our $AUTHORITY = '%AUTHORITY%';
our $VERSION   = '%VERSION%';

use Scalar::Util;
use Carp;

sub import {
	my $prefer = (shift)->decide;
	
	if ($prefer eq 'Mo') {
		*{(caller(0))[0].'::blessed'} = \&Scalar::Util::blessed;
		*{(caller(0))[0].'::confess'} = \&Carp::confess;
	}
	
	@_ = ($prefer eq $Mo)
		? ($Mo, qw/%MODULES%/)
		: ($prefer);
	
	my $import = $prefer->can('import');
	goto $import;
}

sub decide {
	my ($self) = @_;
	
	{
		local $_ = $ENV{PERL_ANY_MO};
		if (/^MOOSE$/i) { $self->make_moose_available; return 'Moose' }
		if (/^MOUSE$/i) { $self->make_mouse_available; return 'Mouse' }
		if (/^MO$/i)    { $self->make_mo_available;    return $Mo }
		if (/^${Mo}$/i) { $self->make_mo_available;    return $Mo }
		if (/./)        { warn "PERL_ANY_MO should be Moose/Mouse/Mo!" }
	}
	
	return 'Moose' if $self->moose_is_available;
	return 'Mouse' if $self->mouse_is_available;
	$self->make_mo_available;
	return $Mo;
}

# Moose
sub moose_is_available {
	defined $INC{'Moose.pm'}
		and UNIVERSAL::can('Moose', 'can')
		and Moose->can('import');
}
sub make_moose_available {
	return if (shift)->moose_is_available;
	require Moose;
}

# Mouse
sub mouse_is_available {
	defined $INC{'Mouse.pm'}
		and UNIVERSAL::can('Mouse', 'can')
		and Mouse->can('import');
}
sub make_mouse_available {
	return if (shift)->mouse_is_available;
	require Mouse;
}

# Mo
my $AMM_available;
sub mo_is_available {
	return 1 if $AMM_available;
	return;
}
sub make_mo_available {
	return if (shift)->mo_is_available;
	no strict;
	my $AMM = do { local $/ = <DATA> }
		or die "Could not load AMM from DATA";
	eval $AMM
		or die "Could not evaluate AMM: $@";
	$AMM_available = 1;
}

