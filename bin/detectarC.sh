#mientras el demonio este corriendo

for f in $(ls | grep -i '^[a-z]*\.[0-9]*$');
do
        userid=$(echo $f | cut -d "." -f 1);
        idmatch=$(grep "^.*,.*,${userid}," encuestadores.mae);
        if [ "$idmatch" == "" ]; then
                echo "no existe${userid}"i
                #loguear error
        else
                date=$(echo $f | cut -d "." -f 2);
                begindate=$( echo ${idmatch} | cut -d "," -f 4);
                enddate=$( echo ${idmatch} | cut -d "," -f 5);
                if [ $begindate -le $date -a $enddate -ge $date ]; then
                        echo "moviendo";
                        #mover a preparados
                        echo $f;
                        #mv $f /home/luis/Escritorio/;
                        #loguear exito
                fi
                #else 
                        #loguear error
        fi
done
#ir a preparados y hacer el sumar c
#sleep del demonio