FROM node:20-alpine

# Install git and npm packages
RUN apk add --no-cache git curl bash
RUN npm install -g @open-gitagent/gitagent@latest

# Create app directory
WORKDIR /app

# Copy agent configuration
COPY agent.yaml SOUL.md RULES.md ./
COPY tools/ ./tools/
COPY skills/ ./skills/
COPY memory/ ./memory/

# Expose ports
# 3333 = GitAgent Web UI
EXPOSE 3333

# Start GitAgent in server mode
CMD ["gitagent", "--dir", "/app", "--port", "3333", "--host", "0.0.0.0"]
