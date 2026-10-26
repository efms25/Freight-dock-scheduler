# --- Deps stage ---
FROM node:24-slim AS deps

 WORKDIR /app

 COPY package.json package-lock.json ./

 RUN npm ci --ignore-scripts

# --- Shared Builder Stage ---
FROM deps AS builder
 
 WORKDIR /app
 COPY prisma.config.ts ./
 COPY tsconfig.json ./
 COPY ./src ./src

 RUN npm run contract:emit
 RUN npm run build

# --- Production install stage ---
FROM node:24-alpine AS prod

 WORKDIR /app
 COPY package.json package-lock.json ./
 RUN npm ci --omit=dev --ignore-scripts
 
# --- Runner Stage ---
FROM node:24-alpine AS runner
 
 WORKDIR /app
 ENV NODE_ENV=production
 COPY package.json ./
 COPY --from=prod /app/node_modules ./node_modules
 COPY --from=builder /app/dist ./dist

 USER node

 EXPOSE 8080

 CMD ["node", "dist/index.js"]


# --- Prisma migration ---
FROM deps AS migrate

WORKDIR /app

ENV NODE_ENV=production \
    PRISMA_DISABLE_TELEMETRY=1

COPY prisma.config.ts ./
COPY migrations ./migrations
COPY src/shared/database ./src/shared/database

#Prisma Checking
RUN npx --no-install prisma --version

USER node

CMD ["npx", "--no-install", "prisma", "db", "migrate", "--to", "production"]