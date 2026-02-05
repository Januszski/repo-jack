FROM golang:1.25-bookworm

WORKDIR /app

# Install dependencies needed for CodeQL
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install CodeQL
ENV CODEQL_VERSION=2.17.5
RUN curl -L \
    https://github.com/github/codeql-cli-binaries/releases/download/v${CODEQL_VERSION}/codeql-linux64.zip \
    -o codeql.zip \
 && unzip codeql.zip \
 && mv codeql /opt/codeql \
 && ln -s /opt/codeql/codeql /usr/local/bin/codeql \
 && rm codeql.zip

# Go deps
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o action ./cmd/action

ENTRYPOINT ["/app/action"]
