#!/usr/bin/env bash
set -euo pipefail

status=0

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  if ! LC_ALL=C grep -Iq . "$file"; then
    continue
  fi
  if ! perl -Mopen=':std,:encoding(UTF-8)' -ne '
    use utf8;
    our $bad;
    my %ok = map { $_ => 1 } (
      0x00E4, # ä
      0x00F6, # ö
      0x00FC, # ü
      0x00C4, # Ä
      0x00D6, # Ö
      0x00DC, # Ü
      0x00DF, # ß
      0x00A9, # ©
    );
    my $line = $.;
    BEGIN { $bad = 0 }
    while (/(.)/g) {
      my $ch = $1;
      my $ord = ord($ch);
      next if $ord <= 127;
      next if exists $ok{$ord};
      printf "%s:%d: disallowed character U+%04X (%s)\n", $ARGV, $line, $ord, $ch;
      $bad = 1;
    }
    END { exit($bad ? 1 : 0) }
  ' "$file"; then
    status=1
  fi
done < <(git ls-files)

if [[ "$status" -ne 0 ]]; then
  echo "Charset check failed." >&2
  exit 1
fi

exit 0
