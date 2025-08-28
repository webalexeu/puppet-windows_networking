windows_network_route { 'Example Route':
  ensure             => present,
  destination_prefix => '172.16.0.0/16',
  interface_alias    => $facts['networking']['primary'],
  next_hop           => '172.16.10.1';
}
