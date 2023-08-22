#!/bin/bash

ulimit -u 20

echo 'Listening on port 3000...'
socat -v -v -v TCP-LISTEN:3000,fork,reuseaddr EXEC:"./app/handler.bash"
