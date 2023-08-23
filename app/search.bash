function handle_GET_search() {
  SEARCH_TERM=${PARAMS["term"]}

  if [ -z "$SEARCH_TERM" ]; then
    RESPONSE=$(cat views/400.http)
    return
  fi

  if [ ! -z "$SEARCH_TERM" ]; then
    QUERY="
SELECT json_agg(row_to_json(t))
FROM (
    SELECT 
      id, 
      name as nome,
      nickname as apelido,
      birth_date as nascimento,
      stack
    FROM people 
    WHERE search LIKE '%$SEARCH_TERM%'
    LIMIT 50
) t"

    RESULT=`psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "$QUERY" | tr -d '[:space:]'` 

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/search.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/search-no-results.jsonr)
    fi
  fi
}
