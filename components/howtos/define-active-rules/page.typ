= Define Active Rules

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-active-rules
```

== Input

=== `ack-safe.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ack-safe.cbs
# Author: Manfred Jeusfeld
# Creation: 2010-07-13 (2014-04-30)
# ----------------------------------------------------------------------
# Compute the Ackermann function (see also http://en.wikipedia.org/wiki/Ackermann_function)
# This script requires ConceptBase 7.2 released after 2010-07-13
# The script shows that an ECArule can be used to prevent the execution of some query calls
# when the parameters math the ON-clause and fulfill the IF-clause of the ECArule.
# Of course, one can also include the check in the membership constraint of the query
# (here: function a(m,n), but that would not lead to a user-definable error message.
# The mode of the ECArule must be Immediate, otherwise the DO-clause would only be evaluated
# after attempting to answer the query call (or function call).


startServer -u nonpersistent -t no


tell "
a in Function isA Integer with
  required,parameter
    m: Integer;
    n: Integer
  constraint
    cack: $ (m=0) and (this=n + 1) or
            (m>0) and (n=0) and (this=a(m-1,1)) or
            (m>0) and (n>0) and (this=a(m-1,a(m,n-1)) ) 
        $
end

ECArule NoHighArgs with
  mode m: Immediate
  rejectMsg rm:
   \"Do not call the Ackermann function with such high argument values!\"
  ecarule
    r1: $ x1,x2/Integer
         ON Ask a[x1/m,x2/n]
         IF (x1 > 3) 
         DO reject
        $
end

"

# a(2,0)=3
ask "a[2/m,0/n]" OBJNAMES  LABEL  Now
echo "a(2,0)="
showAnswer


# a(2,1)=5
ask "a[2/m,1/n]" OBJNAMES  LABEL  Now
echo "a(2,1)="
showAnswer

# a(2,2)=7
ask "a[2/m,2/n]" OBJNAMES  LABEL  Now
echo "a(2,2)="
showAnswer

# a(3,3)=61
ask "a[3/m,3/n]" OBJNAMES  LABEL  Now
echo "a(3,3)="
showAnswer


# this call matches the ECArule NoHighArgs and will be aborted
ask "a[4/m,1/n]" OBJNAMES  LABEL  Now
echo "a(4,1)="
why


```

=== `Active rules modes/Banking example/ECA-banking-Deferred.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ECA-banking-Deferred.cbs
# Author: Manfred Jeusfeld
# Created: 2010-04-22/M.Jeusfeld (2010-04-26/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: CBshell -f ECA-banking-Deferred.cbs
#
# In Deferred mode, the ECArule transferRule produces the expected result:
# The two transfers are executed one after the other because the two
# generated triggers are delayed for both the IF-part and the DO-part. 
# When executed twowards the end of the transaction, the two triggers are
# sequentially evaluated. That means that the 2nd trigger is evaluated after
# all actions of the first trigger have been performed.
#
# Result:
#  Peter's balance: 402 --> 2
#  Mary's balanace: 1 --> 401
# 
# This script requires ConceptBase 7.2 or later.
#

startServer -u nonpersistent -t high

tell '

Account with
  attribute
    balance: Integer
end

Transfer with
  attribute
    fromaccount: Account;
    toaccount: Account;
    amount: Integer
end 


ECArule transferRule with
  mode m: Deferred
  rejectMsg rm:
   "Account balance insufficient"
  ecarule
        er : $  acc1,acc2/Account tr/Transfer m,b1,b2,nb1,nb2/Integer
        ON Tell (tr amount m) 
        IF `(tr fromaccount acc1) and
           `(tr toaccount acc2) and
           `(acc1 balance b1) and
           `(acc2 balance b2) and
           (nb1 = b1 - m) and
           (nb2 = b2 + m) and
           (nb1 >= 0)
        DO Retell (acc1 balance nb1) ,
           Retell (acc2 balance nb2) 
        ELSE
           reject
        $
end
'

tell "
PetersAccount in Account with
  balance b: 402
end 

MarysAccount in Account with
  balance b: 1
end
"



tell "
transfer1 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 250
end

transfer2 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 150
end
"

ask "get_object[PetersAccount/objname]" OBJNAMES  FRAME  Now
ask "get_object[MarysAccount/objname]" OBJNAMES  FRAME  Now



```

=== `Active rules modes/Banking example/ECA-banking-Immediate.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ECA-banking-Immediate.cbs
# Author: Manfred Jeusfeld
# Created: 2010-04-22/M.Jeusfeld (2011-01-04/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: CBshell -f ECA-banking-Immediate.cbs
# 
# In Immediate mode, the ECArule transferRule produces the expected result:
# The two events lead to an immediate execution of both the IF-part and the DO-part
# of the ECArule. There is no decoupling of the two, which caused the wrong result
# in mode ImmediateDeferred.
# Result:
#  Peter's balance: 402 --> 2
#  Mary's balance: 1 --> 401
# 
# This script requires ConceptBase 7.2 or later.
#

startServer -u nonpersistent -t high

tell '

Account with
  attribute
    balance: Integer
end

Transfer with
  attribute
    fromaccount: Account;
    toaccount: Account;
    amount: Integer
end 


ECArule transferRule with
  mode m: Immediate
  rejectMsg rm:
   "Account balance insufficient"
  ecarule
        er : $  acc1,acc2/Account tr/Transfer m,b1,b2,nb1,nb2/Integer
        ON Tell (tr amount m) 
        IF `(tr fromaccount acc1) and
           `(tr toaccount acc2) and
           `(acc1 balance b1) and
           `(acc2 balance b2) and
           (nb1 = b1 - m) and
           (nb2 = b2 + m) and
           (nb1 >= 0)
        DO Retell (acc1 balance nb1) ,
           Retell (acc2 balance nb2) 
        ELSE
           reject
        $
end
'

tell "
PetersAccount in Account with
  balance b: 402
end 

MarysAccount in Account with
  balance b: 1
end
"



tell "
transfer1 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 250
end

transfer2 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 150
end
"

ask "get_object[PetersAccount/objname]" OBJNAMES  FRAME  Now
# balance should be 2  (=correct)
ask "get_object[MarysAccount/objname]" OBJNAMES  FRAME  Now
# balance should be 401  (=correct)



```

=== `Active rules modes/Banking example/ECA-banking-ImmediateDeferred.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ECA-banking-ImmediateDeferred.cbs
# Author: Manfred Jeusfeld
# Created: 2010-04-22/M.Jeusfeld (2011-01-04/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: CBshell -f ECA-banking-ImmediateDeferred.cbs
# 
# In ImmediateDeferred mode, the ECArule transferRule produces the a wrong
# result. The IF parts of both triggers Tell((transfer1 amount 250)) and
# Tell((transfer1 amount 250)) are evaluated immediately. That means no actions
# are performed so far. Both evaluations thus see the same state of accounts.
# The resulting actions for transfer1 are 
#    Retell (PetersAccount balance 152)
#    Retell (MarysAccount balance 251)
# The resulting actions for transfer2 are
#    Retell (PetersAccount balance 252)
#    Retell (MarysAccount balance 151)
# Hence, the second trigger overwrites the updates of the first trigger.

# Result:
#  Peter's balance: 402 --> 252
#  Mary's balanace: 1 --> 151
# 
# This script requires ConceptBase 7.2 or later.
#

startServer -u nonpersistent  -t high

tell '

Account with
  attribute
    balance: Integer
end

Transfer with
  attribute
    fromaccount: Account;
    toaccount: Account;
    amount: Integer
end 


ECArule transferRule with
  mode m: ImmediateDeferred
  rejectMsg rm:
   "Account balance insufficient"
  ecarule
        er : $  acc1,acc2/Account tr/Transfer m,b1,b2,nb1,nb2/Integer
        ON Tell (tr amount m) 
        IF `(tr fromaccount acc1) and
           `(tr toaccount acc2) and
           `(acc1 balance b1) and
           `(acc2 balance b2) and
           (nb1 = b1 - m) and
           (nb2 = b2 + m) and
           (nb1 >= 0)
        DO Retell (acc1 balance nb1) ,
           Retell (acc2 balance nb2) 
        ELSE
           reject
        $
end
'

tell "
PetersAccount in Account with
  balance b: 402
end 

MarysAccount in Account with
  balance b: 1
end
"



tell "
transfer1 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 250
end

transfer2 in Transfer with
   fromaccount a1: PetersAccount
   toaccount a2: MarysAccount
   amount m: 150
end
"

ask "get_object[PetersAccount/objname]" OBJNAMES  FRAME  Now
# balance should be 252  (correct=2)
ask "get_object[MarysAccount/objname]" OBJNAMES  FRAME  Now
# balance should be 151  (correct=401)


```

=== `Active rules modes/ECA transactions/Compare-TRANSACTIONAL/eca-notrans.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: eca-notrans.cbs
# Author: Manfred Jeusfeld
# Created: 2011-05-02/M.Jeusfeld (2019-02-12/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: cbshell eca-notrans.cbs | fgrep ECAaction
#
# This script requires ConceptBase 7.3.12 or later.
# Same as eca-notrans.cbs except that it does not use the TRANSACTIONAL tag
#



cbserver -t high 

# The visit paradigm simulates a situation where certain actions should
# be executed before other actions.
tell "
Person with
  attribute
    visits: House;
    enters: Room;
    opensDoor: Room;
    turnOnLight: Room;
    turnOffLight: Room;
    leaves: Room
end

House with
  attribute
     has: Room
end

Room with
end
"


# The TRANSACTIONAL tag of onPerson_transactional will be processed when ConceptBase
# processes the original event "Tell (p in Person)". Then, all events
# that are caused by the reaction to "Tell (p in Person)" are
# processed before the next original event. 

 
tell "
ECArule onPerson_transactional with
  mode m: Deferred
  ecarule
        er : $  p/Person h/House
        ON Tell (p in Person) 
        IF (h in House)
        DO Tell (p visits h)
        $
end

ECArule onVisitHouse with
  mode m: Deferred
  ecarule
        er : $  p/Person house/House room/Room
        ON Tell (p visits house) 
        IF (house has room)
        DO  Tell (p enters room)
        $
end
"


# afterEnter1 and afterEnter2 are executed whenever (p enters r) is told
# We use mode Immediate for afterEvent1 and Deferred for afterEvent2
# You can play with other configurations
tell "
ECArule afterEnter1 with
  mode m: Immediate
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p opensDoor r)
        $
end

ECArule afterEnter2 with
  mode m: Deferred
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p turnOnLight r),
           Tell (p turnOffLight r),
           Tell (p leaves r)
        $
end
"

# Example data: two houses with two rooms each
# Peter and Mary are supposed to visit them and 
# enter each room
tell "


HouseA in House with
  has
    r1: RoomA1;
    r2: RoomA2
end

RoomA1 in Room 
end

RoomA2 in Room 
end


HouseB in House with
  has
    r1: RoomB1;
    r2: RoomB2
end

RoomB1 in Room 
end

RoomB2 in Room 
end
"


# This initiates the house visits
tell "
peter in Person end
mary in Person end
"

# This produces two events:
#   e1: Tell (peter in Person)
#   e2: Tell (mary in Person)
# Event e1 will cause a "transactional switch", which will basically delay the processing of e2
# until all events caused indirectly by e1 are processed.
# Hence, the actions relating to peter precede the actions relating to mary 




```

=== `Active rules modes/ECA transactions/Compare-TRANSACTIONAL/eca-trans.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: eca-trans.cbs
# Author: Manfred Jeusfeld
# Created: 2011-05-02/M.Jeusfeld (2019-02-12/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: cbshell eca-trans.cbs | fgrep ECAaction
#
# Shows the capabilities of the TRANSACTIONAL tag of ECArules to
# control the execution order of ECA triggers.
#
# This script requires ConceptBase 7.3.12 or later.
# Derived from ECA-Transactions4.cbs
#



cbserver -t high 

# The visit paradigm simulates a situation where certain actions should
# be executed before other actions.
tell "
Person with
  attribute
    visits: House;
    enters: Room;
    opensDoor: Room;
    turnOnLight: Room;
    turnOffLight: Room;
    leaves: Room
end

House with
  attribute
     has: Room
end

Room with
end
"


# The TRANSACTIONAL tag of onPerson_transactional will be processed when ConceptBase
# processes the original event "Tell (p in Person)". Then, all events
# that are caused by the reaction to "Tell (p in Person)" are
# processed before the next original event. 

 
tell "
ECArule onPerson_transactional with
  mode m: Deferred
  ecarule
        er : $  p/Person h/House
        ON TRANSACTIONAL Tell (p in Person) 
        IF (h in House)
        DO Tell (p visits h)
        $
end

ECArule onVisitHouse with
  mode m: Deferred
  ecarule
        er : $  p/Person house/House room/Room
        ON Tell (p visits house) 
        IF (house has room)
        DO  Tell (p enters room)
        $
end
"


# afterEnter1 and afterEnter2 are executed whenever (p enters r) is told
# We use mode Immediate for afterEvent1 and Deferred for afterEvent2
# You can play with other configurations
tell "
ECArule afterEnter1 with
  mode m: Immediate
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p opensDoor r)
        $
end

ECArule afterEnter2 with
  mode m: Deferred
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p turnOnLight r),
           Tell (p turnOffLight r),
           Tell (p leaves r)
        $
end
"

# Example data: two houses with two rooms each
# Peter and Mary are supposed to visit them and 
# enter each room
tell "


HouseA in House with
  has
    r1: RoomA1;
    r2: RoomA2
end

RoomA1 in Room 
end

RoomA2 in Room 
end


HouseB in House with
  has
    r1: RoomB1;
    r2: RoomB2
end

RoomB1 in Room 
end

RoomB2 in Room 
end
"


# This initiates the house visits
tell "
peter in Person end
mary in Person end
"

# This produces two events:
#   e1: Tell (peter in Person)
#   e2: Tell (mary in Person)
# Event e1 will cause a "transactional switch", which will basically delay the processing of e2
# until all events caused indirectly by e1 are processed.
# Hence, the actions relating to peter precede the actions relating to mary 




```

=== `Active rules modes/ECA transactions/Deprecated/ECA-Transactions2.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ECA-Transactions2.cbs
# Author: Manfred Jeusfeld
# Created: 2011-03-29/M.Jeusfeld (2011-03-29/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: CBshell -f ECA-Transactions2.cbs | fgrep ECAaction
#
# Shows the capabilities of the tBegin/tEnd constructs to
# control the execution order of ECA triggers.
#
# 
# This script requires ConceptBase 7.3.11 or later.
#

startServer -u nonpersistent -port 4411 -t high 

# The visit paradigm simulates a situation where certain actions should
# be executed before other actions.
tell "
Person with
  attribute
    visits: House;
    enters: Room;
    opensDoor: Room;
    turnOnLight: Room;
    turnOffLight: Room;
    leaves: Room
end

House with
  attribute
     has: Room
end

Room with
end
"


# Example data: two houses with two rooms each
# Peter and Mary are supposed to visit them and 
# enter each room
tell "
peter in Person end
mary in Person end

HouseA in House with
  has
    r1: RoomA1;
    r2: RoomA2
end

RoomA1 in Room 
end

RoomA2 in Room 
end


HouseB in House with
  has
    r1: RoomB1;
    r2: RoomB2
end

RoomB1 in Room 
end

RoomB2 in Room 
end
"




# for HouseA we do not want that the actions of two
# persons in the house interfere. So, we start with a tBegin.
# This will prefer the first event (peter visits HouseA) over
# (mary visits HouseA) since all subsequent triggers generated
# after tBegin are first executed before (mary visits HouseA) is
# processed
 
tell "
ECArule onVisitHouseA with
  mode m: Deferred
  ecarule
        er : $  p/Person
        ON Tell (p visits HouseA) 
        IF TRUE
        DO tBegin,
             Tell (p enters RoomA1),
             Tell (p enters RoomA2),
           tEnd
        $
end
"

# onVisitHouseB is just showing the regular sequence of actions without the tBegin
tell "
ECArule onVisitHouseB with
  mode m: Deferred
  ecarule
        er : $  p/Person
        ON Tell (p visits HouseB) 
        IF TRUE
        DO   Tell (p enters RoomB1),
             Tell (p enters RoomB2)
        $
end
"

# afterEnter1 and afterEnter2 are executed wheneber (p enters r) is told
# We use mode Immediate for afterEvent1 and Deferred for afterEvent2
# You can play with other configurations
tell "
ECArule afterEnter1 with
  mode m: Immediate
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p opensDoor r)
        $
end

ECArule afterEnter2 with
  mode m: Deferred
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p turnOnLight r),
           Tell (p turnOffLight r),
           Tell (p leaves r)
        $
end
"


# This creates 4 events. The first two match onVisitHouseA,
# the other two match onVisitHouseB

tell "
peter with visits v1: HouseA end
mary with visits v1: HouseA end
peter with visits v2: HouseB end
mary with visits v2: HouseB end
"




# The above tell command causes the following execution sequence:
 
# ECAactionManager: onVisitHouseA --> DO Tell (peter enters RoomA1)
# ECAactionManager: afterEnter1 --> DO Tell (peter opensDoor RoomA1)
# ECAactionManager: onVisitHouseA --> DO Tell (peter enters RoomA2)
# ECAactionManager: afterEnter1 --> DO Tell (peter opensDoor RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOnLight RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOffLight RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (peter leaves RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOnLight RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOffLight RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (peter leaves RoomA2)
# ECAactionManager: onVisitHouseA --> DO Tell (mary enters RoomA1)
# ECAactionManager: afterEnter1 --> DO Tell (mary opensDoor RoomA1)
# ECAactionManager: onVisitHouseA --> DO Tell (mary enters RoomA2)
# ECAactionManager: afterEnter1 --> DO Tell (mary opensDoor RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOnLight RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOffLight RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (mary leaves RoomA1)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOnLight RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOffLight RoomA2)
# ECAactionManager: afterEnter2 --> DO Tell (mary leaves RoomA2)
# ECAactionManager: onVisitHouseB --> DO Tell (peter enters RoomB1)
# ECAactionManager: afterEnter1 --> DO Tell (peter opensDoor RoomB1)
# ECAactionManager: onVisitHouseB --> DO Tell (peter enters RoomB2)
# ECAactionManager: afterEnter1 --> DO Tell (peter opensDoor RoomB2)
# ECAactionManager: onVisitHouseB --> DO Tell (mary enters RoomB1)
# ECAactionManager: afterEnter1 --> DO Tell (mary opensDoor RoomB1)
# ECAactionManager: onVisitHouseB --> DO Tell (mary enters RoomB2)
# ECAactionManager: afterEnter1 --> DO Tell (mary opensDoor RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOnLight RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOffLight RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (peter leaves RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOnLight RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (peter turnOffLight RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (peter leaves RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOnLight RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOffLight RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (mary leaves RoomB1)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOnLight RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (mary turnOffLight RoomB2)
# ECAactionManager: afterEnter2 --> DO Tell (mary leaves RoomB2)



# The tBegin/tEnd forces the grouping of the peter's actions before
# mary's actions for rule onVisitHouseA
# The ECArule onVisitHouseB doesn't use tBegin/tEnd. Hence, the actions
# peter and mary are mixed.






```

=== `Active rules modes/ECA transactions/Deprecated/ECA-Transactions3.cbs.txt`

```telos
# This file is governed by the Creative Commons license
#   attributeion-NonCommercial 3.0 Unported
#   http://creativecommons.org/licenses/by-nc/3.0/
#   http://creativecommons.org/licenses/by-nc/3.0/legalcode
#
# Extended licenses, in particular commercial licenses, can be obtained from the
# author of the source code.
# Any re-distribution as source code must acknowledge the original author of this file.

#
# File: ECA-Transactions3.cbs
# Author: Manfred Jeusfeld
# Created: 2011-03-30/M.Jeusfeld (2011-03-30/M.Jeusfeld)
# ------------------------------------------------------
#
# Start: CBshell -f ECA-Transactions3.cbs | fgrep ECAaction
#
# Shows the capabilities of the tBegin/tEnd constructs to
# control the execution order of ECA triggers.
#
# 
# This script requires ConceptBase 7.3.11 or later.
#

startServer -u nonpersistent -port 4411 -t high 

# The visit paradigm simulates a situation where certain actions should
# be executed before other actions.
tell "
Person with
  attribute
    visits: House;
    enters: Room;
    opensDoor: Room;
    turnOnLight: Room;
    turnOffLight: Room;
    leaves: Room
end

House with
  attribute
     has: Room
end

Room with
end
"


# The tBegin in onPerson_transactional will be invoked when ConceptBase
# processes the original event "Tell (p in Person)". Then, all events
# that are caused by the reaction to "Tell (p in Person)" are
# processed before the next original event. 
# We do not use tEnd here. The transactional ordering of actions is
# enforced by tBegin alone.
 
tell "
ECArule onPerson_transactional with
  mode m: Deferred
  ecarule
        er : $  p/Person h/House
        ON Tell (p in Person) 
        IF (h in House)
        DO tBegin,
           Tell (p visits h)
        $
end

ECArule onVisitHouse with
  mode m: Deferred
  ecarule
        er : $  p/Person house/House room/Room
        ON Tell (p visits house) 
        IF (house has room)
        DO  Tell (p enters room)
        $
end
"


# afterEnter1 and afterEnter2 are executed whenever (p enters r) is told
# We use mode Immediate for afterEvent1 and Deferred for afterEvent2
# You can play with other configurations
tell "
ECArule afterEnter1 with
  mode m: Immediate
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p opensDoor r)
        $
end

ECArule afterEnter2 with
  mode m: Deferred
  ecarule
        er : $  p/Person r/Room
        ON Tell (p enters r) 
        IF TRUE
        DO Tell (p turnOnLight r),
           Tell (p turnOffLight r),
           Tell (p leaves r)
        $
end
"

# Example data: two houses with two rooms each
# Peter and Mary are supposed to visit them and 
# enter each room
tell "


HouseA in House with
  has
    r1: RoomA1;
    r2: RoomA2
end

RoomA1 in Room 
end

RoomA2 in Room 
end


HouseB in House with
  has
    r1: RoomB1;
    r2: RoomB2
end

RoomB1 in Room 
end

RoomB2 in Room 
end
"


# This initiates the house visits
tell "
peter in Person end
mary in Person end
"

# This produces two events:
#   e1: Tell (peter in Person)
#   e2: Tell (mary in Person)
# Event e1 will cause a tBegin which will then delay the processing of e2
# until all events caused indirectly by e1 are processed.
# Hence, the actions relating to peter precede the actions relating to mary 




```

== Shell output

```text
=== HOW-TO: define-active-rules (asset validation + smoke) ===

./Active rules modes/Banking example/ECA-banking-Deferred.cbs.txt
./Active rules modes/Banking example/ECA-banking-Immediate.cbs.txt
./Active rules modes/Banking example/ECA-banking-ImmediateDeferred.cbs.txt
./Active rules modes/ECA transactions/Compare-TRANSACTIONAL/eca-notrans.cbs.txt
./Active rules modes/ECA transactions/Compare-TRANSACTIONAL/eca-trans.cbs.txt
./Active rules modes/ECA transactions/Deprecated/ECA-Transactions.cbs.txt
./Active rules modes/ECA transactions/Deprecated/ECA-Transactions2.cbs.txt
./Active rules modes/ECA transactions/Deprecated/ECA-Transactions3.cbs.txt
./Active rules modes/ECA transactions/ECA-Transactions4.cbs.txt
./Active rules modes/ECA transactions/ECA-Transactions5.cbs.txt
./Active rules modes/Petri net example/PN-Deferred.cbs.txt
./Active rules modes/Petri net example/PN-Immediate.cbs.txt
./Active rules modes/Petri net example/PN-ImmediateDeferred.cbs.txt
./ECA-CreateIndividual.sml.txt
./ECA-DivByZero.sml.txt
./ECA-ExistentialVariables.sml.txt
./ECA-MakeIntegers.sml.txt
./ECA-MakePowers.sml.txt
./ECA-ManyFriends.sml.txt
./ECA-ON-Ask.sml.txt
./ECA-Priority.cbs.txt
./ECA-Raise.cbs.txt
./ECA-lastmodified.sml.txt
./ECA-lastmodified2.cbs.txt
./ECA-lastmodified3.cbs.txt
./ECA-twoRules.cbs.txt
./ECA-with-Constraints.sml.txt
./EmployeeCount.sml.txt
./ack-safe.cbs.txt

This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>Proposition,MetaClass,"</graphtype>","
  <name>{this}</name>{Foreach(({this.property},{this|property}),(v,l),
  <property>
    <name>{l}</name>
    <value>{v}</value>
  </property>)}
  <implementedBy>{this.implementedBy}</implementedBy>
",GeneratedObject,0,$Rule(Condition(exists([In(_G48691, id_881)], forall([Aedot(id_886, _G48691, _G48697)], FALSE))), Conclusion(Adot(id_886, _G48691, id_1011)))$,DefaultJavaPalette,DeriveExpression,DefaultIndividualGT,DefaultLinkGT,ImplicitIsAGT,ImplicitInstanceOfGT,ImplicitAttributeGT,QueryCall,DefaultIsAGT,DefaultInstanceOfGT,DefaultAttributeGT,HiddenObject,MetametaGT,SimpleClassGT,MetaClassGT,Function,ClassGT,QueryClassGT,$ forall p/IsA (p graphtype DefaultIsAGT) $,$ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $,$ forall p/Attribute (p graphtype DefaultAttributeGT) $,$ forall p/Individual (p graphtype DefaultIndividualGT) $,$ forall c/MetametaClass (c graphtype MetametaGT) $,$ forall t/SimpleClass  (t graphtype SimpleClassGT) $,vQueryClass,$ forall t/MetaClass  (t graphtype MetaClassGT) $,$ forall c/Individual (c in Class) ==> (c graphtype ClassGT) $,$ forall c/QueryClass (c graphtype QueryClassGT) $,MetametaClass,"210,210,210","0,0,0","i5.cb.graph.shapes.Rect","i5.cb.graph.cbeditor.CBIndividual","2",$ not (this in HiddenObject) and not (this in Function) $,"i5.cb.graph.cbeditor.CBLink","0,205,255","3",1,"0,150,255",Version,"dashed","0,210,0",T_0,Module,"0,180,0",TransactionTime,Label,"20,20,20","127,255,212",Boolean,"32,178,170","i5.cb.graph.shapes.Ellipse","bold",10,FALSE,"255,192,203","255,0,0",TRUE,"135,206,235","65,105,225",System,ViewMaintenanceStrategy,"0,206,209",5,"255,255,255",BottomUpVM,"0,0,255","italic",7,$Rule(Condition(exists([In(_G23372, id_15)], TRUE)), Conclusion(Adot(id_876, _G23372, id_1042)))$,$Rule(Condition(exists([In(_G26016, id_1)], TRUE)), Conclusion(Adot(id_876, _G26016, id_1045)))$,TopDownVM,$Rule(Condition(exists([In(_G28635, id_6)], TRUE)), Conclusion(Adot(id_876, _G28635, id_1048)))$,$Rule(Condition(exists([In(_G31281, id_7)], TRUE)), Conclusion(Adot(id_876, _G31281, id_1022)))$,$Rule(Condition(exists([In(_G2266, id_11)], TRUE)), Conclusion(Adot(id_876, _G2266, id_1051)))$,$Rule(Condition(exists([In(_G4891, id_9)], TRUE)), Conclusion(Adot(id_876, _G4891, id_1054)))$,$Rule(Condition(exists([In(_G7498, id_10)], TRUE)), Conclusion(Adot(id_876, _G7498, id_1057)))$,NaiveVM,$Rule(Condition(exists([In(_G10493, id_7), In(_G10493, id_2)], TRUE)), Conclusion(Adot(id_876, _G10493, id_1060)))$,$Rule(Condition(exists([In(_G13216, id_65)], TRUE)), Conclusion(Adot(id_876, _G13216, id_1063)))$,ECArule,ECAassertion,ECAmode,$ forall r/ECArule e1,e2/ECAassertion
		(r ecarule e1) and (r ecarule e2) ==> (e1 == e2) $,$ forall r/ECArule exists e/ECAassertion
		(r ecarule e) $,$ forall r/ECArule m1,m2/ECAmode
		(r mode m1) and (r mode m2) ==> (m1 == m2) $,$ forall r/ECArule a1,a2/Boolean
		(r active a1) and (r active a2) ==> (a1 == a2) $,$ forall r/ECArule i,j/Integer
		(r depth i) and (r depth j) ==> (i == j) $,Immediate,ImmediateDeferred,Deferred,YesClass,yes,$forall([Adot(id_1406, _G7936, _G7942), Adot(id_1406, _G7936, _G7948)], IDENTICAL(_G7942, _G7948))$,Order,$Insert(Adot(id_1406, _G8372, _G8378), forall([e2], [Adot(_G8372, r, e2)], IDENTICAL(_G8378, e2)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$Insert(Adot(id_1406, _G9319, _G9331), forall([e1], [Adot(_G9319, r, e1)], IDENTICAL(e1, _G9331)), [range(e2, [id_1405]), range(e1, [id_1405]), range(r, [id_1403])])$,$forall([In(_G12295, id_1403)], exists([Adot(id_1406, _G12295, _G12301)], TRUE))$,$Insert(In(_G12658, id_1403), forall([], [], exists([e], [Adot(id_1406, _G12658, e)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,ascending,$Delete(Adot(id_1406, _G13321, _G13456), forall([], [In(r, id_1403)], exists([_G13456], [Adot(_G13321, r, _G13456)], TRUE)), [range(e, [id_1405]), range(r, [id_1403])])$,$forall([Adot(id_1410, _G17573, _G17579), Adot(id_1410, _G17573, _G17585)], IDENTICAL(_G17579, _G17585))$,$Insert(Adot(id_1410, _G18010, _G18016), forall([m2], [Adot(_G18010, r, m2)], IDENTICAL(_G18016, m2)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,$Insert(Adot(id_1410, _G18958, _G18970), forall([m1], [Adot(_G18958, r, m1)], IDENTICAL(m1, _G18970)), [range(m2, [id_1409]), range(m1, [id_1409]), range(r, [id_1403])])$,descending,$forall([Adot(id_1411, _G23229, _G23235), Adot(id_1411, _G23229, _G23241)], IDENTICAL(_G23235, _G23241))$,$Insert(Adot(id_1411, _G23666, _G23672), forall([a2], [Adot(_G23666, r, a2)], IDENTICAL(_G23672, a2)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,$Insert(Adot(id_1411, _G24613, _G24625), forall([a1], [Adot(_G24613, r, a1)], IDENTICAL(a1, _G24625)), [range(a2, [id_125]), range(a1, [id_125]), range(r, [id_1403])])$,AnswerFormat,$forall([Adot(id_1412, _G28832, _G28838), Adot(id_1412, _G28832, _G28844)], IDENTICAL(_G28838, _G28844))$,$Insert(Adot(id_1412, _G29269, _G29275), forall([j], [Adot(_G29269, r, j)], IDENTICAL(_G29275, j)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,$Insert(Adot(id_1412, _G30216, _G30228), forall([i], [Adot(_G30216, r, i)], IDENTICAL(i, _G30228)), [range(j, [id_18]), range(i, [id_18]), range(r, [id_1403])])$,oHome,CB_User,AutoHomeModule,Resource,CB_Operation,CB_ReadOperation,CB_WriteOperation,TELL,TELL_MODEL,UNTELL,RETELL,LPI_CALL,ASK,HYPO_ASK,listModule,IsolatedValue,$ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $,DoNotSave_LM,$ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $,toLabel,"returns s as a label without quotes and special character and creates it as individual object",concat,"Appends string s2 to the end of string s1; same as ConcatenateStrings",BuiltinClass,COUNT,DoNotSave_1,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,purgeModule,listModuleReloadable,"(C) 1987 ConceptBase Team, in particular Manfred Jeusfeld, Martin Staudt, Hans Nissen, Christoph Quix, Eva Krueger; all rights reserved.","Use permitted under FreeBSD style license, see http://conceptbase.sourceforge.net/CB-FreeBSD-License.txt.","The System module is the root module of ConceptBase. It contains the pre-defined objects and classes for ConceptBase.",XBridgePalette,"counts the instances of class",$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal contains gt)
                  ==> (pal contains gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultLink gt)
                  ==> (pal defaultLink gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitIsA gt)
                  ==> (pal implicitIsA gt) $,COUNT_Attribute,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $,$ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitAttribute gt)
                  ==> (pal implicitAttribute gt) $,TelosPalette,"This is the preferred default graphical palette for ConceptBase 8.2 (released 2021). The previous DefaultJavaPalette is still supported. TelosPalette is closer to the symbols used in UML class diagrams and has better support for long strings.",INDIVIDUAL_TP_GT,ATTR_TP_GT,ISADEDUCED_TP_GT,INSTOFDEDUCED_TP_GT,ATTRDEDUCED_TP_GT,CLASS_TP_GT,QUERYCLASS_TP_GT,INSTOF_TP_GT,ISA_TP_GT,STRING_TP_GT,VALUE_TP_GT,ASSERTION_TP_GT,"Caret","counts the attributes in category <attrcat> of object <objname>","ldashed",6,$ forall a/InstanceOf (a graphtype INSTOF_TP_GT) $,"1",Integer,SUM,"0,50,255","Arrow",$ forall a/IsA (a graphtype ISA_TP_GT) $,"computes the sum of the instances of class (must be reals or integers)","10","255,255,255,240",$ forall x/Proposition!attribute (x graphtype ATTR_TP_GT) $,AVG,"Rect","resizable",$ forall x/Individual (x graphtype INDIVIDUAL_TP_GT) $,"250,250,250",$ forall x/Class (x graphtype CLASS_TP_GT) $,"computes the average of the instances of class (must be reals or integers)","100,100,100","11","wrap","1000","0.3",$ forall x/String (x graphtype STRING_TP_GT) $,MAX,$ forall x/Integer (x graphtype VALUE_TP_GT) $,Class,$ forall x/Real (x graphtype VALUE_TP_GT) $,8,"gives the maximum of the instances of class (must be reals or integers)",$ forall x/MSFOLassertion (x graphtype ASSERTION_TP_GT) $,"255,245,245",$ forall x/QueryClass (x graphtype QUERYCLASS_TP_GT) $,concatl,"Appends the labels2 to the label s1; result is a Label, i.e. not necessarily an object name",MIN,concatl4,"Concats the labels s1,s2,s3,s4",concatl6,Real,"Concats the labels s1,s2,s3,s4,s5,s6",HiddenLabel,resultOf,toString,"gives the minimum of the instances of class (must be reals or integers)","convert the label of obj into a string with double quotes around it",length,"compute the number of characters of the label of obj. The double quotes of strings are not counted.",isLike,"check wether the label (first parameter) is matching a pattern (2nd parameter); Use wildcard * in the pattern",GlobalVariable,currentPalette,valueOf,IsolatedCB_User,SUM_Attribute,$ not exists a/Attribute From(a,this) or To(a,this) $,DoNotSave_2,$ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             (~this in IsolatedCB_User) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G33706, id_881), In(_G33712, id_891), Isa(_G33712, id_1698), NE(_G33712, id_1640)], exists([Adot(id_879, id_1698, _G33706)], TRUE))), Conclusion(Adot(id_879, _G33712, _G33706)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette contains gt)) ==> (pal contains gt) $,$Rule(Condition(exists([In(_G40259, id_881), In(_G40265, id_891), Isa(_G40265, id_1640), NE(_G40265, id_1640)], exists([Adot(id_879, id_1640, _G40259)], TRUE))), Conclusion(Adot(id_879, _G40265, _G40259)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G28653, id_891), Isa(_G28653, id_1698), NE(_G28653, id_1640), In(_G28647, id_881)], exists([Adot(id_894, id_1698, _G28647)], TRUE))), Conclusion(Adot(id_894, _G28653, _G28647)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultIndividual gt)) ==> (pal defaultIndividual gt) $,$Rule(Condition(exists([In(_G35135, id_891), Isa(_G35135, id_1640), NE(_G35135, id_1640), In(_G35129, id_881)], exists([Adot(id_894, id_1640, _G35129)], TRUE))), Conclusion(Adot(id_894, _G35135, _G35129)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G22851, id_891), Isa(_G22851, id_1698), NE(_G22851, id_1640), In(_G22845, id_881)], exists([Adot(id_895, id_1698, _G22845)], TRUE))), Conclusion(Adot(id_895, _G22851, _G22845)))$,"computes the sum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette defaultLink gt)) ==> (pal defaultLink gt) $,$Rule(Condition(exists([In(_G29261, id_891), Isa(_G29261, id_1640), NE(_G29261, id_1640), In(_G29255, id_881)], exists([Adot(id_895, id_1640, _G29255)], TRUE))), Conclusion(Adot(id_895, _G29261, _G29255)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G17286, id_891), Isa(_G17286, id_1698), NE(_G17286, id_1640), In(_G17280, id_881)], exists([Adot(id_896, id_1698, _G17280)], TRUE))), Conclusion(Adot(id_896, _G17286, _G17280)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitIsA gt)) ==> (pal implicitIsA gt) $,$Rule(Condition(exists([In(_G23696, id_891), Isa(_G23696, id_1640), NE(_G23696, id_1640), In(_G23690, id_881)], exists([Adot(id_896, id_1640, _G23690)], TRUE))), Conclusion(Adot(id_896, _G23696, _G23690)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,AVG_Attribute,$Rule(Condition(exists([In(_G12072, id_891), Isa(_G12072, id_1698), NE(_G12072, id_1640), In(_G12066, id_881)], exists([Adot(id_897, id_1698, _G12066)], TRUE))), Conclusion(Adot(id_897, _G12072, _G12066)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitInstanceOf gt)) ==> (pal implicitInstanceOf gt) $,$Rule(Condition(exists([In(_G18566, id_891), Isa(_G18566, id_1640), NE(_G18566, id_1640), In(_G18560, id_881)], exists([Adot(id_897, id_1640, _G18560)], TRUE))), Conclusion(Adot(id_897, _G18566, _G18560)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,TelosPalette) and (pal <> XBridgePalette) and (TelosPalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G7142, id_891), Isa(_G7142, id_1698), NE(_G7142, id_1640), In(_G7136, id_881)], exists([Adot(id_898, id_1698, _G7136)], TRUE))), Conclusion(Adot(id_898, _G7142, _G7136)))$,$ forall pal/JavaGraphicalPalette gt/JavaGraphicalType   (Isa(pal,XBridgePalette) and (pal <> XBridgePalette) and (XBridgePalette implicitAttribute gt)) ==> (pal implicitAttribute gt) $,$Rule(Condition(exists([In(_G13623, id_891), Isa(_G13623, id_1640), NE(_G13623, id_1640), In(_G13617, id_881)], exists([Adot(id_898, id_1640, _G13617)], TRUE))), Conclusion(Adot(id_898, _G13623, _G13617)))$,$Rule(Condition(exists([In(_G17334, id_1)], TRUE)), Conclusion(Adot(id_876, _G17334, id_1732)))$,$Rule(Condition(exists([In(_G19893, id_15)], TRUE)), Conclusion(Adot(id_876, _G19893, id_1735)))$,$Rule(Condition(exists([In(_G22775, id_6)], TRUE)), Conclusion(Adot(id_876, _G22775, id_1710)))$,$Rule(Condition(exists([In(_G25430, id_7)], TRUE)), Conclusion(Adot(id_876, _G25430, id_1706)))$,$Rule(Condition(exists([In(_G28022, id_2)], TRUE)), Conclusion(Adot(id_876, _G28022, id_1726)))$,"computes the average of the attributes in category <attrcat> of object <objname> (must be reals or integers)",$Rule(Condition(exists([In(_G30623, id_24)], TRUE)), Conclusion(Adot(id_876, _G30623, id_1738)))$,$Rule(Condition(exists([In(_G33222, id_18)], TRUE)), Conclusion(Adot(id_876, _G33222, id_1741)))$,$Rule(Condition(exists([In(_G35800, id_21)], TRUE)), Conclusion(Adot(id_876, _G35800, id_1741)))$,$Rule(Condition(exists([In(_G38459, id_33)], TRUE)), Conclusion(Adot(id_876, _G38459, id_1744)))$,$Rule(Condition(exists([In(_G41097, id_65)], TRUE)), Conclusion(Adot(id_876, _G41097, id_1729)))$,jeusfeld,nixbld,MAX_Attribute,String,"gives the maximum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",MIN_Attribute,"gives the minimum of the attributes in category <attrcat> of object <objname> (must be reals or integers)",PLUS,"computes r1 + r2",IPLUS,"computes i1 + i2",AssertionEvaluators,MINUS,"computes r1 - r2",IMINUS,Assertions,"computes i1 - i2",MULT,"computes r1 * r2",IMULT,"computes i1 * i2",DIV,MSFOLassertion,"computes r1 / r2",IDIV,"computes truncate(i1/i2)",ConcatenateStrings,"Appends string s2 to the end of string s1",ConcatenateStrings3,MAssertion,"Append strings s1 + s2 + s3",ConcatenateStrings4,"Append strings s1 + s2 + s3 + s4",StringToLabel,"returns s as a label (without quotes)",BDMConstraintCheck,BDMRuleCheck,MRule,get_object,exists,rename,get_object_star,Magic,changeAttributeValue,find_instances,$ (this in ~class) $,find_storeframes_instances,MSFOLrule,$ (this in ~class) and (not
(this in MSFOLassertion)) and
(not (this in BDMConstraintCheck)) and
(not (this in BDMRuleCheck))$,ISINSTANCE,$ ((~obj in ~class)==>(this == TRUE))and
    (not (~obj in ~class)==>(this == FALSE)) $,ISSUBCLASS,$ ((~sub isA ~super)==>(this == TRUE))and
    (not (~sub isA ~super)==>(this == FALSE)) $,find_iattributes,metaMSFOLrule,$ To(this,~class) $,find_specializations,$    (~ded == TRUE) and (this isA ~class)
           or (~ded == FALSE) and Isa_e(this,~class) $,MSFOLconstraint,AvailableVersions,$ exists x/Proposition P(x,~this,'*instanceof',Version) and Known(x,~time) $,find_incoming_links,$ To(this,~objname) and In(this,~category) $,find_incoming_links_simple,$ To(this,~objname) $,find_outgoing_links,metaMSFOLconstraint,$ From(this,~objname) and In(this,~category) $,find_outgoing_links_simple,$ From(this,~objname) $,find_classes,$ In(~objname,this) or
              (In_s(~this,QueryClass) and In(~objname,~this)) or
              (In_s(~this,QueryCall) and In(~objname,~this))$,find_explicit_classes,$ In_s(~objname,this) $,find_explicit_instances,MSFOLquery,$ In_s(this,~class) $,find_generalizations,$    (~ded == TRUE) and (~class isA this)
           or (~ded == FALSE) and Isa_e(~class,this) $,IS_EXPLICIT_INSTANCE,$ (In_s(~obj,~class)==>(this == TRUE)) and
    (not In_s(~obj,~class)==>(this == FALSE)) $,IS_EXPLICIT_SUBCLASS,QueryClass,$ (Isa_e(~sub,~super)==>(this == TRUE)) and
    (not Isa_e(~sub,~super)==>(this == FALSE)) $,find_referring_objects,$ exists a/Attribute l/Label Pa(a,this,l,~class) $,AF_find_referring_objects_obi,"","{ASKquery(get_object[{this}/objname],FRAME)}",IS_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A(~src,l,~dst) and UNIFIES(this,TRUE) $,Individual,IS_EXPLICIT_ATTRIBUTE_OF,$ exists l/Label Label(~attrCat,l) and A_e(~src,l,~dst) and UNIFIES(this,TRUE) $,get_links2,GenericQueryClass,$ exists l/Label P(this,~src,l,~dst) $,get_links3,$ exists l/Label P(this,~src,l,~dst) and (this in ~cat) $,find_all_explicit_attribute_values,$ exists x/Attribute l/Label Pa(x,~objname,l,this) $,find_referring_objects2,$ AeD(~cat,this,~objname) $,BuiltinQueryClass,find_all_referring_objects2,$ AD(~cat,this,~objname) $,find_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,c,l,d) and not(UNIFIES(c,Proposition)) and
 not (In(d,MSFOLassertion) or In(d,BDMRuleCheck) or In(d,BDMConstraintCheck))) or UNIFIES(this,Attribute) $,find_used_attribute_categories,Token,View,$  exists x/Proposition AD(this,~objname,x) and 
                (this <> Class!rule) and (this <> Class!constraint) and 
                (this <> Proposition!applyConstraintIfInsert) and (this <> Proposition!applyConstraintIfDelete) and 
                (this <> Proposition!applyRuleIfInsert) and (this <> Proposition!applyRuleIfDelete) and 
                (this <> Proposition!deducedBy) $,find_attribute_values,$ AD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_explicit_attribute_values,$ AeD(~cat,~objname,this) and not In(this,BDMRuleCheck) and not In(this,BDMConstraintCheck) $,find_incoming_attribute_categories,$ (exists c,d/Proposition l/Label In(~objname,c) and Pa(this,d,l,c) and not(UNIFIES(c,Proposition))) or UNIFIES(this,Attribute) $,find_used_incoming_attribute_categories,SubView,$  exists x/Proposition AD(this,x,~objname)  $,find_object,$ UNIFIES(this,~objname) $,DatalogQueryClass,"Similar to get_object, but just returns the object (used by JavaGraphBrowser)",GraphicalType,GraphicalPalette,JavaGraphicalType,$ forall jgt/JavaGraphicalType (not (exists i/Integer A_e(jgt,priority,i))) ==> A(jgt,priority,0) $,JavaGraphicalPalette,SimpleClass,CBGraphEditorResult,"This answer format has four parameters: 'obj' is the object
   which is related to the result objects, 'cat' is the category of the link
   between 'obj' and 'this', 'pal' is the graphical palette, and 'objtype'
   specifies whether 'obj' should be considered as source (src) or destination (dst)
   in the set of edges to be included in answer.","<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<result>",DatalogRule,"</result>","
{buildCBEditorResult({this},{obj},{cat},{pal},{objtype})}
",CBGraphEditorResultWithoutEdges,"This answer format is like CBGraphEditorResult but it
   will not output any edges. Therefore, it has only the parameter
   'pal' to indicate the graphical palette.","
{buildCBEditorResultWithoutEdges({this},{pal})}
",GetJavaGraphicalPalette,DatalogInRule,$ UNIFIES(this,~pal) $,XML_JavaGraphicalPalette,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<palette>","</palette>","
<contains>
{Foreach(({this.contains}),(gt),
{ASKquery(GetJavaGraphicalType[{gt}/gt],XML_JavaGraphicalType)})}
</contains>
  <defaultIndividual>{this.defaultIndividual}</defaultIndividual>
  <defaultLink>{this.defaultLink}</defaultLink>
  <implicitIsA>{this.implicitIsA}</implicitIsA>
  <implicitInstanceOf>{this.implicitInstanceOf}</implicitInstanceOf>
  <implicitAttribute>{this.implicitAttribute}</implicitAttribute>
{Foreach(({this.palproperty},{this|palproperty}),(v,l),
  <palproperty>
    <name>{l}</name>
    <value>{v}</value>
  </palproperty>)}
",GetJavaGraphicalType,DatalogAttrRule,$ UNIFIES(~gt,this)  $,XML_JavaGraphicalType,"<graphtype>"
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
