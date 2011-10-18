#!/bin/bash

#stopD

ARCHIVO_CONF="$GRUPO/conf/instalarC.conf"

. $ARCHIVO_CONF

if [ -e  $LIBDIR/.data.txt ]; then
	loguearC.sh stopD I "Parando el demonio"
	rm $LIBDIR/.data.txt;
else
	loguearC.sh stopD A "El demonio ya fue detenido"
fi

