#stopD

if [ -e .data.txt ]; then
	echo "parando demonio..";
	rm .data.txt;
else
	echo "demonio ya parado";
fi
