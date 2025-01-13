/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/*
 * This file defines the structure of an SML fragment (Telos frame).
 * The main structures are te_SMLfragmentList and te_ClassList as
 * they are also returned by the parser.
 *
 * A short explanation of fragment.h using an example:
 *
 *      Individual Object in Class1, Class2 isA SuperClass1, SuperClass2  with
 *      cat1,cat2
 *           lab1 : val1;
 *           lab2 : val2
 *      cat3
 *           lab3 : val3
 *      end
 *
 *  then a call of te_frame_parser("....") (see te_callparser.h) will produce
 *   the following structure as output:
 *
 *  FrameParseOutput:
 *     error should be 0, and smlfrag is a pointer to the first SML fragment.
 *
 *  te_SMLfragmentList
 *    - "id" is the object name (here: Object),
 *      encapsulated in the OBjectIdentifier struct (see below)
 *    - "inOmega" is the Omega-Class (or SystemClass, here: Individual).
 *      Although this is defined as a list, it should contain only one element
 *    - "in" is the list of classes (here Class1 and Class2)
 *    - "isa" is the list of super classes (here SuperClass1 and SuperClass2)
 *    - "with" is the list of attribute declarations, here there are two attribute
 *       declarations:
 *       1. cat1,cat2
 *            lab1 : val1;
 *            lab2 : val2
 *       2. cat3
 *            lab3 : val3
 *       Thus, they are grouped by categories. The first element in the AttrDeclList
 *       will have the following data:
 *         classList = cat1, cat2
 *         attrList = PropertyList of
 *                        1. label = lab1
 *                           value = val1
 *                           (objectSet will be empty for standard Telos frames)
 *                        2. label = lab2
 *                           value = val2
 *         next = pointing to the next AttrDeclList element with the following data:
 *         classlist = cat3
 *         attrList = PropertyList with one element
 *                           label = lab3
 *                           value = val3
 *    - "next" will be NULL as there is only one frame
 *
 *  Except for "id", all elements of the SML fragment may be NULL.
 *
 *  The ObjectIdentifier structure represents objectnames:
 *    - "id" will be set if the object is a simple label, e.g. "Class"
 *    - "bind" is used for derive expressions, i.e. queries with parameters, e.g.
 *       "find_instances[Class/class]".
 *    - "selector" will be used, if the objectname is a select expression, e.g.
 *        Object->Class or Object!attribute. The selector is then "->" or "!"
 *    - obj_left/right is the left and right part of the select expression.
 *
 *  All other structure are probably not relevant if you are parsing
 *  only answers of ConceptBase. There are used for the extended syntax of views.
 *
 */

#ifndef FRAGMENT_H
#define FRAGMENT_H


/** A binding list represents the list of parameters in a
  * derive expression.
  */
typedef struct bindingList {
    struct objectIdentifier    *lab1;
    char            *op;
    struct objectIdentifier    *lab2;
    struct bindingList    *next;
}        BindingList;

/** An object identifier represents a Telos object name.
  * It may be a simple object name, a derive expression,
  * or a select expression.
  */
typedef struct objectIdentifier {
    char            *id;
    struct bindingList    *bind;
    char            *selector;
        struct objectIdentifier *obj_left;
        struct objectIdentifier *obj_right;
}        ObjectIdentifier;

/** A class list is a list of object identifiers */
typedef struct classlist {
    ObjectIdentifier *Class;
    struct classlist *next;
}               te_ClassList;

/** An AttrClassList is a list of attribute categories.
  * Attribute categories or simple labels.
  */
typedef struct attrclasslist {
    char           *Class;
    struct attrclasslist *next;
}               AttrClassList;

/** Used only internally for extended syntax */
typedef struct specObjId  {
    char *label;
    struct specObjId *specobjright;
    struct objectIdentifier *oid;
}   SpecObjId;

/* Forward */
struct restriction;

/** Used only internally for extended syntax */
typedef struct selectexpb {
    struct specObjId *objectleft;
    struct restriction *restleft;
    char *labelleft;
    char Operator;
    struct selectexpb *selectExp;
    char *labelright;
    struct restriction *restright;
}    SelectExpB;

/** Used only internally for extended syntax */
typedef struct restriction {
    char *label;
    struct objectIdentifier *Class;
    struct classlist *enumeration;
    struct selectexpb *selectExp;
}   Restriction;

/* FORWARD */
struct smlfragmentList;

/** Used only internally for extended syntax */
typedef struct objectset {
    struct classlist *enumeration;
    struct selectexpb *selectExp;
    struct smlfragmentList *complexRef;
}        ObjectSet;

/** A property list is a list of attributes. Attributes
 * have a label and a value. The member objectSet is used
 * only in an extended syntax.
 */
typedef struct propertylist {
    char                *label;
    ObjectIdentifier    *value;
    ObjectSet           *objectSet;
    struct propertylist *next;
}               PropertyList;

/** An AttrDeclList is a list of attribute declarations.
 * It represents everthing between "with" and "end" in a
 * Telos frame. One attribute declaration has a list of attribute
 * categories and a list of properties (attribute definitions).
 */
typedef struct attrdecllist {
    AttrClassList        *classList;
    PropertyList        *attrList;
    struct attrdecllist *next;
}               AttrDeclList;

/** A SMLfragmentList is a list of Telos frames. Each Telos
 * frame has an object identifier (id). It may have in addition
 * an inOmega class, a list of in-Classes, a list of isA-Classes,
 * and an attribute declaration. Except id, all members may be NULL.
 */
typedef struct smlfragmentList {
    ObjectIdentifier    *id;
    te_ClassList        *inOmega;
    te_ClassList        *in;
    te_ClassList        *isa;
    AttrDeclList        *with;
    struct smlfragmentList    *next;
}        te_SMLfragmentList;


#endif
