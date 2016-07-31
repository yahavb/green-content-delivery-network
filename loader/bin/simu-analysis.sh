curl http://104.154.70.81/map.php?cmd=cnt_by_keys\&key=TS*TYPE*> ~/Downloads/1.csv
cat 1.csv | egrep '^TS*'| sed 's/TS//g' | sed 's/TYPE//g'| sed 's/-_/,/g' | sort > ~/Downloads/2.csv

echo "File ~/Downloads/2.csv is ready for analysis"
