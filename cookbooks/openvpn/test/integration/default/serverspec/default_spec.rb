require 'spec_helper'

%w(openvpn easy-rsa).each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

describe file('/etc/openvpn/server.conf') do
  it { should be_file }
  its(:content) { should match /^user nobody$/ }
  its(:content) { should match /^group nogroup$/ }
  its(:content) { should match /^push "dhcp-option DNS 208.67.222.222"/ }
  its(:content) { should match /^push "dhcp-option DNS 208.67.220.220"/ }
  its(:content) { should match /^dh dh2048.pem$/ }
end

describe file('/etc/sysctl.conf') do
  its(:content) { should match /^net.ipv4.ip_forward=1$/ }
end