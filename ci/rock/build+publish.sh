#!/bin/sh
set -eu

if [ -z "${1:-}" ]; then
  echo "Please specify rock version"
  echo "Done!"
  exit 1
fi

echo "Build & publish ..."
luarockapikey=$(sed -n '1s/\r$//p' apikey)

luarocks upload --force --api-key="$luarockapikey" "myauth-${1}.rockspec"

echo "Done!"
