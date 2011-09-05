#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'MyApp',
  VERSION_FROM => 'lib/MyApp.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  EXE_FILES    => ['script/my_app'],
  PREREQ_PM    => {'Mojolicious' => '1.90'},
  test         => {TESTS => 't/*.t'}
);
