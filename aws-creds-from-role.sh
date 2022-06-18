export AWS_CREDS=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/<iam-role>)
export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDS | jq -r ".SecretAccessKey")
export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDS | jq -r ".AccessKeyId")
export AWS_SESSION_TOKEN=$(echo $AWS_CREDS | jq -r ".Token")
