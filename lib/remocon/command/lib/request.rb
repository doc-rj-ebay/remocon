# frozen_string_literal: true

module Remocon
  module Request
    def self.push(config)
      raise "etag should be specified. If you want to ignore this error, then please add --force option" unless config.etag

      client, uri = Request.build_client(config)

      headers = {
          "Authorization" => "Bearer #{config.token}",
          "Content-Type" => "application/json; UTF8",
          "If-Match" => config.etag,
      }

      request = Net::HTTP::Put.new(uri.request_uri, headers)
      request.body = +""
      request.body << File.read(config.config_json_file_path).delete("\r\n")

      response = client.request(request)

      response_body = begin
        json_str = response.try(:read_body)
        (json_str ? JSON.parse(json_str) : {}).with_indifferent_access
      end

      return response, response_body
    end

    def self.validate(config, config_temp_file)
      raise "etag should be specified. If you want to ignore this error, then please add --force option" unless config.etag

      client, uri = Request.build_client(config)

      headers = {
          "Authorization" => "Bearer #{config.token}",
          "Content-Type" => "application/json; UTF8",
          "If-Match" => config.etag,
      }

      request = Net::HTTP::Put.new("#{uri.request_uri}?validate_only=true", headers)
      request.body = +""
      request.body << config_temp_file.read.delete("\r\n")

      response = client.request(request)

      response_body = begin
        json_str = response.try(:read_body)
        (json_str ? JSON.parse(json_str) : {}).with_indifferent_access
      end

      return response, response_body
    end

    def self.pull(config)
      client, uri = Request.build_client(config)

      headers = {
          "Authorization" => "Bearer #{config.token}",
          "Content-Type" => "application/json; UTF8",
          "Content-Encoding" => "gzip",
      }

      request = Net::HTTP::Get.new(uri.request_uri, headers)

      response = client.request(request)

      [response.body, response.header["etag"]]
    end

    def self.fetch_etag(config)
      # remote config api doesn't support head request so we need to use GET instead.

      client, uri = Request.build_client(config)

      headers = {
          "Authorization" => "Bearer #{config.token}",
          "Content-Type" => "application/json; UTF8",
          "Content-Encoding" => "gzip"
      }

      request = Net::HTTP::Get.new(uri.request_uri, headers)

      response = client.request(request)

      response.kind_of?(Net::HTTPOK) && response.header["etag"]
    end

    def self.build_client(config)
      uri = URI.parse(config.endpoint)
      client = Net::HTTP.new(uri.host, uri.port)
      client.use_ssl = true
      return client, uri
    end
  end
end
