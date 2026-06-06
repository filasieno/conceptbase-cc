# Shared source patches for the legacy CB_Make server build.
{ swi-prolog, openjdk11, clang }:

''
  substituteInPlace ProductPOOL/config.mk \
    --replace-fail '/home/jeusfeld/swiprolog' "${swi-prolog}" \
    --replace-fail 'lib/pl-5.7.10/include' "lib/swipl-${swi-prolog.version}/include" \
    --replace-fail 'JAVADIR:=/usr' "JAVADIR:=${openjdk11}"

  sed -i 's|CFLAGS=-O2 -Wall -D|CFLAGS=-O2 -Wall -D_DEFAULT_SOURCE -Wno-implicit-function-declaration -Wno-error -D|g' \
    ProductPOOL/config.mk
  sed -i 's|CXXFLAGS=-O2 -Wall -D|CXXFLAGS=-O2 -Wall -Wno-error -D|g' \
    ProductPOOL/config.mk

  sed -i '354s/.*/    if(PL_unify_integer(retterm, ret))/' \
    ProductPOOL/serverSources/C_Files/libGeneral/swiGeneral.c

  find ProductPOOL -name Makefile -print0 | xargs -0 \
    sed -i 's|/bin/rm|rm|g; s|RM=/bin/rm|RM=rm|g'

  chmod u+x AdminPOOL/bin/CB* AdminPOOL/bin/makePlcb AdminPOOL/bin/touch_ifw 2>/dev/null || true
  chmod u+x AdminPOOL/bin/*latex* 2>/dev/null || true
  chmod u+x ProductPOOL/bin/CB* 2>/dev/null || true

  # Server-only builds skip the legacy Java makefile; install must tolerate missing JARs.
  substituteInPlace AdminPOOL/bin/CB_Install \
    --replace-fail 'cp $CB_POOL/java/classes/cb.jar $CB_PRODUCT/lib/classes' \
      'test -f $CB_POOL/java/classes/cb.jar && cp $CB_POOL/java/classes/cb.jar $CB_PRODUCT/lib/classes || true' \
    --replace-fail 'cp $CB_POOL/java/lib/*.jar $CB_PRODUCT/lib/classes' \
      'for _jar in $CB_POOL/java/lib/*.jar; do test -f "$_jar" && cp "$_jar" $CB_PRODUCT/lib/classes; done || true'
''
