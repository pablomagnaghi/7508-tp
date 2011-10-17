#!/bin/bash

# Autor: Carlos Pantelides 74901
# 
# Test para listarc.pl

#bootstrap
export GRUPO=/home/carlos/7508/7508fiuba2011g2/trunk
export DIRECTORIO_LIB=$GRUPO/grupo2/lib


fixture1() {
	export DIRECTORIO_MAESTROS=$GRUPO/test/fixtures/maestros
	export DIRECTORIO_YA=$GRUPO/test/fixtures/ya
	export ARCHIVO_ENCUESTAS=$DIRECTORIO_YA/encuestas.sum
	export LIMPIAR="$DIRECTORIO_YA"'/reporte*'
}

RUN="../grupo2/inst/comandos/listarC.pl"


extraDiff() {
	if [ $1 -eq 1 ]; then
		echo "------------------------------------------------------------------"
		echo "Fail....";
		echo "$2" > esperado.txt
		echo "$3" > salida.txt
		diff --side-by-side esperado.txt salida.txt
		echo "------------------------------------------------------------------"
	fi
}

oneTimeTearDown() {
	fixture1
	rm  -r $LIMPIAR
}

testEntorno() {
	fixture1
	echo "GRUPO               : $GRUPO"
	echo "DIRECTORIO_YA       : $DIRECTORIO_YA"
	echo "DIRECTORIO_LIB      : $DIRECTORIO_LIB"
	echo "DIRECTORIO_MAESTROS : $DIRECTORIO_MAESTROS" 
	echo "ARCHIVO_ENCUESTAS   : $ARCHIVO_ENCUESTAS"
	echo "RUN                 : $RUN"
	echo "LIMPIAR             : $LIMPIAR"
}

testExitNoSalida() {
	$RUN > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status" 3 $exit
}

testOutputNoSalida() {
	$RUN 2>&1 | grep -q -e "Debe proveer un destino -c o -e"
	exit=$?
	assertEquals "Mal mensaje error" 0 $exit
}

testSalida() {
	$RUN -c 2>&1 | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "-c No salida a pantalla" 0 $exit

	$RUN -e 2>&1 | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "-e No salida a archivo" 0 $exit

	o=$($RUN -e -c 2>&1)
	echo $o | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "-e -c No salida a archivo" 0 $exit

	echo $o | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "-c -e No salida a archivo" 0 $exit
}

testExitArgumentoDesconocido() {
	$RUN -x  > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -x" 2 $exit

	$RUN -x -E 1 > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -x -E 1" 2 $exit

	$RUN -E 1 -x  > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -E 1 -x" 2 $exit
}


testOutputArgumentoDesconocido() {
	$RUN -x 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-x Argumento desconocido no detectado" 0 $exit

	$RUN -E 1 -x 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-E 1 -x Argumento desconocido no detectado" 0 $exit

	$RUN -x -E 1 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-x -E 1 Argumento desconocido no detectado" 0 $exit
}

testExitCriteriosVacios() {
	$RUN -c -E  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -E no detectado" 4 $exit

	$RUN -c -C  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -C no detectado" 4 $exit

	$RUN -c -N  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -N no detectado" 4 $exit

	$RUN -c -S  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -S no detectado" 4 $exit
}

testOutputCriteriosVacios() {
	$RUN -c -E 2>&1 | grep -q -e "Debe proveer algun elemento para -E"
	exit=$?
	assertEquals "Critero vacio -E no detectado" 0 $exit

	$RUN -c -C 2>&1 | grep -q -e "Debe proveer algun elemento para -C"
	exit=$?
	assertEquals "Critero vacio -C no detectado" 0 $exit

	$RUN -c -N 2>&1 | grep -q -e "Debe proveer algun elemento para -N"
	exit=$?
	assertEquals "Critero vacio -N no detectado" 0 $exit

	$RUN -c -S 2>&1 | grep -q -e "Debe proveer algun elemento para -S"
	exit=$?
	assertEquals "Critero vacio -S no detectado" 0 $exit
}


testOutputFicha() {
	fixture1
	esperado=\
"Encuesta Nro: 1024 realizada por EPORRA Elisa Porra el dia 20110907

Cliente 30354444882, Modalidad P, Sitio E y Persona II

Encuesta aplicada E01 Estandar para nuevos clientes compuesta por 9 preguntas

Puntaje obtenido: 12 calificación: amarillo
--------------------------------------------------------------------------------"

	salida=$( $RUN 2>/dev/null -c -E EPORRA -F  )
	assertEquals "Salida de ficha no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}


testOutputReporteSinAgrupacionUnCasoUnEncuestadorUnCaso() {
	fixture1
	esperado=\
"+---------+----------+----------+----------+
|         |    verde | amarillo |     rojo |
+---------+----------+----------+----------+
| Totales |       -- |        1 |       -- |
+---------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -E EPORRA )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputReporteSinAgrupacionVariosCasos() {
	fixture1
	esperado=\
"+---------+----------+----------+----------+
|         |    verde | amarillo |     rojo |
+---------+----------+----------+----------+
| Totales |        2 |        3 |        2 |
+---------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputReporteAgrupadoPorEncuestadorUnEncuestadorUnCaso() {
	fixture1
	esperado=\
"+-------------+----------+----------+----------+
|             |    verde | amarillo |     rojo |
+-------------+----------+----------+----------+
| Elisa Porra |       -- |        1 |       -- |
|     Totales |       -- |        1 |       -- |
+-------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A e -E EPORRA )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputReporteAgrupadoPorEncuestadorUnEncuestadorVariosCasos() {
	fixture1
	esperado=\
"+--------------+----------+----------+----------+
|              |    verde | amarillo |     rojo |
+--------------+----------+----------+----------+
| Elio Stepano |        2 |        2 |        2 |
|      Totales |        2 |        2 |        2 |
+--------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A e -E ESTEPANO )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputReporteAgrupadoPorEncuestadorYCodigoUnEncuestadorVariosCasos() {
	fixture1
	esperado=\
"+------------------+----------+----------+----------+
|                  |    verde | amarillo |     rojo |
+------------------+----------+----------+----------+
| Elio Stepano.E02 |       -- |       -- |        1 |
| Elio Stepano.E03 |        2 |        2 |        1 |
|          Totales |        2 |        2 |        2 |
+------------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A e c -E ESTEPANO )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputComodinesEAsterisco() {
	fixture1
	esperado=\
"+--------------+----------+----------+----------+
|              |    verde | amarillo |     rojo |
+--------------+----------+----------+----------+
|  Elisa Porra |       -- |        1 |       -- |
| Elio Stepano |        2 |        2 |        2 |
|      Totales |        2 |        3 |        2 |
+--------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A e -E "E*" )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputComodinesEPAsterisco() {
	fixture1
	esperado=\
"+-------------+----------+----------+----------+
|             |    verde | amarillo |     rojo |
+-------------+----------+----------+----------+
| Elisa Porra |       -- |        1 |       -- |
|     Totales |       -- |        1 |       -- |
+-------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A e -E "EP*" )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}



testOutputComodinesPreguntaSAsterisco() {
	fixture1
	esperado=\
"+--------------+----------+----------+----------+
|              |    verde | amarillo |     rojo |
+--------------+----------+----------+----------+
| Elio Stepano |        2 |        2 |        2 |
|      Totales |        2 |        2 |        2 |
+--------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -E ?S* -A e )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}


testOutputComodinesE0Pregunta() {
	fixture1
	esperado=\
"+------------------+----------+----------+----------+
|                  |    verde | amarillo |     rojo |
+------------------+----------+----------+----------+
| E03.Elio Stepano |        2 |        2 |        1 |
|  E01.Elisa Porra |       -- |        1 |       -- |
| E02.Elio Stepano |       -- |       -- |        1 |
|          Totales |        2 |        3 |        2 |
+------------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A c e -C "E0?" )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputRangoNumero() {
	fixture1
	esperado=\
"+-----------------------+----------+----------+----------+
|                       |    verde | amarillo |     rojo |
+-----------------------+----------+----------+----------+
|  1024.E01.Elisa Porra |       -- |        1 |       -- |
| 1022.E03.Elio Stepano |        1 |       -- |       -- |
| 1023.E03.Elio Stepano |        1 |       -- |       -- |
|               Totales |        2 |        1 |       -- |
+-----------------------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -c -A n c e -N 1022 1024 )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}


. shunit2/shunit2
