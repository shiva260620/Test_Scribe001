# Use a Node.js base image with Alpine for smaller size
FROM node:20.2.0-alpine3.16

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files to install dependencies
COPY package.* ./

# Install the application dependencies
RUN npm install

# Install bash, curl, and other necessary packages for installing Syft
RUN apk add --no-cache bash curl libc6-compat

# Download and install Syft using a more robust method compatible with Alpine
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Verify Syft installation
RUN syft --version

# Copy the source code into the container
COPY src ./src

# Generate an SBOM with Syft
RUN syft . -o json > /app/sbom.json

# Run Scribe Security checks on the generated SBOM
RUN scribe run --context-type docker --output-directory /app/cribe-output --sbom /app/sbom.json -P $SCRIBE_TOKEN

# Set the default command to run the application
CMD ["node", "src/app.js"]
