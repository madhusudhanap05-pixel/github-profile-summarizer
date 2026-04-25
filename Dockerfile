# ---------- Stage 1: Build React app ----------
FROM node:20-alpine AS build
WORKDIR /app

# Install build dependencies (needed for native modules)
RUN apk add --no-cache python3 make g++

# Build arguments
ARG VITE_GITHUB_TOKEN
ARG VITE_MAX_REPOS=50

# Environment variables for Vite
ENV VITE_GITHUB_TOKEN=$VITE_GITHUB_TOKEN
ENV VITE_MAX_REPOS=$VITE_MAX_REPOS

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:stable-alpine

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built app
COPY --from=build /app/dist /usr/share/nginx/html

# Custom Nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
