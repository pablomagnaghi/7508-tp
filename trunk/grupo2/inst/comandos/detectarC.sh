#!/bin/bash

#Inicializo variables
GRUPO="/home/luis/Escritorio/grupo2"
ARRIDIR="$GRUPO/arribos"
LIBDIR="lib"
BINDIR="bin"

#Escribo el pid de la aplicacion en el archivo .data.txt
pid=$(ps | grep -m 1 detectarC.sh | awk '{ print $1 }');
echo $pid > $GRUPO/lib/.data.txt;

#Ciclo del demonio
while [ -e .data.txt ] 
do
	cd $ARRIDIR;
	for file in $(ls);
	do
        	if [ -f $file ];then

			validName=$(echo $file | grep -i '^[a-z]*\.[0-9]*$')
			if [ "$validName" != "" ];then
			
				userid=$(echo $file | cut -d "." -f 1);
				idmatch=$(grep "^.*,.*,${userid}," $GRUPO/mae/encuestadores.mae);
				if [ "$idmatch" == "" ]; then
					./$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/;
			       	 	./$GRUPO/loguearC.sh detectarC.sh A "No existe el usuario ${userid} en el archivo encuestadores, moviendo a rechazados"
			
				else
        
	        			date=$(echo $file | cut -d "." -f 2);
                			begindate=$( echo ${idmatch} | cut -d "," -f 4);
                			enddate=$( echo ${idmatch} | cut -d "," -f 5);
                			if [ $begindate -le $date -a $enddate -ge $date ]; then
						#moviendo a preparados
						./$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/preparados/;
				       	 	./$GRUPO/loguearC.sh detectarC.sh I "Moviendo ${file} a preparados"
                			else
						./$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/;
				       	 	./$GRUPO/loguearC.sh detectarC.sh A "Fechas invalidas para ${userid}, moviendo a rechazados"
                			fi
        			fi
			else
				./$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/;
		       	 	./$GRUPO/loguearC.sh detectarC.sh A "Nombre invalido para ${file}"
			fi
		else
			./$GRUPO/$LIBDIR/moverC.sh $file $GRUPO/rechazados/;
	       	 	./$GRUPO/loguearC.sh detectarC.sh A "${file} no es un archivo regular"
		fi
	done
	cd $GRUPO/preparados/;
	arch=$(ls -a);
	if [ arch != "" ]; then	
		./$GRUPO/$BINDIR/sumarC.sh
	fi

	sleep 10;
	cd $GRUPO;

done	
