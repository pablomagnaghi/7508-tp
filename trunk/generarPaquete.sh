#!/bin/bash
# Generador del paquete de instalacion
# Autor: Carlos Pantelides 74901

ACTUAL=$PWD
cd $(dirname $0)
if [ $? -ne 0 ]; then
	echo "Error"
	exit 1
fi

tar -czf $ACTUAL/grupo2.tgz \
./grupo2/inst/instalarC.sh \
./grupo2/inst/comandos/detectarC.sh \
./grupo2/inst/comandos/iniciarC.sh \
./grupo2/inst/comandos/listarC.pl \
./grupo2/inst/comandos/sumarC.sh \
./grupo2/inst/comandos/run.pl \
./grupo2/inst/mae/encuestas.mae \
./grupo2/inst/mae/preguntas.mae \
./grupo2/inst/mae/encuestadores.mae \
./grupo2/lib/Lib.pm \
./grupo2/lib/loguearC.sh \
./grupo2/lib/moverC.sh \
./grupo2/lib/mirarC.sh \
./grupo2/lib/Util.pm \
./grupo2/lib/stopD.sh \
./grupo2/lib/startD.sh
