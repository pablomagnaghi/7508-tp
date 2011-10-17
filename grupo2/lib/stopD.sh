#stopD

if [ -e  $GRUPO/lib/.data.txt ]; then
	echo "parando demonio..";
	rm $GRUPO/lib/.data.txt;
	return 0
else
	echo "demonio ya parado";
	return 1
fi

