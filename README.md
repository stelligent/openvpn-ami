# Summary

Cookbook and packer specification to spit out an OpenVPN AMI.

The run-list for the AMI lays down the OpenVPN software but doesn't lay down any of the server and client keys.

The cookbook includes recipes that can be invoked (in user data) when the instance is brought up to
pull the server and client keys from an S3 bucket.

# Generating Keys

On a Mac, install Tunnelblick and then select "Open easy-rsa in Terminal" from the Utilities menu.

From there, follow the instructions at: https://openvpn.net/index.php/open-source/documentation/howto.html

Be sure to run build-dh with 2048:

    KEY_SIZE=2048 ./build-dh 
    
These instructions will generate a bunch of certificates and keys including:
  * ca.crt
  * ca.key
  * server.crt
  * server.key
  * clients 1-n crt and key
  * dh2048.pem
  
Most of these items will need to be loaded onto an OpenVPN instance and some of them are sensitive.  See the 
aforementioned howto guide on which items are sensitive - there is an easy-to-follow table.
   
The load_keys recipe called from userdata expects to find these files in an S3 bucket and for the
key files to be encrypted with KMS.  The instance must be running in EC2 with an instance profile
that allows permission to decrypt with the KMS key the credentials were encrypted with originally
before they were pushed to S3.

To get all the relevant artifacts up to S3, there is a convenience script:

    bin/encrypt_keys_with_kms.sh <kms_key_arn> <key region> <key dir> <s3 target bucket>

On a Mac with Tunnelblick, you likely want this for the "key dir":

    ~/Library/Application\ Support/Tunnelblick/easy-rsa/keys
    
When this script is run, you'll need to have Encrypt privileges with the specified key (i.e. make sure AWS_ACCESS_KEY_ID, etc.
is set in the environment such that it has privilege to Encrypt).