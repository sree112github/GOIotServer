# ---------- Stage 1: Build ----------
FROM golang:1.24 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum first (for better caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go app
# - CGO disabled for static build
# - GOOS=linux ensures it's built for container
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# ---------- Stage 2: Run ----------
FROM alpine:latest

# Set working directory
WORKDIR /root/

# Copy the pre-built binary file from the builder stage
COPY --from=builder /app/server .

# Expose port (adjust if your app uses another)
EXPOSE 8080

# Run the executable
CMD ["./server"]
