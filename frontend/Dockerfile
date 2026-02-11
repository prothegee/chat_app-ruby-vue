# Alternatif 1: Menggunakan 'serve'
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
COPY .env.production .env
RUN npm run build

COPY --from=builder /app/dist ./dist
RUN npm install -g http-server
EXPOSE 10001
CMD ["http-server", "dist", "-p", "10001", "-g", "--cors"]
