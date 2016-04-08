include_recipe 'iptables::default'

##
# NOTE:
# presumably you don't want to run this for the AMI... otherwise the AMI is sort of tied to a particular VPC CIDR

iptables_rule 'masquerade_rule' do
  action :enable
  variables(vpc_cidr: node['openvpn']['vpc_cidr'],
            network_interface: 'eth0')
end

## this probably breaks if the VPC cidr isn't /16
extra_vpn_rules = <<END
push "route #{strip_cidr_suffix(node['openvpn']['vpc_cidr'])} 255.255.0.0"
client-config-dir /etc/openvpn/easy-rsa-keys
END

template '/etc/openvpn/server.conf' do
  source 'server.conf.erb'
  owner 'root'
  group 'root'
  mode '0744'
  variables(extra_rules: extra_vpn_rules)
end