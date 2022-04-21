source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "pg", "~> 1.3.5"
gem "puma", "~> 5.0"
gem "sequel", "~> 5.55"
gem "sinatra", "~> 2.2.0"
gem "zeitwerk", "~> 2.5"

group :development, :test do
  gem "dotenv"
end

group :development do
  gem "rubocop"
end

group :test do
  gem "rspec"
end
