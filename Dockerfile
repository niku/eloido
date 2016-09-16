FROM elixir
MAINTAINER niku

RUN mkdir /myapp
ADD . /myapp
WORKDIR /myapp

RUN mix local.hex --force && \
    mix deps.get && \
    mix compile

CMD ["iex"]
