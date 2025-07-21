# checkout-go

## Step By Step

### 1. Docker

#### 1.1 - create `Dockerfile` and `docker-compose.yaml` at root.

Run `docker compose up` to install everything (this part is just to install)

`Dockerfile`:

```yaml
# Specifies the base image for your Docker image.
# Here it's pulling the official Go image from Docker Hub, tagged at version 1.19.0.
FROM golang:1.19.0

# Sets the working directory inside the container to /usr/src/app.
# If the directory doesn’t exist, Docker will create it.
# All subsequent commands in the Dockerfile (like COPY, RUN, CMD)
# that use relative paths will be executed with /usr/src/app as the current directory.
WORKDIR /usr/src/app
```

`docker-compose.yaml`:

```yaml
services:
  web: # Defines the “web” service
    build: . # Build image from Dockerfile in the current directory
    ports:
      - 3000:3000 # Map host port 3000 → container port 3000
    volumes:
      - .:/app # Mount current directory into /app in the container
```

<br>

#### 1.2 - start a shell in the web container

To run commands inside the container’s Bash shell, use: `docker compose run --service-ports web bash` (this command targets the web service defined in the `docker.componse.yml` file).
To test it, run `go version` to verify if it is at the right go version.
To get out of the cointainer, type `exit` at the terminal.

<br/>

#### 1.3 - installing and managing dependencies in Go container

To install dependencies, enter again inside the container: `docker compose run --service-ports web bash`.
To handle the dependencies it will be used Go Modules, to initialize this: `go mod init github.com/AdrianaSaty/checkout-go` -> it's a good practice to name the package with the url it can be downloaded from.

<br/>

#### 1.4 - installing Go Fiber inside container

Still inside the container, run `go get github.com/gofiber/fiber/v2`
This library provides a fast and minimalist web framework for building APIs in Go.

#### 1.5 - hello world

Create a new file at the project root called main.go and paste in the “Hello, World!” example from the [Go Fiber docs](https://docs.gofiber.io/):

```go
package main

import "github.com/gofiber/fiber/v2"

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Listen(":3000")
}
```

And then run ` go run main.go -b 0.0.0.0`.
The `-b 0.0.0.0` flag tells Fiber to bind to all network interfaces (not just localhost). This ensures that, when running inside Docker, the container’s port is reachable from your host machine or browser.

To test it, open the browser at `http://localhost:3000/` and you should see:
"Hello, World!"

<br/>

#### 1.6 - automate app startup on container run

At the moment, entering the web service container is required each time to run the application. To enable startup from the host machine, add these lines to the respective configuration files:

`Dockerfile`:

```yaml
# ...

# Copy source files into the container
COPY . .
# Ensure all modules are downloaded and tidy
RUN go mod tidy
```

`docker-compose.yaml`:

```yaml
services:
  web:
    # ...
    command: go run main.go -b 0.0.0.0
```

Then run `docker componse up` and access `http://localhost:3000/`

<br/>

#### 1.7 - installing air inside container

By default, changes to main.go require a manual rebuild before appearing in the browser. To enable live reloading on source changes, install the [air](https://github.com/air-verse/air) library.

Update the `Dockerfile` to install the `air` package, and also to use go version 1.23 or higher (recommended by air docs):

```yaml
FROM golang:1.24
# Install a package called air to enable live reloading
RUN go install github.com/air-verse/air@latest
```

To setup this up, create a `.air.toml` file at the project root and copy the example configuration from the [official documentation](https://github.com/air-verse/air/blob/master/air_example.toml).

Update the `docker-compose.yml` to run the`docker compose build` usig `air`:

```yaml
services:
  web:
    # …
    command: ["air"]
```

Finally, rebuild the image and restart the stack to apply these changes:<br/>
`docker compose build`<br/>
`docker compose up`
