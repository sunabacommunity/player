#!/bin/bash
haxe buildsys.hxml

if (($? == 0))
then
  node build "$@"
fi