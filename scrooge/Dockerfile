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
#
#ENV USER=terraform
#ENV UID=1000
#ENV GID=1000
#RUN addgroup -g $GID $USER && adduser \
#    --disabled-password \
#    --gecos "" \
#    --ingroup "$USER" \
#    --ingroup "root" \
#    --uid "$UID" \
#    "$USER"
#
#USER $USER

COPY --from=go_build /app/app /bin/scrooge

COPY main.template.tf /main.tf
COPY terraformrc.template $HOME/.terraformrc
COPY destroy /bin/destroy
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/destroy && chmod +x /bin/entrypoint.sh

VOLUME /mnt/projects
ENV TF_PLUGIN_CACHE_DIR="/mnt/projects/.terraform.d/plugin-cache"
ENV MOUNT_POINT="/mnt/projects"

ENTRYPOINT ["entrypoint.sh"]
