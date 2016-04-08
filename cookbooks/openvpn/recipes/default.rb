include_recipe 'awscli::default'

packages_to_install = %w(openvpn easy-rsa)

packages_to_install.each do |package_to_install|
  package package_to_install
end

template '/etc/openvpn/server.conf' do
  source 'server.conf.erb'
  owner 'root'
  group 'root'
  mode '0744'
end

ruby_block 'make forwarding permanent' do
  block do
    file = Chef::Util::FileEdit.new('/etc/sysctl.conf')
    file.insert_line_if_no_match(/^net\.ipv4\.ip_forward=1/,'net.ipv4.ip_forward=1')
    file.write_file
  end
end

