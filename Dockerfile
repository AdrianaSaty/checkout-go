# Specifies the base image for your Docker image. 
# Here it's pulling the official Go image from Docker Hub, tagged at version 1.19.0.
FROM golang:1.24

# Sets the working directory inside the container to /app.
# If the directory doesn’t exist, Docker will create it.
# All subsequent commands in the Dockerfile (like COPY, RUN, CMD) 
# that use relative paths will be executed with /app as the current directory.
WORKDIR /usr/src/app

# Install a package called air to enable live reloading
RUN go install github.com/air-verse/air@latest

# Copy source files into the container
COPY . . 
# Ensure all modules are downloaded and tidy
RUN go mod tidy