# Build client.
FROM codesimple/elm:0.19 AS client_builder
RUN mkdir /app
WORKDIR /app
# Copy client from this folder to WORKDIR.
COPY ./client /app
# Build the client.
RUN elm make src/Main.elm --output dist/js/app.js   # => /app/dist



# Build server.
FROM golang:1.15-alpine3.12 AS server_builder
RUN mkdir /app
WORKDIR /app
# Add trusted certificates.
RUN apk --no-cache add ca-certificates
# Copy everything from this folder to WORKDIR.
COPY . .
# Specify Go build options.
ENV CGO_ENABLED=0 GOOS=linux GO111MODULE=on
# Compile the program and save in WORKDIR.
RUN go build -o serve  # => /srv/serve



# Migrate the build artifact, files, and dirs to Ubuntu.
FROM ubuntu:latest
RUN mkdir /mess
WORKDIR /mess
# Copying over the trusted TLS certificates.
COPY --from=client_builder /app/dist /mess/client/dist
COPY --from=server_builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=server_builder /app/serve /mess/serve
COPY ./migrations /mess/migrations/
COPY ./.env /mess/.env
# At this point we will have:
#
#     /mess
#     --> client/dist/
#     --> migrations/
#     --> serve*
#     --> .env
#
# Exposing default HTTP, HTTPS, and the dev port.
EXPOSE 8080 80 443



# Start the server.
CMD ["/mess/serve"]
