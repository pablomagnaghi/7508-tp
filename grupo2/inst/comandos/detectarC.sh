#!/bin/bash

ARCHIVO_CONF="$GRUPO/conf/instalarC.conf"

. $ARCHIVO_CONF

#Escribo el pid de la aplicacion en el archivo .data.txt
pid=$(ps | grep -m 1 detectarC.sh | awk '{ print $1 }');
echo $pid > $LIBDIR/.data.txt;
if [ $? -ne 0 ]; then
	loguearC.sh detectarC SE "No se pudo crear el archivo testigo para ejecutar detectarC.sh"
else 
	loguearC.sh detectarC I "Arrancando demonio"

	#Ciclo del demonio
	while [ -e $LIBDIR/.data.txt ]; do

		cd $ARRIDIR

		for file in $(ls $ARRIDIR ); do

			if [ -f $file ];then
				validName=$(echo $file | grep -i '^[a-z]*\.[0-9]*$')

				if [ "$validName" != "" ];then
					userid=$(echo $file | cut -d "." -f 1);
					idmatch=$(grep "^.*,.*,${userid}," $DATAMAE/encuestadores.mae);

					if [ "$idmatch" == "" ]; then
						moverC.sh $file $GRUPO/rechazados/
						loguearC.sh detectarC A "No existe el usuario ${userid} en el archivo encuestadores, moviendo a rechazados"
					else
						date=$(echo $file | cut -d "." -f 2);
						begindate=$( echo ${idmatch} | cut -d "," -f 4);
						enddate=$( echo ${idmatch} | cut -d "," -f 5);

						if [ $begindate -le $date -a $enddate -ge $date ]; then
							moverC.sh $file $GRUPO/preparados/
							loguearC.sh detectarC I "Moviendo ${file} a preparados"
						else
							moverC.sh $file $GRUPO/rechazados/
							loguearC.sh detectarC A "Fechas invalidas para ${userid}, moviendo a rechazados"
						fi
					fi
				else
					moverC.sh $file $GRUPO/rechazados/
					loguearC.sh detectarC A "Nombre invalido para ${file}"
				fi
			else
				moverC.sh $file $GRUPO/rechazados/
				loguearC.sh detectarC A "${file} no es un archivo regular"
			fi
		done
		arch=$(ls $GRUPO/preparados )
		if [ "$arch" != "" ]; then
			loguearC.sh detectarC I "Invocando sumarC"
			sumarC.sh
		fi
		sleep 10;
	done
	loguearC.sh detectarC I "Terminando detectar.."
fi
