#!/usr/bin/env bash

users=$(aws iam list-users --query "Users[].UserName" --output text)

for user in $users; do
  access_key_ids=$(aws iam list-access-keys \
                       --user-name "$user" \
                       --query "AccessKeyMetadata[].AccessKeyId" \
                       --output text)
  for access_key in $access_key_ids; do
    lastUsed=$(aws iam get-access-key-last-used \
                   --access-key-id "$access_key" \
                   --query "AccessKeyLastUsed.LastUsedDate" \
                   --output text)
    echo "$lastUsed,$access_key,$user"
  done
done
