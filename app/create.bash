function handle_POST_create() {
  if [ ! -z "$BODY" ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)

    QUERY="
WITH data AS (
  SELECT
    json_array_elements('$BODY'::json) AS item
)
INSERT INTO people (id, name, nickname, birth_date, stack)
SELECT
  '$UUID',
  item->>'nome',
  item->>'apelido',
  to_date(item->>'nascimento', 'YYYY-MM-DD'),
  ARRAY(SELECT json_array_elements_text(item->'stack'))
FROM data"

    psql -t -h postgres -U postgres -d postgres -c "$QUERY"
    RESPONSE=$(cat views/201.http | sed "s/{{uuid}}/$UUID/")
  fi
}
