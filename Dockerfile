#Creo que hay que configurar ng server o algo con eso
#No recuerdo esta parte de la actividad xd

#Imagen base node liviana
FROM node:20-alpine

#crea Carpeta proyecto
WORKDIR /app

#Copiando dependencias
COPY package*.json ./

#Instalando todas las dependencias
RUN npm install

#Copiamos todo
COPY . .

#Exponemos el puerto por defecto del `ng serve` o.o
EXPOSE 4200

#Lanzamos el server de desarrollo
# --host 0.0.0.0 #Se supone que permite que el puerto sea accesible desde el contenedor
# --poll 2000 #Fuerza al compilador a detectar cambios en volúmenes

#Comandos ejecutables
CMD["npm", "run", "start"]

