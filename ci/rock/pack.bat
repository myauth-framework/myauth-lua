@echo off

IF [%1]==[] goto noparam

echo "Build ..."

luarocks pack  myauth-%1.rockspec

goto done

:noparam
echo "Please specify rock version"
goto done

:done
echo "Done!"