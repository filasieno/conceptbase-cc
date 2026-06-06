Deal with missing libraries of CBserver
=======================================

Manfred Jeusfeld (2024-03-17)


ConceptBase server can be compiled under Ubuntu 16.04, or 20.04, or 22.04

However, on the target platform, we may have a different variant of Ubuntu (or equivalent Mint)
Thus, we need to make the required libraries available there via the local directory
 $CB_HOME/linux64/lib  (or linux or linuxarm, depending on the CPU platform)

This local directory is made findable via LD_LIBRARY_PATH in the Shell script $CB_HOME/cbserver

The necessary instructions for copiying the library files are in publishCB



(1) Libraries by ConceptBase on target platform ConceptBase Ubuntu 16.04 when compiled under Ubuntu 20.04

cp /usr/lib/x86_64-linux-gnu/libtinfo.so.6.2 $CB_HOME/linux64/lib/libtinfo.so.6
cp  /usr/lib/x86_64-linux-gnu/libm-2.31.so $CB_HOME/linux64/lib/libm.so.6

Available under Ubuntu 16.04
/usr/lib/x86_64-linux-gnu/libtinfo.so.5
/usr/lib/x86_64-linux-gnu/libm.so.6 (libm-2.23)





(2) Libraries by ConceptBase on target platform ConceptBase Ubuntu 20.04 when compiled under Ubuntu 16.04

tbd



