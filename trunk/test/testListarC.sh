#!/bin/bash
. ../bin/setGrupoCarlos.sh
RUN="../bin/listarC.pl"

testExitNoArgumentos() {
	$RUN > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status" 2 $exit
}

testOutputNoArgumentos() {
	$RUN 2>&1 | grep -q -e "Debe proveer un destino -c o -e"
	exit=$?
	assertEquals "Mal mensaje error" 0 $exit
}

testSalida() {
	$RUN -c 2>&1 | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "No salida a pantalla" 0 $exit

	$RUN -e 2>&1 | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "No salida a archivo" 0 $exit

	o=$($RUN -e -c 2>&1)
	echo $o | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "No salida a archivo" 0 $exit

	echo $o | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "No salida a archivo" 0 $exit
}




. shunit2/shunit2
