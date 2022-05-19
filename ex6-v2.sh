#!/bin/bash

NEW_USER=myapp

echo
echo === Instalando Nodejs y Npm
sleep 1
apt-get -y install nodejs npm 

echo 
echo === Creando usuario myapp
useradd -m $NEW_USER

echo
echo === Descargando bootcamp-node-envvars-project
sleep 1
runuser -l $NEW_USER -c "wget https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"

echo
echo === Untar y Unzip de paquete
sleep 1
runuser -l $NEW_USER -c "tar xvzf bootcamp-node-envvars-project-1.0.0.tgz"

echo
echo === Listando el contenido descargado
sleep 1
cd package
echo
ls -l
echo

echo === Seteando variables de ambiente



echo
read -p "=== Ingrese el directorio de log (ruta absoluta): " log_directory

if ! [ -d "$log_directory" ]
then
  mkdir -p "$log_directory"
fi

chown $NEW_USER:$NEW_USER $log_directory

sleep 1
PID=$(pidof node)
if ! [ -z $PID ]
then
	echo
	echo "=== El servicio ya esta levantado con el PID $PID y en el puerto $(netstat -anp| grep node| awk '{print $4}'|awk -F':' '{print $NF}')"
else
  echo
  echo === Ejecutando \'npm install\' y \'node server.js\'
  echo "=== Directorio actual: $(pwd)"
  sleep 3
  runuser -l $NEW_USER -c "
   export APP_ENV=dev &&
   export DB_USER=myuser &&
   export DB_PWD=mypassword &&
   export LOG_DIR=$log_directory &&
   echo Variables: $APP_ENV $DB_USER $DB_PWD $LOG_DIR &&
   cd package &&
   npm install &&
   node server.js &"
  sleep 10
  PID=$(pidof node)
  echo
  echo "=== El servicio está levantado con el PID $PID y en el puerto $(netstat -anp| grep node| awk '{print $4}'|awk -F':' '{print $NF}')"
fi

