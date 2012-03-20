use Test::More;
eval { require Class::ISA; 1 }
	or plan skip_all => 'need Class::ISA';

{
	package Foo;
	use Any::Mo;
	has foo => (is => 'ro');
}

{
	package Bar;
	BEGIN {
		eval { require Moose; 1 }
			or Test::More::plan skip_all => 'need Moose'
	}
	use Any::Mo;
	has foo => (is => 'ro');
}

my $foo = Foo->new;
my $bar = Bar->new;

plan tests => 2;

is_deeply(
	[ Class::ISA::super_path('Foo') ],
	[ qw/Any::Mo::Mo::Object/ ],
	'Foo inheritance',
	);
	
is_deeply(
	[ Class::ISA::super_path('Bar') ],
	[ qw/Moose::Object/ ],
	'Bar inheritance',
	);
	
