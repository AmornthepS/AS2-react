# Build stage
FROM node:16-buster AS build

# Install Bun
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://bun.sh/install | bash

# Set PATH for Bun
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app
COPY package*.json ./
RUN bun install
COPY . .
RUN bun run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]