require 'json'

module Zensana
  class Error < StandardError
    def self.msg=(msg)
      @msg = msg
    end

    def self.msg
      @msg
    end

    def initialize(msg=nil)
      super msg || self.class.msg
    end

    def self.handle_http_errors(http_response)
      message = JSON.parse(http_response.body)['errors'].first['message'] rescue nil
      case http_response.code
      when 200 then return
      when 404 then raise NotFound, message
      when 401..403 then raise AccessDenied, message
      else raise Unprocessable, message
      end
    end
  end

  class AccessDenied < Error
    self.msg = "Access denied - check credentials"
  end

  class Unprocessable < Error
    self.msg = "Something went wrong in the external service"
  end

  class NotFound < Error
    self.msg = "That item does not exist"
  end
end