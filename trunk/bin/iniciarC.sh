#!/bin/bash

#comando iniciarc.sh

#VERIFICO PARAMETROS
#Si la cantidad de parámetros, exceptuando al cero, es mayor a cero
#muestro un mensaje de error

if [ $# -gt 0 ] 
then
	echo "No pueden existir parametros" >&2
	exit 1
fi

#HIPOTESIS: No hace falta parsear la configuracion, pues tanto "~" como "grupo2" deben ser
#conocidos programaticamente, ya que la configuracion se halla en ~/grupo2/conf

#export GRUPO="~/grupo2/"

#ESTO FUE DE PRUEBA, COLOCAR LO NECESARIO PARA HACER PRUEBAS
export GRUPO="/home/pablo/Escritorio/PRUEBATPSO"

#VERIFICO LA EXISTENCIA DEL ARCHIVO DE CONFIGURACION

ARCHIVO_CONF="$GRUPO/conf/instalarC.conf"

if [ ! -f $ARCHIVO_CONF ]; then
	echo "Inicialización de ambiente no fue exitosa. No existe archivo de configuración $ARCHIVO_CONF"
	exit 1
fi

#SETEO INICIAL DE LAS VARIABLES DE AMBIENTE

#Reviso si las variables han sido seteadas anteriormente 

VARIABLES=( CURRDIR CONFDIR DATAMAE LIBDIR BINDIR ARRIDIR DATASIZE LOGDIR LOGEXT MAXLOGSIZE )

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

DIRECTORIOS=( RECHAZADOS PREPARADOS LISTOS NOLISTOS YA ARRIDIR LOGDIR BINDIR )

for i in "${DIRECTORIOS[@]}";do
	#echo "DIRECTORIO: $GRUPO${!i}"
	if [ ! -d $GRUPO${!i} ]; then
		echo "Inicialización de ambiente no fue exitosa. No existe directorio $GRUPO${!i}"
		exit 1
	fi
done

DIRECTORIOS=( CONFDIR DATAMAE LIBDIR )

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

ARCHIVOS=( DETECTAR SUMAR LISTAR )

for i in "${ARCHIVOS[@]}";do
	if [ ! -e ${!i} ]; then
	echo "Inicialización de ambiente no fue exitosa. No existe archivo ${!i}"
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
	echo "Inicialización de ambiente no fue exitosa. No existe archivo $DATAMAE${!i}"
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

#verifico si el demonio esta corriendo

if [ -z "$DEMONIO_CORRIENDO" ]; then
	$DETECTAR &
	pid=$!
	if [ $? -ne 0 ]; then
		echo "Inicialización de ambiente no fue exitosa. Error al ejecutar el comando $DETECTAR"
		exit 1
	fi
else
	echo "Inicialización de ambiente no fue exitosa. El comando $DETECTAR se encuentra corriendo"
	exit 1
fi

echo "Inicialización de Ambiente Concluida"
echo "Ambiente"
echo "CURRDIR=$CURRDIR"
echo "CONFDIR=$CONFDIR"
echo "DATAMAE=$DATAMAE"
echo "LIBDIR=$LIBDIR"
echo "BINDIR=$BINDIR"
echo "ARRIDIR=$ARRIDIR"
echo "DATASIZE=$DATASIZE"
echo "LOGDIR=$LOGDIR"
echo "LOGEXT=$LOGEXT"
echo "MAXLOGSIZE=$MAXLOGSIZE"
echo "Demonio corriendo bajo el Nro.: <$pid>"

exit 0











