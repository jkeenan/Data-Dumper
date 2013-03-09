#!perl

use Test::More;

BEGIN { plan tests => 1+2*5; }

BEGIN { use_ok('Data::Dumper') };

my $skip_reason =
    "Test::More::is_deeply() not available until Test-Simple 0.60: rt.cpan.org 9441";

# RT 39420: Data::Dumper fails to escape bless class name

run_tests_for_bless();
SKIP: {
    skip "XS version was unavailable, so we already ran with pure Perl", 5
        if $Data::Dumper::Useperl;
    local $Data::Dumper::Useperl = 1;
    run_tests_for_bless();
}

sub run_tests_for_bless {
diag("\$Data::Dumper::Useperl = $Data::Dumper::Useperl");

{
    my $t = bless( {}, q{a'b} );
    my $dt = Dumper($t);
    my $o = <<'PERL';
$VAR1 = bless( {}, 'a\'b' );
PERL

    is($dt, $o, "package name in bless is escaped if needed");
    SKIP: {
        skip $skip_reason, 1
            unless do { my $v = eval $Test::More::VERSION; $v >= 0.60 };
        is_deeply(scalar eval($dt), $t, "eval reverts dump");
    }
}

{
    my $t = bless( {}, q{a\\} );
    my $dt = Dumper($t);
    my $o = <<'PERL';
$VAR1 = bless( {}, 'a\\' );
PERL

    is($dt, $o, "package name in bless is escaped if needed");
    SKIP: {
        skip $skip_reason, 1
            unless do { my $v = eval $Test::More::VERSION; $v >= 0.60 };
        is_deeply(scalar eval($dt), $t, "eval reverts dump");
    }
}

SKIP: {
    skip(q/no 're::regexp_pattern'/, 1)
        if ! defined(*re::regexp_pattern{CODE});

    my $t = bless( qr//, 'foo');
    my $dt = Dumper($t);
    my $o = ($] >= 5.013006 ? <<'PERL' : <<'PERL_LEGACY');
$VAR1 = bless( qr/(?^:)/, 'foo' );
PERL
$VAR1 = bless( qr/(?-xism:)/, 'foo' );
PERL_LEGACY

    is($dt, $o, "We can dump blessed qr//'s properly");
}

} # END sub run_tests_for_bless()
