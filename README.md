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

## Usage

### windows_dns_client
Manage individual nrpt rule

#### Listing Nrpt Rule

The type and provider is able to enumerate the port forward existing on the 
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

The basic syntax for ensuring rules is: 

```puppet
windows_dns_client_nrpt_rule { 'Example Rule':
    namespace => 'fabrikam.com',
    name_servers => ['192.168.1.2','192.168.1.1'];
} 
```

If a nrpt rule with the same name but different properties already exists, it will be
updated to ensure it is defined correctly. To delete a nrpt rule, set
`ensure => absent`.

#### Purging nrpt rule

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
