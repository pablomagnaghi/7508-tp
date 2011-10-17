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
	echo charly controla directorio ${GRUPO}${!i}
	if [ ! -d $GRUPO${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio ${GRUPO}${!i}"
		exit 1
	fi
done


DIRECTORIOS=( CONFDIR DATAMAE LIBDIR ARRIDIR LOGDIR BINDIR )

for i in "${DIRECTORIOS[@]}";do
	echo charly controla directorio $GRUPO${!i}
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
	echo charly controla ejecutable ${BINDIR}/${!i}
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
	echo charly controla ejecutable ${LIBDIR}/${!i}
	if [ ! -x ${LIBDIR}/${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${LIBDIR}/${!i} o no tiene permiso de ejecución"
		exit 1
	fi
done


#Verifico existencia de los archivos maestros

ENCUESTAS="encuestas.mae"
PREGUNTAS="preguntas.mae"
ENCUESTADORES="encuestadores.mae"

ARCHIVOS=( ENCUESTAS PREGUNTAS ENCUESTADORES )

for i in "${ARCHIVOS[@]}";do
	echo charly controla maestro ${DATAMAE}/${!i}
	if [ ! -r ${DATAMAE}/${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe archivo ${$DATAMAE}/${!i} o no tiene permiso de lectura"
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



ARCHIVO_PID=".data.txt"

# vemos si existe el archivo testigo
echo charly dice que vamos a ver si existe $LIBDIR/$ARCHIVO_PID
if [ -r $LIBDIR/$ARCHIVO_PID ]; then
	
	PID=$(cat $LIBDIR/$ARCHIVO_PID)
	echo charly dice que existe un pidfile para el pid $PID
	# vemos si se esta ejecutando el proceso con el pid del archivo testigo
	echo 'charly dice que va a ejecutar ps ax | grep -q "^'$PID 
	ps ax | grep -q "^$PID "
	if [ $? -eq 0 ]; then
		echo "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
		return 1
	fi
	echo charly dice que no hay problema
	# el archivo testigo ha quedado de un mal cierre anteriormente
	rm $LIBDIR/$ARCHIVO_PID
fi

$LIBDIR/$START
r=$?
echo "Esperando a que $LIBDIR/$START inicie..."
sleep 2
if [ $r -ne 0 ]; then
	echo "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando ${START}"
	#exit 1
else
	#Busco el número de pid en el archivo data.txt
	#Hipotesis: este archivo esta en la carpeta actual si startD.sh
	#fue ejecutado exitosamente, data.txt solo contienen el número del proceso
	if [ ! -r $LIBDIR/$ARCHIVO_PID ]; then
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
sleep 5


