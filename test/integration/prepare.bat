@echo off

echo "Start test servers..."
docker-compose -p myauth-lua-test -f test-env-docker-compose.yml up -d  

echo "Done!"