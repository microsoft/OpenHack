FROM golang:1.12.6-alpine3.10 as builder

COPY . .

RUN CGO_ENABLED=0 go build -a -tags netgo -o /app/insurance ./app

FROM alpine:3.10
RUN apk update \
    && apk add ca-certificates \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates
    
ENTRYPOINT ["/insurance"]
COPY --from=builder /app /