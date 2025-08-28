require 'puppet'
require 'json'
Puppet::Type.type(:windows_network_route).provide(:windows_network_route, parent: Puppet::Provider) do
  confine osfamily: 'windows'
  mk_resource_methods
  desc 'Windows Net route'
  

  POWERSHELL = ['powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command']

  def exists?
    @property_hash[:ensure] == :present
  end


  # all work done in `flush()` method
  def create()
  end

  # all work done in `flush()` method
  def destroy()
  end

  # Update process will delete the old route and create the new one (in-place update only support route metric)
  def flush
    # @property_hash contains the `IS` values (thanks Gary!)... For new rules there is no `IS`, there is only the
    # `SHOULD`. The setter methods from `mk_resource_methods` (or manually created) won't be called either. You have
    # to inspect @resource instead

    # we are flushing an existing resource to either update it or ensure=>absent it
    # therefore, delete this rule now and create a new one if needed
    if @property_hash[:ensure] == :present
      # Delete
      cmd = ["Remove-NetRoute", "-DestinationPrefix '#{resource[:destination_prefix]}'"]
      cmd += ["-Confirm:\$false"]

      Puppet::Util::Execution.execute(POWERSHELL + cmd)
    end

    if @resource[:ensure] == :present
      # Create
      cmd = ["New-NetRoute"]
      cmd += ["-DestinationPrefix", "'#{resource[:destination_prefix]}'"]
      cmd += ["-InterfaceAlias", "'#{resource[:interface_alias]}'"] if resource[:interface_alias]
      cmd += ["-InterfaceIndex", "'#{resource[:interface_index]}'"] if resource[:interface_index]
      cmd += ["-NextHop", "'#{resource[:next_hop]}'"] if resource[:next_hop]
      cmd += ["-AddressFamily", "'#{resource[:address_family]}'"] if resource[:address_family]
      cmd += ["-Publish", "'#{resource[:publish]}'"] if resource[:publish]
      cmd += ["-RouteMetric", "'#{resource[:route_metric]}'"] if resource[:route_metric]

      Puppet::Util::Execution.execute(POWERSHELL + cmd)
    end
  end


  def self.instances
    powershell_script = <<-PS
      Get-netRoute -PolicyStore PersistentStore -Protocol NetMgmt -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{
          DestinationPrefix = $_.DestinationPrefix
          InterfaceAlias    = $_.InterfaceAlias
          InterfaceIndex    = $_.InterfaceIndex
          NextHop           = $_.NextHop
          AddressFamily     = ($_.AddressFamily).ToString()
          Publish           = ($_.Publish).ToString()
          RouteMetric       = $_.RouteMetric
        }
      } | ConvertTo-Json -Depth 3
    PS

    json = Puppet::Util::Execution.execute(POWERSHELL + [powershell_script], failonfail: false)

    if json.empty?
      Puppet.debug("No Net routes found.")
      return []
    end
    
    begin
      routes = JSON.parse(json)
      routes = [routes] unless routes.is_a?(Array)
      routes.map do |route|
          new({
            ensure: :present,
            name: route['DestinationPrefix'],
            destination_prefix: route['DestinationPrefix'],
            interface_alias: route['InterfaceAlias'],
            interface_index: route['InterfaceIndex'],
            next_hop: route['NextHop'],
            address_family: route['AddressFamily'],
            publish: route['Publish'],
            route_metric: route['RouteMetric'],
          })
      end
    rescue JSON::ParserError => e
      Puppet.warning("Failed to parse Net routes: #{e}")
      Puppet.debug("Raw JSON output: #{json}")

      []
    end
  end

  def self.prefetch(resources)
    instances.each do |instance|
      if (resource = resources[instance.name])
        resource.provider = instance
      end
    end
  end
end
