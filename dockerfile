FROM node:24 AS deps

 WORKDIR /app

 COPY package.json package-lock.json ./

 RUN npm ci --ignore-scripts

FROM node:24 AS builder
 
 WORKDIR /app

 COPY --from=deps /app/package.json ./
 COPY --from=deps /app/package-lock.json ./
 COPY --from=deps /app/node_modules ./node_modules
 COPY ./src ./src

 RUN npm run build

FROM node:24-slim AS prod

 WORKDIR /app

 COPY --from=builder /app/package.json ./
 COPY --from=builder /app/package-lock.json ./

 RUN npm ci --omit=dev --ignore-scripts
 
FROM node:24-alpine AS runner
 
 WORKDIR /app

 COPY --from=builder /app/package.json ./
 COPY --from=builder /app/package-lock.json ./
 COPY --from=builder /app/dist ./dist
 COPY --from=prod /app/node_modules ./node_modules

 USER node

 EXPOSE 8080

 ENV NODE_ENV=production

 ENTRYPOINT ["node", "dist/index.js"]