use inc::Module::Install;

name 'Cirdan';

requires 'UNIVERSAL::require';
requires 'Exporter::Lite';
requires 'Any::Moose';
requires 'Text::MicroTemplate';
requires 'Encode';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'HTTP::Request::Common';

tests 't/*.t';

WriteAll;
