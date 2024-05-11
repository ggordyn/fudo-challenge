# Use a Ruby base image
FROM ruby:3.0
WORKDIR /app

# Copy Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock /app/

# Install dependencies
RUN gem install bundler
RUN bundler install

# Copy the rest of the application
COPY . /app/

EXPOSE 3000

CMD ["ruby", "src/main.rb"]
