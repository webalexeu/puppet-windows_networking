require 'puppet'
require 'json'
Puppet::Type.type(:windows_dns_client_nrpt_rule).provide(:windows_dns_client_nrpt_rule, parent: Puppet::Provider) do
  confine osfamily: 'windows'
  mk_resource_methods
  desc 'Windows Dns Client NRPT Rule'
  

  POWERSHELL ||= ['powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command']

  def exists?
    @property_hash[:ensure] == :present
  end

  def powershell_array(array)
    "@(" + array.map { |v| "'#{v}'" }.join(',') + ")"
  end  

  def create
    cmd = ["$NrptRuleName=("]
    cmd += ["Add-DnsClientNrptRule"] 
    cmd += ["-Comment", "'#{resource[:comment]}'"] if resource[:comment]
    cmd += ["-DirectAccessEnabled", resource[:da_enable]] if resource[:da_enable]
    cmd += ["-DAIPsecEncryptionType", "'#{resource[:da_ipsec_encryption_type]}'"] if resource[:da_ipsec_encryption_type]
    cmd += ["-DAIPsecRequired", resource[:da_ipsec_required]] if resource[:da_ipsec_required]
    cmd += ["-DANameServers", powershell_array(resource[:da_name_servers])] if resource[:da_name_servers]
    cmd += ["-DirectAccessProxyName", "'#{resource[:da_proxy_server_name]}'"] if resource[:da_proxy_server_name]
    cmd += ["-DirectAccessProxyType", "'#{resource[:da_proxy_type]}'"] if resource[:da_proxy_type]
    cmd += ["-DisplayName", "'#{resource[:display_name]}'"] if resource[:display_name]
    cmd += ["-DnsSecEnabled", resource[:dnssec_enable]] if resource[:dnssec_enable]
    cmd += ["-DnsSecQueryIPsecEncryption", "'#{resource[:dnssec_ipsec_encryption_type]}'"] if resource[:dnssec_ipsec_encryption_type]
    cmd += ["-DnsSecQueryIPsecRequired", resource[:dnssec_ipsec_required]] if resource[:dnssec_ipsec_required]
    cmd += ["-DnsSecValidationRequired", resource[:dnssec_validation_required]] if resource[:dnssec_validation_required]
    cmd += ["-IPsecCARestriction", "'#{resource[:ipsec_trust_authority]}'"] if resource[:ipsec_trust_authority]
    cmd += ["-NameEncoding", "'#{resource[:name_encoding]}'"] if resource[:name_encoding]
    cmd += ["-NameServers", powershell_array(resource[:name_servers])] if resource[:name_servers]
    cmd += ["-Namespace", powershell_array(resource[:namespace])] if resource[:namespace]    
    cmd += ["-PassThru"]
    cmd += [").Name;"]
    cmd += ["Rename-Item -Path \"HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Dnscache\\Parameters\\DnsPolicyConfig\\$($NrptRuleName)\" -NewName '#{resource[:name]}'"]

    Puppet::Util::Execution.execute(POWERSHELL + cmd)
  end

  def flush
    return unless @property_hash[:ensure] == @resource[:ensure]

    cmd = ["Set-DnsClientNrptRule -Name '#{resource[:name]}'"]
    cmd += ["-Comment", "'#{resource[:comment]}'"] if resource[:comment]
    cmd += ["-DirectAccessEnabled", resource[:da_enable]] if resource[:da_enable]
    cmd += ["-DAIPsecEncryptionType", "'#{resource[:da_ipsec_encryption_type]}'"] if resource[:da_ipsec_encryption_type]
    cmd += ["-DAIPsecRequired", resource[:da_ipsec_required]] if resource[:da_ipsec_required]
    cmd += ["-DANameServers", powershell_array(resource[:da_name_servers])] if resource[:da_name_servers]
    cmd += ["-DirectAccessProxyName", "'#{resource[:da_proxy_server_name]}'"] if resource[:da_proxy_server_name]
    cmd += ["-DirectAccessProxyType", "'#{resource[:da_proxy_type]}'"] if resource[:da_proxy_type]
    cmd += ["-DisplayName", "'#{resource[:display_name]}'"] if resource[:display_name]
    cmd += ["-DnsSecEnabled", resource[:dnssec_enable]] if resource[:dnssec_enable]
    cmd += ["-DnsSecQueryIPsecEncryption", "'#{resource[:dnssec_ipsec_encryption_type]}'"] if resource[:dnssec_ipsec_encryption_type]
    cmd += ["-DnsSecQueryIPsecRequired", resource[:dnssec_ipsec_required]] if resource[:dnssec_ipsec_required]
    cmd += ["-DnsSecValidationRequired", resource[:dnssec_validation_required]] if resource[:dnssec_validation_required]
    cmd += ["-IPsecCARestriction", "'#{resource[:ipsec_trust_authority]}'"] if resource[:ipsec_trust_authority]
    cmd += ["-NameEncoding", "'#{resource[:name_encoding]}'"] if resource[:name_encoding]
    cmd += ["-NameServers", powershell_array(resource[:name_servers])] if resource[:name_servers]
    cmd += ["-Namespace", powershell_array(resource[:namespace])] if resource[:namespace]    
    
    Puppet::Util::Execution.execute(POWERSHELL + cmd)
  end

  def destroy
    cmd = ["Remove-DnsClientNrptRule -Name '#{resource[:name]}'", "-Force"]

    Puppet::Util::Execution.execute(POWERSHELL + cmd)
  end

  def self.instances
    powershell_script = <<-PS
      Get-DnsClientNrptRule | ForEach-Object {
        [PSCustomObject]@{
          Name                             = $_.Name
          Namespace                        = if ($_.Namespace) { @($_.Namespace) } else { $null }
          NameEncoding                     = $_.NameEncoding
          NameServers                      = if ($_.NameServers) { @($_.NameServers | ForEach-Object { $_.IPAddressToString }) } else { $null }
          Comment                          = $_.Comment
          DisplayName                      = $_.DisplayName
          DirectAccessEnabled              = $_.DirectAccessEnabled
          DirectAccessProxyName            = $_.DirectAccessProxyName
          DirectAccessProxyType            = $_.DirectAccessProxyType
          DirectAccessQueryIPsecEncryption = $_.DirectAccessQueryIPsecEncryption
          DirectAccessQueryIPsecRequired   = $_.DirectAccessQueryIPsecRequired
          DnsSecEnabled                    = $_.DnsSecEnabled
          DnsSecQueryIPsecEncryption       = $_.DnsSecQueryIPsecEncryption
          DnsSecQueryIPsecRequired         = $_.DnsSecQueryIPsecRequired
          DnsSecValidationRequired         = $_.DnsSecValidationRequired
          IPsecCARestriction               = $_.IPsecCARestriction
          DAIPsecRequired                  = $_.DAIPsecRequired
          DAIPsecEncryptionType            = $_.DAIPsecEncryptionType
          DANameServers                    = if ($_.DANameServers) { @($_.DANameServers | ForEach-Object { $_.IPAddressToString }) } else { $null }
        }
      } | ConvertTo-Json -Depth 3
    PS

    json = Puppet::Util::Execution.execute(POWERSHELL + [powershell_script], failonfail: false)

    if json.empty?
      Puppet.debug("No NRPT rules found.")
      return []
    end
    
    begin
      rules = JSON.parse(json)
      rules = [rules] unless rules.is_a?(Array)
      rules.map do |rule|
          new({
            ensure: :present,
            name: rule['Name'],
            comment: rule['Comment'],
            da_enable: rule['DirectAccessEnabled'],
            da_ipsec_encryption_type: rule['DAIPsecEncryptionType'],
            da_ipsec_required: rule['DAIPsecRequired'],
            da_name_servers: Array(rule['DANameServers']),
            da_proxy_server_name: rule['DirectAccessProxyName'],
            da_proxy_type: rule['DirectAccessProxyType'],
            display_name: rule['DisplayName'],
            dnssec_enable: rule['DnsSecEnabled'],
            dnssec_ipsec_encryption_type: rule['DnsSecQueryIPsecEncryption'],
            dnssec_ipsec_required: rule['DnsSecQueryIPsecRequired'],
            dnssec_validation_required: rule['DnsSecValidationRequired'],
            ipsec_trust_authority: rule['IPsecCARestriction'],
            name_encoding: rule['NameEncoding'],
            name_servers: Array(rule['NameServers']),
            namespace: Array(rule['Namespace'])
          })
      end
    rescue JSON::ParserError => e
      Puppet.warning("Failed to parse Nrpt rules: #{e}")
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
