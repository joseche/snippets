# install tools
yum install -y policycoreutils-devel

# create policy from logs
grep nginx /var/log/audit/audit.log | audit2allow -M nginx

# add policy to allowed policies
semodule -i nginx.pp

# more info
grep nginx /var/log/audit/audit.log | audit2why
	Was caused by:
		Missing type enforcement TE allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

# to add permission by role:
semanage permissive -a httpd_t

# to remove permission by role:
semanage permissive -d httpd_t
