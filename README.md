# casino-frontend

SPA desarrollada en **Angular 17** para **VidalCasino**, correspondiente a la **Evaluación Parcial 3 (EP3)** de la asignatura **Introducción a Herramientas DevOps (ISY1101)**.

En esta versión la aplicación se despliega sobre **Amazon EKS (Kubernetes)**, utilizando **Docker**, **Amazon ECR**, **GitHub Actions** y **Nginx** como servidor web y reverse proxy.

---

# Arquitectura

```text
                        Internet
                            │
                            ▼
                 AWS LoadBalancer Service
                            │
                            ▼
                 casino-frontend (Nginx)
                            │
       ┌────────────┬─────────────┬──────────────┬──────────────┐
       ▼            ▼             ▼              ▼
 casino-backend bonos-service apuestas-service estadisticas-service
      :3000          :8004          :8005             :8006
                    (Services ClusterIP)

                            │
                            ▼
                       PostgreSQL
```

El frontend es el único servicio expuesto públicamente mediante un **Service tipo LoadBalancer**. Los microservicios se comunican internamente mediante **ClusterIP** y nombres DNS del clúster.

---

# Stack

| Capa                 | Tecnología              |
| -------------------- | ----------------------- |
| Framework            | Angular 17              |
| Lenguaje             | TypeScript 5            |
| Servidor Web         | Nginx                   |
| Contenedores         | Docker                  |
| Orquestación         | Kubernetes (Amazon EKS) |
| Registro de imágenes | Amazon ECR              |
| CI/CD                | GitHub Actions          |
| Backend              | Node.js + Express       |
| Base de datos        | PostgreSQL              |

---

# Estructura del proyecto

```text
casino-frontend/
│
├── src/
│ 
  ├── app/
│   ├── assets/
│   ├── environments/
│   └── styles.css
│
├── nginx/
│   └── nginx.conf
│
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── hpa.yaml
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── Dockerfile
├── .dockerignore
├── angular.json
├── package.json
├── tsconfig.json
└── README.md
```

---

# Ejecución local

## Requisitos

* Node.js 20 o superior
* npm
* Backend ejecutándose en `http://localhost:3000`

## Instalar dependencias

```bash
npm install
```

## Ejecutar la aplicación

```bash
npm start
```

La aplicación estará disponible en:

```
http://localhost:4200
```

---

# Build de producción

```bash
npm run build
```

Angular genera el build en:

```text
dist/
└── casino-frontend/
    └── browser/
```

Esta carpeta es utilizada por el Dockerfile para copiar los archivos estáticos hacia Nginx.

---

# Docker

## Construir la imagen

```bash
docker build -t casino-frontend .
```

## Ejecutar el contenedor

```bash
docker run -p 80:8080 casino-frontend
```

Acceder desde:

```
http://localhost
```

---

# Configuración de Nginx

Nginx cumple dos funciones principales.

## Servidor estático

Entrega la aplicación Angular generada durante el proceso de build.

## Reverse Proxy

Todas las solicitudes hacia:

```text
/api/*
```

son redireccionadas al backend correspondiente mediante los nombres DNS internos del clúster.

Ejemplo:

```text
/api/login
            ↓
casino-backend:3000

/api/bonos
            ↓
bonos-service:8004

/api/apuestas
            ↓
apuestas-service:8005

/api/estadisticas
            ↓
estadisticas-service:8006
```

Además, Nginx implementa el **SPA Fallback** mediante:

```nginx
try_files $uri $uri/ /index.html;
```

permitiendo refrescar cualquier ruta de Angular sin obtener un error 404.

---

# Kubernetes

El frontend se despliega mediante un **Deployment** y un **Service tipo LoadBalancer**.

Los manifiestos incluyen:

* Deployment
* Service
* Horizontal Pod Autoscaler (HPA)
* Requests y Limits de CPU
* Variables de entorno mediante ConfigMap y Secret

Despliegue:

```bash
kubectl apply -f kubernetes/
```

Verificar recursos:

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get hpa
```

---

# Variables de entorno

## Desarrollo

```ts
apiBaseUrl = "http://localhost:3000";
```

## Producción

```ts
apiBaseUrl = "";
```

Al utilizar una URL vacía, Angular realiza llamadas relativas como:

```text
/api/login
```

Las cuales son interceptadas por Nginx y reenviadas al backend correspondiente.

---

# Pipeline CI/CD

El despliegue está automatizado mediante **GitHub Actions**.

El workflow se ejecuta automáticamente al realizar un **push** sobre la rama:

```text
deploy
```

## Flujo del pipeline

```text
Push

↓

Build Angular

↓

Docker Build

↓

Push a Amazon ECR

↓

Deploy a Amazon EKS
```

Cada imagen Docker es publicada con tres etiquetas:

* `latest`
* `${{ github.sha }}`
* `vX.Y.Z`

---

# Autoescalado

El proyecto utiliza un **Horizontal Pod Autoscaler (HPA)**.

Configuración utilizada:

* CPU objetivo: 50%
* Réplicas mínimas: 2
* Réplicas máximas: 6

Cuando aumenta la carga de trabajo, Kubernetes incrementa automáticamente el número de Pods.

---

# Recuperación automática

Los Deployments garantizan la alta disponibilidad del sistema.

Ejemplo:

```bash
kubectl delete pod <nombre-del-pod>
```

Kubernetes detecta la eliminación del Pod y crea uno nuevo automáticamente.

---

# Integración

Flujo general de la aplicación:

```text
Usuario

↓

Frontend Angular

↓

Nginx

↓

Microservicios

↓

PostgreSQL
```

Toda la comunicación entre servicios se realiza mediante la red interna del clúster utilizando **Services ClusterIP**.

---

# Repositorios relacionados

* casino-backend
* bonos-service
* apuestas-service
* estadisticas-service

Cada repositorio contiene:

* Dockerfile
* Workflow GitHub Actions
* Deployment Kubernetes
* Service Kubernetes

---

# Comandos útiles

## Ver Pods

```bash
kubectl get pods
```

## Ver Servicios

```bash
kubectl get svc
```

## Ver HPA

```bash
kubectl get hpa
```

## Ver logs

```bash
kubectl logs <pod>
```

## Reiniciar Deployment

```bash
kubectl rollout restart deployment casino-frontend
```

---

# Autores

**Evaluación Parcial 3**

Introducción a Herramientas DevOps

ISY1101
