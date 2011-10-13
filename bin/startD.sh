#startD.sh

if [ -e data.txt ]; then
	#agregar el log
	echo "demonio corriendo";
else
	echo "arrancando demonio";
	cd $GRUPO/inst/comandos/;
	detectarC.sh &
fi;
