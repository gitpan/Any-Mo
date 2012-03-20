{
	package Foo;
	use Any::Mo;
	has foo => (is => 'ro');
}

{
	package Bar;
	BEGIN { require Moose; }
	use Any::Mo;
	has foo => (is => 'ro');
}

my $foo = Foo->new;
my $bar = Bar->new;

require Class::ISA;
require Data::Dumper;

print Data::Dumper::Dumper([ Class::ISA::super_path('Foo') ]);
print Data::Dumper::Dumper([ Class::ISA::super_path('Bar') ]);
