#!/bin/bash
#======================================================================================
# AUTOR: Maximiliano Gismondi
#
# ARCHIVO: sumarC.sh
#
# USO: sumarC.sh
#
# CÓD ERROR: 0: Ejecución exitosa.
#            1: Variable GRUPO o LIBDIR no inicializada.
#            2: Script loguearC no encontrado.
#            3: Script moverC no encontrado.
#            4: Directorio no encontrado (Ver log por más detalles).
#            5: Archivo no encontrado (Ver log por más detalles).
#            6: Error al ejecutar comando moverC.
#            7: Existe otra instancia de sumarC corriendo.
#======================================================================================


#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Invoca al comando loguearC
#
# PARÁMETRO 1:    Tipo.
# PARÁMETRO 2:    Mensaje.
# 
# VALOR RETORNO:  Retorna el valor que devuelve loguearC
#======================================================================================
loguear() {
	$logcmd "sumarC" "$1" "$2"
	errorCode=$?
	if [ $errorCode -ne "0" ]; then
		echo "SumarC - E - Hubo un error al invocar al logger. El código es: \"$?\". \
Los parametros con los que se invoco fueron Comando: sumarC Tipo:\"$1\" Mensaje:\"$2\""
	fi
	return $errorCode
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Invoca al comando moverC
#
# PARÁMETRO 1:    Archivo origen.
# PARÁMETRO 2:    Directorio destino.
# 
# VALOR RETORNO:  Retorna el valor que devuelve moverC
#======================================================================================
mover() {
	$movercmd "$1" "$2"
	return $?
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Parsea un registro pregunta ( del archivo 'preguntas.mae' ) para
#                 obtener el factor de ponderacion.
#
# PRE-CONDICIÓN:  El registro 'pregunta' que recibe esta correctamente formateado según 
#                 el enunciado del TP.
# POST-CONDICIÓN: Emite por stdout el factor numérico de ponderacion. Ej "-2","1",etc
#
# PARÁMETRO 1:    Registro 'pregunta'.
# 
# VALOR RETORNO:  0: Éxito
#======================================================================================
obtenerPonderacion() {
	tipoPregunta=`echo $1 | cut -d $sc -f 3`
	ponderacion=`echo $1 | cut -d $sc -f 4`
	case "$ponderacion" in
		"ALTA"  ) ponderacionNum="3" ;;
		"MEDIA" ) ponderacionNum="2" ;;
		"BAJA" ) ponderacionNum="1" ;;
	esac

	if [ $tipoPregunta == "+" ]; then
		echo "$ponderacionNum"
	else
		echo "$tipoPregunta""$ponderacionNum"
	fi
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Calcula el puntaje de una respuesta
#
# PRE-CONDICIÓN:  La variable 'preguntas' contiene las preguntas de el archivo maestro
#                 'preguntas.mae'
# POST-CONDICIÓN: Emite por stdout el puntaje de la respuesta
#
# PARÁMETRO 1:    Id de pregunta.
# PARÁMETRO 2:    Valor de la respuesta.
# 
# VALOR RETORNO:  0: Éxito
#                 $paramsError: Parámetro 1 o 2 nulo.
#                 $pregIdError: Id de pregunta no encontrado (i.e pregunta inexistente)
#======================================================================================
obtenerPuntaje() {
	if [ -z "$1" -o -z "$2" ] ; then 
		return $paramsError
	fi

	pregId=0
	aux=0
	while [ "$pregId" != "$1" -a "$aux" -le "${#preguntas[@]}" ] ; do
		pregId=`echo ${preguntas[$aux]} | cut -d ${sc} -f 1`
		let "aux += 1"
	done
	
	if [ "$aux" -gt "${#preguntas[@]}" ] ; then
		return $pregIdError
	fi

	let "aux -= 1"

	ponderacion=`obtenerPonderacion ${preguntas[$aux]}`
	respuesta=$2

	puntaje=$((ponderacion * respuesta))

	echo "$puntaje"
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Obtiene la cantidad de preguntas de una encuesta determinada
#
# PRE-CONDICIÓN:  La variable 'encuestas' contiene las preguntas de el archivo maestro
#                 'encuestas.mae'
# POST-CONDICIÓN: Emite por stdout la cantidad de preguntas para la encuesta que se
#                 corresponde con el id recibido como parametro 
#
# PARÁMETRO 1:    Id de encuesta.
# 
# VALOR RETORNO:  0: Éxito
#                 $paramsError - Parámetro 1 nulo
#                 $encuestaIdError - Id de encuesta no encontrado
#======================================================================================
obtenerCantPreguntas() {
	if [ -z "$1" ] ; then 
		return $paramsError
	fi
	
	codEncuesta=0
	aux=-1
	while [ "$codEncuesta" != "$1" -a "$aux" -le "${#encuestas[@]}" ] ; do
		let "aux += 1"
		codEncuesta=`echo "${encuestas[$aux]}" | cut -d "$sc" -f 1`
	done

	if [ "$codEncuesta" != "$1" ] ; then
		return $encuestaIdError
	fi

	echo "`echo "${encuestas[$aux]}" | cut -d $sc -f 3`"

	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Imprime un bloque de encuesta al archivo de encuestas rechazadas.
#
# PRE-CONDICIÓN:  La variable 'lineas' contiene las preguntas de el archivo de
#                 encuestas que se esta procesando.
# POST-CONDICIÓN: Emite por stdout el bloque Cabecera-n*Detalles que se quiere 
#                 desechar, comenzando por la linea que se recibe como primer parámetro
#                 hasta llegar a una linea que cumpla con la expresión regular "^C,.*$"
#                 Almacena en la variable ${!$2} el valor de la primer línea del 
#                 siguiente bloque.
#
# PARÁMETRO 1:    Número de la primer línea del bloque.
# PARÁMETRO 2:    Nombre de una variable en donde se almacenara el numero de línea del
#                 siguiente bloque.
# 
# VALOR RETORNO:  0: Éxito.
#======================================================================================
desecharBloque() {	
	aux="$1"
	ptrNroLineaSigBloque="$2"
	
	if [ `echo "${lineas[$aux]}" | grep -E -c "^C.*$"` -eq "1" ]; then
		echo "${lineas[$aux]}"
		let "aux += 1"
	fi

	while [ "$aux" -le "${#lineas[@]}" -a \
            		`echo "${lineas[$aux]}" | grep -E -c "^C,.*$"` -ne "1" ] ; do
		echo "${lineas[$aux]}"
		let "aux += 1"
	done
	eval $ptrNroLineaSigBloque="$aux"
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida que el userId se corresponda con un identificador de un
#                 encuestador válido.  
#
# PRE-CONDICIÓN:  La variable 'encuestadores' contiene la información sobre los 
#                 encuestadores almacenada en el archivo maestro de encuestadores 
#                 'encuestadores.mae'.
#
# POST-CONDICIÓN: ---
#
# PARÁMETRO 1:    Id de encuestador.
# 
# VALOR RETORNO:  0: El id de encuestador existe en el archivo maestro.
#                 $encuestadorIdError: El id de encuestador no fue encontrado.
#======================================================================================
validarUserId() {
	aux="0"
	while [ "$aux" -le "${#encuestadores[@]}" -a "$userIdActual" != "$1" ] ; do
		userIdActual=`echo "${encuestadores[$aux]}" | cut -d "${sc}" -f 3`
		let "aux += 1"
	done
	if [ "$userIdActual" == "$1" ] ; then
		return 0
	else
		return $encuestadorIdError
	fi
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida que la cantidad de respouestas de una encuesta determinada
#                 coincida con la cantidad esperada.
#
# PRE-CONDICIÓN:  La variable 'lineas' contiene las preguntas de el archivo de
#                 encuestas que se esta procesando.
# POST-CONDICIÓN: Emite por stdout 0 si la cantidad de respuestas coincide con la
#                 cantidad esperada. Un número mayor a 0 si hay más respuestas de las
#                 esperadas o un número menor a 0 si hay menos.
#
# PARÁMETRO 1:    Número de línea desde donde empezar a contar las respuestas.
# PARÁMETRO 2:    Cantidad de respuestas esperadas.
# 
# VALOR RETORNO:  0: Éxito.
#======================================================================================
validarCantidadPreguntas() {
	aux="$1"
	while [ "$aux" -le "${#lineas[@]}" -a  \
            `echo "${lineas[$aux]}" | grep -E -c "$regexDetalle"` -eq "1" ] ; do
		let "aux += 1"
	done
	echo "$(($aux - $1 - $2))"
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida que todas las respuestas de un mismo bloque posean el mismo
#                 número de encuesta.
#
# PRE-CONDICIÓN:  La variable 'lineas' contiene las preguntas de el archivo de
#                 encuestas que se esta procesando.
# POST-CONDICIÓN: Emite por stdout la cantidad de respuestas cuyo número de encuesta
#                 coincidió con el número de encuesta recibido por parámetro.
#
# PARÁMETRO 1:    Número de línea desde donde empezar a contar las respuestas.
# PARÁMETRO 2:    Número de encuesta.
# 
# VALOR RETORNO:  0: Éxito.
#======================================================================================
validarNumeroEncuesta() {
	aux="$1"
	while [ "$aux" -le "${#lineas[@]}" -a \
            `echo "${lineas[$aux]}" | grep -E -c "^D${sc}$2${sc}.*$"` -eq "1" ] ; do
		let "aux += 1"
	done
	echo "$(($aux - $1))"
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida que el número de encuesta sea único, i.e. no exista otra 
#                 encuesta, previamente procesada, con el mismo número de encuesta.
#
# PRE-CONDICIÓN:  Variable 'sumarioEncuestas' contiene la información del archivo
#                 'encuestas.sum'
# POST-CONDICIÓN: Emite por stdout 0 si la encuesta no esta repetida. Emite 
#                 $errorEncRepetida si ya existe una encuesta procesada con ese número.
#
# PARÁMETRO 1:    Número de encuesta.
# 
# VALOR RETORNO:  0: Todos lo casos.
#======================================================================================
validarEncuestaRepetida() {
	aux=0
	sumarioEncuestas=($(cat "$archSumario"))

	while [[ "$aux" -le "${#sumarioEncuestas[@]}" && \
"`echo "${sumarioEncuestas[$aux]}" | cut -d "${sc}" -f 3`" != "$1" ]] ; do

		let "aux += 1"
	done

	if [ "${#sumarioEncuestas[@]}" -eq "0" -o "$aux" -gt "${#sumarioEncuestas[@]}" ] ; then
		echo "0"
	else 
		echo "$errorEncRepetida"
	fi
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida los archivos y directorios necesarios para la ejecución del
#                 comando.
#
# PRE-CONDICIÓN:  Inicializar las variables a validar
# POST-CONDICIÓN: Devuelve un codigo de error que indica si es posible continuar con
#                 la ejecución. Emite a traves de la funcion 'loguear' una descripción
#                 del error ocurrido. 
#
# PARÁMETROS:     Sin parámetros.
# 
# VALOR RETORNO:  0: En caso de que se pueda continuar.
#                 $dirNoEncontrado: En caso de que no exista alguno de los directorios
#                 $archNoEncontrado: En caso de que no exista algun archivo maestro.
#======================================================================================
validarDirectoriosYArchivos() {
	directorios=( $GRUPO $dirPreparados $dirListos $dirRechazados )

	for i in "${directorios[@]}";do
		if [ ! -e ${i} -o ! -d ${i} ]; then
			loguear $logFatal "No existe el directorio: \"${i}\". Abortando \
la ejecución."
			return $dirNoEncontrado
		fi
	done

	maestros=( $archMaePreguntas $archMaeEncuestadores $archMaeEncuestas )

	for i in "${maestros[@]}";do
		if [ ! -f ${i} ]; then
			loguear $logFatal "No existe el archivo maestro: \"${i}\". Abortando la \
ejecución."
			return $archNoEncontrado
		fi
	done

	archivos=( $archSumario $archEncuestasRech )

	for i in "${archivos[@]}";do
		if [ ! -f ${i} ]; then
			loguear $logAlerta "No se encontro el archivo \"${i}\". Se creará uno \
vacío para continuar con la ejecución"
			: > "${i}"
		fi
	done

	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Valida el codigo de encuesta.
#
# PRE-CONDICIÓN:  
# POST-CONDICIÓN: 
#
# PARÁMETROS:     
# 
# VALOR RETORNO:  0: En todos los casos.
#======================================================================================
validarCodigoEncuesta() {
	aux=0

	while [[ "$aux" -le "${#encuestas[@]}" && \
"`echo "${encuestas[$aux]}" | cut -d "${sc}" -f 1`" != "$1" ]] ; do

		let "aux += 1"
	done
	
	if [ $aux -gt "${#encuestas[@]}" ]; then
		echo "1"
	else
		echo "0"
	fi

	return 0	
}

noVarReq=1
noLogger=2
noMover=3
dirNoEncontrado=4
archNoEncontrado=5
moverError=6
sumarCorriendoError=7
paramsError=7
errorEncRepetida=17
pregIdError=18
encuestaIdError=19
encuestadorIdError=20

logInfo="I"
logAlerta="A"
logError="E"
logFatal="SE"

logcmd="$LIBDIR/loguearC.sh"
movercmd="$LIBDIR/moverC.sh"

archMaePreguntas="$GRUPO/mae/preguntas.mae"
archMaeEncuestadores="$GRUPO/mae/encuestadores.mae"
archMaeEncuestas="$GRUPO/mae/encuestas.mae"
archSumario="$GRUPO/ya/encuestas.sum"
archEncuestasRech="$GRUPO/nolistos/encuestas.rech"

dirPreparados=$GRUPO"/preparados"
dirListos=$GRUPO"/listos"
dirRechazados=$GRUPO"/rechazados"

############################### Validación del entorno ################################
variables=( GRUPO LIBDIR )

for i in "${variables[@]}"; do
	if [ ! ${!i} ]; then
		echo "SEVERO - La variable ${i} no ha sido inicializada. Abortando la \
ejecución"
		exit $noVarReq
	fi
done

if [ ! -f "$logcmd" ]; then
	echo "SEVERO - No se ha encontrado el script para loguear \"$logcmd\". \
Abortando la ejecución"
	exit $noLogger
fi

if [ ! -f "$movercmd" ]; then
	echo "SEVERO - No se ha encontrado el script para loguear \"$movercmd\". \
Abortando la ejecución"
	exit $noMover
fi

validarDirectoriosYArchivos
ambienteValido=$?
if [ $ambienteValido -ne 0 ] ; then
	exit $ambienteValido
fi

###################### Checkeo si hay otra instancia corriendo ########################
archivoPid="$LIBDIR/.sumarC.pid"

if [ -e $archivoPid ]; then
	pid=$(cat $archivoPid)
	
	if [ `ps ax | grep -c "^[ ]*$pid "` -ne 0 ]; then
		loguear $logFatal "Existe otra instancia de sumarC ejecutándose actualmente. \
Esta ejecución será abortada."
		exit $sumarCorriendoError
	fi
	rm $archivoPid
fi

pid=$(ps | grep -m 1 sumarC.sh | awk '{ print $1 }');
echo $pid > $archivoPid; # Si no hay otra instancia, guardo el pid de ésta.



origIfs=$IFS
IFS=$'\n'

preguntas=($(cat "$archMaePreguntas"))
encuestadores=($(cat "$archMaeEncuestadores"))
encuestas=($(cat "$archMaeEncuestas"))
sc=,												# Separador de campos


regexEncuestador="^[0-9]{11}${sc}[^,]+${sc}[^,]{8}${sc}[0-9]{8}${sc}[0-9]{8}$"
regexCabecera="^C${sc}[0-9]+${sc}[^,]{3}${sc}[0-9]*${sc}[PLESO]${sc}[^,]+${sc}\
(ID|II|RP|RC)${sc}[ETCP]${sc}(ESP|MKT|VEN|LEG)${sc}.*$"
regexDetalle="^D${sc}[0-9]+${sc}[0-9]+${sc}.+${sc}.*$"
regexDetalleSimple="^D,.*$"

archivos=`ls "$dirPreparados" | cat`

loguear $logInfo "Ha iniciado el procesamiento de archivos del directorio: \
\"$dirPreparados\""

for archivo in $archivos ; do

	if [ -f "$dirListos/$archivo" ] ; then
		loguear $logAlerta "El archivo \"$archivo\" ya se ha procesado. Será movido \
al directorio directorio de rechazados."
		mover "$dirPreparados/$archivo" "$dirRechazados"
		if [ $? -ne "0" ]; then
			loguear $logFatal "No se ha movido con exito el archivo \
\"$dirPreparados/$archivo\" al directorio \"$dirListos\". Abortando ejecución."
			exit $moverError
		fi
		continue
	fi
	
	loguear $logInfo "Archivo a Procesar: $archivo"

	userId=`echo "$archivo" | cut -d "." -f 1`

	validarUserId $userId
	if [ "$?" -eq "$encuestadorIdError" ] ; then
		loguear $logError "User Id de encuestador incorrecto. Archivo \"$archivo\" \
rechazado"
		cat "$GRUPO"/"$dirPreparados"/"$archivo" >> "$archEncuestasRech"
		continue
	fi

	fechaEncuesta=`echo "$archivo" | cut -d "." -f 2`
	lineas=($(cat "$dirPreparados"/"$archivo"))
	cantidadLineas=${#lineas[@]}

	formatoCabeceraValido=0
	nroLineaActual=0

	####################### Ciclo de Procesamiento de Encuestas #######################
	while [ "$nroLineaActual" -lt "$cantidadLineas" ] ; do

		########################## Valido formato cabecera ############################
		formatoCabeceraValido=0
		while [ "$formatoCabeceraValido" -ne "1" -a \
                "$nroLineaActual" -lt "$cantidadLineas" ] ; do

			formatoCabeceraValido=\
`echo "${lineas[$nroLineaActual]}" | grep -E -c "$regexCabecera"`

			if [ "$formatoCabeceraValido" -ne "1" ] ; then 
				loguear $logError "Formato de cabecera incorrecto, rechazando \
encuesta. Archivo \"$archivo\", línea número $nroLineaActual"
				desecharBloque "$nroLineaActual" "nroLineaActual" \
>> "$archEncuestasRech"
			fi
		done

		if [ "$nroLineaActual" -ge "$cantidadLineas" ] ; then
			loguear $logAlerta "Se alcanzó el fin de archivo inesperadamente. \
Archivo \"$archivo\""
			break
		fi

		########################## Parseo registro cabecera ###########################
		cabecera=`echo "${lineas[$nroLineaActual]}"`
		nroEncuesta=`echo "$cabecera" | cut -d "$sc" -f 2`
		codEncuesta=`echo "$cabecera" | cut -d "$sc" -f 3`
		sitioEncuesta=`echo "$cabecera" | cut -d "$sc" -f 5`
		codCliente=`echo "$cabecera" | cut -d "$sc" -f 6`
		personaEncuestada=`echo "$cabecera" | cut -d "$sc" -f 7`
		modEncuesta=`echo "$cabecera" | cut -d "$sc" -f 8`
		cantPregEsperadas=`obtenerCantPreguntas "$codEncuesta"`

		inicioBloque=$nroLineaActual
		desecharBloque="false"

		######################## Validaciones a nivel bloque ##########################
		let "nroLineaActual += 1"
		resultado=`validarCantidadPreguntas "$nroLineaActual" "$cantPregEsperadas"`
		if [ "$resultado" -gt "0" ] ; then

			loguear $logError "Exceso de registro detalle. La encuesta número \
\"$nroEncuesta\" perteneciente al archivo \"$archivo\" será rechazada."
			desecharBloque="true"

		elif [ "$resultado" -lt "0" ] ; then

			loguear $logError "Falta de registro detalle. La encuesta número \
\"$nroEncuesta\" perteneciente al archivo \"$archivo\" será rechazada."
			desecharBloque="true"

		elif [ `validarCodigoEncuesta $codEncuesta` -ne "0" ]; then

			loguear $logError "No se reconoce a $codEncuesta como un código de encuesta\
 válido. La encuesta $nroEncuesta, del archivo $archivo será rechazada."
			desecharBloque="true"

		elif [ `validarNumeroEncuesta "$nroLineaActual" "$nroEncuesta"`\
                -ne "$cantPregEsperadas" ] ; then

			loguear $logError "No todos los registros detalles de la encuesta \
\"$nroEncuesta\" perteneciente al archivo \"$archivo\" tienen el mismo número de \
encuesta. Dicha encuesta será rechazada."
			desecharBloque="true"

		elif [ `validarEncuestaRepetida "$nroEncuesta"` -ne "0" ] ; then
			loguear $logError "Ya existe una encuesta cuyo número es \"$nroEncuesta\" \
procesada. La encuesta del archivo \"$archivo\", linea \"$inicioBloque\" será \
rechazada."
			desecharBloque="true"

		else
			########################### Calculo del puntaje ###########################
			puntajeTotal="0"
			while [ "$cantPregEsperadas" -gt "0" ] ; do
	
				pregId=`echo "${lineas[$nroLineaActual]}" | cut -d "$sc" -f 3`
				respuesta=`echo "${lineas[$nroLineaActual]}" | cut -d "$sc" -f 4`

				puntajeParcial=`obtenerPuntaje "$pregId" "$respuesta"`

				if [ $? -ne "0" ] ; then

					loguear $logError "Id de pregunta invalido, el id: \"$pregId\" no \
coincide con ninguna pregunta del archivo maestro. La encuesta número \
\"$nroEncuesta\" perteneciente al archivo \"$archivo\" será rechazada"
					desecharBloque="true"
					break
				fi
	
				let "puntajeTotal += puntajeParcial"
				let "nroLineaActual += 1"
				let "cantPregEsperadas -= 1"
			done
		fi

		if [ "$desecharBloque" = "true" ] ; then
			desecharBloque "$inicioBloque" "nroLineaActual" >> "$archEncuestasRech"
		else
			echo "$userId${sc}$fechaEncuesta${sc}$nroEncuesta${sc}$codEncuesta${sc}\
$puntajeTotal${sc}$codCliente${sc}$sitioEncuesta${sc}$modEncuesta${sc}\
$personaEncuestada" >> "$archSumario"
		fi

	done 
	######################## Fin procesamiento de la encuesta #########################

	mover "$dirPreparados/$archivo" "$dirListos"

	if [ $? -ne "0" ]; then
		loguear $logFatal "No se ha movido con exito el archivo \
\"$dirPreparados/$archivo\" al directorio \"$dirListos\". Abortando ejecución."
		exit $moverError
	fi

	loguear $logInfo "Archivo: \"$archivo\" procesado correctamente."
	
done # Fin procesamiento del archivo

loguear $logInfo "Ha finalizado el procesamiento de archivos del directorio: \
\"$dirPreparados\""

IFS=$origIfs
rm $archivoPid

exit 0
