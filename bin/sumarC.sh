#!/bin/bash

paramsError=1
pregIdError=18
encuestaIdError=19

origIfs=$IFS
IFS=$'\n'

grupo=.
preguntas=($(cat "$grupo/mae/preguntas.mae"))
encuestas=($(cat "$grupo/mae/encuestas.mae"))
archSumario="$grupo/grupo2/ya/encuestas.sum"
archEncuestasRech="$grupo/grupo2/nolistos/encuestas.rech"
sc=,												# Separador de campos

: > "$archSumario" # TODO borrar
: > "$archEncuestasRech" # TODO borrar
: > "unArchivo" # TODO borrar

# Recibe un registro de tipo pregunta, devuelve la ponderacion
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

# Recibe id de pregunta y respuesta, devuelve el puntaje calculado
# Errores: id de pregunta no encontrado
obtenerPuntaje() {
	if [ -z "$1" ] ; then 
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

# Recibe codigo de encuesta, devuelve cantidad de preguntas para esa encuesta
# Errores: id de encuesta no encontrado
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

# Recibe el numero de linea del bloque cabecera y el nombre de una variable. 
# Emite el bloque y guarda en la variable el numero de linea del siguiente bloque
desecharBloque() {	
	aux="$1"
	ptrNroLineaSigBloque="$2"
	while [ "$aux" -le "${#lineas[@]}" -a `echo "${lineas[$aux]}" | grep -E -c "^D.*$"` -eq "1" ] ; do
		echo "${lineas[$aux]}"
		let "aux += 1"
	done
	eval $ptrNroLineaSigBloque="$aux"	
}

# validarCantidadPreguntas <primer registro de detalle> <cantidad de preguntas>
# devuelve 0 si coinciden, >0 si hay mas preguntas, <0 si hay menos
validarCantidadPreguntas() {
	aux="$1"
	while [ "$aux" -le "${#lineas[@]}" -a `echo "${lineas[$aux]}" | grep -E -c "^D.*$"` -eq "1" ] ; do
		let "aux += 1"
	done
	echo "$(($aux - $1 - $2))"
}

# validarNumeroEncuesta <primer registro de detalle> <numero de encuesta>
# Devuelve la cantidad de preguntas de esa encuesta
validarNumeroEncuesta() {
	aux="$1"
	while [ "$aux" -le "${#lineas[@]}" -a `echo "${lineas[$aux]}" | grep -E -c "^D${sc}$2${sc}.*$"` -eq "1" ] ; do
		let "aux += 1"
	done
	echo "$(($aux - $1))"
}

# Creo el archivo encuestas.sum si no existe
if [ ! -e $archSumario ] ; then
	: > "$archSumario"
fi
if [ ! -e $archEncuestasRech ] ; then
	: > "$archEncuestasRech"
fi

if [ ! -e "unArchivo" ] ; then # TODO borrar, solo para testing
	: > "unArchivo"
fi

dirIn=entrada
regexCabecera="^C${sc}[0-9]+${sc}.{3}${sc}[0-9]*${sc}[PLESO]${sc}.+${sc}(ID|II|RP|RC)${sc}[ETCP]${sc}(ESP|MKT|VEN|LEG)${sc}.*$"
regexDetalle="^D${sc}[0-9]+${sc}[0-9]+${sc}.+${sc}.*$"

archivos=`ls "$grupo"/"$dirIn" | cat`

for archivo in $archivos ; do
	echo "Procesando Archivo: $archivo"

	userId=`echo "$archivo" | cut -d "." -f 1`
	fechaEncuesta=`echo "$archivo" | cut -d "." -f 2`

	lineas=($(cat "$grupo"/"$dirIn"/"$archivo"))
	cantidadLineas=${#lineas[@]}

	formatoCabeceraValido=0
	nroLineaActual=-1

	while [ "$nroLineaActual" -le "${#lineas[@]}" ] ; do
		while [ "$formatoCabeceraValido" -ne "1" -a "$nroLineaActual" -le "$cantidadLineas" ] ; do
			let "nroLineaActual += 1"
			# TODO desechar bloque, log
			formatoCabeceraValido=`echo "${lineas[$nroLineaActual]}" | grep -E -c "$regexCabecera"`
		done

		if [ "$nroLineaActual" -gt "$cantidadLineas" ] ; then
			# TODO log
			break
		fi

		echo "Procesando cabecera: ${lineas[$nroLineaActual]}" >> "unArchivo"

		############################ Parseo registro cabecera #############################
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

		################################## Validaciones ###################################
		let "nroLineaActual += 1"
		resultado=`validarCantidadPreguntas "$nroLineaActual" "$cantPregEsperadas"`
		if [ "$resultado" -gt "0" ] ; then
			echo "mas preguntas de las esperadas" >> "unArchivo"
			desecharBloque="true"
		elif [ "$resultado" -lt "0" ] ; then
			echo "menos preguntas de las esperadas" >> "unArchivo"
			desecharBloque="true"
		elif [ `validarNumeroEncuesta "$nroLineaActual" "$nroEncuesta"` -ne "$cantPregEsperadas" ] ; then
			echo "numero de encuesta invalido" >> "unArchivo"
			desecharBloque="true"
		else 	
			############################# Calculo del puntaje #############################
			puntajeTotal="0"
			while [ "$cantPregEsperadas" -gt "0" ] ; do
				if [ $((`echo "${lineas[$nroLineaActual]}" | cut -d "$sc" -f 2`)) -ne "$nroEncuesta" ] ; then
					# TODO Log error
					desecharBloque="true"
					break
				fi
	
				pregId=`echo "${lineas[$nroLineaActual]}" | cut -d "$sc" -f 3`
				respuesta=`echo "${lineas[$nroLineaActual]}" | cut -d "$sc" -f 4`

				puntajeParcial=`obtenerPuntaje "$pregId" "$respuesta"`

				if [ $? -ne "0" ] ; then
					# Log error
					echo "Id de pregunta invalido $pregId" >> "unArchivo"	# TODO Borrar Linea
					desecharBloque="true"
					break
				fi
	
				let "puntajeTotal += puntajeParcial"
				let "nroLineaActual += 1"
				let "cantPregEsperadas -= 1"
			done
			########################### Fin Calculo del puntaje ###########################
		fi

		if [ "$desecharBloque" = "true" ] ; then
			echo "desecharBloque: $desecharBloque" >> "$archEncuestasRech"
		else
			echo "$userId${sc}$fechaEncuesta${sc}$nroEncuesta${sc}$codEncuesta${sc}$puntajeTotal${sc}$codCliente${sc}$sitioEncuesta${sc}$modEncuesta${sc}$personaEncuestada" >> "$archSumario"
		fi
		
		let "nroLineaActual += 1"

	done # Fin procesamiento del bloque
	
done # Fin procesamiento del archivo

IFS=$origIfs

exit 0
