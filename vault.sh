# installation:
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install vault

# login
export VAULT_ADDR=https://vault.mycorp.com
vault login -method=aws header_value=vault.mycorp.com role=myapp-role


# read key value pairs
vault kv list kv/myapp/staging
vault kv get kv/myapp/staging/access:somesecret
vault kv get -field=API_KEY kv/myapp/staging/access:somesecret
