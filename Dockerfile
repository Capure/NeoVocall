FROM node:17.3.1-alpine as build-stage

LABEL name "NeoVocall (build stage)"
LABEL original-maintainer "Zhycorp <support@zhycorp.com>"

WORKDIR /tmp/build

# Install node-gyp dependencies
RUN apk add --no-cache build-base git python3

# Copy package.json and package-lock.json
COPY package.json .
COPY package-lock.json .

# Install dependencies
RUN npm install

# Copy Project files
COPY . .

# Build TypeScript Project
RUN npm run build

# Prune devDependencies
RUN npm prune --production

# Get ready for production
FROM node:17.3.1-alpine

LABEL name "NeoVocall (build stage)"
LABEL original-maintainer "Zhycorp <support@zhycorp.com>"

WORKDIR /app

# Install dependencies
RUN apk add --no-cache tzdata

# Copy needed files
COPY --from=build-stage /tmp/build/package.json .
COPY --from=build-stage /tmp/build/package-lock.json .
COPY --from=build-stage /tmp/build/node_modules ./node_modules
COPY --from=build-stage /tmp/build/dist .

# Mark cache folder as docker volume
VOLUME ["/app/cache", "/app/logs"]

# Start the app with node
CMD ["node", "main.js"]
