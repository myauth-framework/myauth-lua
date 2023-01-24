@echo off

IF [%1]==[] goto noparam

echo "Build image ..."
docker build --no-cache --build-arg MYAUTH_LUA_VERSION=%1 -t ghcr.io/myauth-framework/myauth-lua-host:%1 -t ghcr.io/myauth-framework/myauth-lua-host:latest .

echo "Publish image '%1' ..."
docker push ghcr.io/myauth-framework/myauth-lua-host:%1

echo "Publish image 'latest' ..."
docker push ghcr.io/myauth-framework/myauth-lua-host:latest

goto done

:noparam
echo "Please specify image version"
goto done

:done
echo "Done!"