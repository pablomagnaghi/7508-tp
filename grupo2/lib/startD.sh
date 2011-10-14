#startD.sh

if [ -e data.txt ]; then
	#agregar el log
	echo "demonio corriendo";
else
	echo "arrancando demonio";
	cd ..
	cd inst/comandos/
	detectarC.sh &
fi;
