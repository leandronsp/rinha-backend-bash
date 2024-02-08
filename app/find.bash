function handle_GET_find() {
  UUID="${PARAMS["id"]}"

  [[ ! -z "${UUID}" ]] && {
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
    WHERE id = '${UUID}'
) t"

    RESULT="$(psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "$QUERY" | tr -d '[:space:]')"

    [[ ! -z "${RESULT}" ]] && {
      RESPONSE=$(sed "s/{{data}}/${RESULT}/" <<< "$(< "views/find.jsonr")")
    }||{
      RESPONSE=$(< "views/find-not-found.jsonr")
    }
  }
}
