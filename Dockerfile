ARG APP_NAME=spoter

FROM golang:1.17-buster AS base

ARG APP_NAME

WORKDIR /go/src/app

FROM base AS build

ARG APP_NAME

COPY . .

RUN make

FROM heroku/heroku:20 AS final

ARG APP_NAME

COPY --from=build /go/src/app/bin/$APP_NAME /app

CMD ["/app"]
