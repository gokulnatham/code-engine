FROM icr.io/codeengine/golang:alpine AS build
# hadolint ignore=DL3017
RUN apk update && apk upgrade
COPY helloworld.go /
RUN go build -ldflags '-s -w -extldflags "-static"' -o /helloworld /helloworld.go

# hadolint ignore=DL3006
FROM icr.io/codeengine/alpine
# hadolint ignore=DL3017
RUN apk update && apk upgrade
# Copy the exe into a smaller base image
COPY --from=build /helloworld /helloworld
# hadolint ignore=DL3025
CMD /helloworld
