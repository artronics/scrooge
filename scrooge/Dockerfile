FROM golang:alpine as go_build
LABEL maintainer="Jalal Hosseini - @artronics"

ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . ./

RUN CGO_ENABLED=0 go build -o app .

FROM hashicorp/terraform
COPY --from=go_build /app/app /bin/scrooge

ENTRYPOINT ["scrooge"]
CMD ["scrooge"]