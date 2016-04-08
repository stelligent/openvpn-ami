require 'spec_helper'

%w(/etc/openvpn/server.crt /etc/openvpn/ca.crt).each do |openvpn_file|
  describe file(openvpn_file) do
    its(:size) { should > 0 }
    its(:content) { should match /-----BEGIN CERTIFICATE-----/ }
  end
end

describe iptables do
  it { should have_rule('-j MASQUERADE').with_table('nat').with_chain('POSTROUTING') }

  # er not sure about this...
  it { should have_rule('-s 10.0.0.0/16').with_table('nat').with_chain('POSTROUTING') }
end
