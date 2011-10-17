#!/bin/bash

################################### MOVERC ##########################################
#                                                                                   #
# Uso: moverC.sh <origen> <destino> [<comando que invoca>]		            #
#										    #
# Errores: 1-Cantidad erronea de argumentos.					    #
#	   2-Archivo origen o directorio destino inexistente.			    #
#	   3-Archivo origen o directorio destino sin permisos.	                    #
#                                                                                   #
#####################################################################################

# Validacion de cantidad de argumentos:
if [ $# -lt 2 ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Faltan argumentos. Uso: mover <origen> <destino> [<comando que invoca>]."
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"
	exit 1
fi

if [ $# -gt 3 ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Sobran argumentos. Uso: mover <origen> <destino> [<comando que invoca>]."	
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"	
	exit 1
fi

# Validacion de existencia de archivo origen y directorio destino:

ORIGEN=$1
DESTINO=$2

if [ ! -e $ORIGEN ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Archivo origen $ORIGEN inexistente."
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"
	exit 2
fi

if [ ! -r $ORIGEN -o  ! -w $ORIGEN ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Archivo origen $ORIGEN sin permisos."
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"
	exit 3
fi

if [ ! -d $DESTINO ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Directorio destino $DESTINO inexistente"
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"
	exit 2
fi

if [ ! -r $DESTINO -o  ! -w $DESTINO ];then
	TIPO_MENSAJE="SE"
	MENSAJE="Directorio destino $DESTINO sin permisos."
	$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"
	exit 3
fi


NOMBRE_ARCHIVO=`echo "$ORIGEN" | sed 's/^.*\/\(.*\)$/\1/'`
DESTINO="$DESTINO/$NOMBRE_ARCHIVO"

if [ -e $DESTINO ];then # si el archivo ya existe	
	RUTA_DUPLICADO="$2/dup"
	if [ ! -d $RUTA_DUPLICADO ];then # si no existe el directorio /dup lo crea

		mkdir $RUTA_DUPLICADO
	fi

	SEC=0
	until [ ! -e $ARCHIVO_DUPLICADO ]
	do
		SEC=`expr $SEC + 1`
		ARCHIVO_DUPLICADO="$RUTA_DUPLICADO/$NOMBRE_ARCHIVO.$SEC"		
	done
	DESTINO=$ARCHIVO_DUPLICADO
fi

mv $ORIGEN $DESTINO


TIPO_MENSAJE="I"
MENSAJE="Movimiento desde $ORIGEN a $DESTINO exitoso."
$GRUPO/lib/loguearC.sh "moverC" "$TIPO_MENSAJE" "$MENSAJE"

if [ $# -eq 3 ];then
	MENSAJE="Movimiento desde $ORIGEN a $DESTINO exitoso a traves de moverC."
	COMANDO_INVOCANTE="$3"
	echo "$MENSAJE"
	$GRUPO/lib/loguearC.sh "$3" "$TIPO_MENSAJE" "$MENSAJE"
fi

exit 0

