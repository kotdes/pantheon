#!/bin/sh
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
testez="$root/DevPackages/_Index/roblox_testez@0.4.1/testez/src"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

if [ ! -d "$testez" ]; then
	echo "TestEZ is missing. Run 'wally install' first." >&2
	exit 1
fi

rewrite() {
	sed \
		-e 's|require(script\.Parent\.Parent\.src\.\([A-Za-z]*\))|require("../src/\1")|' \
		-e 's|require(script\.Parent\.Parent\.\([A-Za-z]*\))|require("../\1")|' \
		-e 's|require(script\.Parent\.\([A-Za-z]*\)\.\([A-Za-z]*\))|require("./\1/\2")|' \
		-e 's|require(script\.Parent\.\([A-Za-z]*\))|require("./\1")|' \
		"$1" | awk -v header="$3" 'NR == 1 && /^--!/ { print; print header; next } NR == 1 { print header } { print }' >"$2"
}

mkdir "$work/src"
for file in Path History Types Define Router Controller; do
	rewrite "$root/src/$file.luau" "$work/src/$file.luau" "local warn = function() end"
done

shim='local tick, typeof, warn, _G = os.clock, type, print, {}; local game = { GetService = function() return { Error = function(_, message) print(message) end } end }'
mkdir -p "$work/testez/Reporters"
for file in TestPlanner TestPlan TestRunner TestSession TestResults TestEnum Context Expectation ExpectationContext LifecycleHooks; do
	rewrite "$testez/$file.lua" "$work/testez/$file.luau" "$shim"
done
rewrite "$testez/Reporters/TextReporter.lua" "$work/testez/Reporters/TextReporter.luau" "$shim"

mkdir "$work/tests"
specs="return {"
for file in "$root"/tests/*.spec.luau "$root/tests/Helpers.luau"; do
	name="$(basename "$file")"
	rewrite "$file" "$work/tests/$name" ""
	case "$name" in
		*.spec.luau) specs="$specs { name = \"${name%.spec.luau}\", path = \"./tests/${name%.luau}\" },";;
	esac
done
echo "$specs }" >"$work/specs.luau"
cp "$root/tests/run.luau" "$work/run.luau"

luau "$work/run.luau"
