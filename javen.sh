#!/usr/bin/bash


arg="$1"

# CONFIG

mavenRepositoryBase="/home/$USER/.m2/repository"

if [[ "$arg" == "-cm" || "$arg" == "-rm" ]]; then
	packageBase="./src/main/java"
	mainClass="AppMain" 
elif [[ "$arg" == "-ct" || "$arg" == "-rt" ]]; then
	packageBase="./src/test/java"
	mainClass="TestMain" 
fi
# /CONFIG

cpm=""
cp=""
file=$(cat ./javen.classpaths.txt)
for line in $file; do
	cp="${cp}${mavenRepositoryBase}/$line:"
	cpm="${cpm}${mavenRepositoryBase}/$line "
done

# FIX_ME: raises "find: '': No such file or directory" notice when -vu is used
find "$packageBase" -type f -name "*.java" > ./javen.source.files.txt



if [[ -z "$arg" || "$arg" == "-cm"  || "$arg" == "-ct" ]]; then
	mode=""
	if [[ "$arg" == "-cm" ]]; then
		mode="main"
	else
		mode="main"
	fi
	javac="javac -cp $cp -d ./bin/$mode -sourcepath $packageBase @javen.source.files.txt" 
	
	echo "COMPILING: $javac"

	if [[ $2 == "loop" ]]; then
		echo -n 'input characters: '
		while read -N 1 -s -r; do
			$javac
			[[ $REPLY = x ]] && { printf '\nBye: %s\n' x; exit 0; } || echo $REPLY

		done	
	else
		$javac
	fi
fi

if [[ "$arg" == "-vu" ]]; then
	rm -r ./vendor/*
	file=$(cat ./javen.classpaths.txt)
	for line in $file; do
		mkdir -p `dirname ./vendor/$line`
		cp $mavenRepositoryBase/$line ./vendor/$line
	done
fi

if [[ "$arg" == "-jb" ]]; then
	#echo "BUILDING JAR"
	echo "Manifest-Version: 1.0" > javen.manifest.txt

	version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
	echo "Created-By: $version" >> javen.manifest.txt
	echo "Main-Class: com.avion.app.$mainClass" >> javen.manifest.txt
	echo "Class-Path: $cpm" >> javen.manifest.txt

	cd ./bin/main
	find "." -type f -name "*.class" > ../../javen.classes.txt
	cd ../..
	file=$(cat ./javen.classes.txt)
	cf=""
	for line in $file; do
		cf="${cf} $line"
	done

	jar="jar -cfm main.jar javen.manifest.txt -C ./bin/main $cf"
	echo "$jar"
	$jar 
fi



if [[ -z "$arg" || "$arg" == "-rm" ]]; then
	java="java -cp ./bin/main:$cp com.avion.app.$mainClass $2" 
	echo "RUNNING: $java"
	$java
elif [[ "$arg" == "-rt" ]]; then
	java="java -cp ./bin/test:$cp com.avion.app.$mainClass $2" 
	echo "RUNNING: $java"
	$java
fi


