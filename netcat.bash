#!/bin/bash

PID=$$ 

## Create the response FIFO
mkdir -p /tmp/pid-$PID
FIFO_PATH=/tmp/pid-$PID/response
rm -f $FIFO_PATH
mkfifo $FIFO_PATH

source ./app/handler.bash

echo 'Listening on 3000...'

## Keep the server running forever
while true; do
  ## 1. wait for FIFO
  ## 2. creates a socket and listens to the port 3000
  ## 3. as soon as a request message arrives to the socket, pipes it to the handleRequest function
  ## 4. the handleRequest function processes the request message and routes it to the response handler, which writes to the FIFO
  ## 5. as soon as the FIFO receives a message, it's sent to the socket
  ## 6. closes the connection (`-N`), closes the socket and repeat the loop
  cat $FIFO_PATH | nc -lN 3000 | handleRequest
done
