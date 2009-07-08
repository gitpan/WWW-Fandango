use inc::Module::Install;

name           'WWW-Fandango';
all_from       'lib/Net/Fandango.pm';

no_index directory => 'examples';

requires	'Moose'					=> '0.87';
requires	'Modern::Perl'			=> '1.03';
requires	'WWW::Mechanize'		=> '1.54';
requires	'HTML::TreeBuilder' 	=> '3.23';

license 'MIT';

WriteAll;