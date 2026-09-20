#!/bin/bash

if [ -n "${1:-}" ]; then
  
  resty -I ../../src -Ilib ./$1-test.lua

else
  
  echo "Start search tests $(pwd)"

  find . -type f -name '*-test.lua' | while IFS= read -r file; do
    resty -I ../../src -Ilib "$file"
  done

fi