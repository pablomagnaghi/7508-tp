#!/bin/bash

# COMANDO - TIPO - MENSAJE 

GRUPO="/home/marcelo/Facu/PruebasSO/grupo02"


##### FLUJO PRINCIPAL #####
. "$GRUPO/conf/instalarC.conf"

# Verifico cantidad de parametros:
if [ $# != 3 ]; then
	echo "Cantidad de parámetros inválida."
	exit 1
fi

NOMBRE_USUARIO=`whoami`

#Tipo de MENSAJE
tipo="`echo $2 | tr "[:lower:]" "[:upper:]"`"
if [ "$tipo" = "I" -o "$tipo" = "A" -o "$tipo" = "E" -o "$tipo" = "SE" ];then
	TIPO_MENSAJE="$tipo"
else
	echo "Tipo de mensaje "$2" inválido."
	exit 1
fi

NOMBRE_COMANDO=$1
#Crear nombre de archivo
if [ ! -d "$LOGDIR" ]; then
	mkdir "$GRUPO/logdir" # directorio por defecto
	RUTA_ARCHIVO="$GRUPO/logdir/$NOMBRE_COMANDO$LOGEXT"
else
	RUTA_ARCHIVO="$LOGDIR/$1$LOGEXT"
fi

#Sacar espacios
MENSAJE=`echo "$3" | sed 's/\s\{1,\}/ /g' | sed 's/\(^\s\)\(.*\)\(\s$\)/\2/'`

TAMANIO_MAXIMO=`expr $MAXLOGSIZE \* 1024` # en bytes
FECHA_HORA=`date "+%d/%m/%Y-%H:%M:%S"`
mensajeALoguear="$FECHA_HORA - $NOMBRE_USUARIO - $NOMBRE_COMANDO - $TIPO_MENSAJE - $MENSAJE"
TAMANIO_MENSAJE=`echo $mensajeALoguear | wc -c` # en bytes

if [ $TAMANIO_MENSAJE -gt `expr $TAMANIO_MAXIMO / 2` ]; then
	echo "No se pudo loguear el mensaje ya que supera el tamaño máximo permitido."
	exit 1
fi

if [ -e "$RUTA_ARCHIVO" ]; then
	TAMANIO_ARCHIVO=`stat -c%s $RUTA_ARCHIVO` # en bytes

	if [ `expr $TAMANIO_MENSAJE + $TAMANIO_ARCHIVO` -gt $TAMANIO_MAXIMO ];then
		i=0

		tamanioAcumulado=0
		while read linea ; do
			i=$(($i+1));
			tamanioLinea=`echo $linea | wc -c`
			tamanioAcumulado=$(($tamanioAcumulado+$tamanioLinea));
			if [ $tamanioAcumulado -gt `expr $TAMANIO_ARCHIVO / 2` ]; then
				nroLinea=$(($i+1));
				break
			fi
		done < "$RUTA_ARCHIVO"

		lineaDesde=""
		lineaDesde="$nroLinea"		

		tail --lines=+"$lineaDesde" "$RUTA_ARCHIVO" >> "$RUTA_ARCHIVO.temp"

		rm "$RUTA_ARCHIVO"
		mv "$RUTA_ARCHIVO.temp" "$RUTA_ARCHIVO"

		FECHA_HORA=`date "+%d/%m/%Y-%H:%M:%S"`
		mensajeALoguear="$FECHA_HORA - $NOMBRE_USUARIO - $NOMBRE_COMANDO - A - Log excedido."	
		echo "Log excedido."
		echo "$mensajeALoguear" >> "$RUTA_ARCHIVO"
	fi
fi

#Loguear
FECHA_HORA=`date "+%d/%m/%Y-%H:%M:%S"`
mensajeALoguear="$FECHA_HORA - $NOMBRE_USUARIO - $NOMBRE_COMANDO - $TIPO_MENSAJE - $MENSAJE"

echo "$mensajeALoguear" >> "$RUTA_ARCHIVO"

exit 0
