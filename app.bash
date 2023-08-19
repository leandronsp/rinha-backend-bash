#!/bin/bash

## Create the response FIFO
FIFO_PATH=/tmp/response
rm -f $FIFO_PATH
mkfifo $FIFO_PATH

function handle_GET_hello() {
  RESPONSE=$(cat views/hello.jsonr)
  echo $RESPONSE
}

function handleRequest() {
  ## Read the HTTP request until \r\n
  while read line; do
    echo $line
    trline=$(echo $line | tr -d '[\r\n]') ## Removes the \r\n from the EOL

    ## Breaks the loop when line is empty
    [ -z "$trline" ] && break

    ## Parses the headline
    ## e.g GET /login HTTP/1.1 -> GET /login
    HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'
    [[ "$trline" =~ $HEADLINE_REGEX ]] &&
      REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")

    ## Parses the Content-Length header
    ## e.g Content-Length: 42 -> 42
    CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
    [[ "$trline" =~ $CONTENT_LENGTH_REGEX ]] &&
      CONTENT_LENGTH=$(echo $trline | sed -E "s/$CONTENT_LENGTH_REGEX/\1/")

    ## Parses the Cookie header
    ## e.g Cookie: name=John -> name John
    COOKIE_REGEX='Cookie:\s(.*?)\=(.*?).*?'
    [[ "$trline" =~ $COOKIE_REGEX ]] &&
      read COOKIE_NAME COOKIE_VALUE <<< $(echo $trline | sed -E "s/$COOKIE_REGEX/\1 \2/")
  done

  ## Read the remaining HTTP request body
  if [ ! -z "$CONTENT_LENGTH" ]; then
    BODY_REGEX='(.*?)=(.*?)'

    while read -n$CONTENT_LENGTH -t1 line; do
      #echo $line
      trline=`echo $line | tr -d '[\r\n]'`

      [ -z "$trline" ] && break

      read INPUT_NAME INPUT_VALUE <<< $(echo $trline | sed -E "s/$BODY_REGEX/\1 \2/")
    done
  fi

  ## Route request to the response handler
  case "$REQUEST" in
    "GET /hello")   handle_GET_hello ;;
  esac

  echo -e "$RESPONSE" > $FIFO_PATH
}

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
