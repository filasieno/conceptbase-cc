#! /bin/bash
# Example to start CBserverLoadBalancer on port number 4001
# The pool servers are here from 5001 to 5002. See also startpoolservers.sh
# 
# Shutdown gracefully by stoploadbalancer.sh

# Java version; no longer maintained
# (java CBserverLoadBalancer stop456 4001 5001 5002 &> log_loadbalancer4001.log) &

# Compiled Rust version
# Variant 1: any number of users can login due to pool server sharing
(CBserverLoadBalancer stop456 4001 5001 5002 &> log_loadbalancer4001.log) &

# Variant 2: any number of users can login due to pool server sharing
# but assignment will be memorized for future sessions
#(CBserverLoadBalancer stop456 4001 5001 5002 -c up1.cfg &> log_loadbalancer4001.log) &

# Variant 3: pool servers are exclusive per user; no sharing; enabled by -fix
#(CBserverLoadBalancer stop456 4001 5001 5002 -c up1.cfg -fix &> log_loadbalancer4001.log) &
