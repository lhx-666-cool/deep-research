# Use an official Node.js runtime as a parent image
FROM node:20-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock or pnpm-lock.yaml)
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Install project dependencies
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile 

# Copy the rest of the application code
COPY . .

# Build the application (assuming there's a build script in package.json)
RUN pnpm run build  


# --- Production Stage ---
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/public ./public

# Install only production dependencies (assuming you have devDependencies)
RUN npm install -g pnpm
RUN pnpm install --prod --frozen-lockfile


# Expose the port the app runs on (assuming it's 3000, change if needed)
EXPOSE 3000

# Define the command to run the application
CMD ["pnpm", "start"]
