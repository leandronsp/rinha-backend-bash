function handle_POST_create() {
  if [ ! -z "$BODY" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)

    QUERY="
WITH data AS (
  SELECT
    '$BODY'::json AS item
)
INSERT INTO people (id, name, nickname, birth_date, stack)
SELECT
  '$UUID',
  item->>'nome',
  item->>'apelido',
  to_date(item->>'nascimento', 'YYYY-MM-DD'),
  ARRAY[item->>'stack']
FROM data"

    psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "$QUERY" >&2
    PSQL_STATUS=$?

    if [ $PSQL_STATUS -ne 0 ]; then
      RESPONSE=$(cat views/422.http)
    else
      RESPONSE=$(cat views/201.http | sed "s/{{uuid}}/$UUID/")
    fi
  fi
}
