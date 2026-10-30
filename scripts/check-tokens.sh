#!/usr/bin/env bash
# Fails when a component sets a text size from a raw number instead of a `theme.Typography` role.
# A line that is meant to be off the scale can end with `-- token-ok`.
set -euo pipefail
cd "$(dirname "$0")/.."
hits=$(grep -rnE 'TextSize *= *(A\.size\(theme, *)?[0-9]+' src/Components | grep -v 'token-ok' || true)
if [ -n "$hits" ]; then
	echo "Raw text sizes. Use a theme.Typography role, or mark the line with '-- token-ok':"
	echo "$hits"
	exit 1
fi
