require 'soundcloud'

class Soundcloud
  def handle_response(refreshing_enabled=true, &block)
    response = block.call
    parsed_response = ::JSON.parse(response.body)

    if parsed_response && !response.success?
      parsed_response = HashResponseWrapper.new(parsed_response)

      if parsed_response.code == 401 && refreshing_enabled && options_for_refresh_flow_present?
        exchange_token
        # TODO it should return the original
        handle_response(false, &block)
      else
        #raise ResponseError.new(response), ResponseError.message(response)
        raise ResponseError.new(parsed_response)
        #raise ResponseError.from(response)
      end
    elsif parsed_response.is_a? Hash
      HashResponseWrapper.new(parsed_response)
    elsif parsed_response.is_a? Array
      ArrayResponseWrapper.new(parsed_response)
    end
  end
end