package WWW::Fandango::Location;

use Moose;
use Moose::Util::TypeConstraints;
use Modern::Perl;
use DateTime;

subtype 'ZipCode'
	=> as 'Int' => where { $_ =~ /^\d{5}$/ } => message {
		"$_ doesn't seem to be a zip code."
	};

has 'zip' => (
	is => 'rw',
	isa => 'ZipCode',
);

no Moose;
__PACKAGE__->meta->make_immutable;