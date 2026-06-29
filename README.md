# casino-frontend

SPA en **Angular 17** (standalone components, signals, lazy routes) del
**Casino Online** — asignatura **Introducción a Herramientas DevOps (ISY1101)**.
Consume la API de `casino-backend` y los microservicios de bonos, apuestas y
estadísticas.

## Stack
- Angular 17 · TypeScript 5.4
- Animaciones: GSAP 3, Three.js, Phaser 3
- Auth: JWT vía HTTP interceptor
- Pruebas: **Karma + Jasmine**

## Cómo funciona
- **Auth:** login/registro contra el backend; `AuthService` guarda el JWT en
  `localStorage` con **signals**; `authInterceptor` adjunta `Authorization: Bearer`
  a cada request; `authGuard` protege las rutas privadas.
- **Rutas:** todas las vistas usan **lazy loading** (`loadComponent`).
- **Backend:** las URLs salen de `environment.apiBaseUrl` (dev: `http://localhost:3000`;
  prod: cadena vacía → rutas relativas).

## Estructura (resumen)
```
src/app/
├── services/      auth.service.ts · casino.service.ts · apuestas.service.ts · ...
├── interceptors/  auth.interceptor.ts
├── guards/        auth.guard.ts
├── components/    login · register · lobby · slots · roulette · blackjack ·
│                  bonos · apuestas (mini-cancha) · estadisticas · history · header
└── models/        casino.models.ts
```

## Ejecutar en local
Requisito: backend corriendo en `http://localhost:3000`.
```bash
npm ci             # instala dependencias desde package-lock.json
npm start          # ng serve → http://localhost:4200
```

## Pruebas
Este repo **ya incluye pruebas unitarias** (Karma + Jasmine). Para correrlas en
modo CI (sin ventana ni watch):
```bash
npm ci
npm test -- --watch=false --browsers=ChromeHeadless
```
