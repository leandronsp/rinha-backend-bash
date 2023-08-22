# Exemplos de requests
# curl -v -XPOST -H "content-type: application/json" -d '{"apelido" : "xpto", "nome" : "xpto xpto", "nascimento" : "2000-01-01", "stack": null}' "http://localhost:9999/pessoas"
# curl -v -XGET "http://localhost:9999/pessoas/1"
# curl -v -XGET "http://localhost:9999/pessoas?t=xpto"
# curl -v "http://localhost:9999/contagem-pessoas"

GATLING_BIN_DIR=$HOME/gatling/bin
WORKSPACE=$PWD/stress-test

sh $GATLING_BIN_DIR/gatling.sh -rm local -s RinhaBackendSimulation \
    -rf $WORKSPACE/user-files/results \
    -sf $WORKSPACE/user-files/simulations \
    -rsf $WORKSPACE/user-files/resources \

curl -v "http://localhost:9999/contagem-pessoas"

## Report
GATLING_REPORT=`ls $WORKSPACE/user-files/results | sort | head -n 1`
OUTPUT_REPORT=/var/www/html/rinha

sudo cp -R $WORKSPACE/user-files/results/$GATLING_REPORT $OUTPUT_REPORT

echo "Report written to $OUTPUT_REPORT. Open http://localhost/rinha/index.html to see it."
