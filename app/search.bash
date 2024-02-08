function handle_GET_search() {
  SEARCH_TERM="${PARAMS["term"]}"

  [[ -z "${SEARCH_TERM}" ]] && {
    RESPONSE="$(< views/400.http)"
    return
  }

  [[ ! -z "${SEARCH_TERM}" ]] && {
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
    WHERE search LIKE '%${SEARCH_TERM}%'
    LIMIT 50
) t"

    RESULT="$(psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "${QUERY}" | tr -d '[:space:]')"

    [[ ! -z "${RESULT}" ]] && {
      RESPONSE=$(sed "s/{{data}}/${RESULT}/" <<< $(< "views/search.jsonr"))
    } || {
      RESPONSE="$(< "views/search-no-results.jsonr")"
    }
  }
}
