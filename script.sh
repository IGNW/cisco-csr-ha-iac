chmod 600 csr.pem 
ssh -vi csr.pem -o StrictHostKeyChecking=no ec2-user@54.218.247.87 << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address 10.16.3.252 255.255.255.0 
end
guestshell enable
guestshell
pip install csr_aws_ha --user
EOF
ssh -vi csr.pem -o StrictHostKeyChecking=no ec2-user@54.201.154.239 << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address 10.16.4.252 255.255.255.0 
end
guestshell enable
guestshell
pip install csr_aws_ha --user
EOF
