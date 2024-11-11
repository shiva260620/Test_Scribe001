# Use a Debian-based Node.js image for broader compatibility
FROM node:20.2.0-bullseye

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files to install dependencies
COPY package.* ./

# Install the application dependencies
RUN npm install

# Install curl to download Syft and the Scribe Security tools
RUN apt-get update && apt-get install -y curl

# Download and install Syft
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
