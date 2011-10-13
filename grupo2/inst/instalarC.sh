#!/bin/bash

CURRDIR=$PWD
GRUPO=${CURRDIR%/*}
USERID=`whoami`
ARCHIVO_LOG="$CURRDIR/instalarC.log"
ARRIDIR="$GRUPO/arribos"
DATASIZE="100"
BINDIR="$GRUPO/bin"
LOGDIR="$GRUPO/log"
LOGEXT=".log"
LOGSIZE="400"
ACEPTO_TERMINOS="no"

INICIARC_INSTALADO="0"
DETECTARC_INSTALADO="0"
SUMARC_INSTALADO="0"
LISTARC_INSTALADO="0"

loguear () { # $1: 1: logueo W5;
             #     2: logueo W5 y por stdout;
	     #     3: logueo !W5 y por stdout.
	     # $2: mensaje. 
	
	local mensaje="`date "+%d/%m/%Y-%H:%M:%S"` - $USERID - instalarC - I - $2 "
	case $1 in
	1)
		echo "$mensaje">>"$ARCHIVO_LOG"
		;;
	2)
		echo "$mensaje">>"$ARCHIVO_LOG"
		echo "$2"
		;;
	3)
		echo "$2" | tee -a "$ARCHIVO_LOG"
		;;
	esac
}

# Muestra del proceso cancelado
procesoCancelado () {
	loguear 2 "Proceso de instalación cancelado."
	exit 1
}

########## DETECTAR PAQUETE INSTALADO ##########
mostrarPaqueteInstalado (){ # $1 = $instalados 
		
	loguear 3 "*********************************************************"
	loguear 3 "*  Sistema Consultar Copyright SisOp (c)2011            *"
	loguear 3 "*********************************************************"
	loguear 3 "* Se encuentran instalados los siguientes componentes:  *"	
	echo -e  "$1" | tail --lines=+2 | tee -a "$ARCHIVO_LOG"	
	loguear 3 "*********************************************************"
}

mostrarPaqueteIncompleto () { # $1 = $instalados ; $2 =  $noInstalados
		
	loguear 3 "*********************************************************"
	loguear 3 "*  Sistema Consultar Copyright SisOp (c)2011            *"
	loguear 3 "*********************************************************"
	loguear 3 "* Se encuentran instalados los siguientes componentes:  *"	
	echo -e  "$1" | tail --lines=+2 | tee -a "$ARCHIVO_LOG"	
	loguear 3 "* Faltan instalar los componentes:                      *"	
	echo -e  "$2" | tail --lines=+2 | tee -a "$ARCHIVO_LOG"	
	loguear 3 "*********************************************************"
}

verificarLineaArchivoConf () {
	if [ "$1" = ""  ];then 
		loguear 2 "Archivo de configuración corrupto."
		procesoCancelado
	fi
}

verificarIntegridadArchivoConf () {

	if [ `cat "$GRUPO/conf/instalarC.conf" | grep CURRDIR | sed 's/CURRDIR=//'` != "$GRUPO" ];then
		loguear 2 "Archivo de configuración corrupto."
		procesoCancelado
	fi

	if [ `cat "$GRUPO/conf/instalarC.conf" | grep CONFDIR | sed 's/CONFDIR=//'` != "$GRUPO/conf" ];then
		loguear 2 "Archivo de configuración corrupto."
		procesoCancelado
	fi

	if [ `cat "$GRUPO/conf/instalarC.conf" | grep DATAMAE | sed 's/DATAMAE=//'` != "$GRUPO/mae" ];then
		loguear 2 "Archivo de configuración corrupto."
		procesoCancelado
	fi

	if [ `cat "$GRUPO/conf/instalarC.conf" | grep LIBDIR | sed 's/LIBDIR=//'` != "$GRUPO/lib" ];then
		loguear 2 "Archivo de configuración corrupto."
		procesoCancelado
	fi

	BINDIR=`cat "$GRUPO/conf/instalarC.conf" | grep BINDIR | sed 's/BINDIR=//'`
	verificarLineaArchivoConf "$BINDIR"

	ARRIDIR=`cat "$GRUPO/conf/instalarC.conf" | grep ARRIDIR | sed 's/ARRIDIR=//'`
	verificarLineaArchivoConf "$ARRIDIR"
	
	DATASIZE=`cat "$GRUPO/conf/instalarC.conf" | grep DATASIZE | sed 's/DATASIZE=//'`
	verificarLineaArchivoConf "$DATASIZE"

	LOGDIR=`cat "$GRUPO/conf/instalarC.conf" | grep LOGDIR | sed 's/LOGDIR=//'`
	verificarLineaArchivoConf "$LOGDIR"

	LOGEXT=`cat "$GRUPO/conf/instalarC.conf" | grep LOGEXT | sed 's/LOGEXT=//'`
	verificarLineaArchivoConf "$LOGEXT"

	LOGSIZE=`cat "$GRUPO/conf/instalarC.conf" | grep MAXLOGSIZE | sed 's/MAXLOGSIZE=//'`
	verificarLineaArchivoConf "$LOGSIZE"
}

detectarPaqueteInstalado () {
	local instalados=""
	local noInstalados=""
	local fechaInst=""
	local usrInst=""

	if [ -e "$GRUPO/conf/instalarC.conf" ]; then
		verificarIntegridadArchivoConf 
		if [ -f $BINDIR/iniciarC.sh ]; then
			fechaInst=`cat "$GRUPO/conf/instalarC.conf" | grep INICIARF | sed 's/INICIARF=//'`
			usrInst=`cat "$GRUPO/conf/instalarC.conf" | grep INICIARU | sed 's/INICIARU=//'`
			instalados=$instalados"\n* iniciarC.sh\t$fechaInst\t$usrInst\t\t*"
			INICIARC_INSTALADO="1"
		else
			noInstalados="* $noInstalados\n* iniciarC.sh\t\t\t\t\t\t*"
			INICIARC_INSTALADO="0"
		fi
		if [ -f $BINDIR/detectarC.sh ]; then
			fechaInst=`cat "$GRUPO/conf/instalarC.conf" | grep DETECTARF | sed 's/DETECTARF=//'`
			usrInst=`cat "$GRUPO/conf/instalarC.conf" | grep DETECTARU | sed 's/DETECTARU=//'`
			instalados=$instalados"\n* detectarC.sh\t$fechaInst\t$usrInst\t\t*"
			DETECTARC_INSTALADO="1"
		else
			noInstalados="$noInstalados\n* detectarC.sh\t\t\t\t\t\t*"
			DETECTARC_INSTALADO="0"
		fi
		if [ -f $BINDIR/sumarC.sh ]; then
			fechaInst=`cat "$GRUPO/conf/instalarC.conf" | grep SUMARF | sed 's/SUMARF=//'`
			usrInst=`cat "$GRUPO/conf/instalarC.conf" | grep SUMARU | sed 's/SUMARU=//'`
			instalados=$instalados"\n* sumarC.sh\t$fechaInst\t$usrInst\t\t*"
			SUMARC_INSTALADO="1"
		else
			noInstalados="$noInstalados\n* sumarC.sh\t\t\t\t\t\t*"
			SUMARC_INSTALDO="0"
		fi
		if [ -f $BINDIR/listarC.pl ]; then
			fechaInst=`cat "$GRUPO/conf/instalarC.conf" | grep LISTARF | sed 's/LISTARF=//'`
			usrInst=`cat "$GRUPO/conf/instalarC.conf" | grep LISTARU | sed 's/LISTARU=//'`
			instalados=$instalados"\n* listarC.pl\t$fechaInst\t$usrInst\t\t*"
			LISTARC_INSTALADO="1"
		else
			noInstalados="$noInstalados\n* listarC.pl\t\t\t\t\t\t*"
			LISTARC_INSTALADO="0"
		fi

		if [ "$INICIARC_INSTALADO" = "1" -a "$DETECTARC_INSTALADO" = "1" -a "$SUMARC_INSTALADO" = "1" -a "$LISTARC_INSTALADO" = "1" ];then
			loguear 1 "Mostrando paquete instalado."			
			mostrarPaqueteInstalado "$instalados"		
			return 0
		else
			loguear 1 "Mostrando paquete incompleto."
			mostrarPaqueteIncompleto "$instalados" "$noInstalados"
			return 1		
		fi
	else
		return 2
	fi
}

confirmarCompletarInstalacion () {
	loguear 1 "Confirmando completar instalación."
	BINDIR=`cat "$GRUPO/conf/instalarC.conf" | grep BINDIR | sed 's/BINDIR=//'`
	ARRIDIR=`cat "$GRUPO/conf/instalarC.conf" | grep ARRIDIR | sed 's/ARRIDIR=//'`
	DATASIZE=`cat "$GRUPO/conf/instalarC.conf" | grep DATASIZE | sed 's/DATASIZE=//'`
	LOGDIR=`cat "$GRUPO/conf/instalarC.conf" | grep LOGDIR | sed 's/LOGDIR=//'`
	LOGEXT=`cat "$GRUPO/conf/instalarC.conf" | grep LOGEXT | sed 's/LOGEXT=//'`
	LOGSIZE=`cat "$GRUPO/conf/instalarC.conf" | grep MAXLOGSIZE | sed 's/MAXLOGSIZE=//'`
	loguear 3 "Se instalarán los componentes faltantes y los parámetros de instalación serán los siguientes:"	
	loguear 3 "***********************************************************************"
	loguear 3 "* Parámetros de Instalación del paquete Consultar                     *"
	loguear 3 "***********************************************************************"
	loguear 3 "\"Directorio de trabajo: $GRUPO\""
	loguear 3 "\"Directorio de instalación: $GRUPO/inst\""
	loguear 3 "\"Directorio de configuración: $GRUPO/conf\""
	loguear 3 "\"Directorio de datos maestros: $GRUPO/mae\""
	loguear 3 "\"Directorio de ejecutables: $BINDIR\""
	loguear 3 "\"Librería de funciones: $GRUPO/lib\""
	loguear 3 "\"Directorio de arribos: $ARRIDIR\""
	loguear 3 "\"Espacio mínimo reservado en $ARRIDIR: $DATASIZE Mb\""
	loguear 3 "\"Directorio para los archivos de Log: $LOGDIR\""
	loguear 3 "\"Extensión para los archivos de Log: $LOGEXT\""
	loguear 3 "\"Tamaño máximo para cada archivo de Log: $LOGSIZE Kb\""
	loguear 3 "\"Log de la instalación: $GRUPO/inst\""
 	loguear 3 "***********************************************************************" 
	loguear 3 "¿Desea completar la instalación? S/N: "
	validarRespuesta
}


########## ACEPTACION DE TERMINOS Y CONDICIONES ##########
mostrarLicencia () {
	loguear 1 "Aceptacion de términos y condiciones:" 
	loguear 3 "*****************************************************************"
	loguear 3 "* 	Sistema Consultar Copyright SisOp (c)2011               *" 
	loguear 3 "*****************************************************************"
	loguear 3 "* Al instalar Consultar UD. expresa estar en un todo de acuerdo *"
	loguear 3 "* con los términos y condiciones del \"ACUERDO DE LICENCIA DE    *" 
	loguear 3 "* SOFTWARE\" incluido en este paquete.                    	*" 
 	loguear 3 "*****************************************************************" 
	loguear 3 "¿Está de acuerdo con los términos y condiciones? S/N: " 
}

validarRespuesta () {	
	local respuesta=""
	read respuesta #Leo la selección del usuario
	
	#Verifico que el usuario haya ingresado una opción correcta
	while [ "$respuesta" != "S" -a  "$respuesta" != "s" -a "$respuesta" != "N" -a "$respuesta" != "n" ]
	do
		echo "Opción inválida. Por favor ingrese S/N: "
		loguear 1 "Usuario ingreso respuesta incorrecta: $respuesta"
		read respuesta
	done
	loguear 1 "Respuesta del usuario: $respuesta" 
	
	if [ "$respuesta" = "N" -o  "$respuesta" = "n" ]
	then
		procesoCancelado
	fi
}

consultarLicencia () {
	mostrarLicencia
	validarRespuesta
}

########## VERIFICAR QUE PERL INSTALADO ##########
verificarPerlInstalado () { 
	perlExiste=`whereis perl`
	if [ "$perlExiste" != "perl:" ]
	then
		local versionPerl=`perl --version | grep -o 'v[0-9]\{1,2\}\(\.[0-9]\{1,2\}\)\{1,2\}'`
		local releasePerl=`echo "$versionPerl" | cut -f1 -d. | cut -c2-`
		if [ $releasePerl -ge 5 ]
		then
			loguear 2 "Perl $versionPerl instalado."
		else
			errorPerl;
		fi
	else
		errorPerl;
	fi
}

errorPerl () {
	loguear 1 "Perl versión 5 o superior no instalada."
	loguear 3 "Para instalar Consultar es necesario contar con Perl 5 o superior instalado. Efectúe su instalación e inténtelo nuevamente."        
	procesoCancelado;
}

########## MOSTRAR MENSAJES INFORMATIVOS  ##########
mostrarMensajesInformativos () {
	loguear 1 "Mostrando mensajes informativos."
	loguear 3 "Todos los directorios del sistema serán subdirectorios de $GRUPO"
	loguear 3 "Todos los componentes de la instalación se obtendrán del repositorio: $GRUPO/inst"
	loguear 1 "Listando directorio:"
	loguear 3 "`ls -B $GRUPO/inst`"
	loguear 3 "El log de la instalación se almacenará en $GRUPO/inst"
	loguear 3 "Al finalizar la instalación, si la misma fue exitosa se dejará un archivo de configuración en $GRUPO/conf"
}

########## DEFINIR DIRECTORIO DE ARRIBO DE ARCHIVOS EXTERNOS ##########
validarDirectorio () {
	if [ ! -z "`echo "$1" | grep ' '`" ]; then
		return 1
	fi

	if [ -e  $1 ]; then
		if [ ! -d $1 ]; then 			
			return 1		
		fi
	fi
	return 0;
}

definirDirectorioArriboArchivos () {
	local directorio=""
	loguear 1 "Definiendo directorio de arribo de archivos externos."
	loguear 3 "Ingrese el nombre del directorio que permite el arribo de archivos externos o Enter para dejar el directorio por defecto ($ARRIDIR): "
	read directorio
	if [ ! -z "$directorio" ]; then
		validarDirectorio "$GRUPO/$directorio"
		while [ $? != 0  -o  -z "$directorio" ]
		do
			echo "Directorio inválido. Intente nuevamente: "
			loguear 1 "Usuario ingreso directorio inválido: $directorio"
			read directorio
			validarDirectorio "$GRUPO/$directorio"
		done
		ARRIDIR="$GRUPO/$directorio"
	fi
	loguear 1 "Directorio elegido para arribo de archivos externos: $ARRIDIR"
}

########## DEFINIR ESPACIO MINIMO PARA DATOS ##########
validarNumero () {
	if [ ! -z "`echo "$1" | grep ' '`" -o -z "$1" ]; then
		return 1
	fi

	if [ ! -z "`echo "$1" | grep '[^0-9]\{1,\}'`" ]; then
		return 1
	fi
	if [ "$1" -le 0 ]; then
		return 1
	fi
	return 0
}


definirEspacioMinimoParaDatos () {
	local espacio=""
	local espacioLibre=`df -BM . | tail -1  | sed 's/ \+/,/g' | cut -f4 -d, | sed 's/M//'`
	loguear 1 "Definiendo espacio mínimo para datos"

	local valorValido="0"
	while [ $valorValido = "0" ]
	do	
		loguear 3 "Ingrese el espacio mínimo requerido para datos externos (en Mbytes) o Enter para dejar el valor por defecto ("$DATASIZE"Mb): "
		read espacio
		if [ ! -z "$espacio" ]; then
			validarNumero "$espacio"
			while [ $? != 0 ]
			do
				echo "Valor: $espacio inválido. Intente nuevamente: "
				loguear 1 "Usuario ingresó valor inválido: $espacio"
				read espacio
				validarNumero "$espacio"
			done
		else
			espacio=$DATASIZE
		fi

		if [ $espacioLibre -lt $espacio ]
		then
			loguear 3 "Insuficiente espacio en disco. Espacio disponible: $espacioLibre Mb. Espacio requerido $espacio Mb."
		else
			DATASIZE=$espacio
			valorValido="1"				
		fi
	done

	loguear 1 "Espacio mínimo elegido para datos externos: $DATASIZE Mb"
}

########## DEFINIR DIRECTORIO DE EJECUTABLES ##########
definirDirectorioEjecutables () {
	local directorio=""
	loguear 1 "Definiendo directorio de ejecutables."
	loguear 3 "Ingrese el nombre del subdirectorio de ejecutables o Enter para dejar el directorio por defecto ($BINDIR): "
	read directorio
	if [ ! -z "$directorio" ]; then
		validarDirectorio "$GRUPO/$directorio"
		while [ $? != 0 -o  -z "$directorio" ]
		do
			echo "Directorio inválido. Intente nuevamente: "
			loguear 1 "Usuario ingreso directorio inválido: $directorio"
			read directorio
			validarDirectorio "$GRUPO/$directorio"
		done
		BINDIR="$GRUPO/$directorio"
	fi
	loguear 1 "Directorio elegido para archivos ejecutables: $BINDIR"
}

########## DEFINIR DIRECTORIO PARA ARCHIVOS DE LOG ##########
definirDirectorioArchivosLog () {
	local directorio=""
	loguear 1 "Definiendo directorio para archivos de log."
	loguear 3 "Ingrese el nombre del directorio de log o Enter para dejar el directorio por defecto ($LOGDIR): "
	read directorio
	if [ ! -z "$directorio" ]; then
		validarDirectorio "$GRUPO/$directorio"
		while [ $? != 0 -o -z "$directorio" ]
		do
			echo "Directorio inválido. Intente nuevamente: "
			loguear 1 "Usuario ingreso directorio inválido: $directorio"
			read directorio
			validarDirectorio "$GRUPO/$directorio"
		done
		LOGDIR="$GRUPO/$directorio"
	fi
	loguear 1 "Directorio elegido para archivos de log: $LOGDIR"
}

########## DEFINIR EXTENSION Y TAMAÑO DE ARCHIVOS DE LOG ##########
definirExtensionArchivosLog () {

	local extension=""
	loguear 1 "Definiendo extensión para archivos de log."
	loguear 3 "Ingrese la extensión de log o Enter para dejar el valor por defecto ($LOGEXT): "
	read extension
	if [ ! -z "$extension" ]; then
		while [ ! -z "`echo $extension | grep "/"`" -o ! -z "`echo "$extension" | grep ' '`" -o  -z "$extension" ]
		do
			echo "Extensión inválida. Intente nuevamente: "
			loguear 1 "Usuario ingresó extensión inválida: $extension"
			read extension
		done
		LOGEXT=".$extension"
	fi
	loguear 1 "Extensión elegida para archivos de log: $LOGEXT"
}

definirTamanioArchivosLog () {
	local tamanio=""
	loguear 1 "Definiendo tamaño maximo para archivos de log."
	loguear 3 "Ingrese el tamaño máximo para los archivos $LOGEXT (en Kbytes) o Enter para dejar el valor por defecto ($LOGSIZE KB): "
	read tamanio
	if [ ! -z "$tamanio" ]; then
		validarNumero "$tamanio"		
		while [ $? != 0 ]
		do
			echo "Tamanio inválido. Intente nuevamente: "
			loguear 1 "Usuario ingresó tamanio inválido: $tamanio"
			read tamanio
			validarNumero "$tamanio"
		done
		LOGSIZE=$tamanio
	fi
	loguear 1 "Tamaño máximo elegido para archivos de $LOGEXT: $LOGSIZE Kb"
}

########## MOSTRAR ESTRUCTURA DE DIRECTORIOS Y VALORES DE PARAMETROS ##########
mostrarEstructuraDirectoriosYValoresParametros () {
	
	clear
	loguear 1 "Mostrando estructura de directorios y valores de parámetros."
	loguear 3 "***********************************************************************"
	loguear 3 "* Parámetros de Instalación del paquete Consultar                     *"
	loguear 3 "***********************************************************************"
	loguear 3 "\"Directorio de trabajo: $GRUPO\""
	loguear 3 "\"Directorio de instalación: $GRUPO/inst\""
	loguear 3 "\"Directorio de configuración: $GRUPO/conf\""
	loguear 3 "\"Directorio de datos maestros: $GRUPO/mae\""
	loguear 3 "\"Directorio de ejecutables: $BINDIR\""
	loguear 3 "\"Librería de funciones: $GRUPO/lib\""
	loguear 3 "\"Directorio de arribos: $ARRIDIR\""
	loguear 3 "\"Espacio mínimo reservado en $ARRIDIR: $DATASIZE Mb\""
	loguear 3 "\"Directorio para los archivos de Log: $LOGDIR\""
	loguear 3 "\"Extensión para los archivos de Log: $LOGEXT\""
	loguear 3 "\"Tamaño máximo para cada archivo de Log: $LOGSIZE Kb\""
	loguear 3 "\"Log de la instalación: $GRUPO/inst\""
	loguear 3 ""
	loguear 3 "Si los datos ingresados son correctos de ENTER para continuar, si desea modificar algún parámetro oprima cualquier tecla para reiniciar"
	loguear 3 "************************************************************************"
}

########## CONFIRMAR INICIO DE INSTALACION ##########
confirmarInstalacion () {
	
	loguear 1 "Confirmando instalación."
	loguear 3 "Iniciando Instalación... Está UD. seguro? (S/N): "
	local respuesta=""
	read respuesta
	
	#Verifico que el usuario haya ingresado una opción correcta
	while [ "$respuesta" != "S" -a  "$respuesta" != "s" -a "$respuesta" != "N" -a "$respuesta" != "n" ]
	do
		echo "Opción inválida. Por favor ingrese S/N: "
		loguear 1 "Usuario ingreso respuesta incorrecta: $respuesta"
		read respuesta
	done
	loguear 1 "Respuesta del usuario: $respuesta" 
	
	if [ "$respuesta" = "N" -o  "$respuesta" = "n" ]
	then
		loguear 1 "El usuario no confirmó la instalación."
		procesoCancelado
	fi
}

########## INSTALACIÓN ##########
verificarComandoInstalado () {
	if [ -e $BINDIR/$1 ]; then
		return 0
	else
		return 1
	fi
}

crearEstructurasDeDirectorio () {
	mkdir -p "$GRUPO/conf"
	mkdir -p "$GRUPO/mae"
	mkdir -p "$BINDIR"
	mkdir -p "$ARRIDIR"
	mkdir -p "$LOGDIR"
	mkdir -p "$GRUPO/rechazados"
	mkdir -p "$GRUPO/preparados"
	mkdir -p "$GRUPO/listos"
	mkdir -p "$GRUPO/nolistos"
	mkdir -p "$GRUPO/ya"
}

detectarComponenteFaltante (){
	if [ ! -f "$1" ];then
		loguear 2 "Paquete de instalación corrupto. Falta archivo "$1"."
		procesoCancelado
	fi
}

moverArchivosMaestrosYEjecutables () {
	if [ "$INICIARC_INSTALADO" = "0" ]; then
		detectarComponenteFaltante "$GRUPO/inst/comandos/iniciarC.sh"
		cp $GRUPO/inst/comandos/iniciarC.sh $BINDIR
		loguear 1 "Se movió iniciarC.sh."
	fi

	if [ "$DETECTARC_INSTALADO" = "0" ]; then
		detectarComponenteFaltante "$GRUPO/inst/comandos/detectarC.sh"
		cp $GRUPO/inst/comandos/detectarC.sh $BINDIR
		loguear 1 "Se movió detectarC.sh."
	fi

	if [ "$SUMARC_INSTALADO" = "0" ]; then
		detectarComponenteFaltante "$GRUPO/inst/comandos/sumarC.sh"
		cp $GRUPO/inst/comandos/sumarC.sh $BINDIR
		loguear 1 "Se movió sumarC.sh."
	fi

	if [ "$LISTARC_INSTALADO" = "0" ]; then
		detectarComponenteFaltante "$GRUPO/inst/comandos/listarC.pl"
		cp $GRUPO/inst/comandos/listarC.pl $BINDIR
		loguear 1 "Se movió listarC.pl."
	fi

	if [ ! -f "$GRUPO/mae/encuestas.mae" ];	then
		detectarComponenteFaltante "$GRUPO/inst/mae/encuestas.mae"
		cp $GRUPO/inst/mae/encuestas.mae $GRUPO/mae
		loguear 1 "Se movió encuestas.mae."
	fi

	if [ ! -f "$GRUPO/mae/encuestadores.mae" ];	then
		detectarComponenteFaltante "$GRUPO/inst/mae/encuestadores.mae"
		cp $GRUPO/inst/mae/encuestadores.mae $GRUPO/mae
		loguear 1 "Se movió encuestadores.mae."
	fi

	if [ ! -f "$GRUPO/mae/preguntas.mae" ];	then
		detectarComponenteFaltante "$GRUPO/inst/mae/preguntas.mae"
		cp $GRUPO/inst/mae/preguntas.mae $GRUPO/mae
		loguear 1 "Se movió preguntas.mae."
	fi

	detectarComponenteFaltante "$GRUPO/lib/moverC.sh"
	detectarComponenteFaltante "$GRUPO/lib/loguearC.sh"
	detectarComponenteFaltante "$GRUPO/lib/mirarC.sh"
	detectarComponenteFaltante "$GRUPO/lib/startD.sh"
	detectarComponenteFaltante "$GRUPO/lib/stopD.sh"

	FECHA_Y_HORA_INSTALACION=`date "+%d/%m/%Y-%H:%M:%S"`
}

actualizarArchivoConfiguracion () {
	loguear 1 "Actualizando archivo de configuración."	
	local archivoConfiguracion="$GRUPO/conf/instalarC.conf"
	if [ ! -f  $archivoConfiguracion ]; then		
		echo "CURRDIR=$GRUPO" > "$archivoConfiguracion"
		echo "CONFDIR=$GRUPO/conf" >> "$archivoConfiguracion"
		echo "DATAMAE=$GRUPO/mae" >> "$archivoConfiguracion"
		echo "LIBDIR=$GRUPO/lib" >> "$archivoConfiguracion"
		echo "BINDIR=$BINDIR" >> "$archivoConfiguracion"
		echo "ARRIDIR=$ARRIDIR" >> "$archivoConfiguracion"
		echo "DATASIZE=$DATASIZE" >> "$archivoConfiguracion"
		echo "LOGDIR=$LOGDIR" >> "$archivoConfiguracion"
		echo "LOGEXT=$LOGEXT" >> "$archivoConfiguracion"
		echo "MAXLOGSIZE=$LOGSIZE" >> "$archivoConfiguracion"

		verificarComandoInstalado "iniciarC.sh"
		if [ $?="0" ]; then

			echo "INICIARU=$USERID" >> "$archivoConfiguracion"
			echo "INICIARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoConfiguracion"
		else
			echo "INICIARU=" >> "$archivoConfiguracion"
			echo "INICIARF=" >> "$archivoConfiguracion"
		fi

		verificarComandoInstalado "detectarC.sh"
		if [ $?="0" ]; then
			echo "DETECTARU=$USERID" >> "$archivoConfiguracion"
			echo "DETECTARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoConfiguracion"
		else
			echo "DETECTARU=" >> "$archivoConfiguracion"
			echo "DETECTARF=" >> "$archivoConfiguracion"
		fi

		verificarComandoInstalado "sumarC.sh"
		if [ $?="0" ]; then
			echo "SUMARU=$USERID" >> "$archivoConfiguracion"
			echo "SUMARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoConfiguracion"
		else
			echo "SUMARU=" >> "$archivoConfiguracion"
			echo "SUMARF=" >> "$archivoConfiguracion"
		fi
	
		verificarComandoInstalado "listarC.sh"
		if [ $?="0" ]; then
			echo "LISTARU=$USERID" >> "$archivoConfiguracion"
			echo "LISTARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoConfiguracion"
		else
			echo "LISTARU=" >> "$archivoConfiguracion"
			echo "LISTARF=" >> "$archivoConfiguracion"
		fi
	else
		local archivoTemp="$GRUPO/conf/InstalarC.conf.temp"
		echo "CURRDIR=$GRUPO" > "$archivoTemp"
		echo "CONFDIR=$GRUPO/conf" >> "$archivoTemp"
		echo "DATAMAE=$GRUPO/mae" >> "$archivoTemp"
		echo "LIBDIR=$GRUPO/lib" >> "$archivoTemp"
		echo "BINDIR=$BINDIR" >> "$archivoTemp"
		echo "ARRIDIR=$ARRIDIR" >> "$archivoTemp"
		echo "DATASIZE=$DATASIZE" >> "$archivoTemp"
		echo "LOGDIR=$LOGDIR" >> "$archivoTemp"
		echo "LOGEXT=$LOGEXT" >> "$archivoTemp"
		echo "MAXLOGSIZE=$LOGSIZE" >> "$archivoTemp"

		if [ "$INICIARC_INSTALADO" = "0" ];then
			echo "INICIARU=$USERID" >> "$archivoTemp"
			echo "INICIARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoTemp"		
		else
			echo `cat "$archivoConfiguracion" | grep INICIARU` >> "$archivoTemp"
			echo `cat "$archivoConfiguracion" | grep INICIARF` >> "$archivoTemp"
		fi

		if [ "$DETECTARC_INSTALADO" = "0" ];then
			echo "DETECTARU=$USERID" >> "$archivoTemp"
			echo "DETECTARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoTemp"	
		else
			echo `cat "$archivoConfiguracion" | grep DETECTARU` >> "$archivoTemp"
			echo `cat "$archivoConfiguracion" | grep DETECTARF` >> "$archivoTemp"
		fi

		if [ "$SUMARC_INSTALADO" = "0" ];then
			echo "SUMARU=$USERID" >> "$archivoTemp"
			echo "SUMARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoTemp"	
		else
			echo `cat "$archivoConfiguracion" | grep SUMARU` >> "$archivoTemp"
			echo `cat "$archivoConfiguracion" | grep SUMARF` >> "$archivoTemp"
		fi

		if [ "$LISTARC_INSTALADO" = "0" ];then
			echo "LISTARU=$USERID" >> "$archivoTemp"
			echo "LISTARF=$FECHA_Y_HORA_INSTALACION" >> "$archivoTemp"
		else
			echo `cat "$archivoConfiguracion" | grep LISTARU` >> "$archivoTemp"
			echo `cat "$archivoConfiguracion" | grep LISTARF` >> "$archivoTemp"
		fi

		rm "$archivoConfiguracion"
		mv "$archivoTemp" "$archivoConfiguracion"
		
	fi
}

########## MOSTRAR MENSAJE INDICANDO QUÉ FUE LO QUE SE INSTALO ##########
mostrarMensajeFinInstalacion () {
	local instalados=""
	local noInstalados=""

	loguear 1 "Mostrando mensaje fin de instalación."
	detectarPaqueteInstalado 
	loguear 3 "* FIN del Proceso de Instalación Copyright SisOp (c)2011*"
	loguear 3 "*********************************************************"
}

########## FLUJO DE EJECUCIÓN ##########
loguear 1 "Inicio de Ejecución"
detectarPaqueteInstalado
case "$?" in
	0)
		crearEstructurasDeDirectorio
		moverArchivosMaestrosYEjecutables
		exit 0
		;;
	1)
		
		confirmarCompletarInstalacion
		;;
	2)
		consultarLicencia
		verificarPerlInstalado
		while [ ! -z "$ACEPTO_TERMINOS" ]
		do
			mostrarMensajesInformativos
			definirDirectorioArriboArchivos
			definirEspacioMinimoParaDatos
			definirDirectorioEjecutables
			definirDirectorioArchivosLog
			definirExtensionArchivosLog
			definirTamanioArchivosLog
			mostrarEstructuraDirectoriosYValoresParametros
			read ACEPTO_TERMINOS

			if [ ! -z "$ACEPTO_TERMINOS" ]; then
				clear
			fi	
		done
		confirmarInstalacion
		loguear 2 "Creando Estructuras de Directorio......."
		#crearEstructurasDeDirectorio
		#moverArchivosMaestrosYEjecutables
		;;
esac
crearEstructurasDeDirectorio
loguear 2 "Moviendo Archivos ...."	
moverArchivosMaestrosYEjecutables
actualizarArchivoConfiguracion
mostrarMensajeFinInstalacion
exit 0
