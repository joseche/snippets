
# from p7b to pem
openssl pkcs7 -print_certs -in star_recruitics_com.p7b -out star.rx.pem

# from pem to pfx
openssl pksc7 -print_certs -in mycert.crt -inkey mykey.pem -out iis-cert.pfx

# print cert on https
openssl s_client -showcerts -servername google.com -connect google.com:443

# print cert dates
openssl s_client -connect google.com:443 </dev/null 2>/dev/null|openssl x509 -noout -dates

# print subject
openssl s_client -connect google.com:443 </dev/null 2>/dev/null|grep subject

