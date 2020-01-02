#!/bin/bash
cat <<EOF >> csr.pem
${ssh_key}
EOF
chmod 600 csr.pem 
ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip} 'guestshell disable'
until ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip} 'guestshell enable'; do
    sleep 5
done
function test () {
ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip} << EOF
configure terminal 
interface GigabitEthernet2 
no shutdown 
ip address ${csrv1_eth1_private} 255.255.255.0 
end
EOF
}
test 

function enable_guestshell () {
  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv1_public_ip} <<-'EOF'
guestshell enable
EOF
}

function install_csr_aws_ha () {
  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv1_public_ip} <<-'EOF'
guestshell run pip install csr_aws_ha --user
EOF
}
function pip_freeze () {
  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv1_public_ip} <<-'EOF' > ok
guestshell run pip freeze 
EOF
}

until [ $test ];
do
  echo 'no csr_aws_ha package found, trying again'
  enable_guestshell
  echo "Tried to enable guestshell"
  install_csr_aws_ha
  echo 'tried pip install'
  pip_freeze 
  echo 'tried pip freeze'
  for i in $(<ok);
  do
    package=$(echo "$i" | awk -F '=' '{print $1}')
    if [ "$package" = "csr-aws-ha" ];
    then
      echo 'package found'
      test=1
      break
    fi
  done
done
#
#ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv1_public_ip} << EOF
#configure terminal
#crypto isakmp policy 1
#encr aes 256
#authentication pre-share
#crypto isakmp key cisco address 0.0.0.0
#end
#
#configure terminal
#crypto ipsec transform-set uni-perf esp-aes 256 esp-sha-hmac
#mode tunnel
#end
#
#configure terminal
#crypto ipsec profile vti-1
#set security-association lifetime kilobytes disable
#set security-association lifetime seconds 86400
#set transform-set uni-perf
#set pfs group2
#end
#
#configure terminal
#interface Tunnel1
#ip address ${csrv1_eth1_private} 255.255.255.252.
#load-interval 30
#tunnel source GigabitEthernet1
#tunnel mode ipsec ipv4
#tunnel destination ${csrv2_public_ip} 
#tunnel protection ipsec profile vti-1
#bfd interval 100 min_rx 100 multiplier 3
#end
#
#configure terminal
#router eigrp 1
#network 192.168.101.0 0.0.0.255
#bfd all-interfaces
#end
#
#configure terminal
#redundancy
#cloud-ha bfd peer ${csrv2_eth1_private}
#end
#
#guestshell
#create_node.py -i 2 -t ${private_rtb} -rg us-west-2 -n ${csrv1_eth1_eni}
#EOF

#until ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv2_public_ip} 'guestshell enable'; do
#    sleep 5
#done
#ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv2_public_ip} << EOF
#configure terminal 
#interface GigabitEthernet2 
#no shutdown 
#ip address ${csrv2_eth1_private} 255.255.255.0 
#end
#EOF
#until [ $test2 ]; do
#  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv2_public_ip} 'guestshell enable'
#  echo 'no csr_aws_ha package found, trying again'
#  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv2_public_ip} 'guestshell run pip install csr_aws_ha'
#  echo 'tried pip install'
#  ssh -o StrictHostKeyChecking=no -i csr.pem ec2-user@${csrv2_public_ip} 'guestshell run pip freeze' > ok
#  echo 'tried pip freeze'
#  cat ok
#  for i in $(cat ok);
#  echo $i
#  do
#    package=$(echo "$i" | awk -F '=' '{print $1}')
#    if [ "$package" = "csr-aws-ha" ]
#    then
#      echo 'package found'
#      test2=1
#      break
#    fi
#  done
#done
#ssh -i csr.pem -o StrictHostKeyChecking=no ec2-user@${csrv2_public_ip} << EOF
#configure terminal
#interface GigabitEthernet2
#no shutdown
#ip address ${csrv2_eth1_private} 255.255.255.0
#end
#
#configure terminal
#crypto isakmp policy 1
#encr aes 256
#authentication pre-share
#crypto isakmp key cisco address 0.0.0.0
#end
#
#configure terminal
#crypto ipsec transform-set uni-perf esp-aes 256 esp-sha-hmac
#mode tunnel
#end
#
#configure terminal
#crypto ipsec profile vti-1
#set security-association lifetime kilobytes disable
#set security-association lifetime seconds 86400
#set transform-set uni-perf
#set pfs group2
#end
#
#configure terminal
#interface Tunnel1
#ip address ${csrv2_eth1_private} 255.255.255.252.
#load-interval 30
#tunnel source GigabitEthernet1
#tunnel mode ipsec ipv4
#tunnel destination ${csrv1_public_ip} 
#tunnel protection ipsec profile vti-1
#bfd interval 100 min_rx 100 multiplier 3
#end
#
#configure terminal
#router eigrp 1
#network 192.168.101.0 0.0.0.255
#bfd all-interfaces
#end
#
#configure terminal
#redundancy
#cloud-ha bfd peer ${csrv1_eth1_private}
#end
#
#guestshell
#create_node.py -i 2 -t ${private_rtb} -rg us-west-2 -n ${csrv2_eth1_eni}
#EOF
