FROM elixir
MAINTAINER niku

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN mix local.hex --force && \
    mix deps.get && \
    mix compile

CMD ["iex"]
