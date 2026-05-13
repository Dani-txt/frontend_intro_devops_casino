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
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=builder --chown=nginx:nginx /app/dist/casino-frontend/browser/. /usr/share/nginx/html/

#Exponemos el puerto por defecto del `ng serve` o.o
EXPOSE 8080

