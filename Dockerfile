FROM ruby:3.3-alpine
RUN adduser -D -u 10001 app
WORKDIR /app
COPY lib ./lib
COPY bin ./bin
RUN chmod 0555 bin/sky-ca-inspect
USER 10001
ENTRYPOINT ["ruby", "/app/bin/sky-ca-inspect"]
