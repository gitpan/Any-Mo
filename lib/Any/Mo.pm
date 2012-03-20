package Any::Mo;

use 5.006;
use strict qw/vars subs/;
no warnings;

our $Mo        = __PACKAGE__.'::Mo';
our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.30';

use Scalar::Util;
use Carp;

sub import {
	my $prefer = (shift)->decide;
	
	if ($prefer eq 'Mo') {
		*{(caller(0))[0].'::blessed'} = \&Scalar::Util::blessed;
		*{(caller(0))[0].'::confess'} = \&Carp::confess;
	}
	
	@_ = ($prefer eq $Mo)
		? ($Mo, qw/build builder coerce default is isa required/)
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

__PACKAGE__
__DATA__
package Any::Mo::Mo;
$VERSION='0.30';
no warnings;my$M='Any::Mo::'.'Mo'.::;*{$M.Object::new}=sub{bless{@_[1..$#_]},$_[0]};*{$M.import}=sub{import warnings;$^H|=1538;my($P,%e,%o)=caller.::;shift;&{$M.$_.::e}($P,\%e,\%o,\@_)for@_;return if$e{M};%e=(extends,sub{eval"no $_[0]()";@{$P.ISA}=$_[0]},has,sub{my$n=shift;my$m=sub{$#_?$_[0]{$n}=$_[1]:$_[0]{$n}};$m=$o{$_}->($m,$n,@_)for sort keys%o;*{$P.$n}=$m},%e,);*{$P.$_}=$e{$_}for keys%e;@{$P.ISA}=$M.Object};
;package Any::Mo::Mo::build;my$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'build::e'}=sub{my($P,$e)=@_;$e->{new}=sub{$c=shift;my$s=bless{@_},$c;my@B;do{@B=($c.::BUILD,@B)}while($c)=@{$c.::ISA};exists&$_&&&$_($s)for@B;$s}};
;package Any::Mo::Mo::builder;my$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'builder::e'}=sub{my($P,$e,$o)=@_;$o->{builder}=sub{my($m,$n,%a)=@_;my$b=$a{builder}or return$m;sub{$#_?$m->(@_):!exists$_[0]{$n}?$_[0]{$n}=$_[0]->$b:$m->(@_)}}};
;package Any::Mo::Mo::coerce;my$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'coerce::e'}=sub{my($P,$e,$o)=@_;$o->{coerce}=sub{my($m,$n,%a)=@_;$a{coerce}or return$m;sub{$#_?$m->($_[0],$a{coerce}->($_[1])):$m->(@_)}};my$C=$e->{new}||*{$M.Object::new}{CODE};$e->{new}=sub{my$s=$C->(@_);$s->$_($s->{$_})for keys%$s;$s}};
;package Any::Mo::Mo::default;my$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'default::e'}=sub{my($P,$e,$o)=@_;$o->{default}=sub{my($m,$n,%a)=@_;$a{default}or return$m;sub{$#_?$m->(@_):!exists$_[0]{$n}?$_[0]{$n}=$a{default}->(@_):$m->(@_)}}};
;package Any::Mo::Mo::is;$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'is::e'}=sub{my($P,$e,$o)=@_;$o->{is}=sub{my($m,$n,%a)=@_;$a{is}or return$m;sub{$#_&&$a{is}eq 'ro'&&caller ne 'Mo::coerce'?die:$m->(@_)}}};
;package Any::Mo::Mo::isa;$M='Any::Mo::'."Mo::";
$VERSION='0.30';
sub O{UNIVERSAL::can(@_,'isa')}sub Z{1}sub R(){ref}sub Y(){defined&&!ref}sub L(){Y&&/^([+-]?\d+|([+-]?)(?=\d|\.\d)\d*(\.\d*)?(e([+-]?\d+))?|(Inf(inity)?|NaN))$/i}our%TC=(Any,\&Z,Item,\&Z,Bool,\&Z,Undef,sub{!defined},Defined,sub{defined},Value,\&Y,Str,\&Y,Num,\&L,Int,sub{L&&int($_)==$_},Ref,\&R,FileHandle,\&R,Object,sub{R&&O($_)},(map{$_.Name,sub{Y&&/^\S+$/}}qw/Class Role/),map{my$J=/R/?$_:uc$_;"${_}Ref",sub{R eq$J}}qw/Scalar Array Hash Code Glob Regexp/,);sub check{my$v=pop;if(ref$_[0]eq'CODE'){return eval{$_[0]->($v);1}}@_=split/\|/,shift;while(@_){(my$t=shift)=~s/(^\s+)|(\s+$)//g;if($t=~/^Maybe\[(.+)\]$/){unshift@_,'Undef',$1;next}$t=$1 if$t=~/^(.+)\[/;if(my$k=$TC{$t}){local$_=$v;return 1 if$k->()}elsif($t=~/::/){return 1 if O($v)&&$v->isa($t)}else{return 1}}0}sub av{my$t=shift;ref($t)eq'CODE'?$t->(@_):do{die"not $t\n"if!check($t,@_)}}my%cx;*{$M.isa::e}=sub{my($P,$e,$o)=@_;my$C=*{$P.new}{CODE}||*{$M.Object::new}{CODE};*{$P.new}=sub{my%a=@_[1..$#_];for(keys%a){av($cx{$P.$_},$a{$_})if$cx{$P.$_}}goto$C};$o->{isa}=sub{my($m,$n,%a)=@_;my$V=$cx{$P.$n}=$a{isa}or return$m;sub{av($V,$_[1])if$#_;$m->(@_)}}}
;package Any::Mo::Mo::required;my$M='Any::Mo::'."Mo::";
$VERSION='0.30';
*{$M.'required::e'}=sub{my($P,$e,$o)=@_;$o->{required}=sub{my($m,$n,%a)=@_;if($a{required}){my$C=*{$P."new"}{CODE}||*{$M.Object::new}{CODE};no warnings 'redefine';*{$P."new"}=sub{my$s=$C->(@_);my%a=@_[1..$#_];die$n." required"if!$a{$n};$s}}$m}};
;