#Imagen base node
FROM node:20-alpine AS builder
#crea Carpeta proyecto
WORKDIR /app
#Copiando dependencias
COPY package*.json ./
#Instalando todas las dependencias
RUN npm ci
#Copiamos todo
COPY . .
RUN npm run build

#Fase runtime, imagen más liviana
FROM nginx:alpine AS runtime

RUN rm -rf /usr/share/nginx/html/* \
 && rm -f /etc/nginx/conf.d/default.conf

COPY default.conf.template /etc/nginx/templates/default.conf.template

COPY --from=builder /app/dist/casino-frontend/browser/. /usr/share/nginx/html/

#Exponemos el puerto por defecto del `ng serve` o.o
EXPOSE 80

