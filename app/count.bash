function handle_GET_count() {
  RESULT=`psql -t -h pgbouncer -U postgres -d postgres -p 6432 -c "SELECT COUNT(*) FROM people"`
  RESPONSE="$(sed "s/{{count}}/$RESULT/" <<< "$(< "views/count.textr")")"
}
