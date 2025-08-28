Puppet::Type.newtype(:windows_network_route) do
    @doc = "Manage Net routes on Windows"

    ensurable do
      desc 'How to ensure this net route (`present` or `absent`)'
  
      defaultto :present
      defaultvalues
    end

  newparam(:destination_prefix, namevar: true) do
    desc 'The destination network prefix (e.g., 0.0.0.0/0).'
    validate do |value|
      unless value =~ %r{^\d{1,3}(\.\d{1,3}){3}/\d+$}
        raise ArgumentError, "Invalid destination prefix format: #{value}"
      end
    end
  end

    newproperty(:interface_alias) do
    desc 'Specifies an alias of network interfaces. The cmdlet modifies IP routes for the interfaces that have the aliases that you specify.'
  end


  newproperty(:next_hop) do
    desc 'The next hop IP address for the route.'
  end


  newproperty(:interface_index) do
    desc 'The index of the network interface.'
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, 'interface_index must be an integer'
      end
    end
  end

  newproperty(:address_family) do
    desc 'The IP address family (IPv4 or IPv6).'
    newvalues(:ipv4, :ipv6, :IPv4, :IPv6)
    defaultto(:IPv4)
  end

  newproperty(:route_metric) do
    desc 'The route metric used to prioritize routes.'
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, 'route_metric must be an integer'
      end
    end
  end

  newproperty(:publish) do
    desc 'Whether the route is published in router advertisements.'
    newvalues(:No, :Yes, :Age)
  end

  newproperty(:interface_metric) do
    desc 'The metric of the associated interface.'
  end

end
