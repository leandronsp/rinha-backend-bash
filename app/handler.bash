#!/bin/bash

declare -A params

function handleRequest() {
  ## Read the HTTP request until \r\n
  while read line; do
    #echo $line
    trline=$(tr -d '[\r\n]' <<< "${line}") ## Removes the \r\n from the EOL

    ## Breaks the loop when line is empty
    [[ -z "$trline" ]] && break

    ## Parses the headline
    ## e.g GET /contagem-pessoas HTTP/1.1 -> GET /contagem-pessoas
    HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'

    [[ "${trline}" =~ "${HEADLINE_REGEX}" ]] &&  {
      REQUEST=$(sed -E "s/${HEADLINE_REGEX}/\1 \2/" <<< "${trline}")
      echo ${REQUEST} >&2
      
      ## Parses the query string
      QUERY_STRING_REGEX='(.*?)\?t=(.*)'
      [[ "${REQUEST}" =~ "${QUERY_STRING_REGEX}" ]] && {
        PARAMS["term"]="$(sed -E "s/$QUERY_STRING_REGEX/\2/" <<< "${REQUEST}")"
        REQUEST="$(sed -E "s/$QUERY_STRING_REGEX/\1/" <<< "${REQUEST}")"
      }

      ## Parses the path parameter (UUID)
      # e.g GET /pessoas/123e4567 HTTP/1.1 -> GET /pessoas/:id -> 123e4567
      PATH_PARAMETER_REGEX='(.*?\s\/.*?)\/(.*?)$'
      [[ "${REQUEST}" =~ "${PATH_PARAMETER_REGEX}" ]] && {
        PARAMS["id"]="$(sed -E "s/$PATH_PARAMETER_REGEX/\2/" <<< "${REQUEST}")"
        REQUEST="$(sed -E "s/$PATH_PARAMETER_REGEX/\1\/:id/" <<< "${REQUEST}")"
      }
    }

    ## Parses the Content-Length header
    ## e.g Content-Length: 42 -> 42
    CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
    [[ "${trline}" =~ "${CONTENT_LENGTH_REGEX}" ]] && {
      CONTENT_LENGTH="$(sed -E "s/$CONTENT_LENGTH_REGEX/\1/" <<< "${trline}")"
    }

    ## Parses the Cookie header
    ## e.g Cookie: name=John -> name John
    COOKIE_REGEX='Cookie:\s(.*?)\=(.*?).*?'
    [[ "${trline}" =~ "${COOKIE_REGEX}" ]] &&
      IFS=" " read COOKIE_NAME COOKIE_VALUE <<< "$(sed -E "s/$COOKIE_REGEX/\1 \2/" <<< "${trline}")"
  done

  ## Read the remaining HTTP request body
  [[ ! -z "${CONTENT_LENGTH}" ]] && {
    read -n"${CONTENT_LENGTH}" BODY
  }

  ## Route request to the response handler
  source ./app/search.bash
  source ./app/count.bash
  source ./app/find.bash
  source ./app/create.bash
  source ./app/not-found.bash

  ## Route request to the response handler
  case "$REQUEST" in
    "GET /contagem-pessoas") handle_GET_count ;;
    "GET /pessoas")          handle_GET_search ;;
    "GET /pessoas/:id")      handle_GET_find ;;
    "POST /pessoas")         handle_POST_create ;;
    *)                       handle_not_found ;;
  esac

  echo -e "${RESPONSE}" > ${FIFO_PATH}
}
