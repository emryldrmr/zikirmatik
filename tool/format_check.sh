#!/bin/sh
# Hand-written Dart is formatted; generated files keep their generator's layout.
find lib test -type f -name '*.dart' ! -name '*.g.dart' ! -name 'app_localizations*.dart' |
  xargs dart format --output=none --set-exit-if-changed
