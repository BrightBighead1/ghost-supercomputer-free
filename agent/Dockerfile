FROM node:20-alpine

# Install git, curl, postgres client
RUN apk add --no-cache git curl bash postgresql-client

# Install GitAgent
RUN npm install -g @open-gitagent/gitagent@latest

# Create app directory
WORKDIR /app

# Copy agent configuration
COPY agent.yaml SOUL.md RULES.md ./
COPY tools/ ./tools/
COPY skills/ ./skills/
COPY memory/ ./memory/
COPY scripts/ ./scripts/

# Make scripts executable
RUN chmod +x ./scripts/*.sh 2>/dev/null || true

# Expose ports
# 3333 = GitAgent Web UI
EXPOSE 3333

# Start GitAgent in server mode
CMD ["gitagent", "--dir", "/app", "--port", "3333", "--host", "0.0.0.0"]
