#!/bin/bash -ex

KMS_KEY_ID=xxxxx
KMS_KEY_REGION=xxxx
KEY_DIR=xxxxx
TARGET_BUCKET=xxxx

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
    aws s3 cp ${key} s3://${TARGET_BUCKET}/clients/${key//.key.enc/}/${key}

    aws s3 cp "${KEY_DIR}"/${key//.key.enc/}.crt s3://${TARGET_BUCKET}/clients/${key//.key.enc/}/${key//.key.enc/}.crt
  fi
done
