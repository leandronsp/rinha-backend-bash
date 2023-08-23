#!/bin/bash

ulimit -n 1024

echo 'Listening on 3000...'

while true; do
  socat -v -v -v TCP-LISTEN:3000,reuseaddr EXEC:"./app/handler.bash"
done
