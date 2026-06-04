#! /bin/bash
# Example to start CBserverLoadBalancer on port number 4001
# The pool servers are here from 5001 to 5002. See also startpoolservers.sh
# 
# Shutdown gracefully by stoploadbalancer.sh

# Note: Define a stopkey like:
# export CB_SHUTDOWN_KEY="stop456"

# Compiled Rust version
# Variant 1: any number of users can login due to pool server sharing
(export CB_SHUTDOWN_KEY="stop456"; CBserverLoadBalancer 4001 5001 5002 &>> log_loadbalancer4001.log) &

# Variant 2: any number of users can login due to pool server sharing
# but assignment will be memorized for future sessions
#(export CB_SHUTDOWN_KEY="stop456"; CBserverLoadBalancer 4001 5001 5002 -c up1.cfg &>> log_loadbalancer4001.log) &

# Variant 3: pool servers are exclusive per user; no sharing; enabled by -fix
#(export CB_SHUTDOWN_KEY="stop456"; CBserverLoadBalancer 4001 5001 5002 -c up1.cfg -fix &>> log_loadbalancer4001.log) &
