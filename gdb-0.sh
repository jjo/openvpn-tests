# sudo ./openvpn --mktun --dev tap0
gdb --args ./openvpn --dev tap0 --proto tcp-server --local localhost --lport 5011 ../keys/openvpn.key --mode server --tls-server --dh easy-rsa/2.0/keys/dh1024.pem --ca easy-rsa/2.0/keys/ca.crt --cert easy-rsa/2.0/keys/myserver.crt --key easy-rsa/2.0/keys/myserver.key
