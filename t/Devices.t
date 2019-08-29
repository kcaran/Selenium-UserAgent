use JSON;
use LWP::UserAgent;
use Selenium::UserAgent;
use Test::Spec;

my $ua = LWP::UserAgent->new;
my $devices_url = 'https://code.cdn.mozilla.net/devices/devices.json';
my $res = $ua->get($devices_url);

plan skip_all => 'Cannot get device source document'
  unless $res->code == 200;

my $devices = decode_json($res->content);

describe 'Device information' => sub {
    my $expected_phones = [ @{ $devices->{phones} }, @{ $devices->{tablets} }];
    my $expected_tablets = $devices->{tablets};

    my $phones = {
#       iphone4 => 'Apple iPhone 4',
        iphone5 => 'iPhone 5/SE',
        iphone6 => 'iPhone 6/7/8',
        iphone6plus => 'iPhone 6/7/8 Plus',
        iphone_x => 'iPhone X/XS',
        iphone_xr => 'iPhone XR',
        iphone_xs_max => 'iPhone XS Max',
#       galaxy_s3 => 'Samsung Galaxy S3',
#       galaxy_s4 => 'Samsung Galaxy S4',
        galaxy_s5 => 'Galaxy S5',
        galaxy_note3 => 'Galaxy Note 3',
#       nexus4 => 'Google Nexus 4',
    };

    my $actual = get_actual_phones();

    describe 'phones' => sub {

        foreach my $name (keys %$phones) {
            my $converted_name = $phones->{$name};
            my @details = grep { $_->{name} eq $converted_name } @$expected_phones;
            my $expected = $details[0];

            it 'should match width for ' . $name => sub {
                is($actual->{$name}->{portrait}->{width}, $expected->{width});
            };

            it 'should match height for ' . $name => sub {
                is($actual->{$name}->{portrait}->{height}, $expected->{height});
            };

            it 'should match pixel ratio for ' . $name => sub {
                is($actual->{$name}->{pixel_ratio}, $expected->{pixelRatio});
            };
        }
    };

    describe 'tablets' => sub {
        my $tablets = {
            ipad => 'iPad',
			ipad_mini => 'iPad Mini',
            ipad_pro_10_5 => 'iPad Pro (10.5-inch)',
            ipad_pro_12_9 => 'iPad Pro (12.9-inch)',
            nexus10 => 'Nexus 10'
        };

        foreach my $name (keys %$tablets) {
            my $converted_name = $tablets->{$name};
            my @details = grep { $_->{name} eq $converted_name } @$expected_tablets;
            my $expected = $details[0];

            it 'should match width for ' . $name => sub {
                is($actual->{$name}->{portrait}->{width}, $expected->{width});
            };

            it 'should match height for ' . $name => sub {
                is($actual->{$name}->{portrait}->{height}, $expected->{height});
            };

            it 'should match pixel ratio for ' . $name => sub {
                is($actual->{$name}->{pixel_ratio}, $expected->{pixelRatio});
            };
        }
    };
};

sub get_actual_phones {
    return Selenium::UserAgent->new(
        agent => 'iphone', browserName => 'chrome'
    )->_specs;
}

runtests;
