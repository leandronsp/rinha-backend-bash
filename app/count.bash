function handle_GET_count() {
  RESULT=`psql -t -h postgres -U postgres -d postgres -c "SELECT COUNT(*) FROM people"`
  RESPONSE=$(cat views/count.textr | sed "s/{{count}}/$RESULT/")
}
