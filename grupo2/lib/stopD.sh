#stopD

stopD() {
	if [ -e .data.txt ]; then
		echo "parando demonio..";
		rm .data.txt;
		return 0
	else
		echo "demonio ya parado";
		return 1
	fi
}
