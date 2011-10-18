#!/bin/bash

#startD.sh

ARCHIVO_CONF="$GRUPO/conf/instalarC.conf"

. $ARCHIVO_CONF

if [ -e  $LIBDIR/.data.txt ]; then
	loguearC.sh startD A "El demonio ya esta inicializado"
	sleep 3
else
	loguearC.sh startD I "Arrancando demonio"
	$BINDIR/detectarC.sh &
	sleep 3
fi;
