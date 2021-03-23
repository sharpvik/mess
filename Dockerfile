# Build styles.
FROM ubuntudesign/sass AS styles_builder
RUN mkdir /cli
WORKDIR /cli
COPY ./client /cli
RUN if [ ! -d "/cli/dist/css" ]; then mkdir /cli/dist/css; fi
RUN sass sass/main.sass:dist/css/main.css
# => /cli/dist/ + css



# Build client.
FROM codesimple/elm:0.19 AS client_builder
RUN mkdir /app
WORKDIR /app
COPY ./client /app
COPY --from=styles_builder /cli/dist /app/dist
RUN if [ ! -d "/app/dist/js" ]; then mkdir /app/dist/js; fi
RUN elm make src/Main.elm --output dist/js/app.js
# => /app/dist/ + js



# Build server.
FROM golang:1.16-alpine3.12 AS server_builder
RUN mkdir /app
WORKDIR /app
# Add trusted certificates.
RUN apk --no-cache add ca-certificates
COPY . .
ENV CGO_ENABLED=0 GOOS=linux GO111MODULE=on
RUN go build -o serve
# => /srv/serve*



# Migrate the build artifact, files, and dirs to Ubuntu.
FROM ubuntu:latest
RUN mkdir /mess
WORKDIR /mess
# Copying things over ...
COPY --from=client_builder /app/dist /mess/client/dist
COPY --from=server_builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=server_builder /app/serve /mess/serve
# At this point we will have:
#
#     /mess
#     --> client/dist/
#     --> serve*
#
# Exposing default HTTP, HTTPS, and the dev port.
EXPOSE 80 443


# Start the server.
CMD [ "/mess/serve" ]