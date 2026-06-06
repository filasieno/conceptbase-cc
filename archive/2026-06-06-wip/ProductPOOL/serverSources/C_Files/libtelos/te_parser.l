/*
*
* File:         %M%
* version:      %I%
* Creation:     
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*/

%{
#include "te_parser.tab.h"
#include <string.h>
#include <stdlib.h>

/* global variables/functions */
extern void te_parser_error(char* s);

/* variables/functions for string management */	
static char* string_buf_ptr;
static int string_buf_max_size;
static int old_state;
void addToStringBuf(const char* s);

/* errormeldung */
char* te_parser_errmsg;

/* module Kontext */
char *get_mod_context();	
extern char *mod_context;

/* variables for InputBuffer */ 	
/* no longer needed, see init_te_parser ... 
static char* te_parser_InputBuffer;  *//* [0..te_parser_InputBufferSize-1] *//*
static unsigned te_parser_InputBufferSize;
static unsigned te_parser_InputBufferCount;
*/

/* initialize the input buffer */	
void init_te_parser_InputBuffer( char *buf, unsigned bufSize ) {
    yy_scan_string(buf); /* changed how input is read because
			    alte Methode mit YY_INPUT not funktionierte
			    (nach error kommt der Parser aus dem Tritt) */
    te_parser_errmsg=NULL;
/*	te_parser_InputBuffer = buf;
	te_parser_InputBufferSize = bufSize;
	te_parser_InputBufferCount = 0; */
}

/* read input, one character at a time */	
/* Nicht more necessary, siehe init_te_parser... 
#undef YY_INPUT
#define YY_INPUT( buf, result, max_size )  \
	{  \
		if( te_parser_InputBufferCount >= te_parser_InputBufferSize ) \
			result = YY_NULL;  \
		else {  \
			*buf = te_parser_InputBuffer[te_parser_InputBufferCount++];  \
			result = 1;  \
		}  \
	}
*/
/* Debugging */	
#ifdef DEBUG
#define ECHO1(a1)           printf(a1)
#define ECHO2(a1,a2)        printf(a1,a2)
#else
#define ECHO1(a1) 
#define ECHO2(a1,a2) 
#endif


%}
/* Zustaende */
%x comment_state string_state rule_state

/* Zeilennummern verwalten */
%option yylineno

/* Startzustaende */
%START CML PT


/* Makros */
Selector1		"!"|"^"|"@"
Selector2		"->"|"=>"

Real			[-]?([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][-+]?[0-9]+)?
Integer			[-]?[0-9]+

Leerzeichen             [ \t\r\f]
String                  [^\.\|\'\"\$\:\; \n\@\t\r\f\!\^\-\>\=\,\(\)\[\]\{\}\/]+
HKString                \"([^\\\"]|\\\"|\\\\)*\"
RuleString              \$([^\\\$]|\\\$|\\\\|\\\")*\$
ModuleString		[^\.\|\'\"\$\:\; \n\@\t\r\f\!\^\>\=\,\(\)\[\]\{\}\/]+

FastAlles4		[^\{\}]*
Comment			\{{FastAlles4}\}

TelosCML		"{$set syntax=CML}"
TelosPT			"{$set syntax=PlainToronto}"
TelosPA			"{$set syntax=PlainAachen}"
Module			"{$set module="{ModuleString}"}"


/******* REGELN ********/
%%
{TelosCML}	{ 
	ECHO2("%s ", te_parser_text); ECHO1("CML Mode");
	BEGIN CML; 
}

{TelosPT}  { 
	ECHO2("%s ", te_parser_text); ECHO1("PT Mode");
	BEGIN PT; 
}

{TelosPA}  { 
	ECHO2("%s ", te_parser_text); ECHO1("PA Mode");
	BEGIN 0; 
}

{module}  {
	char *dummy;
	/* kopiert die Modulkomponente "module" from dem token */
	/* "{$set module="{module}"}" in die variable mod_context */
	
	/* if mod_context is already set, multiple module */
	/* directives in one file -> error */
	if (mod_context) {
		te_parser_error("SET_MODULE_ERROR");
		/*te_parser_wrap();*/
		return (ERROR);
	}
	
	ECHO2("Module Context: %s \n", te_parser_text);
	dummy = te_parser_text;
	while (((*dummy) != '=') && (*dummy))  dummy++;
	if (*dummy) {
		dummy++;
		mod_context = (char *)strdup(dummy);
		dummy = mod_context;
		while (((*dummy) != '}') && (*dummy))  dummy++;
		if (*dummy) 
			(*dummy)= 0;
		else   
			mod_context = (char *)strdup("ERROR");
	}
	else mod_context = (char *)strdup("ERROR");
}

{Leerzeichen}           ;

\n			;

[\:\;\,\(\)\[\]\/]	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(te_parser_text[0]); 
}

<CML>IN	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(IN); 
}

in	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(IN); 
}

<CML>ISA  { 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(ISA); 
}

isA	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(ISA); 
}

<CML>WITH { 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(WITH); 
}

with { 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(WITH); 
}

<CML>END { 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(END); 
}

<PT>end	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(ENDMIT); 
}

end	{ 
	ECHO2("end:%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(END); 
}

{Selector1}	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(SELECTOR1); 
}

{Selector2}	{ 
	ECHO2("%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(SELECTOR2); 
}

{String} { 
	ECHO2("LABEL: %s \n", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(LABEL); 
}

\" { /* for String */
	string_buf_max_size=32;
	string_buf_ptr=(char*) malloc(string_buf_max_size);
	string_buf_ptr[0]='\"';
	string_buf_ptr[1]='\0';
	old_state=YYSTATE;
	ECHO1("\"");
	BEGIN(string_state);
}

<string_state>\\\" {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<string_state>\\[^\"] {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<string_state>[^\\\"] {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<string_state>\" {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
	te_parser_lval.s=strdup(string_buf_ptr);
	BEGIN(old_state);
	return LABEL;
}

\$ { /* for Rule */
	string_buf_max_size=32;
	string_buf_ptr=(char*) malloc(string_buf_max_size);
	string_buf_ptr[0]='$';
	string_buf_ptr[1]='\0';
	old_state=YYSTATE;
	ECHO1("$");
	BEGIN(rule_state);
}

<rule_state>\\\$ {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<rule_state>\\[^\$] {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<rule_state>[^\\\$] {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
}

<rule_state>\$ {
	ECHO2("%s",te_parser_text);
	addToStringBuf(te_parser_text);
	te_parser_lval.s=strdup(string_buf_ptr);
	BEGIN(old_state);
	return LABEL;
}

{Real} { 
	ECHO2("REAL:%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(NUMBER); 
}

{Integer} { 
	ECHO2("INTEGER:%s ", te_parser_text);
	te_parser_lval.s = (char *)strdup(te_parser_text);
	return(NUMBER); 
}

['.'|'|'] { 
	ECHO2("%s ", te_parser_text); 
	te_parser_lval.ch=te_parser_text[0];
	return SELECTORB;
}

"{" { /* for {Comment} */
	ECHO1("{");
	old_state=YYSTATE;
	BEGIN(comment_state);
}

<comment_state>[^\}]*  { 
	ECHO2("%s",te_parser_text); 
}

<comment_state>"}"    {
	ECHO1("}");
	BEGIN(old_state);
}

<<EOF>> {
    return(ENDOFINPUT);
}

.  { 
	te_parser_errmsg=(char*)malloc(strlen(te_parser_text)+40);
	sprintf(te_parser_errmsg,"lexical error at symbol \"%s\"",te_parser_text);
	return(ERROR);
}
%%

/* yywrap */
int te_parser_wrap() {
	BEGIN 0;
	te_parser_lineno = 1;
	/* Nicht more necessary, siehe init_te_parser... 
	te_parser_InputBuffer=NULL;
	te_parser_InputBufferCount=0;
	te_parser_InputBufferSize = 0; 
	*/
	return(1); 
}

/* String Buffer um Argument verlaengern */
void addToStringBuf(const char* s) {
	
	char* sTmp;
	
	if((strlen(string_buf_ptr) + strlen(s))>=string_buf_max_size) {
		string_buf_max_size=string_buf_max_size*2+strlen(s);
		sTmp=(char*) malloc(string_buf_max_size);
		strcpy(sTmp,string_buf_ptr);
		free(string_buf_ptr);
		string_buf_ptr=sTmp;
	}
	strcat(string_buf_ptr,s);
}


/* If a "{$set module="{module}"}" token was scanned, */
/* returns mod_context. If not, DEFAULT is returned */
char *get_mod_context(){
    if (mod_context)	
		return mod_context;
    else
		return "DEFAULT";
}
