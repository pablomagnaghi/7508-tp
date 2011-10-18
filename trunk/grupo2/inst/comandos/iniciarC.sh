#!/bin/bash

#Comando: iniciarC.sh
#Autor: Magnaghi, Pablo
#Padrón: 88126

#VERIFICO PARAMETROS
#Si la cantidad de parámetros, exceptuando al cero, es mayor a cero
#muestro un mensaje de error


if [ $0 != 'bash' ]; then
	echo "Este comando debe invocarse como \". iniciarC.sh\""
	exit 1
fi

if [ $# -gt 0 ]; then
	echo "No pueden existir parametros" >&2
	exit 1
fi

#VERIFICO LA EXISTENCIA DEL ARCHIVO DE CONFIGURACION

if [ -z $GRUPO ]; then
	echo "Inicialización de ambiente no fue exitosa. No Ha sido seteada la variable \$GRUPO"
	exit 1
fi


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
	if [ ! -d $GRUPO${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio ${GRUPO}${!i}"
		exit 1
	fi
done


DIRECTORIOS=( CONFDIR DATAMAE LIBDIR ARRIDIR LOGDIR BINDIR )

for i in "${DIRECTORIOS[@]}";do
	if [ ! -d ${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio ${GRUPO}${!i}"
		exit 1
	fi
done

#Verifico la existencia de los archivos en BINDIR

DETECTAR="detectarC.sh"
SUMAR="sumarC.sh"
LISTAR="listarC.pl"

ARCHIVOS=( DETECTAR SUMAR LISTAR )

for i in "${ARCHIVOS[@]}";do
	if [ ! -x ${BINDIR}/${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${BINDIR}/${!i} o no tiene permiso de ejecución"
		exit 1
	fi
done

#Verifico la existencia de los archivos

LOGUEAR="loguearC.sh"
MIRAR="mirarC.sh"
MOVER="moverC.sh"
START="startD.sh"
STOP="stopD.sh"

ARCHIVOS=( LOGUEAR MIRAR MOVER START STOP )

for i in "${ARCHIVOS[@]}";do
	if [ ! -x ${LIBDIR}/${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${LIBDIR}/${!i} o no tiene permiso de ejecución"
		exit 1
	fi
done

$LOGUEAR iniciarC I "Se han seteado las variables"
echo "Se han seteado las variables"

#Verifico existencia de los archivos maestros

ENCUESTAS="encuestas.mae"
PREGUNTAS="preguntas.mae"
ENCUESTADORES="encuestadores.mae"

ARCHIVOS=( ENCUESTAS PREGUNTAS ENCUESTADORES )

for i in "${ARCHIVOS[@]}";do
	if [ ! -r ${DATAMAE}/${!i} ]; then
		$LOGUEAR iniciarC SE "Inicialización de ambiente no fue exitosa. No existe archivo ${$DATAMAE}/${!i} o no tiene permiso de lectura"
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${$DATAMAE}/${!i} o no tiene permiso de lectura"
		exit 1
	fi
done

#Seteo la variable PATH
export PATH="$PATH:$GRUPO/$BINDIR"

#Se realizo el seteo de las variables de ambiente y la verificación 
#de las condiciones óptimas para la ejecucion

#Invocar al script detectarC siempre que detectarC no se esté ejecutando (verificar con ps).

ARCHIVO_PID=".data.txt"

# vemos si existe el archivo testigo
if [ -r $LIBDIR/$ARCHIVO_PID ]; then
	
	PID=$(cat $LIBDIR/$ARCHIVO_PID)
	# vemos si se esta ejecutando el proceso con el pid del archivo testigo
	
	ps ax | grep -q "$PID "
	if [ $? -eq 0 ]; then
		$LOGUEAR iniciarC SE "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
		echo "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
		exit 1
	fi
	rm $LIBDIR/$ARCHIVO_PID
fi

$LIBDIR/$START
r=$?

$LOGUEAR iniciarC I "Esperando a que $LIBDIR/$START inicie..."
echo "Esperando a que $LIBDIR/$START inicie..."

sleep 2

if [ $r -ne 0 ]; then
	$LOGUEAR iniciarC SE "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando ${START}"
	echo "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando ${START}"
	#exit 1
else
	#Busco el número de pid en el archivo data.txt
	#Hipotesis: este archivo esta en la carpeta actual si startD.sh
	#fue ejecutado exitosamente, data.txt solo contienen el número del proceso
	if [ ! -r $LIBDIR/$ARCHIVO_PID ]; then
		$LOGUEAR iniciarC SE "Inicialización de ambiente no fue exitosa. No existe archivo $LIBDIR/${ARCHIVO_PID} o no tiene permiso de lectura"
		echo "Inicialización de ambiente no fue exitosa. No existe archivo $LIBDIR/${ARCHIVO_PID} o no tiene permiso de lectura"
		#exit 1
	else
		PID=$(cat $LIBDIR/$ARCHIVO_PID)	
	fi
fi

#exporto variables para los comandos sumar y listar
ENCUESTAS_SUM="/encuestas.sum"
export GRUPO
export ARCHIVO_ENCUESTAS=$GRUPO$YA$ENCUESTAS_SUM
export DIRECTORIO_YA=$GRUPO$YA
export DIRECTORIO_LIB=$LIBDIR
export DIRECTORIO_MAESTROS=$DATAMAE


echo "Inicialización de Ambiente Concluida"
echo "Ambiente"

for i in "${VARIABLES[@]}";do
	echo "$i=${!i}"
done

echo "Demonio corriendo bajo el Nro.: <$PID>"


#escribo en log
$LOGUEAR iniciarC I "Inicialización de Ambiente Concluida"
$LOGUEAR iniciarC I "Ambiente"

for i in "${VARIABLES[@]}";do
	$LOGUEAR iniciarC I "$i=${!i}"
done

$LOGUEAR iniciarC I "Demonio corriendo bajo el Nro.: <$PID>"

sleep 5


