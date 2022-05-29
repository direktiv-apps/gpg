FROM golang:1.18-buster as build

COPY go.mod src/go.mod
COPY go.sum src/go.sum
RUN cd src/ && go mod download

COPY cmd src/cmd/
COPY models src/models/
COPY restapi src/restapi/

RUN cd src && \
    export CGO_LDFLAGS="-static -w -s" && \
    go build -tags osusergo,netgo -o /application cmd/gpg-server/main.go; 


FROM golang:1.18-buster as build-app

COPY go.mod src/go.mod
COPY go.sum src/go.sum
RUN cd src/ && go mod download

COPY cmd src/cmd/

RUN cd src && \
    export CGO_LDFLAGS="-static -w -s" && \
    go build -tags osusergo,netgo -o /runner cmd/gpg-runner/main.go; 

FROM ubuntu:21.04

RUN apt-get update && apt-get install pinentry-tty  gnupg gnupg-agent ca-certificates -y
COPY --from=build-app /runner /bin/runner

COPY gpg-agent.conf /root/.gnupg/gpg-agent.conf
RUN mkdir -p /root/.gnupg && chmod 700 /root/.gnupg
COPY gpg.conf /root/.gnupg/
RUN chmod 600 /root/.gnupg/gpg.conf

ENV GPG_TTY=/dev/console

# DON'T CHANGE BELOW 
COPY --from=build /application /bin/application

EXPOSE 8080
EXPOSE 9292

CMD ["/bin/application", "--port=8080", "--host=0.0.0.0", "--write-timeout=0"]

