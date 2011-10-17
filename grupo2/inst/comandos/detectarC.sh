#!/bin/bash

#Inicializo variables
ARRIDIR="$GRUPO/arribos"
LIBDIR="lib"
BINDIR="bin"

#Escribo el pid de la aplicacion en el archivo .data.txt
pid=$(ps | grep -m 1 detectarC.sh | awk '{ print $1 }');
echo $pid > $GRUPO/lib/.data.txt;
if [ $? -ne 0 ]; then
	echo No se pudo crear archivo testigo
else 
	echo charly dice que esta todo bien

	#Ciclo del demonio
	while [ -e $GRUPO/lib/.data.txt ]; do
		echo charly dice que hacemos otro loop en $ARRIDIR
		cd $ARRIDIR
		for file in $(ls $ARRIDIR ); do
			echo charly dice que va a ver que hacer con $file
			if [ -f $file ];then
				validName=$(echo $file | grep -i '^[a-z]*\.[0-9]*$')
				if [ "$validName" != "" ];then
					echo charly dice que hay un nombre valido
					userid=$(echo $file | cut -d "." -f 1);
					idmatch=$(grep "^.*,.*,${userid}," $GRUPO/mae/encuestadores.mae);
					if [ "$idmatch" == "" ]; then
						echo charly dice que no existe el usuario
						$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/
						$GRUPO/$LIBDIR/loguearC.sh detectarC.sh A "No existe el usuario ${userid} en el archivo encuestadores, moviendo a rechazados"
					else
						date=$(echo $file | cut -d "." -f 2);
						begindate=$( echo ${idmatch} | cut -d "," -f 4);
						enddate=$( echo ${idmatch} | cut -d "," -f 5);
						if [ $begindate -le $date -a $enddate -ge $date ]; then
							echo charly dice que movera a preparados
							#moviendo a preparados
							$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/preparados/
							$GRUPO/$LIBDIR/loguearC.sh detectarC.sh I "Moviendo ${file} a preparados"
						else
							echo charly dice que mueve a rechazados por las fechas invalidas
							$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/
							$GRUPO/$LIBDIR/loguearC.sh detectarC.sh A "Fechas invalidas para ${userid}, moviendo a rechazados"
						fi
					fi
				else
					echo charly dice que mueve a rechazados por el nombre invalido
					$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/
					$GRUPO/$LIBDIR/loguearC.sh detectarC.sh A "Nombre invalido para ${file}"
				fi
			else
				echo charly dice que mueve $file a rechazados pues no es un archivo regular, pero pienso que es mejor ignorarlo
				$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/
				$GRUPO/$LIBDIR/loguearC.sh detectarC.sh A "${file} no es un archivo regular"
			fi
		done
		arch=$(ls $GRUPO/preparados )
		echo charly dice que $arch
		if [ $arch != "" ]; then
			echo charly dice que vamos a sumar $arch
			sumarC.sh
		fi
		sleep 10;
	done
	echo "saliendo de detectar"	
fi
