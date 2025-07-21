# Specifies the base image for your Docker image. 
# Here it's pulling the official Go image from Docker Hub, tagged at version 1.19.0.
FROM golang:1.19.0

# Sets the working directory inside the container to /app.
# If the directory doesn’t exist, Docker will create it.
# All subsequent commands in the Dockerfile (like COPY, RUN, CMD) 
# that use relative paths will be executed with /app as the current directory.
WORKDIR /usr/src/app
