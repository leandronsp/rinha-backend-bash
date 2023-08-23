#!/bin/bash

echo 'Listening on 3000...'
socat -v -v -v TCP-LISTEN:3000,fork,reuseaddr EXEC:"./app/handler.bash"
