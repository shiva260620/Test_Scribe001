FROM node:20.2.0-alpine3.16

WORKDIR /app

COPY package.* .

RUN npm install

COPY src ./src

CMD node src/app.js
