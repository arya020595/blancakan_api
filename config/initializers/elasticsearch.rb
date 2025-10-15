Elasticsearch::Model.client = Elasticsearch::Client.new(
  hosts: [
    {
      host: Rails.application.credentials.dig(:elasticsearch, :host),
      scheme: 'https',
      port: Rails.application.credentials.dig(:elasticsearch, :por),
      user: Rails.application.credentials.dig(:elasticsearch, :username),
      password: Rails.application.credentials.dig(:elasticsearch, :password)
    }
  ],
  transport_options: {
    ssl: { ca_file: Rails.application.credentials.dig(:elasticsearch, :ca_file) }
  }
)
