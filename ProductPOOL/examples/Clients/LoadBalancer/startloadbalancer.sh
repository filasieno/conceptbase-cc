#! /bin/bash
# Example to start CBserverLoadBalancer on port number 4001
# The pool servers are here from 5001 to 5002. See also startpoolservers.sh
# 
# Shutdown gracefully by 
# echo "SHUTDOWN_BALANCER stop456" | nc localhost 4001
#

# Java version
(java CBserverLoadBalancer stop456 4001 5001 5002 &> log_loadbalancer4001.txt) &

# Compiled Rust version (preferred)
(CBserverLoadBalancer stop 4001 5001 5002 &> log_loadbalancer4001.txt) &

