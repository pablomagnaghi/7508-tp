#!/bin/bash

################################### MOVERC ##########################################
#                                                                                   #
# Uso: moverC <origen> <destino> [<comando que invoca>]				    #
#										    #
# Errores: 1-Cantidad erronea de argumentos					    #
#	   2-Archivo origen o directorio destino inexistente			    #
#	   3-Archivo origen o directorio destino sin permisos	                    #
#                                                                                   #
#####################################################################################



#source utils.sh

# Validacion de cantidad de argumentos:
if [ $# -lt 2 ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Faltan argumentos. Uso: mover <origen> <destino> [<comando que invoca>]"
	echo "$MENSAJE"
	exit 1
fi

if [ $# -gt 3 ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Sobran argumentos. Uso: mover <origen> <destino> [<comando que invoca>]"
	echo "$MENSAJE"
	exit 1
fi

# Validacion de existencia de archivo origen y directorio destino:

ORIGEN=$1
DESTINO=$2

if [ ! -e $ORIGEN ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Archivo origen $ORIGEN inexistente"
	echo "$MENSAJE"
	exit 2
fi

if [ ! -r $ORIGEN -o  ! -w $ORIGEN ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Archivo origen $ORIGEN sin permisos"
	echo "$MENSAJE"
	exit 3
fi

if [ ! -d $DESTINO ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Directorio destino $DESTINO inexistente"
	echo "$MENSAJE"
	exit 2
fi

if [ ! -r $DESTINO -o  ! -w $DESTINO ]
then
	TIPO_MENSAJE="ES"
	MENSAJE="Directorio destino $DESTINO sin permisos"
	echo "$MENSAJE"
	exit 3
fi


NOMBRE_ARCHIVO=`echo "$ORIGEN" | sed 's/^.*\/\(.*\)$/\1/'`
DESTINO="$DESTINO/$NOMBRE_ARCHIVO"

if [ -e $DESTINO ] # si el archivo ya existe	
then
	RUTA_DUPLICADO="$2/dup"

	if [ ! -d $RUTA_DUPLICADO ] # si no existe el directorio /dup lo crea
	then
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

cp $ORIGEN $DESTINO
rm $ORIGEN

TIPO_MENSAJE="I"
MENSAJE="Movimiento desde $ORIGEN a $DESTINO"
echo "$MENSAJE"

if [ $# -eq 3 ]
then
	COMANDO_INVOCANTE="$3"
	echo "$MENSAJE"
fi

exit 0

