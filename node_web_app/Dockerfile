FROM node:14.17.1-slim
WORKDIR /var/www/html/
COPY node_web_app/package*.json ./
RUN npm cache clean --force && npm install
COPY ./ ./
EXPOSE 3000
CMD [ "node", "index.js" ]