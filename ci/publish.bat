@echo off

IF [%1]==[] goto noparam

echo "Build & publish ..."
set /p luarockapikey=<apikey

luarocks upload --skip-pack --force --api-key=%luarockapikey% myauth-%1.rockspec

goto done

:noparam
echo "Please specify rock version"
goto done

:done
echo "Done!"