# Estágio 1: Motor Ruby
FROM ruby:3.4.8-slim as ruby-worker

# Estágio 2: API NestJS
FROM node:20-slim
COPY --from=ruby-worker /usr/local/ /usr/local/

WORKDIR /app
COPY nestjs-api/package*.json ./nestjs-api/
RUN cd nestjs-api && npm install
COPY . .

EXPOSE 3000
CMD ["sh", "-c", "cd nestjs-api && npm run start"]