#!/bin/bash -ex

bundle install

pushd cookbooks
  cd openvpn
  berks vendor /var/tmp/berks-cookbooks
popd

packer build ./packer.json
