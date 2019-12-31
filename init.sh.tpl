chmod 600 csr.pem 
until -vi csr.pem -o ClientAliveInterval=10 -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip}; do
    sleep 5
done
#ssh -vi csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip} << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address ${csrv1_eth1_private} 255.255.255.0 
end

guestshell enable
guestshell
pip install csr_aws_ha --user
exit

configure terminal
crypto isakmp policy 1
encr aes 256
authentication pre-share
crypto isakmp key cisco address 0.0.0.0
end

configure terminal
crypto ipsec transform-set uni-perf esp-aes 256 esp-sha-hmac
mode tunnel
end

configure terminal
crypto ipsec profile vti-1
set security-association lifetime kilobytes disable
set security-association lifetime seconds 86400
set transform-set uni-perf
set pfs group2
end

configure terminal
interface Tunnel1
ip address ${csrv1_eth1_private} 255.255.255.252.
load-interval 30
tunnel source GigabitEthernet1
tunnel mode ipsec ipv4
tunnel destination ${csrv2_public_ip} 
tunnel protection ipsec profile vti-1
bfd interval 100 min_rx 100 multiplier 3
end

configure terminal
router eigrp 1
network 192.168.101.0 0.0.0.255
bfd all-interfaces
end

configure terminal
redundancy
cloud-ha bfd peer ${csrv2_eth1_private}
end

guestshell
create_node.py -i 2 -t ${private_rtb} -rg us-west-2 -n ${csrv1_eth1_eni}
exit
EOF

until -vi csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv2_public_ip}; do
    sleep 5
done
#ssh -vi csr.pem -o ClientAliveInterval=10 -o StrictHostKeyChecking=no ec2-user@${csrv2_public_ip} << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address ${csrv2_eth1_private} 255.255.255.0 
end
guestshell enable
guestshell
pip install csr_aws_ha --user
exit

configure terminal
interface GigabitEthernet2
no shutdown
ip address ${csrv2_eth1_private} 255.255.255.0
end

configure terminal
crypto isakmp policy 1
encr aes 256
authentication pre-share
crypto isakmp key cisco address 0.0.0.0
end

configure terminal
crypto ipsec transform-set uni-perf esp-aes 256 esp-sha-hmac
mode tunnel
end

configure terminal
crypto ipsec profile vti-1
set security-association lifetime kilobytes disable
set security-association lifetime seconds 86400
set transform-set uni-perf
set pfs group2
end

configure terminal
interface Tunnel1
ip address ${csrv2_eth1_private} 255.255.255.252.
load-interval 30
tunnel source GigabitEthernet1
tunnel mode ipsec ipv4
tunnel destination ${csrv1_public_ip} 
tunnel protection ipsec profile vti-1
bfd interval 100 min_rx 100 multiplier 3
end

configure terminal
router eigrp 1
network 192.168.101.0 0.0.0.255
bfd all-interfaces
end

configure terminal
redundancy
cloud-ha bfd peer ${csrv1_eth1_private}
end

guestshell
create_node.py -i 2 -t ${private_rtb} -rg us-west-2 -n ${csrv2_eth1_eni}
exit
EOF
