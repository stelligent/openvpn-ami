def discover_client_credentials(credentials_bucket:)

  fixup_aws_environment_variables

  require 'aws-sdk'
  s3client = Aws::S3::Client.new
  s3 = Aws::S3::Resource.new(client: s3client)

  clients_object_summaries = s3.bucket(credentials_bucket).objects(prefix: 'clients')
  clients_object_summaries.inject(Set.new) do |client_names, client_object_summary|
    client_name = client_object_summary.key.split('/')[1]
    unless client_name.nil? or client_name.strip.empty?
      client_names << client_name
    end
    client_names
  end
end

def strip_cidr_suffix(cidr_range)
  cidr_range.gsub(/\/\d+/,'')
end

# helps to run locally v. in an instance profile
def fixup_aws_environment_variables
  unless node['aws']['aws_access_key_id'].nil?
    ENV['AWS_ACCESS_KEY_ID'] =  node['aws']['aws_access_key_id']
    ENV['AWS_SECRET_ACCESS_KEY'] = node['aws']['aws_secret_access_key']
  end
  ENV['AWS_REGION'] = node['aws']['region'] unless node['aws']['region'].nil?
end