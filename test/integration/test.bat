@echo off

docker run ^
	--network=myauth-lua-test_default ^
	-v %cd%\test-server\test.lua:/test.lua ^
	--rm ^
	--name myauth-lua-integration-tester myauth-lua-integration-tester 