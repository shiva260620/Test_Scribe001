# Use a Node.js base image with Alpine for smaller size
FROM node:20.2.0-alpine3.16

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files to install dependencies
COPY package.* ./

# Install the application dependencies
RUN npm install

# Install curl, bash, and Syft (for SBOM generation)
RUN apk add --no-cache curl bash && \
    curl -sSL https://scribe.security/install | bash && \
    curl -sSL https://github.com/anchore/syft/releases/download/v0.70.0/syft-v0.70.0-linux-amd64 -o /usr/local/bin/syft && \
    chmod +x /usr/local/bin/syft

# Copy the source code into the container
COPY src ./src

# Optionally, generate an SBOM (if using Syft)
RUN syft . -o json > /app/sbom.json

# Run Scribe Security checks on the generated SBOM
RUN scribe run --context-type docker --output-directory /app/cribe-output --sbom /app/sbom.json -P $SCRIBE_TOKEN

# Set the default command to run the application
CMD node src/app.js
