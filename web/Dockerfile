FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package.json ./
COPY yarn.lock* ./
RUN yarn install

# Copy source
COPY . .

# Expose port
EXPOSE 5173

# Start dev server
CMD ["yarn", "dev", "--host", "0.0.0.0"]
