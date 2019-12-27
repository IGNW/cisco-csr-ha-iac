chmod 600 csr.pem 
ssh -vi csr.pem -o StrictHostKeyChecking=no ec2-user@18.237.107.172 << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address 10.16.3.252 255.255.255.0 
end
EOF
ssh -vi csr.pem -o StrictHostKeyChecking=no ec2-user@34.219.161.164 << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address 10.16.4.252 255.255.255.0 
end
EOF
