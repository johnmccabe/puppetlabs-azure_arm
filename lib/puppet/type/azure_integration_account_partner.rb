require 'puppet/parameter/boolean'

Puppet::Type.newtype(:azure_integration_account_partner) do
  @doc = "The integration account partner."

  ensurable

  validate do
    required_properties = [
      :properties,
      :integration_account_name,
      :partner,
      :partner_name,
      :resource_group_name,
    ]
    required_properties.each do |property|
      # We check for both places so as to cover the puppet resource path as well
      if self[:ensure] == :present && self[property].nil? && self.provider.send(property) == :absent
        raise Puppet::Error, "In azure_integration_account_partner you must provide a value for #{property}"
      end
    end
  end
  newproperty(:id) do
    desc "The resource id."
    validate do |value|
      true
    end
  end
  newproperty(:location) do
    desc "The resource location."
    validate do |value|
      true
    end
  end
  newparam(:name) do
    isnamevar
    desc "Gets the resource name."
    validate do |value|
      true
    end
  end
  newproperty(:properties) do
    desc "The integration account partner properties."
    validate do |value|
      true
    end
  end
  newproperty(:tags) do
    desc "The resource tags."
    validate do |value|
      true
    end
  end
  newproperty(:type) do
    desc "Gets the resource type."
    validate do |value|
      true
    end
  end
  newparam(:api_version) do
    desc "The API version."
    validate do |value|
      true
    end
  end
  newparam(:integration_account_name) do
    desc "The integration account name."
    validate do |value|
      true
    end
  end
  newparam(:partner) do
    desc "The integration account partner."
    validate do |value|
      true
    end
  end
  newparam(:partner_name) do
    desc "The integration account partner name."
    validate do |value|
      true
    end
  end
  newparam(:resource_group_name) do
    desc "The resource group name."
    validate do |value|
      true
    end
  end
  newparam(:subscription_id) do
    desc "The subscription id."
    validate do |value|
      true
    end
  end
end
