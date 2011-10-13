#!/bin/bash

# COMANDO - FILTROS
# Filtros posibles:
#                   -n=<numero> 
#                   -t=<tipo: A|E|I|SE>
#                   -s="<string>"

GRUPO="/home/marcelo/Facu/PruebasSO/grupo02"

##### VALIDAR OPCION #####
validarOpcion () {
	 
	esOpcionCorrecta=`echo "$1" | grep '^-[n|t|s]=.*$'`
	if [ "$esOpcionCorrecta" = "" ]; then
		echo "Opcion incorrecta $1"	
		exit 1
	fi
	
	esOpcionN=`echo "$1" | grep '^-n=[0-9]\{1,\}$'`
	if [ "$esOpcionN" != "" ]; then
		nroLineas=`echo "$1" | sed 's/-n=//'`
		procesarOpcionN $nroLineas
	else
		esOpcionS=`echo "$1" | grep '^-s=.*$'`
		if [ "$esOpcionS" != "" ]; then
			string=`echo "$1" | sed 's/-s=//'`
			procesarOpcionS $string
		else
			esOpcionT=`echo "$1" | grep '^-t=[I|A|E|SE]$'`
			if [ "$esOpcionT" != "" ]; then
				tipo=`echo "$1" | sed 's/-t=//'`
				procesarOpcionT $tipo
			else
				echo "Opcion incorrecta $1"
				rm  "$RUTA_LOG.mostrar"
				exit 1
			fi
		fi
	fi	
}

##### PROCESAR OPCION N #####
procesarOpcionN () {
	tail --lines=$1 "$RUTA_LOG.mostrar" >> "$RUTA_LOG.temp"
	rm "$RUTA_LOG.mostrar"
	mv "$RUTA_LOG.temp" "$RUTA_LOG.mostrar"
}

##### PROCESAR OPCION S #####
procesarOpcionS () {
	grep "$1" "$RUTA_LOG.mostrar" >> "$RUTA_LOG.temp"
	rm "$RUTA_LOG.mostrar"
	mv "$RUTA_LOG.temp" "$RUTA_LOG.mostrar"
}

##### PROCESAR OPCION T #####
procesarOpcionT () {
	grep '^.*-.*-.*- '"$1"'.*$' "$RUTA_LOG.mostrar" >> "$RUTA_LOG.temp"
	rm "$RUTA_LOG.mostrar"
	mv "$RUTA_LOG.temp" "$RUTA_LOG.mostrar"
}




##### FLUJO PRINCIPAL #####

. "$GRUPO/conf/instalarC.conf"

# Verifico cantidad de parametros:
if [ $# -lt 1  ]; then
	echo "Cantidad de parámetros inválida."
	exit 1
fi

RUTA_LOG="$LOGDIR/$1$LOGEXT"
#Verificar que exista el archivo de log
if [ ! -f "$RUTA_LOG" ]; then
	echo "Archivo de log "$RUTA_LOG" inexistente"
	exit 1	
fi

if [ $# -eq 1 ]; then
	cat "$RUTA_LOG"
	exit 0 	
fi

cp "$RUTA_LOG" "$RUTA_LOG.mostrar"

for parametro in "$@"; do
	if [ "$parametro" != "$1" ]; then    
		validarOpcion "$parametro"
	fi
done

cat "$RUTA_LOG.mostrar"
rm  "$RUTA_LOG.mostrar"

exit 0
