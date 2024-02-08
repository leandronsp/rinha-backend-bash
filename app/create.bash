function handle_POST_create() {
  [[ ! -z "${BODY}" ]] && {
    UUID="$(< "/proc/sys/kernel/random/uuid")"

    QUERY="
WITH data AS (
  SELECT
    '${BODY}'::json AS item
)
INSERT INTO people (id, name, nickname, birth_date, stack)
SELECT
  '${UUID}',
  item->>'nome',
  item->>'apelido',
  to_date(item->>'nascimento', 'YYYY-MM-DD'),
  ARRAY[item->>'stack']
FROM data"

    psql -h pgbouncer -U postgres -d postgres -p 6432 -c "${QUERY}" >&2
    PSQL_STATUS="${?}"

    [[ $PSQL_STATUS -ne 0 ]] && {
      RESPONSE="$(<  "views/422.http")"
    } || {
      RESPONSE="$( sed "s/{{uuid}}/${UUID}/" <<< "$(< "views/201.http")")"
    }
  }
}
