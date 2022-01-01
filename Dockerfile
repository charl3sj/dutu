FROM elixir:1.13-alpine

RUN apk update && \
    apk add git && \
    apk add postgresql-client && \
    apk add inotify-tools && \
    apk add nodejs && \
    apk add curl && \
    curl -L https://npmjs.org/install.sh | sh && \
    mix local.hex --force && \
    mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

EXPOSE 9023

CMD ["mix", "phx.server"]
