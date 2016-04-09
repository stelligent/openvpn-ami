#!/bin/bash -ex

KMS_KEY_ID=$1
KMS_KEY_REGION=$2
KEY_DIR=$3
TARGET_BUCKET=$4

for key in "${KEY_DIR}"/*.key;
do
  key_contents=$(cat "${key}")
  key_name=$(basename "${key}")
  aws kms encrypt --key-id ${KMS_KEY_ID} \
                  --plaintext "${key_contents}" \
                  --query CiphertextBlob \
                  --output text\
                  --region ${KMS_KEY_REGION} | base64 --decode > ./${key_name}.enc
done


aws s3 cp "${KEY_DIR}"/ca.crt s3://${TARGET_BUCKET}/
aws s3 cp "${KEY_DIR}"/server.crt s3://${TARGET_BUCKET}/
aws s3 cp "${KEY_DIR}"/dh2048.pem s3://${TARGET_BUCKET}/

aws s3 cp server.key.enc s3://${TARGET_BUCKET}/
for key in $(ls *.key.enc);
do
  if [[ ${key} != server.key.enc && ${key} != ca.key.enc ]];
  then
    client_name=${key//.key.enc/}
    aws s3 cp ${key} s3://${TARGET_BUCKET}/clients/${client_name}/${key}

    aws s3 cp "${KEY_DIR}"/${client_name}.crt s3://${TARGET_BUCKET}/clients/${client_name}/${client_name}.crt
  fi
done
