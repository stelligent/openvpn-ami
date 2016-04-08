include_recipe 'openvpn::load_keys'

include_recipe 'openvpn::networking_rules'

service 'openvpn' do
  action :restart
end