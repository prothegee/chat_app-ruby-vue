# Alternatif 1: Menggunakan 'serve'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Install serve globally
RUN npm install -g serve

# Serve dengan proper production flags
EXPOSE 10001
CMD ["serve", "-s", "dist", "-l", "10001", "--no-clipboard"]

# Alternatif 2: Multi-stage dengan http-server
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
RUN npm install -g http-server
EXPOSE 10001
CMD ["http-server", "dist", "-p", "10001", "-g", "--cors"]
