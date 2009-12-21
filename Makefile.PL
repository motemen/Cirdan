use inc::Module::Install;

name 'Cirdan';

requires 'Any::Moose';
requires 'Encode';
requires 'Exporter::Lite';
requires 'JSON::Syck';
requires 'Text::MicroTemplate';
requires 'UNIVERSAL::require';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'HTTP::Request::Common';

tests 't/*.t';

WriteAll;
