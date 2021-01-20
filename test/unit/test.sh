#!/bin/bash

echo "Start search tests $(pwd)"
for filename in *-test.lua; do
    resty -I .. -Ilib "$filename"
done