use Test::More tests => 1;
BEGIN { use_ok('Any::Mo') };

q{ Meh...
use Test::Pod;
use Test::Pod::Coverage;
} or exit(1);
