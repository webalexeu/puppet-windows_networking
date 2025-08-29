![Build Status](https://ci.appveyor.com/api/projects/status/github/webalexeu/puppet-windows_networkingt?svg=true)
# windows_networking

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Manage the windows networking settings with Puppet.

## Features
* Create/edit/delete nrpt rule (`windows_dns_client_nrpt_rule`)
* Create/edit/delete network route (`windows_network_route`)

## Usage

### windows_network_route

Manage individual network route (Persistent route)
Note: 
- This resource is only managing manual routes and not routes created by DHCP/routing protocols.
- IPv4 is the default, to create IPv6 route, use the `address_family` property.

#### Listing Network Routes
The type and provider is able to enumerate the network route (persistent) existing on the 
system:

```shell
C:\>puppet resource windows_network_route
...
windows_network_route { '172.16.0.0/16':
  ensure          => 'present',
  address_family  => 'IPv4',
  interface_alias => 'Ethernet',
  interface_index => 2,
  next_hop        => '172.16.10.1',
  provider        => 'windows_network_route',
  publish         => 'No',
  route_metric    => 256,
}
```

#### Ensuring a network route

The basic syntax for ensuring route is: 

```puppet
windows_network_route { 'Example Route':
  ensure             => present,
  destination_prefix => '172.16.0.0/16',
  interface_alias    => $facts['networking']['primary'],
  next_hop           => '172.16.10.1';
}
```

In-place update is not implemented, when the network route defintion change, the route will be deleted and recreated. 
To delete a network route, set `ensure => absent`.

#### Purging network routes

You can choose to purge unmanaged network routes from the system (be careful! - this will
remove _any_ network routes that is not managed by Puppet):

```puppet
resources { 'windows_network_route':
  purge => true;
}
```


### windows_dns_client_nrpt_rule

Manage individual nrpt rule

#### Listing Nrpt Rule

The type and provider is able to enumerate the nrpt rule existing on the 
system:

```shell
C:\>puppet resource windows_dns_client_nrpt_rule
...
windows_dns_client_nrpt_rule { 'Example Rule':
  ensure        => 'present',
  da_enable     => false,
  dnssec_enable => false,
  name_encoding => 'Disable',
  name_servers  => ['192.168.1.2','192.168.1.1'],
  namespace     => ['fabrikam.com'],
  provider      => 'windows_dns_client_nrpt_rule',
}
windows_dns_client_nrpt_rule { 'Example Rule 2':
  ensure        => 'present',
  da_enable     => false,
  dnssec_enable => false,
  name_encoding => 'Disable',
  name_servers  => ['192.168.1.2'],
  namespace     => ['contoso.com','contoso.net'],
  provider      => 'windows_dns_client_nrpt_rule',
}
```

#### Ensuring a nrpt rule

The basic syntax for ensuring rule is: 

```puppet
windows_dns_client_nrpt_rule { 'Example Rule':
    namespace => 'fabrikam.com',
    name_servers => ['192.168.1.2','192.168.1.1'];
} 
```

If a nrpt rule with the same name but different properties already exists, it will be
updated to ensure it is defined correctly. To delete a nrpt rule, set
`ensure => absent`.

#### Purging nrpt rules

You can choose to purge unmanaged nrpt rule from the system (be careful! - this will
remove _any_ nrpt rule that is not managed by Puppet):

```puppet
resources { 'windows_dns_client_nrpt_rule':
  purge => true;
}
```


## Troubleshooting
* Try running puppet in debug mode (`--debug`)


## Limitations


## Development

PRs accepted :)

## Testing


## Source
