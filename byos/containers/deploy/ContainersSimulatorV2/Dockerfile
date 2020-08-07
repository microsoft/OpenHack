#build stage
FROM golang:1.12.6 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go test -timeout 30s -test.coverprofile /tmp/go-code-cover .
RUN CGO_ENABLED=0 go build -a -tags netgo -o /simulator

FROM alpine:3.10
ENV PORT=80
RUN apk update \
    && apk add ca-certificates \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates
WORKDIR /app
ENTRYPOINT ["/app/simulator", "-logtostderr=true", "-v=1"]
LABEL Name=containerssimulator Version=0.0.1
EXPOSE 8080
COPY --from=builder /simulator /app/
COPY --from=builder /app/views/ /app/views/
