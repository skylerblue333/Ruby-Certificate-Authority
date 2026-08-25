FROM ruby:3.4-slim
RUN useradd --system --uid 10001 --no-create-home sky
WORKDIR /app
COPY lib ./lib
COPY bin ./bin
USER 10001:10001
CMD ["ruby", "bin/self_test.rb"]
