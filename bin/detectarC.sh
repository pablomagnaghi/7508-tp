#!/bin/bash
#mientras el demonio este corriendo

while [ -e .data.txt ] 
do
	for file in $(ls | grep -i '^[a-z]*\.[0-9]*$');
	do
        	userid=$(echo $file | cut -d "." -f 1);
	        idmatch=$(grep "^.*,.*,${userid}," encuestadores.mae);
        	if [ "$idmatch" == "" ]; then
                	echo "no existe${userid}";
               	 	#loguear error
        	else
                	date=$(echo $file | cut -d "." -f 2);
                	begindate=$( echo ${idmatch} | cut -d "," -f 4);
                	enddate=$( echo ${idmatch} | cut -d "," -f 5);
                	if [ $begindate -le $date -a $enddate -ge $date ]; then
                        	echo "moviendo";
                        	#mover a preparados
                        	echo $file;
                        	mv $file /home/luis/Escritorio/;
                        	#loguear exito
                	else
                        	echo "fechas invalidas para ${file}";
                        	#loguear error
                	fi
        	fi
	done
	#ir a preparados y hacer el sumar c
	sleep 10;
done	
#sleep del demonio
