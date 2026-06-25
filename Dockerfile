# syntax=docker/dockerfile:1

FROM node:20-slim AS backend-dev

WORKDIR /app

COPY backend/package*.json ./

RUN npm config set ignore-scripts false
RUN npm ci

COPY backend ./

EXPOSE 3000

CMD ["npm", "run", "dev"]


FROM node:20-slim AS frontend-dev

WORKDIR /app

COPY client/package*.json ./

RUN npm ci

COPY client ./

EXPOSE 5173

CMD ["npm", "run", "dev"]


FROM node:20-slim AS backend-test

WORKDIR /app

COPY backend/package*.json ./

RUN npm config set ignore-scripts false
RUN npm ci

COPY backend ./

ENV NODE_ENV=test

RUN npm test


FROM node:20-slim AS frontend-build

WORKDIR /app

COPY client/package*.json ./

RUN npm ci

COPY client ./

RUN npm run build


FROM node:20-slim AS final

WORKDIR /app

ENV NODE_ENV=production

COPY backend/package*.json ./

RUN npm config set ignore-scripts false
RUN npm ci --omit=dev
RUN npm cache clean --force

COPY backend ./

COPY --from=frontend-build /app/dist ./src/static

COPY --from=backend-test /app/package.json /tmp/backend-tests-passed-package.json

EXPOSE 3000

CMD ["node", "src/index.js"]