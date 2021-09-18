OmniAuth::Mastodon
==================

[![Gem Version](http://img.shields.io/gem/v/omniauth-mastodon.svg)][gem]

[gem]: https://rubygems.org/gems/omniauth-mastodon

Authentication strategy for federated Mastodon instances. This is just slightly more complicated than a traditional OAuth2 flow: We do not know the URL of the OAuth end-points in advance, nor can we be sure that
we already have client credentials for that Mastodon instance.

## Installation

    gem 'omniauth-mastodon-st'

## Configuration

Example:

```ruby
MASTODON_OMNIUATH_SETUP = lambda do |env|
  env["omniauth.strategy"].options[:domain] = Settings::Authentication.mastodon_domain
  env["omniauth.strategy"].options[:client_id] = Settings::Authentication.mastodon_client
  env["omniauth.strategy"].options[:client_secret] = Settings::Authentication.mastodon_secret
  env["omniauth.strategy"].options[:scope] = "read"
end
```
```ruby
Devise.setup do |config|
  config.omniauth :mastodon, setup: MASTODON_OMNIUATH_SETUP
end
```
