function handle_GET_find() {
  UUID=${PARAMS["id"]}

  if [ ! -z "$UUID" ]; then
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
    WHERE id = '$UUID'
) t"

    RESULT=`psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "$QUERY" | tr -d '[:space:]'` 

    if [ ! -z "$RESULT" ]; then
      RESPONSE=$(cat views/find.jsonr | sed "s/{{data}}/$RESULT/")
    else
      RESPONSE=$(cat views/find-not-found.jsonr)
    fi
  fi
}
