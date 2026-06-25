FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
# Eliminar el script que inyecta el resolver local (127.0.0.11)
# incompatible con Kubernetes donde el DNS es CoreDNS
USER root
RUN rm /docker-entrypoint.d/15-local-resolvers.envsh
USER nginx
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder --chown=nginx:nginx \
    /app/dist/casino-frontend/browser/. /usr/share/nginx/html/
EXPOSE 8080