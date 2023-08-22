function handle_GET_search() {
  SEARCH_TERM=${PARAMS["term"]}

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
    WHERE name ILIKE '%$SEARCH_TERM%'
) t"

    RESULT=`psql -t -h postgres -U postgres -d postgres -c "$QUERY" | tr -d '[:space:]'` 

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/search.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/search-no-results.jsonr)
    fi
  fi
}
