#startD.sh

if [ -e data.txt ]; then
	#agregar el log
	echo "demonio corriendo";
else
	echo "arrancando demonio";
	detectarC.sh &
fi;
