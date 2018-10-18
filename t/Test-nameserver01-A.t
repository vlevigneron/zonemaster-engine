use Test::More;

BEGIN {
    use_ok( q{Zonemaster::Engine} );
    use_ok( q{Zonemaster::Engine::Test::Nameserver} );
    use_ok( q{Zonemaster::Engine::Util} );
}

my $datafile = q{t/Test-nameserver01-A.data};

if ( not $ENV{ZONEMASTER_RECORD} ) {
    die q{Stored data file missing} if not -r $datafile;
    Zonemaster::Engine::Nameserver->restore( $datafile );
    Zonemaster::Engine->config->no_network( 1 );
}

Zonemaster::Engine->add_fake_delegation(
    'a.nameserver01.exempelvis.se' => {
        'ns1.a.nameserver01.exempelvis.se' => [ '46.21.97.97',   '2a02:750:12:77::97' ],
        'ns2.a.nameserver01.exempelvis.se' => [ '37.123.169.91', '2001:9b0:1:1c13::53' ],
    }
);

my $zone = Zonemaster::Engine->zone( q{a.nameserver01.exempelvis.se} );

my %res = map { $_->tag => $_ } Zonemaster::Engine::Test::Nameserver->nameserver01( $zone );

ok( $res{NO_RESPONSE},    q{should emit NO_RESPONSE} );
ok( !$res{IS_A_RECURSOR}, q{should not emit IS_A_RECURSOR} );
ok( $res{NO_RECURSOR},    q{should emit NO_RECURSOR} );

if ( $ENV{ZONEMASTER_RECORD} ) {
    Zonemaster::Engine::Nameserver->save( $datafile );
}

done_testing;
