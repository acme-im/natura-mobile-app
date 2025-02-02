#!/bin/bash

do_format() {
  find . -name '*.dart' ! -name '*.g.dart' ! -path '*/generated/*' ! -path './proto/*' | tr '\n' ' ' | xargs dart format --line-length 120 --set-exit-if-changed
}

if do_format; then
  exit 0
else
  echo "run ./scripts/format.sh before committing your changes"
  exit 1
fi
