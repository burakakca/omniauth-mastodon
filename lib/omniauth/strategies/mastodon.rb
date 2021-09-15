require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Mastodon < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'read'.freeze

      option :name, 'mastodon'

      option :credentials
      option :identifier
      option :authorize_options, [:scope]
      option :domain

      option :client_options, {
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['username'],
          nickname: raw_info['username'],
          image: raw_info['avatar'],
          urls: { 'Profile' => raw_info['url'] }
        }
      end

      extra do
        { raw_info: raw_info }
      end

      # Before we can redirect the user to authorize access, we must know where the user is from
      # If the identifier param is not already present, a form will be shown for entering it
      def request_phase
        puts "++++++++++request_phase"
        puts identifier
        puts options[:domain]
        puts options[:client_id]
        puts options[:client_secret]
        puts "++++++++++request_phase"
        identifier ? start_oauth : get_identifier
      end

      def callback_phase
        puts "++++++++++callback_phase"
        puts identifier
        set_options_from_identifier
        super
      end

      def raw_info
        @raw_info ||= access_token.get('api/v1/accounts/verify_credentials').parsed
      end

      def callback_url
        full_host + script_name + callback_path
        puts "++++++++++callback_url"
        puts identifier
        puts full_host + script_name + callback_path
      end

      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def get_identifier
        I18n.with_locale(locale) do
          form = OmniAuth::Form.new(title: translate('.omniauth.mastodon.title'))
          form.text_field translate('.omniauth.mastodon.text'), 'identifier'
          form.button translate('.omniauth.mastodon.button')
          form.to_response
        end
      end

      def translate(t)
        I18n.exists?(t) ? I18n.t(t) : I18n.t(t, locale: :en)
      end

      def locale
        loc = request.params['locale'] || session[:omniauth_login_locale] || I18n.default_locale
        loc = :en unless I18n.locale_available?(loc)
        loc
      end

      def start_oauth
        set_options_from_identifier
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
      end

      def identifier
        i = options.identifier || request.params['identifier'] || (env['omniauth.params'].is_a?(Hash) ? env['omniauth.params']['identifier'] : nil) || session[:identifier]
        i = i.downcase.strip unless i.nil?
        i = nil if i == ''
        session[:identifier] = i unless i.nil?
        i
      end

      def set_options_from_identifier
        username, domain         = identifier.split('@')
        client_id, client_secret = options.credentials.call(domain, callback_url)
        puts "*-**-*"
        puts username
        puts domain
        puts client_id
        puts client_secret
        puts "*-**-*"
        options.identifier            = identifier
        options.client_options[:site] = "https://#{domain}"
        options.client_id             = client_id
        options.client_secret         = client_secret
      end
    end
  end
end
