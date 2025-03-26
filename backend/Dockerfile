# Use the official Node.js image as a base image
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install 
COPY . .
EXPOSE 8080
CMD ["npm", "start"]

