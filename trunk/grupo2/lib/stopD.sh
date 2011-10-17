#stopD

if [ -e  $GRUPO/lib/.data.txt ]; then
	echo "parando demonio..";
	rm $GRUPO/lib/.data.txt;
else
	echo "demonio ya parado";
fi

