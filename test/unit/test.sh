#!/bin/bash

echo "Start search tests $(pwd)"
for filename in *-test.lua; do
    resty -I ../../src -Ilib "$filename"
done