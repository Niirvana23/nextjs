# syntax=docker/dockerfile:1.7
########################  Base deps  ########################
FROM --platform=$BUILDPLATFORM node:20-slim AS deps    # Node 20 LTS :contentReference[oaicite:1]{index=1}
WORKDIR /app
ENV NODE_ENV=production
# فقط فایل‌های وابستگی را کپی می‌کنیم تا cache شود
COPY package.json package-lock.json* .npmrc ./
# BuildKit cache= type
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev && npm cache clean --force

########################  Builder   ########################
FROM deps AS builder
COPY . .
RUN --mount=type=cache,target=/root/.npm \
    npm run build          # همان 'next build' با Turbopack

########################  Runner    ########################
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
# تنها فایل‌های لازم برای ران‌تایم
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static      ./.next/static
COPY --from=builder /app/public            ./public
USER node        # امنیت
EXPOSE 3000
HEALTHCHECK CMD curl -f http://localhost:3000/ || exit 1
CMD ["node","server.js"]

