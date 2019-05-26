#
#
# File:        $Source: /home/cbase/CVS/AdminPOOL/admin.mk,v $
# Version:     $Revision: 1.2 $
# Creation:    16-10-95, Christoph Quix (RWTH)
# Last Change: $Date: 2002/10/07 10:00:43 $ , Christoph Quix (RWTH)
# Release:     %R%
#
# -----------------------------------------
# Globales Makefile fuer den AdminPool
#
#


# Variablen, die hier sich von denen im ProduktPool
# unterscheiden

GLOBAL_POOL	=$(ADMIN_POOL)



# Hier koennen auch Regeln eingetragen werden

# Checkin/Commit ueberschreiben, da anderer Pool
checkout commit:
	cd $(POOL_ROOT)/.. ;\
	$(CVS) $@ AdminPOOL/$(CurrDir)$(CVSFILE)



