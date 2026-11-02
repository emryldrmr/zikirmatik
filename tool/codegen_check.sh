#!/bin/sh
# Generated code is up to date (docs/conventions.md, Known traps: drift codegen goes stale).
# Hashes every generated file, regenerates (l10n + build_runner), hashes again; any difference
# — a changed, new or deleted generated file — fails with the list. Works before a commit too.
set -u
list() {
  find lib -type f \( -name '*.g.dart' -o -name 'app_localizations*.dart' \) | LC_ALL=C sort |
    while read -r f; do printf '%s %s\n' "$(sha1sum < "$f" | cut -d' ' -f1)" "$f"; done
}
before=$(list)
flutter gen-l10n >/dev/null || exit 1
dart run build_runner build --delete-conflicting-outputs >/dev/null || exit 1
after=$(list)
if [ "$before" != "$after" ]; then
  echo "codegen: generated code was stale — regenerated files differ:" >&2
  printf '%s\n' "$before" > "${TMPDIR:-/tmp}/codegen_before.$$"
  printf '%s\n' "$after" | diff "${TMPDIR:-/tmp}/codegen_before.$$" - >&2
  rm -f "${TMPDIR:-/tmp}/codegen_before.$$"
  echo "codegen: commit the regenerated files." >&2
  exit 1
fi
echo "codegen: generated code is up to date"
