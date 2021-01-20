@echo off
for %%f in (*-test.lua) do (
    resty -I ../../src -Ilib %%f 
)