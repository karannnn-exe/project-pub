# 🔹 STEP 1: Build the React App using Node.js
FROM node:16-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the React app
RUN npm run build

# 🔹 STEP 2: Serve the App with Nginx
FROM nginx:alpine

# Set working directory inside container
WORKDIR /usr/share/nginx/html

# Copy the built React files from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

