include_recipe 'aws::default'

%w(server.crt ca.crt server.key.enc dh2048.pem).each do |s3_object|
  aws_s3_file File.join('/etc/openvpn', s3_object) do
    bucket node['openvpn']['credentials_bucket']
    remote_path s3_object

    unless node['aws']['aws_access_key_id'].nil?
      aws_access_key_id node['aws']['aws_access_key_id']
      aws_secret_access_key node['aws']['aws_secret_access_key']
    end

    unless node['aws']['region'].nil?
      region node['aws']['region']
    end
  end
end

bash 'decrypt server key' do
  unless node['aws']['aws_access_key_id'].nil?
    environment(
      'AWS_ACCESS_KEY_ID' => node['aws']['aws_access_key_id'],
      'AWS_SECRET_ACCESS_KEY' => node['aws']['aws_secret_access_key']
    )
  end

  code <<-END
    set -o pipefail
    aws kms decrypt --ciphertext-blob fileb:///etc/openvpn/server.key.enc  \
                    --output text \
                    --region #{node['kms']['key_region']} \
                    --query Plaintext | base64 --decode > /etc/openvpn/server.key
  END
end

keys_directory = '/etc/openvpn/easy-rsa-keys'
directory keys_directory

# need to fix this up to remove revoked keys - clients removed from the s3 bucket
discover_client_credentials(credentials_bucket: node['openvpn']['credentials_bucket']).each do |client_name|
  aws_s3_file File.join(keys_directory, "#{client_name}.key.enc") do
    bucket node['openvpn']['credentials_bucket']
    remote_path "clients/#{client_name}/#{client_name}.key.enc"

    unless node['aws']['aws_access_key_id'].nil?
      aws_access_key_id node['aws']['aws_access_key_id']
      aws_secret_access_key node['aws']['aws_secret_access_key']
    end

    unless node['aws']['region'].nil?
      region node['aws']['region']
    end
  end

  aws_s3_file File.join(keys_directory, "#{client_name}.crt") do
    bucket node['openvpn']['credentials_bucket']
    remote_path "clients/#{client_name}/#{client_name}.crt"

    unless node['aws']['aws_access_key_id'].nil?
      aws_access_key_id node['aws']['aws_access_key_id']
      aws_secret_access_key node['aws']['aws_secret_access_key']
    end

    unless node['aws']['region'].nil?
      region node['aws']['region']
    end
  end

  bash "decrypt client key: #{client_name}" do
    unless node['aws']['aws_access_key_id'].nil?
      environment(
        'AWS_ACCESS_KEY_ID' => node['aws']['aws_access_key_id'],
        'AWS_SECRET_ACCESS_KEY' => node['aws']['aws_secret_access_key']
      )
    end

    code <<-END
      set -o pipefail
      aws kms decrypt --ciphertext-blob fileb://#{keys_directory}/#{client_name}.key.enc  \
                      --output text \
                      --region #{node['kms']['key_region']} \
                      --query Plaintext | base64 --decode > #{keys_directory}/#{client_name}.key
    END
  end
end

