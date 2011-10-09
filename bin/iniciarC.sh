#!/bin/bash

#Comando: iniciarC.sh
#Autor: Magnaghi, Pablo
#Padrón: 88126

#VERIFICO PARAMETROS
#Si la cantidad de parámetros, exceptuando al cero, es mayor a cero
#muestro un mensaje de error

if [ $# -gt 0 ]; then
	echo "No pueden existir parametros" >&2
	exit 1
fi

#Para uso del autor la línea 17, luego debe borrarse para integración
. setGrupoPablo.sh 

#VERIFICO LA EXISTENCIA DEL ARCHIVO DE CONFIGURACION

ARCHIVO_CONF="$GRUPO/conf/instalarC.conf"

if [ ! -f $ARCHIVO_CONF ]; then
	echo "Inicialización de ambiente no fue exitosa. No existe archivo de configuración $ARCHIVO_CONF"
	exit 1
fi

#SETEO INICIAL DE LAS VARIABLES DE AMBIENTE

#Reviso si las variables han sido seteadas anteriormente 

VARIABLES=( CURRDIR CONFDIR DATAMAE LIBDIR BINDIR ARRIDIR DATASIZE LOGDIR LOGEXT MAXLOGSIZE 
INICIARU INICIARF DETECTARU DETECTARF SUMARU SUMARF LISTARU LISTARF )

for i in "${VARIABLES[@]}";do
	if [ ! -z ${!i} ]; then
		#echo "Variable ya seteada $i"
		SETEADAS[${#SETEADAS[*]}]="$i=${!i}"
	fi
done

#Si hay alguna advertencia la muestro
if [ ${#SETEADAS[@]} -ne 0 ]; then
	echo "Advertencia: Las siguientes variables ya habían sido seteadas"
	for i in ${SETEADAS[@]};do
		echo $i
	done
fi

#Incluyo el archivo de configuracion para setear las variables

. $ARCHIVO_CONF

for i in "${VARIABLES[@]}";do
	export $i
done

#VERIFICO SI LA INSTALACION ESTA COMPLETA

#Verifico que los directorios esten creados
RECHAZADOS="/rechazados"
PREPARADOS="/preparados"
LISTOS="/listos"
NOLISTOS="/nolistos"
YA="/ya"

DIRECTORIOS=( RECHAZADOS PREPARADOS LISTOS NOLISTOS YA )

for i in "${DIRECTORIOS[@]}";do
	#echo "DIRECTORIO: $GRUPO${!i}"
	if [ ! -d $GRUPO${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio $GRUPO${!i}"
		exit 1
	fi
done

ENCUESTAS_SUM="/encuestas.sum"
ESCUESTAS_RECH="/encuestas.rech"

ARCHIVOS=( ENCUESTAS_SUM ESCUESTAS_RECH )

for i in "${ARCHIVOS[@]}";do
	if [ ! -r $GRUPO$YA${!i} -o ! -w $GRUPO$YA${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo $GRUPO$YA${!i} o no tiene permisos de lectura y/o escritura"
		exit 1
	fi
done


DIRECTORIOS=( CONFDIR DATAMAE LIBDIR ARRIDIR LOGDIR BINDIR )

for i in "${DIRECTORIOS[@]}";do
	#echo "DIRECTORIO: ${!i}"
	if [ ! -d ${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio ${!i}"
		exit 1
	fi
done

#Verifico la existencia de los archivos

DETECTAR="detectarC.sh"
SUMAR="sumarC.sh"
LISTAR="listarC.pl"
START="startD.sh"
STOP="stopD.sh"

ARCHIVOS=( DETECTAR SUMAR LISTAR START STOP )

for i in "${ARCHIVOS[@]}";do
	if [ ! -x ${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${!i} o no tiene permiso de ejecución"
		exit 1
	fi
done

#Verifico existencia de los archivos maestros

ENCUESTAS="/encuestas.mae"
PREGUNTAS="/preguntas.mae"
ENCUESTADORES="/encuestadores.mae"

ARCHIVOS=( ENCUESTAS PREGUNTAS ENCUESTADORES )

for i in "${ARCHIVOS[@]}";do
	if [ ! -r $DATAMAE${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo $DATAMAE${!i} o no tiene permiso de lectura"
		exit 1
	fi
done

#Seteo la variable PATH
export PATH="$PATH:$GRUPO/$BINDIR"

# Se setea una variable de control para saber si INICIAR fue ejecutado
export INICIADO=1

#Se realizo el seteo de las variables de ambiente y la verificación 
#de las condiciones óptimas para la ejecucion

#Invocar al script detectarC siempre que detectarC no se esté ejecutando (verificar con ps).

#ps -ef lista todos los procesos actualmente en ejecución

#DEMONIO_CORRIENDO=$(ps -ef | grep "$DETECTAR")

DEMONIO_CORRIENDO=$(ps | grep "$DETECTAR")

#Verifico si el demonio esta corriendo

if [ -z "$DEMONIO_CORRIENDO" ]; then
	./$START
	if [ $? -ne 0 ]; then
		echo "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando ${START}"
		exit 1
	else
		#Busco el número de pid en el archivo data.txt
		#Hipotesis: este archivo esta en la carpeta actual si startD.sh
		#fue ejecutado exitosamente, data.txt solo contienen el número del proceso
		ARCHIVO_PID="data.txt"
		if [ ! -r $ARCHIVO_PID ]; then
			echo "Inicialización de ambiente no fue exitosa. No existe archivo ${ARCHIVO_PID} o no tiene permiso de lectura"
			exit 1
		else
			PID=$(cat $ARCHIVO_PID)	
		fi
	fi
else
	echo "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
	exit 1
fi

export ARCHIVO_ENCUESTAS=$GRUPO$YA$ENCUESTAS_SUM
export DIRECTORIO_YA=$GRUPO$YA

echo "Inicialización de Ambiente Concluida"
echo "Ambiente"

for i in "${VARIABLES[@]}";do
	echo "$i=${!i}"
done

echo "Demonio corriendo bajo el Nro.: <$PID>"

exit 0


#-------------ESTA PARTE QUEDA HASTA EL MARTES CUANDO NOS RESPONDAN SI PODEMOS OPTIMIZAR-----------------
#ps -ef lista todos los procesos actualmente en ejecución

#DEMONIO_CORRIENDO=$(ps -ef | grep "$DETECTAR")

#DEMONIO_CORRIENDO=$(ps | grep "$DETECTAR")

#verifico si el demonio esta corriendo

#if [ -z "$DEMONIO_CORRIENDO" ]; then
#	$DETECTAR &
#	pid=$!
#	if [ $? -ne 0 ]; then
#		echo "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando $DETECTAR"
#		exit 1
#	fi
#else
#	echo "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
#	exit 1
#fi

