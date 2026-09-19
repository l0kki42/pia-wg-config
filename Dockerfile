FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY ./pia ./pia
COPY main.go .

ARG TARGETOS
ARG TARGETARCH

ENV GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0

RUN go build -ldflags="-s -w" -o pia-wg-config .

FROM gcr.io/distroless/static-debian13

COPY --from=builder /app/pia-wg-config /bin/pia-wg-config
USER 65534

ENTRYPOINT ["/bin/pia-wg-config"]