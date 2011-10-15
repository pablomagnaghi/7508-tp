#!/bin/bash

#Inicializo variables
GRUPO="/home/luis/Escritorio/grupo2"
ARRIDIR="$GRUPO/arribos"

#Escribo el pid de la aplicacion en el archivo .data.txt
pid=$(ps | grep -m 1 detectarC.sh | awk '{ print $1 }');
echo $pid > $GRUPO/lib/.data.txt;


#Si no exiten los directorios rechazados y preparados, los crea
if [ ! -e $GRUPO/rechazados/ ];then
	mkdir $GRUPO/rechazados/;
fi
if [ ! -e $GRUPO/preparados/ ];then
	mkdir $GRUPO/preparados/;
fi

#Ciclo del demonio
while [ -e .data.txt ] 
do
	cd $ARRIDIR;
	for file in $(ls | grep -i '^[a-z]*\.[0-9]*$');
	do
        
		userid=$(echo $file | cut -d "." -f 1);
	        idmatch=$(grep "^.*,.*,${userid}," encuestadores.mae);
        	if [ "$idmatch" == "" ]; then
	
			mv $file $GRUPO/rechazados/;
               	 	#loguear error
        
		else
        
	        	date=$(echo $file | cut -d "." -f 2);
                	begindate=$( echo ${idmatch} | cut -d "," -f 4);
                	enddate=$( echo ${idmatch} | cut -d "," -f 5);
                	if [ $begindate -le $date -a $enddate -ge $date ]; then
                        	#mover a preparados
                        	mv $file $GRUPO/preparados/;
                        	#loguear exito
                	else
				mv $file $GRUPO/rechazados/;
                        	#loguear error
                	fi
        	fi
	done
	cd $GRUPO/preparados/;
	arch=$(ls -a);
	#if [ arch != "" ]; then	
	#	echo "iniciandosumarC"
	#fi

	#ir a preparados y hacer el sumar c
	sleep 10;
	cd $GRUPO;

done	
