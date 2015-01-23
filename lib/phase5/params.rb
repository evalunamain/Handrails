require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @req = req
      @params = route_params

      parse_www_encoded_form(@req.query_string) if @req.query_string
      parse_www_encoded_form(@req.body) if @req.body

    end

    def [](key)
      key = key.to_s
      @params[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      parsed = URI::decode_www_form(www_encoded_form)

      parsed.each do |key, value|
        nested_params = @params

        nested_keys = parse_key(key)

        nested_keys.each_with_index do |nested_key, i|
          if i + 1 == nested_keys.size
            nested_params[nested_key] = value
          else
            nested_params[nested_key] ||= {}
            nested_params = nested_params[nested_key]
          end
        end
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
