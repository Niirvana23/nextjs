# Use official Node.js as a base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only package.json and package-lock.json first (better for Docker caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy everything else
COPY . .

# Build the Next.js app
RUN npm run build

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]

