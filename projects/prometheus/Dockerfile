FROM node:lts
WORKDIR /usr/src/app
COPY . .

RUN npm install express prom-client

EXPOSE 3000
CMD ["node", "index.js"]