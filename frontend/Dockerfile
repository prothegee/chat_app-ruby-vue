# Alternatif 1: Menggunakan 'serve'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
COPY .env.production .env
RUN npm run build

RUN npm install -g serve

EXPOSE 10001
CMD ["serve", "-s", "dist", "-l", "10001", "--no-clipboard"]

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
RUN npm install -g http-server
EXPOSE 80
CMD ["http-server", "dist", "-p", "80", "-g", "--cors"]
