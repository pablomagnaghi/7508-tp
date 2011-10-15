#startD.sh

startD() {
	#GRUPO="/home/luis/Escritorio/grupo2"

	if [ -e data.txt ]; then
		#agregar el log
		echo "demonio corriendo";
		return 1
	else
		echo "arrancando demonio";
		$GRUPO/bin/detectarC.sh &
		return 0
	fi;

}
