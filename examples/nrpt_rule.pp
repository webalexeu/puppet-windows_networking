windows_dns_client_nrpt_rule { 'Example Rule':
	namespace => 'fabrikam.com',
	name_servers => ['192.168.1.2','192.168.1.1'];
} 

windows_dns_client_nrpt_rule { 'Example Rule 2':
	namespace => ['contoso.com','contoso.net'],
	name_servers => '192.168.1.2';
} 