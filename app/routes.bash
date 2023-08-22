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
