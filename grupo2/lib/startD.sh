#startD.sh


if [ -e  $GRUPO/lib/.data.txt ]; then
	#agregar el log
	echo "demonio corriendo";
	sleep 3
else
	echo "arrancando demonio $GRUPO/bin/detectarC.sh";
	$GRUPO/bin/detectarC.sh &
	sleep 3
fi;
