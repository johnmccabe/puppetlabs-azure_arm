# require "pry"
# require "pry-rescue"
require "json"

Puppet::Type.type(:azure_customer_subscription).provide(:arm) do
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
    @is_create = false
    @is_delete = false
  end

  def etag=(value)
    Puppet.info("etag setter called to change to #{value}")
    @property_flush[:etag] = value
  end

  def id=(value)
    Puppet.info("id setter called to change to #{value}")
    @property_flush[:id] = value
  end

  def location=(value)
    Puppet.info("location setter called to change to #{value}")
    @property_flush[:location] = value
  end

  def name=(value)
    Puppet.info("name setter called to change to #{value}")
    @property_flush[:name] = value
  end

  def properties=(value)
    Puppet.info("properties setter called to change to #{value}")
    @property_flush[:properties] = value
  end

  def tags=(value)
    Puppet.info("tags setter called to change to #{value}")
    @property_flush[:tags] = value
  end

  def type=(value)
    Puppet.info("type setter called to change to #{value}")
    @property_flush[:type] = value
  end


  def create
    @is_create = true
    Puppet.info("Entered create for resource #{name} of type CustomerSubscription")
    hash = build_hash
    response = self.class.invoke_create(resource, hash)

    if response.is_a? Net::HTTPSuccess
      @property_hash[:ensure] = :present
      Puppet.info("Added :ensure to property hash")
    else
      raise Puppet::Error, "Create failed.  Response is #{response} and body is #{response.body}"
    end
  rescue Exception => ex
    Puppet.alert("Exception during create. The state of the resource is unknown.  ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def flush
    Puppet.info("Entered flush for resource #{name} of type CustomerSubscription - creating ? #{@is_create}, deleting ? #{@is_delete}")
    if @is_create || @is_delete
      return # we've already done the create or delete
    end
    hash = build_hash
    response = self.class.invoke_update(resource, hash)

    if response.is_a? Net::HTTPSuccess
      @property_hash[:ensure] = :present
      Puppet.info("Added :ensure to property hash")
    else
      raise Puppet::Error, "Flush failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}"
    end
  rescue Exception => ex
    Puppet.alert("Exception during flush. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def build_hash
    customer_subscription = {}
    customer_subscription["etag"] = resource[:etag] unless resource[:etag].nil?
    customer_subscription["id"] = resource[:id] unless resource[:id].nil?
    customer_subscription["location"] = resource[:location] unless resource[:location].nil?
    customer_subscription["name"] = resource[:name] unless resource[:name].nil?
    customer_subscription["properties"] = resource[:properties] unless resource[:properties].nil?
    customer_subscription["tags"] = resource[:tags] unless resource[:tags].nil?
    customer_subscription["type"] = resource[:type] unless resource[:type].nil?
    return customer_subscription
  end

  def self.build_key_values
    key_values = {}
    key_values["api-version"] = "2017-06-01"
    key_values
  end

  def destroy
    delete(resource)
  end

  def delete(hash)
    Puppet.info("Entered delete for resource #{hash[:name]} of type <no value>")
    @is_delete = true
    response = self.class.invoke_delete(hash)

    if response.is_a? Net::HTTPSuccess
      @property_hash[:ensure] = :present
      Puppet.info "Added :absent to property_hash"
    else
      raise Puppet::Error, "Delete failed.  The state of the resource is unknown.  Response is #{response} and body is #{response.body}"
    end
  rescue Exception => ex
    Puppet.alert("Exception during destroy. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end


  def self.invoke_create(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation CustomerSubscriptions_Create")
    path_params = {}
    query_params = {}
    header_params = {}
    query_params["api-version"] = key_values["api-version"] unless key_values["api-version"].nil?
    query_params["api-version"] = ENV["azure_api_version"] unless ENV["azure_api_version"].nil?
    query_params["api-version"] = resource[:api_version] unless resource.nil? or resource[:api_version].nil?
    path_params[:customer_creation_parameters] = key_values["customerCreationParameters"] unless key_values["customerCreationParameters"].nil?
    path_params[:customer_creation_parameters] = ENV["azure_customer_creation_parameters"] unless ENV["azure_customer_creation_parameters"].nil?
    path_params[:customer_creation_parameters] = resource[:customer_creation_parameters] unless resource.nil? or resource[:customer_creation_parameters].nil?
    path_params[:customer_subscription_name] = key_values["customerSubscriptionName"] unless key_values["customerSubscriptionName"].nil?
    path_params[:customer_subscription_name] = ENV["azure_customer_subscription_name"] unless ENV["azure_customer_subscription_name"].nil?
    path_params[:customer_subscription_name] = resource[:name] unless resource.nil? or resource[:name].nil?
    path_params[:registration_name] = key_values["registrationName"] unless key_values["registrationName"].nil?
    path_params[:registration_name] = ENV["azure_registration_name"] unless ENV["azure_registration_name"].nil?
    path_params[:registration_name] = resource[:registration_name] unless resource.nil? or resource[:registration_name].nil?
    path_params[:resource_group] = key_values["resourceGroup"] unless key_values["resourceGroup"].nil?
    path_params[:resource_group] = ENV["azure_resource_group"] unless ENV["azure_resource_group"].nil?
    path_params[:resource_group] = resource[:resource_group] unless resource.nil? or resource[:resource_group].nil?
    path_params[:subscription_id] = key_values["subscriptionId"] unless key_values["subscriptionId"].nil?
    path_params[:subscription_id] = ENV["azure_subscription_id"] unless ENV["azure_subscription_id"].nil?
    path_params[:subscription_id] = resource[:subscription_id] unless resource.nil? or resource[:subscription_id].nil?
    uri_string = "https://management.azure.com/subscriptions/%{subscription_id}/resourceGroups/%{resource_group}/providers/Microsoft.AzureStack/registrations/%{registration_name}/customerSubscriptions/%{customer_subscription_name}" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of [application/json]
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Put.new(uri)
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (Put) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (Put) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

  def self.invoke_update(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation CustomerSubscriptions_Create")
    path_params = {}
    query_params = {}
    header_params = {}
    query_params["api-version"] = key_values["api-version"] unless key_values["api-version"].nil?
    query_params["api-version"] = ENV["azure_api_version"] unless ENV["azure_api_version"].nil?
    query_params["api-version"] = resource[:api_version] unless resource.nil? or resource[:api_version].nil?
    path_params[:customer_creation_parameters] = key_values["customerCreationParameters"] unless key_values["customerCreationParameters"].nil?
    path_params[:customer_creation_parameters] = ENV["azure_customer_creation_parameters"] unless ENV["azure_customer_creation_parameters"].nil?
    path_params[:customer_creation_parameters] = resource[:customer_creation_parameters] unless resource.nil? or resource[:customer_creation_parameters].nil?
    path_params[:customer_subscription_name] = key_values["customerSubscriptionName"] unless key_values["customerSubscriptionName"].nil?
    path_params[:customer_subscription_name] = ENV["azure_customer_subscription_name"] unless ENV["azure_customer_subscription_name"].nil?
    path_params[:customer_subscription_name] = resource[:name] unless resource.nil? or resource[:name].nil?
    path_params[:registration_name] = key_values["registrationName"] unless key_values["registrationName"].nil?
    path_params[:registration_name] = ENV["azure_registration_name"] unless ENV["azure_registration_name"].nil?
    path_params[:registration_name] = resource[:registration_name] unless resource.nil? or resource[:registration_name].nil?
    path_params[:resource_group] = key_values["resourceGroup"] unless key_values["resourceGroup"].nil?
    path_params[:resource_group] = ENV["azure_resource_group"] unless ENV["azure_resource_group"].nil?
    path_params[:resource_group] = resource[:resource_group] unless resource.nil? or resource[:resource_group].nil?
    path_params[:subscription_id] = key_values["subscriptionId"] unless key_values["subscriptionId"].nil?
    path_params[:subscription_id] = ENV["azure_subscription_id"] unless ENV["azure_subscription_id"].nil?
    path_params[:subscription_id] = resource[:subscription_id] unless resource.nil? or resource[:subscription_id].nil?
    uri_string = "https://management.azure.com/subscriptions/%{subscription_id}/resourceGroups/%{resource_group}/providers/Microsoft.AzureStack/registrations/%{registration_name}/customerSubscriptions/%{customer_subscription_name}" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of [application/json]
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Put.new(uri)
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (Put) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (Put) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

  def self.invoke_delete(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation CustomerSubscriptions_Delete")
    path_params = {}
    query_params = {}
    header_params = {}
    query_params["api-version"] = key_values["api-version"] unless key_values["api-version"].nil?
    query_params["api-version"] = ENV["azure_api_version"] unless ENV["azure_api_version"].nil?
    query_params["api-version"] = resource[:api_version] unless resource.nil? or resource[:api_version].nil?
    path_params[:customer_subscription_name] = key_values["customerSubscriptionName"] unless key_values["customerSubscriptionName"].nil?
    path_params[:customer_subscription_name] = ENV["azure_customer_subscription_name"] unless ENV["azure_customer_subscription_name"].nil?
    path_params[:customer_subscription_name] = resource[:name] unless resource.nil? or resource[:name].nil?
    path_params[:registration_name] = key_values["registrationName"] unless key_values["registrationName"].nil?
    path_params[:registration_name] = ENV["azure_registration_name"] unless ENV["azure_registration_name"].nil?
    path_params[:registration_name] = resource[:registration_name] unless resource.nil? or resource[:registration_name].nil?
    path_params[:resource_group] = key_values["resourceGroup"] unless key_values["resourceGroup"].nil?
    path_params[:resource_group] = ENV["azure_resource_group"] unless ENV["azure_resource_group"].nil?
    path_params[:resource_group] = resource[:resource_group] unless resource.nil? or resource[:resource_group].nil?
    path_params[:subscription_id] = key_values["subscriptionId"] unless key_values["subscriptionId"].nil?
    path_params[:subscription_id] = ENV["azure_subscription_id"] unless ENV["azure_subscription_id"].nil?
    path_params[:subscription_id] = resource[:subscription_id] unless resource.nil? or resource[:subscription_id].nil?
    uri_string = "https://management.azure.com/subscriptions/%{subscription_id}/resourceGroups/%{resource_group}/providers/Microsoft.AzureStack/registrations/%{registration_name}/customerSubscriptions/%{customer_subscription_name}" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of [application/json]
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Delete.new(uri)
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (Delete) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (Delete) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

  def self.invoke_list_with_params(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation CustomerSubscriptions_List")
    path_params = {}
    query_params = {}
    header_params = {}
    query_params["api-version"] = key_values["api-version"] unless key_values["api-version"].nil?
    query_params["api-version"] = ENV["azure_api_version"] unless ENV["azure_api_version"].nil?
    query_params["api-version"] = resource[:api_version] unless resource.nil? or resource[:api_version].nil?
    path_params[:registration_name] = key_values["registrationName"] unless key_values["registrationName"].nil?
    path_params[:registration_name] = ENV["azure_registration_name"] unless ENV["azure_registration_name"].nil?
    path_params[:registration_name] = resource[:registration_name] unless resource.nil? or resource[:registration_name].nil?
    path_params[:resource_group] = key_values["resourceGroup"] unless key_values["resourceGroup"].nil?
    path_params[:resource_group] = ENV["azure_resource_group"] unless ENV["azure_resource_group"].nil?
    path_params[:resource_group] = resource[:resource_group] unless resource.nil? or resource[:resource_group].nil?
    path_params[:subscription_id] = key_values["subscriptionId"] unless key_values["subscriptionId"].nil?
    path_params[:subscription_id] = ENV["azure_subscription_id"] unless ENV["azure_subscription_id"].nil?
    path_params[:subscription_id] = resource[:subscription_id] unless resource.nil? or resource[:subscription_id].nil?
    uri_string = "https://management.azure.com/subscriptions/%{subscription_id}/resourceGroups/%{resource_group}/providers/Microsoft.AzureStack/registrations/%{registration_name}/customerSubscriptions" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of [application/json]
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (Get) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (Get) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

  def self.invoke_get_one(resource = nil, body_params = nil)
    key_values = self.build_key_values
    Puppet.info("Calling operation CustomerSubscriptions_Get")
    path_params = {}
    query_params = {}
    header_params = {}
    query_params["api-version"] = key_values["api-version"] unless key_values["api-version"].nil?
    query_params["api-version"] = ENV["azure_api_version"] unless ENV["azure_api_version"].nil?
    query_params["api-version"] = resource[:api_version] unless resource.nil? or resource[:api_version].nil?
    path_params[:customer_subscription_name] = key_values["customerSubscriptionName"] unless key_values["customerSubscriptionName"].nil?
    path_params[:customer_subscription_name] = ENV["azure_customer_subscription_name"] unless ENV["azure_customer_subscription_name"].nil?
    path_params[:customer_subscription_name] = resource[:name] unless resource.nil? or resource[:name].nil?
    path_params[:registration_name] = key_values["registrationName"] unless key_values["registrationName"].nil?
    path_params[:registration_name] = ENV["azure_registration_name"] unless ENV["azure_registration_name"].nil?
    path_params[:registration_name] = resource[:registration_name] unless resource.nil? or resource[:registration_name].nil?
    path_params[:resource_group] = key_values["resourceGroup"] unless key_values["resourceGroup"].nil?
    path_params[:resource_group] = ENV["azure_resource_group"] unless ENV["azure_resource_group"].nil?
    path_params[:resource_group] = resource[:resource_group] unless resource.nil? or resource[:resource_group].nil?
    path_params[:subscription_id] = key_values["subscriptionId"] unless key_values["subscriptionId"].nil?
    path_params[:subscription_id] = ENV["azure_subscription_id"] unless ENV["azure_subscription_id"].nil?
    path_params[:subscription_id] = resource[:subscription_id] unless resource.nil? or resource[:subscription_id].nil?
    uri_string = "https://management.azure.com/subscriptions/%{subscription_id}/resourceGroups/%{resource_group}/providers/Microsoft.AzureStack/registrations/%{registration_name}/customerSubscriptions/%{customer_subscription_name}" % path_params
    uri_string = uri_string + "?" + to_query(query_params)
    header_params['Content-Type'] = 'application/json' # first of [application/json]
    if authenticate(path_params, query_params, header_params, body_params)
      Puppet.info("Authentication succeeded")
      uri = URI(uri_string)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        add_keys_to_request(req, header_params)
        if body_params
          req.body = body_params.to_json
        end
        Puppet.debug("URI is (Get) #{uri}, body is #{body_params}, query params are #{query_params}, headers are #{header_params}")
        response = http.request req # Net::HTTPResponse object
        Puppet.debug("response code is #{response.code} and body is #{response.body}")
        success = response.is_a? Net::HTTPSuccess
        Puppet.info("Called (Get) endpoint at #{uri}, success was #{success}")
        return response
      end
    end
  end

  def self.authenticate(path_params, query_params, header_params, body_params)
    token = fetch_oauth2_token
    if token
      header_params['Authorization'] = "Bearer #{token}"
      return true
    else
      return false
    end
  end

  def self.fetch_oauth2_token
    Puppet.info("Getting oauth2 token")
    @client_id = ENV["azure_client_id"]
    @client_secret = ENV["azure_client_secret"]
    @tenant_id = ENV["azure_tenant_id"]
    uri = URI("https://login.microsoftonline.com/#{@tenant_id}/oauth2/token")
    response = Net::HTTP.post_form(uri,
                                   'grant_type' => 'client_credentials',
                                   'client_id'     => @client_id,
                                   'client_secret' => @client_secret,
                                   'resource'      => 'https://management.azure.com/')

    Puppet.debug("get oauth2 token response code is #{response.code} and body is #{response.body}")
    success = response.is_a? Net::HTTPSuccess
    if success
      return JSON[response.body]["access_token"]
    else
      raise Puppet::Error, "Unable to get oauth2 token - response is #{response} and body is #{response.body}"
    end
  end

  def exists?
    Puppet.info("exists_one for resource #{name} of type <no value>")
    return exists_one(resource)
  end

  
  def exists_one(resource)
    response = self.class.invoke_get_one(resource)

    if response.is_a? Net::HTTPSuccess
      return true
    else
      return false
    end
  rescue Exception => ex
    Puppet.alert("Exception during exists_one. ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end
  def self.add_keys_to_request(request, hash)
    if hash
      hash.each { |x, v| request[x] = v }
    end
  end

  def self.to_query(hash)
    if hash
      return_value = hash.map { |x, v| "#{x}=#{v}" }.reduce { |x, v| "#{x}&#{v}" }
      if !return_value.nil?
        return return_value
      end
    end
    return ""
  end
end # this is the end of the ruby class

