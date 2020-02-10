/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1


/* Substitute the variable and function names.  */
#define yyparse         te_parser_parse
#define yylex           te_parser_lex
#define yyerror         te_parser_error
#define yydebug         te_parser_debug
#define yynerrs         te_parser_nerrs

#define yylval          te_parser_lval
#define yychar          te_parser_char

/* Copy the first part of user declarations.  */
#line 39 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:339  */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "fragment.h"
#include "te_smlutil.h"

/***********************************************************
 *
 *          DEKLARATIONS
 *
 **********************************************************/

/* extern deklarations */
#define yytext te_parser_text
#define YYERROR_VERBOSE 1
extern char yytext[];
extern int te_parser_lineno;
extern char* te_parser_errmsg;
extern int te_parse_mode;
extern int te_parser_lex();

/* global deklarations */

te_SMLfragmentList *te_sml;          /* globale Struktur, die 
			             SML-Fragmente enthaelt */
te_ClassList *te_classes;            /* globale Struktur, die eine
                                   ClassList enthaelt */
/* lokal deklarations */

te_SMLfragmentList *head, *tail;

char *te_tokenaftererror;   /* Inhalt des Tokens nach einem Fehler */
int te_errorline;           /* Zeilennummer der zuletzt geparsten 
                               Zeile */
int returnvalue;

/* forward deklarations */

int te_parser_wrap();
void te_parser_error(char* s);
void te_frame_ende();
void te_classlist_ende();
void te_reset();
void init_SMLfragmentlist();
void InsertTail();
ObjectIdentifier *new_Oid();
ObjectIdentifier *new_Select();
BindingList *new_bindList();
BindingList *concat_bindList();
BindingList *insert_bindList();
te_ClassList *new_Class();
te_ClassList *concat_Classlist();
AttrClassList *new_AttrClass();
AttrClassList *concat_AttrClasslist();
PropertyList *new_Property();
PropertyList *concat_PropList();
AttrDeclList *new_Decl();
AttrDeclList *concat_DeclList();
ObjectSet* new_objectSet();
SelectExpB* new_selectExpB(SpecObjId *oid,
			   Restriction *restleft,
			   char *labelleft,
			   char Operator,
			   SelectExpB *selectExp,
			   char *labelright,
			   Restriction *restright);
Restriction* new_restriction(char *label,
			     ObjectIdentifier *Class,
			     te_ClassList *enumeration,
			     SelectExpB *sb);
				 
SpecObjId *new_SpecObjId(char *label,
                           SpecObjId *right,
						   ObjectIdentifier *id);
						   
te_SMLfragmentList* new_smlFragmentList(ObjectIdentifier	*id,
		   te_ClassList		*inOmega,
		   te_ClassList		*in,
		   te_ClassList		*isa,
		   AttrDeclList		*with,
		   struct smlfragmentList	*next);


#line 160 "te_parser.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "te_parser.tab.h".  */
#ifndef YY_TE_PARSER_TE_PARSER_TAB_H_INCLUDED
# define YY_TE_PARSER_TE_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int te_parser_debug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IN = 258,
    ISA = 259,
    WITH = 260,
    END = 261,
    ENDMIT = 262,
    SELECTOR2 = 263,
    SELECTOR1 = 264,
    LABEL = 265,
    NUMBER = 266,
    SELECTORB = 267,
    ERROR = 268,
    ENDOFINPUT = 269
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 127 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:355  */
 
  char			    ch;
  char			    *s;
  struct objectIdentifier   *o;
  struct bindingList	    *b;
  struct classlist	    *c;
  struct attrdecllist	    *d;
  struct attrclasslist	    *a;
  struct propertylist	    *p;
  struct selectexpb	    *sexp;
  struct objectset	    *os;
  struct smlfragmentList    *sml;
  struct restriction	    *r;
  struct specObjId          *specoid;

#line 231 "te_parser.tab.c" /* yacc.c:355  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE te_parser_lval;

int te_parser_parse (void);

#endif /* !YY_TE_PARSER_TE_PARSER_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 246 "te_parser.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   153

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  23
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  31
/* YYNRULES -- Number of rules.  */
#define YYNRULES  68
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  118

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   269

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      16,    17,     2,     2,    15,     2,     2,    21,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    18,    22,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    19,     2,    20,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   200,   200,   200,   206,   207,   217,   228,   233,   234,
     235,   238,   244,   250,   251,   256,   259,   262,   264,   267,
     272,   273,   274,   276,   277,   280,   281,   284,   285,   288,
     289,   292,   293,   295,   296,   298,   299,   301,   302,   303,
     306,   309,   310,   314,   315,   319,   320,   322,   323,   324,
     326,   328,   329,   330,   332,   333,   334,   335,   337,   338,
     339,   341,   342,   343,   345,   347,   348,   351,   352
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "IN", "ISA", "WITH", "END", "ENDMIT",
  "SELECTOR2", "SELECTOR1", "LABEL", "NUMBER", "SELECTORB", "ERROR",
  "ENDOFINPUT", "','", "'('", "')'", "':'", "'['", "']'", "'/'", "';'",
  "$accept", "spec", "$@1", "choice", "objectlist", "object", "classlist",
  "className", "objectname", "specobjname", "specobjname2", "bindings",
  "bindinglist", "singlebinding", "inspec", "isaspec", "withspec",
  "decllist", "declaration", "attrcatlist", "propertylist", "property",
  "setofobjects", "enumeration", "selectexpb", "selectexpb2",
  "selectexpb3", "restriction", "complexref", "endspec", "label", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,    44,    40,    41,    58,    91,
      93,    47,    59
};
# endif

#define YYPACT_NINF -48

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-48)))

#define YYTABLE_NINF -23

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     -48,     6,    50,   -48,   -48,   -48,   -48,    52,   -48,    23,
     -48,    44,   -48,    87,    -9,    69,   -48,   -48,   101,   -48,
      52,    52,    52,    83,    32,    15,    52,   -48,   -48,   -48,
      99,     8,    21,   -48,    15,    52,    40,     5,   -12,   -48,
     112,    40,     8,    83,   128,    83,    52,   -48,    52,   128,
      83,   -48,   118,   -48,   -48,    52,   -48,   -48,   -48,    99,
     -48,   -48,    83,    25,   -48,    38,    99,   -48,    83,    63,
     -48,   105,    52,    12,    13,    53,   -48,   -48,   -48,   -48,
     119,    69,    55,    72,    83,   108,    62,   -48,   -48,   116,
      83,   -48,   -48,    71,    77,    83,   -48,    73,   108,   108,
     -48,    95,    63,   -48,    71,    77,   -48,    71,    77,   102,
      97,   115,   126,    83,   -48,   -48,   -48,   -48
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     0,     1,     7,    67,    68,     0,     3,     0,
       9,     0,    13,    31,    25,     0,     5,    10,    31,     6,
       0,     0,     0,     0,    31,    33,     0,    17,    16,    14,
      15,    32,    19,    18,    33,     0,    35,     0,     0,    27,
      25,    35,    34,    37,     0,     0,     0,    26,     0,     0,
      36,    38,     0,    41,    65,     0,    12,    29,    28,    30,
      11,    39,     0,    40,    43,     0,    66,    42,     0,     0,
      44,     0,     0,     0,    45,     0,    46,    47,    48,    49,
      25,     0,     0,     0,    37,     0,     0,    20,    50,     0,
       0,    52,    54,    53,    51,     0,    64,     0,     0,     0,
      21,    24,     0,    56,    57,    55,    59,    60,    58,     0,
      22,     0,     0,     0,    61,    62,    63,    23
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -48,   -48,   -48,   -48,   -48,   127,   -20,   124,    -2,    54,
      33,   -48,   -48,   103,   121,   113,   107,    66,   -46,   -48,
     -48,    84,   -48,    49,    51,    41,   -48,    43,   -48,   -47,
     -14
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     1,     2,     8,     9,    10,    11,    12,    30,    75,
     100,    27,    38,    39,    25,    36,    44,    50,    51,    52,
      63,    64,    76,    77,    78,    91,    92,    93,    79,    56,
      14
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      13,    31,    60,    46,    61,    15,     3,    18,    47,    33,
      26,    24,    40,    22,    23,    42,    24,    84,   -15,    35,
      32,    22,    23,    20,    37,   -22,    45,    20,   -15,    53,
      23,    57,    40,     5,     6,    21,    53,    16,    65,     7,
      22,    23,    96,    61,    37,    43,    59,    68,    67,    73,
      -4,     4,    83,    66,    65,    80,    69,    80,    19,    20,
       5,     6,     5,     6,    -8,    85,     7,    74,     7,    81,
      53,    94,    87,     5,     6,    53,    97,    22,    23,    71,
      95,   101,    72,    98,   105,   108,    28,    20,    80,    99,
      21,   102,    88,     5,     6,    22,    23,     5,     6,   101,
     110,   -15,   -15,     7,    21,    22,    23,    22,    23,    22,
      23,     5,     6,   109,   114,     5,     6,     7,     5,     6,
     113,    71,    54,    55,    90,    82,     5,     6,     5,     6,
      48,    26,   115,    62,    54,    55,    17,    86,    26,   103,
     106,   104,   107,   116,    29,    34,   117,    41,    49,    58,
      89,   111,    70,   112
};

static const yytype_uint8 yycheck[] =
{
       2,    21,    49,    15,    50,     7,     0,     9,    20,    23,
      19,    13,    26,     8,     9,    35,    18,     5,     5,     4,
      22,     8,     9,    15,    26,    12,    21,    15,    15,    43,
       9,    45,    46,    10,    11,     3,    50,    14,    52,    16,
       8,     9,    89,    89,    46,     5,    48,    22,    62,    69,
       0,     1,    72,    55,    68,    69,    18,    71,    14,    15,
      10,    11,    10,    11,    14,    12,    16,    69,    16,    71,
      84,    85,    17,    10,    11,    89,    90,     8,     9,    16,
      18,    95,    19,    12,    98,    99,    17,    15,   102,    12,
       3,    18,    20,    10,    11,     8,     9,    10,    11,   113,
     102,    14,    15,    16,     3,     8,     9,     8,     9,     8,
       9,    10,    11,    18,    17,    10,    11,    16,    10,    11,
      18,    16,     6,     7,    16,    71,    10,    11,    10,    11,
      18,    19,    17,    15,     6,     7,     9,    18,    19,    98,
      99,    98,    99,    17,    20,    24,   113,    34,    41,    46,
      84,   102,    68,   102
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    24,    25,     0,     1,    10,    11,    16,    26,    27,
      28,    29,    30,    31,    53,    31,    14,    28,    31,    14,
      15,     3,     8,     9,    31,    37,    19,    34,    17,    30,
      31,    29,    31,    53,    37,     4,    38,    31,    35,    36,
      53,    38,    29,     5,    39,    21,    15,    20,    18,    39,
      40,    41,    42,    53,     6,     7,    52,    53,    36,    31,
      52,    41,    15,    43,    44,    53,    31,    53,    22,    18,
      44,    16,    19,    29,    31,    32,    45,    46,    47,    51,
      53,    31,    32,    29,     5,    12,    18,    17,    20,    40,
      16,    48,    49,    50,    53,    18,    52,    53,    12,    12,
      33,    53,    18,    48,    50,    53,    48,    50,    53,    18,
      31,    46,    47,    18,    17,    17,    17,    33
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    23,    25,    24,    26,    26,    26,    26,    27,    27,
      27,    28,    28,    29,    29,    30,    31,    31,    31,    31,
      32,    32,    32,    33,    33,    34,    34,    35,    35,    36,
      36,    37,    37,    38,    38,    39,    39,    40,    40,    40,
      41,    42,    42,    43,    43,    44,    44,    45,    45,    45,
      46,    47,    47,    47,    48,    48,    48,    48,    49,    49,
      49,    50,    50,    50,    51,    52,    52,    53,    53
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     0,     2,     2,     1,     0,     1,
       2,     6,     5,     1,     3,     1,     3,     2,     3,     3,
       3,     4,     1,     4,     1,     0,     3,     1,     3,     3,
       3,     0,     2,     0,     2,     0,     2,     0,     1,     2,
       2,     1,     3,     1,     3,     3,     3,     1,     1,     1,
       3,     3,     3,     3,     1,     3,     3,     3,     3,     3,
       3,     5,     5,     5,     4,     1,     2,     1,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 200 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { init_SMLfragmentlist();
                                  returnvalue=0; }
#line 1409 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 202 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { te_parser_wrap();
				  return(returnvalue);
						}
#line 1417 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 206 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { returnvalue=0; }
#line 1423 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 207 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { 
				  if (te_parse_mode) { 
					  te_frame_ende();
					  returnvalue=0;
				  } 
				  else {
					  te_parser_error(NULL);
					  returnvalue=1;
				  }
			  }
#line 1438 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 217 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {
				  if (!te_parse_mode) { 
					  te_classes = (yyvsp[-1].c);
					  te_classlist_ende();
					  returnvalue=0;
				  } 
				  else { 
					  te_parser_error(NULL);
					  returnvalue=1;
 				  }
			  }
#line 1454 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 228 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { 
				  te_parser_error(NULL);
				  returnvalue=1;
			  }
#line 1463 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 243 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {InsertTail((yyvsp[-4].o), new_Class((yyvsp[-5].o)), (yyvsp[-3].c), (yyvsp[-2].c), (yyvsp[-1].d));}
#line 1469 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 248 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {InsertTail((yyvsp[-4].o), NULL, (yyvsp[-3].c), (yyvsp[-2].c), (yyvsp[-1].d));}
#line 1475 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 250 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = new_Class((yyvsp[0].o));}
#line 1481 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 253 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = concat_Classlist((yyvsp[-2].c), new_Class((yyvsp[0].o)));}
#line 1487 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 256 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.o) = (yyvsp[0].o);}
#line 1493 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 261 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.o) = (yyvsp[-1].o);}
#line 1499 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 263 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.o) = new_Oid((yyvsp[-1].s), (yyvsp[0].b));}
#line 1505 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 266 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.o) = new_Select((yyvsp[-2].o), (yyvsp[-1].s), new_Oid((yyvsp[0].s), NULL));}
#line 1511 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 269 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.o) = new_Select((yyvsp[-2].o), (yyvsp[-1].s), (yyvsp[0].o));}
#line 1517 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 272 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.specoid) = (yyvsp[-1].specoid); }
#line 1523 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 273 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.specoid) = new_SpecObjId((yyvsp[-3].s),(yyvsp[0].specoid), 0); }
#line 1529 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 274 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.specoid) = new_SpecObjId( 0, 0,(yyvsp[0].o)); }
#line 1535 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 276 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.specoid) = new_SpecObjId((yyvsp[-3].s),(yyvsp[0].specoid), 0); }
#line 1541 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 277 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.specoid) = new_SpecObjId((yyvsp[0].s), 0, 0); }
#line 1547 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 280 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.b) = NULL;}
#line 1553 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 281 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.b) = (yyvsp[-1].b);}
#line 1559 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 284 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.b) = (yyvsp[0].b);}
#line 1565 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 285 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.b) = concat_bindList((yyvsp[-2].b), (yyvsp[0].b));}
#line 1571 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 288 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.b) = new_bindList((yyvsp[-2].o),"/",new_Oid((yyvsp[0].s),NULL)); }
#line 1577 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 289 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.b) = new_bindList(new_Oid((yyvsp[-2].s),NULL),":",(yyvsp[0].o)); }
#line 1583 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 292 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = NULL;}
#line 1589 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 293 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = (yyvsp[0].c);}
#line 1595 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 295 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = NULL;}
#line 1601 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 296 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.c) = (yyvsp[0].c);}
#line 1607 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 298 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = NULL;}
#line 1613 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 299 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = (yyvsp[0].d);}
#line 1619 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 301 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = NULL;}
#line 1625 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 302 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = (yyvsp[0].d);}
#line 1631 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 304 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = concat_DeclList((yyvsp[-1].d), (yyvsp[0].d));}
#line 1637 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 307 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.d) = new_Decl((yyvsp[-1].a), (yyvsp[0].p));}
#line 1643 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 309 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.a) = new_AttrClass((yyvsp[0].s));}
#line 1649 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 312 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.a) = concat_AttrClasslist((yyvsp[-2].a), new_AttrClass((yyvsp[0].s)));}
#line 1655 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 314 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.p) = (yyvsp[0].p);}
#line 1661 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 44:
#line 317 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.p) = concat_PropList((yyvsp[-2].p), (yyvsp[0].p));}
#line 1667 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 45:
#line 319 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.p) = new_Property((yyvsp[-2].s), (yyvsp[0].o), 0);}
#line 1673 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 320 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.p) = new_Property((yyvsp[-2].s), 0, (yyvsp[0].os));}
#line 1679 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 322 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.os)=new_objectSet((yyvsp[0].c),0,0);}
#line 1685 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 323 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.os)=new_objectSet(0,(yyvsp[0].sexp),0);}
#line 1691 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 49:
#line 324 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.os)=new_objectSet(0,0,(yyvsp[0].sml));}
#line 1697 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 326 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.c)= (yyvsp[-1].c);}
#line 1703 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 328 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB((yyvsp[-2].specoid), 0, 0,(yyvsp[-1].ch), 0,(yyvsp[0].s), 0);}
#line 1709 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 329 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB((yyvsp[-2].specoid), 0, 0,(yyvsp[-1].ch),(yyvsp[0].sexp), 0, 0);}
#line 1715 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 330 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB((yyvsp[-2].specoid), 0, 0,(yyvsp[-1].ch), 0, 0,(yyvsp[0].r));}
#line 1721 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 332 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = (yyvsp[0].sexp);}
#line 1727 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 55:
#line 333 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0,(yyvsp[-2].r), 0,(yyvsp[-1].ch), 0,(yyvsp[0].s), 0);}
#line 1733 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 56:
#line 334 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0,(yyvsp[-2].r), 0,(yyvsp[-1].ch),(yyvsp[0].sexp), 0, 0);}
#line 1739 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 57:
#line 335 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0,(yyvsp[-2].r), 0,(yyvsp[-1].ch), 0, 0,(yyvsp[0].r));}
#line 1745 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 58:
#line 337 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0, 0,(yyvsp[-2].s),(yyvsp[-1].ch), 0,(yyvsp[0].s), 0);}
#line 1751 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 59:
#line 338 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0, 0,(yyvsp[-2].s),(yyvsp[-1].ch),(yyvsp[0].sexp), 0, 0);}
#line 1757 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 60:
#line 339 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sexp) = new_selectExpB( 0, 0,(yyvsp[-2].s),(yyvsp[-1].ch), 0, 0,(yyvsp[0].r));}
#line 1763 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 341 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.r)= new_restriction((yyvsp[-3].s),(yyvsp[-1].o),0,0); }
#line 1769 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 62:
#line 342 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.r)= new_restriction((yyvsp[-3].s),0,(yyvsp[-1].c),0); }
#line 1775 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 63:
#line 343 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.r)= new_restriction((yyvsp[-3].s),0,0,(yyvsp[-1].sexp)); }
#line 1781 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 64:
#line 345 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    { (yyval.sml)=new_smlFragmentList(NULL,NULL,NULL,(yyvsp[-3].c),(yyvsp[-1].d),NULL);}
#line 1787 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 67:
#line 351 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.s) = (yyvsp[0].s);}
#line 1793 "te_parser.tab.c" /* yacc.c:1646  */
    break;

  case 68:
#line 352 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1646  */
    {(yyval.s) = (yyvsp[0].s);}
#line 1799 "te_parser.tab.c" /* yacc.c:1646  */
    break;


#line 1803 "te_parser.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 354 "../../../../serverSources/C_Files/libtelos/te_parser.y" /* yacc.c:1906  */


/***********************************************************
 *
 *        ADDITIONAL C-FUNCTIONS
 *
 * *********************************************************/
/* Fehlerbehandlung, falls der Ausdruck nicht erfolgreich geparst wurde */

void te_parser_error(char *s)
{
  if (!s) {
      s="parse error";
  }
#ifdef DEBUG	
  printf("Parser ended with error at \"%s\" !\n", (char *)s);
#endif
  
  /* Setze das Errortoken nur einmal, es sei denn, es ist "parse error" */
  if ((!te_tokenaftererror) || (!strcmp(te_tokenaftererror,"parse error"))) {
      if(te_parser_errmsg) {
	  /* Lexical error reported by scanner */
	  te_tokenaftererror = (char*) strdup(te_parser_errmsg);
	  free(te_parser_errmsg);
      }
      else {
          te_tokenaftererror = (char *)strdup(s);
      }
      te_errorline = te_parser_lineno;
  }
  

  if(head)
  {
      /* Bislang aufgebaute Struktur zerstoeren, damit der
        Speicherplatz wieder freigegeben wird */
      DestroySMLfrag(head);
      head = NULL;
  }
  te_sml = NULL;
}

/*---------------------------------------------------------*/
/* Zuruecksetzen des Parsers auf den Anfangszustand */
void te_reset()
{
}
/*---------------------------------------------------------*/
/* erfolgreiches Beenden */

void te_frame_ende()
{
#ifdef DEBUG	
  printf("Parser ended correctly !\n");
#endif
	
  te_tokenaftererror = NULL;
  te_errorline = 0;
  te_sml = head;
  te_classes = NULL;
}

void te_classlist_ende()
{
#ifdef DEBUG
  printf("Parser ended correctly !\n");
#endif	
  te_tokenaftererror = NULL;
  te_errorline = 0;
  te_sml = NULL;
}

/*---------------------------------------------------------*/
/* Initialisierung */
void
init_SMLfragmentlist()
{
  te_sml = NULL;
  head = NULL;
  tail = NULL;
}
/*---------------------------------------------------------*/
/* Einfuegen eines Fragmentes am Ende der Liste */
void
InsertTail(ObjectIdentifier *objectid, te_ClassList *inOmega, te_ClassList * in, te_ClassList *isa, AttrDeclList *with)
{
  te_SMLfragmentList *fragment;

  fragment = (te_SMLfragmentList *)malloc(sizeof(te_SMLfragmentList));
  fragment->id = objectid;
  fragment->inOmega = inOmega;
  fragment->in = in;
  fragment->isa = isa;
  fragment->with = with;
  fragment->next = NULL;

  if(head)
  {
    tail->next=fragment;
    tail=fragment;
  }
  else
  {
     head=fragment;
     tail=fragment;
  }
}

/*---------------------------------------------------------*/
/* neue ObjectId */
ObjectIdentifier *
new_Oid(char *data, BindingList *bList)
{
  ObjectIdentifier *oid;
	
  oid = (ObjectIdentifier *)malloc(sizeof(ObjectIdentifier));
  oid->id = strdup(data);
  oid->bind = bList;
  oid->selector = NULL;
  oid->obj_left = NULL;
  oid->obj_right = NULL;

  return(oid);
} 

ObjectIdentifier *
new_Select(ObjectIdentifier *o1, char *sel, ObjectIdentifier *o2)
{
  ObjectIdentifier *oid;

  oid = (ObjectIdentifier *)malloc(sizeof(ObjectIdentifier));
  oid->id = NULL;
  oid->bind = NULL;
  oid->selector = strdup(sel);
  oid->obj_left = o1;
  oid->obj_right = o2;

  return(oid);
} 

/*---------------------------------------------------------*/
/* neue Bindinglist generieren */
BindingList *
new_bindList(ObjectIdentifier *id1, char *o, ObjectIdentifier *id2)
{
  BindingList *bList;

  bList = (BindingList *)malloc(sizeof(BindingList));
  bList->lab1 = id1;
  bList->op = strdup(o);
  bList->lab2 = id2;
  bList->next = NULL;

  return(bList);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Bindinglisten */

BindingList *
concat_bindList(BindingList *bl1, BindingList *bl2)
{
  BindingList *lauf;

  lauf = bl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = bl2;

  return(bl1);
}
/*---------------------------------------------------------*/
/* Einfuegen des ersten labels in eine Bindinglist */
BindingList *
insert_bindList(BindingList *bl1, ObjectIdentifier *id)
{
  bl1->lab1 = id;

  return(bl1);
}

/*---------------------------------------------------------*/
/* neue Classlist generieren */

te_ClassList *
new_Class(ObjectIdentifier *data)
{
  te_ClassList *cl;

  cl = (te_ClassList *) malloc(sizeof(te_ClassList));
  cl->Class = data;
  cl->next = NULL;

  return(cl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Classlisten */

te_ClassList *
concat_Classlist(te_ClassList *cl1, te_ClassList *cl2)
{
  te_ClassList *lauf;

  lauf = cl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = cl2;
  
  return(cl1);
}
/*---------------------------------------------------------*/
/* neues AttrClasslist generieren */

AttrClassList *
new_AttrClass(char *data)
{
  AttrClassList *cl;

  cl = (AttrClassList *) malloc(sizeof(AttrClassList));
  cl->Class = strdup(data);
  cl->next = NULL;

  return(cl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Classlisten */

AttrClassList *
concat_AttrClasslist(AttrClassList *cl1, AttrClassList *cl2)
{
  AttrClassList *lauf;

  lauf = cl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = cl2;
  
  return(cl1);
}
/*---------------------------------------------------------*/
/* neue Propertylist generieren */

PropertyList *
new_Property(char *label, ObjectIdentifier *value, ObjectSet *objectSet)
{
  PropertyList *prop;

  prop = (PropertyList *) malloc(sizeof(PropertyList));
  prop->label = strdup(label);
  prop->value = value;
  prop->objectSet = objectSet;
  prop->next = NULL;

  return(prop);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Propertylisten */

PropertyList *
concat_PropList(PropertyList *pl1, PropertyList *pl2)
{
  PropertyList *lauf;

  lauf = pl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = pl2;
  
  return(pl1);
}
/*---------------------------------------------------------*/
/* neue DeclarationList generieren */

AttrDeclList *
new_Decl(AttrClassList *classList, PropertyList *attrList)
{
  AttrDeclList *adecl;

  adecl = (AttrDeclList *) malloc(sizeof(AttrDeclList));
  adecl->classList = classList;
  adecl->attrList = attrList;
  adecl->next = NULL;
  
  return(adecl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Declarationlisten */

AttrDeclList *
concat_DeclList(AttrDeclList *ad1, AttrDeclList *ad2)
{
  AttrDeclList *lauf;

  lauf = ad1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = ad2;
  
  return(ad1);
}
/*---------------------------------------------------------*/
/* neues ObjectSet generieren */

ObjectSet* new_objectSet(te_ClassList *enumeration,
			 SelectExpB *selectExp,
			 te_SMLfragmentList *complexRef) {

    ObjectSet *new_os;

    new_os = (ObjectSet *) malloc(sizeof(ObjectSet));

    new_os->enumeration	= enumeration;
    new_os->selectExp	= selectExp;
    new_os->complexRef	= complexRef;

    return (new_os);
}

/*---------------------------------------------------------*/
/*  Neue SelectExpB generieren */

SelectExpB* new_selectExpB(SpecObjId *oid,
			   Restriction *restleft,
			   char *labelleft,
			   char Operator,
			   SelectExpB *selectExp,
			   char *labelright,
			   Restriction *restright) {

    SelectExpB *new_sel;

    new_sel = (SelectExpB *) malloc(sizeof(SelectExpB));

    new_sel->objectleft=oid;
    new_sel->restleft=restleft;
	new_sel->labelleft=labelleft;
    new_sel->Operator=Operator;
    new_sel->selectExp=selectExp;
    new_sel->labelright=labelright;
    new_sel->restright=restright;

    return (new_sel);
}


/*---------------------------------------------------------*/
/*  Neue Restriction generieren */
Restriction* new_restriction(char *label,
			     ObjectIdentifier *Class,
			     te_ClassList *enumeration,
			     SelectExpB *sb) {

    Restriction *new_rest;

    new_rest=(Restriction *) malloc(sizeof(Restriction));

    new_rest->label=label;
    new_rest->Class=Class;
    new_rest->enumeration=enumeration;
    new_rest->selectExp=sb;

    return (new_rest);
}

/*---------------------------------------------------------*/
/*  Neues Special-Objekt generieren (wird fuer SelectExpressions benoetigt) */
SpecObjId *new_SpecObjId(char *label,
                         SpecObjId *specobjright,
						 ObjectIdentifier *oid) {

    SpecObjId *new_spec;
	
	new_spec = (SpecObjId *) malloc(sizeof(SpecObjId));
	
	new_spec->label=label;
	new_spec->specobjright=specobjright;
	new_spec->oid=oid;
	
	return (new_spec);	
}

/*---------------------------------------------------------*/
/*  Neue SMLFragmentList anlegen (fuer complexRef) */

te_SMLfragmentList*
new_smlFragmentList(ObjectIdentifier	*id,
		   te_ClassList		*inOmega,
		   te_ClassList		*in,
		   te_ClassList		*isa,
		   AttrDeclList		*with,
		   struct smlfragmentList	*next) {

    te_SMLfragmentList* fragment;

    fragment= (te_SMLfragmentList*) malloc(sizeof(te_SMLfragmentList));

    fragment->id=id;
    fragment->inOmega=inOmega;
    fragment->in=in;
    fragment->isa=isa;
    fragment->with=with;
    fragment->next=next;

    return (fragment);

}

