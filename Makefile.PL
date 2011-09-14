#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Conifer',
  VERSION_FROM => 'lib/Conifer.pm',
  AUTHOR       => 'BlueT - Matthew Lien - 練喆明 <BlueT@BlueT.org>',
  EXE_FILES    => ['script/e04'],
  PREREQ_PM    => {
	'Mojolicious' => '1.90',
	'Data::Dumper' => 0,
	'Redis' => 0,
	'Time::HiRes' => 0,
	'MIME::Base64' => 0,
  },
  test         => {TESTS => 't/*.t'}
);
