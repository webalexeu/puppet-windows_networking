Puppet::Type.newtype(:windows_dns_client_nrpt_rule) do
    @doc = "Manage NRPT rules on Windows"

    ensurable do
      desc 'How to ensure this nrpt rule (`present` or `absent`)'
  
      defaultto :present
      defaultvalues
    end

  newparam(:name, namevar: true) do
    desc "Specifies the DNS Client NRPT rule name."
    validate do |value|
      raise ArgumentError, "Name must be a string" unless value.is_a?(String)
    end
  end

  newproperty(:comment) do
    desc "Stores administrator notes."
  end

  newproperty(:da_enable) do
    desc "Indicates the rule state for DirectAccess."
    newvalues(:true, :false)
  end

  newproperty(:da_ipsec_encryption_type) do
    desc "IPsec encryption setting for DirectAccess."
    newvalues("none", "low", "medium", "high", "None", "Low", "Medium", "High")
  end

  newproperty(:da_ipsec_required) do
    desc "Indicates that IPsec is required for DirectAccess."
    newvalues(:true, :false)
  end

  newproperty(:da_name_servers, array_matching: :all) do
    desc "DNS servers to query when DirectAccess is enabled."
    validate do |value|
      raise ArgumentError, "Each DANameServer must be a string" unless value.is_a?(String)
    end
  end

  newproperty(:da_proxy_server_name) do
    desc "Proxy server to use when connecting to the Internet."
  end

  newproperty(:da_proxy_type) do
    desc "Proxy server type to be used."
    newvalues("noproxy", "usedefault", "useproxyname", "NoProxy", "UseDefault", "UseProxyName")
  end

  newproperty(:display_name) do
    desc "Optional friendly name for the NRPT rule."
  end

  newproperty(:dnssec_enable) do
    newvalues(:true, :false)
    desc "Enables DNSSEC on the rule."
  end

  newproperty(:dnssec_ipsec_encryption_type) do
    desc "IPsec tunnel encryption setting."
    newvalues("none", "low", "medium", "high", "None", "Low", "Medium", "High")
  end

  newproperty(:dnssec_ipsec_required) do
    newvalues(:true, :false)
    desc "DNS client must set up an IPsec connection to the DNS server."
  end

  newproperty(:dnssec_validation_required) do
    newvalues(:true, :false)
    desc "DNSSEC validation is required."
  end

  newproperty(:ipsec_trust_authority) do
    desc "Certification authority to validate the IPsec channel."
  end

  newproperty(:name_encoding) do
    desc "Encoding format for host names in the DNS query."
    newvalues("disable", "utf8withmapping", "utf8withoutmapping", "punycode", "disable", "Utf8WithMapping", "Utf8WithoutMapping", "Punycode")
  end

  newproperty(:name_servers, array_matching: :all) do
    desc "DNS servers to which the DNS query is sent when DirectAccess is disabled."
    validate do |value|
      raise ArgumentError, "Each NameServer must be a string" unless value.is_a?(String)
    end
  end

  newproperty(:namespace, array_matching: :all) do
    desc "DNS namespace."
    validate do |value|
      raise ArgumentError, "Each Namespace must be a string" unless value.is_a?(String)
    end
  end
end
