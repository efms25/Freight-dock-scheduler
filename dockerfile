# --- Deps stage ---
FROM node:24 AS deps

 WORKDIR /app

 COPY package.json package-lock.json ./

 RUN npm ci --ignore-scripts

# --- Shared Builder Stage ---
FROM node:24 AS builder
 
 WORKDIR /app

 COPY --from=deps /app/package.json ./
 COPY --from=deps /app/package-lock.json ./
 COPY --from=deps /app/node_modules ./node_modules
 COPY ./src ./src

 RUN npm run build
 RUN npx prisma generate

# --- Production install stage ---
FROM node:24-slim AS prod

 WORKDIR /app

 COPY --from=builder /app/package.json ./
 COPY --from=builder /app/package-lock.json ./

 RUN npm ci --omit=dev --ignore-scripts
 
# --- Runner Stage ---
FROM node:24-alpine AS runner
 
 WORKDIR /app

 COPY --from=builder /app/package.json ./
 COPY --from=builder /app/package-lock.json ./
 COPY --from=builder /app/dist ./dist
 COPY --from=prod /app/node_modules ./node_modules

 USER node

 EXPOSE 8080

 ENV NODE_ENV=production

 CMD ["node", "dist/index.js"]


# --- Prisma migration ---
FROM deps AS migrate

WORKDIR /app

ENV NODE_ENV=production \
    PRISMA_DISABLE_TELEMETRY=1

COPY prisma.config.ts ./
COPY migrations ./migrations
COPY src/shared/database ./src/shared/database

CMD ["npx", "--no-install", "prisma", "db", "migrate", "--to", "production"]