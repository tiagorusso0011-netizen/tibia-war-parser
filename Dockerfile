# Usamos uma imagem base do Node com a versão mais estável do Linux (Bookworm)
FROM node:20-bookworm

# Instalamos o Ruby nativamente no mesmo sistema para evitar conflito de GLIBC
RUN apt-get update && apt-get install -y ruby-full

# Criamos a pasta principal
WORKDIR /app

# Copiamos todo o seu projeto de elite para dentro do contêiner
COPY . .

# Entramos na pasta da API e instalamos as dependências
WORKDIR /app/nestjs-api
RUN npm install
RUN npm run build

# Liberamos a porta do servidor
EXPOSE 3000

# Ligamos o motor
CMD ["npm", "run", "start:prod"]