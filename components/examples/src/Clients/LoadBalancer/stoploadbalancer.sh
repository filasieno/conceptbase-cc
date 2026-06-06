#! /bin/bash 
# Shutdown a loadbalancer on localhost:4001 gracefully
# Note that the secret word must be the same as in startloadbalancer.sh
#
# Does not work with the Rust version yet; you need to use kill there

# For the Java load balancer:
# echo "SHUTDOWN_BALANCER stop456" | nc localhost 4001

# For the Rust load balancer; we need to do it in a more complicated way
MSG="SHUTDOWN_BALANCER stop456"
LEN=$(printf "$MSG" | wc -c)
# Format the length as a 4-byte hex sequence
LEN_HEX=$(printf "%08x" $LEN | sed 's/../\\x&/g')

printf "X$LEN_HEX$MSG" | nc localhost 4001


