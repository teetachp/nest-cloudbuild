################################################
# Stage 1: Build the application stage          
################################################
## TODO: need to move image to internal gcr
FROM node:20.12.0 AS builder

# Define environment variables
ENV WRKDIR=/app \
    USER=appuser \
    UID=10001

# Never run a process as root in a container.
# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR $WRKDIR

COPY package.json .
COPY package-lock.json .

# Install dependencies
RUN npm install --production

COPY . .

# Build the application
RUN npx @nestjs/cli build

################################################
# Stage 2: Release the application stage            
################################################
## TODO: need to move image to internal gcr
FROM node:20.12.0-slim

WORKDIR /app

# Copy built files from the previous stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .

# Expose the port your app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "run", "start:prod"]