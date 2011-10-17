#!/bin/bash
#======================================================================================
# AUTOR: Maximiliano Gismondi
#
# ARCHIVO: sumarC.sh
#
# USO: sumarC.sh
#======================================================================================


#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    #TODO
#
# PRE-CONDICIÓN:  
# POST-CONDICIÓN: 
#
# PARÁMETRO 1:    Tipo.
# PARÁMETRO 2:    Mensaje.
# 
# VALOR RETORNO:  0: Éxito
#======================================================================================
loguear() {
	$logcmd sumarC.sh $1 $2
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    #TODO
#
# PRE-CONDICIÓN:  
# POST-CONDICIÓN: 
#
# PARÁMETRO 1:    Tipo.
# PARÁMETRO 2:    Mensaje.
# 
# VALOR RETORNO:  0: Éxito
#======================================================================================
mover() {
	$movercmd "$1" "$2"
	return 0
}

#=== FUNCIÓN ==========================================================================
# DESCRIPCIÓN:    Parsea un registro pregunta ( del archivo 'preguntas.mae' ) para
#                 obtener el factor de ponderacion.
#
# PRE-CONDICIÓN:  El registro 'pregunta' que recibe esta correctamente formateado según 
#                 el enunciado del TP.
# POST-CONDICIÓN: Emite por stdout el factor numérico de ponderacion. Ej "-2","+1",etc
#
# PARÁMETRO 1:    Registro 'pregunta'.
# 
# VALOR RETORNO:  0: Éxito
#======================================================================================
obtenerPonderacion() {
	tipoPregunta=`echo $1 | cut -d $sc -f 3`
	ponderacion=`echo $1 | cut -d $sc -f 4`
	case "$ponderacion" in
		ALTA) ponderacionNum="3" ;;
		MEDIA) ponderacionNum="2" ;;
		BAJA) ponderacionNum="1" ;;
	esac

	echo "$tipoPregunta""$ponderacionNum"
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
	aux=-1
	while [ "$pregId" -ne "$1" -a "$aux" -le "${#preguntas[@]}" ] ; do
		let "aux += 1"
		pregId=`echo ${preguntas[$aux]} | cut -d $sc -f 1`
	done
	
	if [ "$pregId" -ne "$1" ] ; then
		return $pregIdError
	fi

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
#                 hasta llegar a una linea que no cumpla con la expresión regular
#                 almacenada en la variable 'regexDetalleSimple'
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
            `echo "${lineas[$aux]}" | grep -E -c "$regexDetalleSimple"` -eq "1" ] ; do
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
            `echo "${lineas[$aux]}" | grep -E -c "$regexDetalleSimple"` -eq "1" ] ; do
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
"`echo "${sumarioEncuestas[$aux]}" | cut -d "$sc" -f 3`" == "$1" ]] ; do
		let "aux += 1"
	done

	if [ "$aux" -eq "0" -o "$aux" -gt "${#sumarioEncuestas[@]}" ] ; then 
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
			loguear $logFatal "No existe el directorio: \"${i}\". Terminando la ejecución."
			return $dirNoEncontrado
		fi
	done

	maestros=( $archMaePreguntas $archMaeEncuestadores $archMaeEncuestas )

	for i in "${maestros[@]}";do
		if [ ! -f ${i} ]; then
			loguear $logFatal "No existe el archivo maestro: \"${i}\". Terminando la \
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

paramsError=1
noGrupoVar=2
noConfigFile=3
noLogger=4
noMover=5
dirNoEncontrado=6
archNoEncontrado=7
errorEncRepetida=10
pregIdError=18
encuestaIdError=19
encuestadorIdError=20

logInfo="I"
logAlerta="A"
logError="E"
logFatal="SE"

if [ ! $GRUPO ]; then
	echo "SEVERO - La variable \$GRUPO no ha sido inicializada. Terminando la \
ejecución"
	exit $noGrupoVar
fi

# TODO validar que no haya otra instancia corriendo

if [ ! -f "$GRUPO/conf/instalarC.conf" ]; then
	echo "SEVERO - No se ha encontrado el archivo de configuración en \
$GRUPO/conf/instalarC.conf. Terminando la ejecución"
	exit $noConfigFile
fi

. "$GRUPO/conf/instalarC.conf"

logcmd="$LIBDIR/loguearC.sh"
movercmd="$LIBDIR/moverC.sh"

if [ ! -f "$logcmd" ]; then
	echo "SEVERO - No se ha encontrado el script para loguear \"$logcmd\". \
Terminando la ejecución"
	exit $noLogger
fi

if [ ! -f "$movercmd" ]; then
	echo "SEVERO - No se ha encontrado el script para loguear \"$movercmd\". \
Terminando la ejecución"
	exit $noMover
fi

archMaePreguntas="$GRUPO/mae/preguntas.mae"
archMaeEncuestadores="$GRUPO/mae/encuestadores.mae"
archMaeEncuestas="$GRUPO/mae/encuestas.mae"
archSumario="$GRUPO/ya/encuestas.sum"
archEncuestasRech="$GRUPO/nolistos/encuestas.rech"

dirPreparados=$GRUPO"/preparados"
dirListos=$GRUPO"/listos"
dirRechazados=$GRUPO"/rechazados"




############################### Validación del entorno ################################
validarDirectoriosYArchivos
ambienteValido=$?
if [ $ambienteValido -ne 0 ] ; then
	exit $ambienteValido
fi


origIfs=$IFS
IFS=$'\n'

preguntas=($(cat "$archMaePreguntas"))
encuestadores=($(cat "$archMaeEncuestadores"))
encuestas=($(cat "$archMaeEncuestas"))
sc=,												# Separador de campos


#: > "$archSumario" # TODO borrar, testing 
#: > "$archEncuestasRech" # TODO borrar, testing 
#: > "archivoDeLog" # TODO borrar, testing 



regexEncuestador="^[0-9]{11}${sc}[^,]+${sc}[^,]{8}${sc}[0-9]{8}${sc}[0-9]{8}$"
regexCabecera="^C${sc}[0-9]+${sc}[^,]{3}${sc}[0-9]*${sc}[PLESO]${sc}[^,]+${sc}(ID|II|RP|RC)\
${sc}[ETCP]${sc}(ESP|MKT|VEN|LEG)${sc}.*$"
regexDetalle="^D${sc}[0-9]+${sc}[0-9]+${sc}.+${sc}.*$"
regexDetalleSimple="^D.*$"

archivos=`ls "$dirPreparados" | cat`

loguear $logInfo "Inicio procesamiento de archivos del directorio: \"$dirPreparados\""

for archivo in $archivos ; do

	if [ -f "$dirListos/$archivo" ] ; then
		loguear $logAlerta "El archivo \"$archivo\" ya se ha procesado. Será movido \
al directorio directorio de rechazados."
		mover "$dirPreparados/$archivo" "$dirRechazados" # TODO checkear si movio exitosamente
		continue
	fi
	
	loguear $logInfo "Archivo a Procesar: $archivo"

	userId=`echo "$archivo" | cut -d "." -f 1`

	validarUserId $userId
	if [ "$?" -eq "$encuestadorIdError" ] ; then
		loguear $logError "User Id de encuestador incorrecto. Archivo \"$archivo\"\
 rechazado"
		cat "$GRUPO"/"$dirPreparados"/"$archivo" >> "$archEncuestasRech"
		continue
	fi

	fechaEncuesta=`echo "$archivo" | cut -d "." -f 2` # TODO validar que sea una fecha valida
	lineas=($(cat "$dirPreparados"/"$archivo"))
	cantidadLineas=${#lineas[@]}

	formatoCabeceraValido=0
	nroLineaActual=0
	while [ "$nroLineaActual" -lt "$cantidadLineas" ] ; do

		########################## Valido formato cabecera ############################
		formatoCabeceraValido=0
		while [ "$formatoCabeceraValido" -ne "1" -a \
                "$nroLineaActual" -lt "$cantidadLineas" ] ; do

			formatoCabeceraValido=\
`echo "${lineas[$nroLineaActual]}" | grep -E -c "$regexCabecera"`

			if [ "$formatoCabeceraValido" -ne "1" ] ; then
				desecharBloque "$nroLineaActual" "nroLineaActual" \
                                >> "$archEncuestasRech" 
				loguear $logError "Formato de cabecera incorrecto, rechazando encuesta. \
Archivo \"$archivo\", línea número $nroLineaActual"
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

		################################ Validaciones #################################
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

		elif [ `validarNumeroEncuesta "$nroLineaActual" "$nroEncuesta"`\
                -ne "$cantPregEsperadas" ] ; then

			loguear $logError "No todos los registros detalles de la encuesta \
\"$nroEncuesta\" perteneciente al archivo \"$archivo\" tienen el mismo número de \
encuesta. Dicha encuesta será rechazada."
			desecharBloque="true"

		elif [ `validarEncuestaRepetida "$nroEncuesta"` -ne "0" ] ; then
			loguear $logError "Existe otra encuesta procesada previamente cuyo número \
de encuesta coincide con el de la encuesta que se está procesando. La encuesta \
número \"$nroEncuesta\" perteneciente al archivo \"$archivo\" será rechazada."
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

	done # Fin procesamiento del bloque

	mover "$dirPreparados/$archivo" "$dirListos" # TODO checkear si movio exitosamente
	
done # Fin procesamiento del archivo

IFS=$origIfs

exit 0
