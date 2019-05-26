const MAXOIDSTRLEN=15;
const MAXSYMBOLSTRLEN=1024;

typedef string oidstr<MAXOIDSTRLEN>;
typedef string symstr<MAXSYMBOLSTRLEN>;

struct prop3 {
   oidstr src;
   symstr lab;	 
   oidstr dst;
};	

struct prop4 {
   oidstr id;
   oidstr src;
   symstr lab;
   oidstr dst;
};

struct prop5 {
   oidstr id;
   oidstr src;
   symstr lab;
   oidstr dst;
   oidstr mod;
};

struct oid2 {
   oidstr id1;
   oidstr id2;
};

struct in_rename {
   symstr newname;
   symstr oldname;
};

struct in_create_node {
   struct prop4 p4;
};

struct out_create_node {
   int       success;
   struct prop4 p4;
};

struct in_getquery {
   struct prop4 p4;
};

struct in_getqueryM {
   struct prop5 p5;
};

struct out_getquery {
  int nr;
};

struct in_find {
   int query;
};

struct out_find3 {
  struct prop3 p3;
  int success;
};

struct out_find {
  struct prop4 p4;
  int success;
};

struct out_findM {
  struct prop5 p5;
  int success;
};

struct out_getid {
  symstr id;
};

struct in_literal_freequery {
  int query;
  int WhatLit;
};

struct in_literal_getquery {
  struct oid2 o2;
  int WhatLit;
};

struct in_literal3_getquery {
  struct prop3 p3;
  int WhatLit;
};

struct in_literal4_getquery {
  struct prop4 p4;
  int WhatLit;
};


struct in_literal_find {
   int query;
   int WhatLit;
};

struct out_literal_find {
  struct oid2 o2;
  int success;
};

struct in_create_name2id {
   symstr name;
};

struct out_create_name2id {
   int          success;
   oidstr   oid;
};


struct in_name2id {
   symstr name;
};

struct out_name2id {
   int          success;
   oidstr oid;
};


struct in_id2name {
   oidstr oid;
};

struct out_id2name {
   int          success;
   symstr name;
};


struct in_select2id {
   symstr name;
};

struct out_select2id {
   int          success;
   oidstr oid;
};


struct in_id2select {
   oidstr oid;
};

struct out_id2select {
   int          success;
   symstr name;
};

struct in_id2time {
   oidstr oid;
};

struct out_id2time {
   int	success;
   int  milsec;
   int	sec;
   int	min;
   int	hour;
   int	mday;
   int	mon;
   int	year;
};

struct in_create_link {
   struct prop4 p4;
};

struct out_create_link {
   int       success;
   struct prop4 p4;
};

struct in_remove {
   oidstr oid;
};

struct in_get_sys_class {
   symstr name;
};

struct out_get_sys_class {
   int          success;
   oidstr oid;
};

struct out_get_prop_id {
   int          success;
   oidstr oid;
};

struct in_set_time_point {
  int milsec;
  int sec;
  int min;
  int hour;
  int mday;
  int mon;
  int year;
};

struct in_zaehler {
   oidstr oid;
   int box;
};

struct out_zaehler {
   int success;
   long count;
};


struct out_get_histogramm {
   int success;
   oidstr oid;
   long count;
};

struct in_upd_restr_hist {
   oidstr oid;
   int box;
   oidstr src;
   oidstr dst;
};

struct in_module {
   oidstr oid;
};


program OBJECTSTORAGE {
   version OBJSTOVERS {
      int R_INIT( in_name2id ) = 101;
      void R_TEST( void ) = 102;
      void R_DONE( void ) = 103;
      out_getquery R_GETQUERY( in_getquery ) = 201;
      out_find R_FIND( in_find ) = 202;
      void R_FREEQUERY( int ) = 203;
      out_getid R_GETID( void ) = 204;
      out_getquery R_LITERAL_GETQUERY( in_literal_getquery ) = 205;
      out_literal_find R_LITERAL_FIND( in_literal_find ) = 206;
      void R_LITERAL_FREEQUERY( in_literal_freequery ) = 207;
      out_getid R_LITERAL_GETID( int ) = 208;
      out_getquery R_LITERAL4_GETQUERY( in_literal4_getquery ) = 209;
      out_find R_LITERAL4_FIND( in_literal_find ) = 210;
      out_getquery R_LITERAL3_GETQUERY( in_literal3_getquery ) = 211;
      out_find3 R_LITERAL3_FIND( in_literal_find ) = 212;
      out_create_name2id R_CREATE_NAME2ID( in_create_name2id ) = 301;
      out_name2id R_NAME2ID( in_name2id ) = 302;
      out_id2name R_ID2NAME( in_id2name ) = 303;
      out_select2id R_SELECT2ID( in_select2id ) = 304;
      out_id2select R_ID2SELECT( in_id2select ) = 305;
      out_id2time R_ID2TIME( in_id2time ) = 306;
      int R_CHECK_IMPLICIT( in_id2select ) = 307;
      out_create_node R_CREATE_NODE( in_create_node ) = 401;
      out_create_node R_CREATE_IMPLICIT_NODE( in_create_node ) = 402;
      out_create_link R_CREATE_LINK( in_create_link ) = 403;
      void R_INSERT_COMMIT( void ) = 404;
      void R_INSERT_ABORT( void ) = 405;
      int R_REMOVE(in_remove)=406;
      void R_REMOVE_ABORT( void ) = 407;
      void R_REMOVE_END( void ) = 408;
      int R_RENAME( in_rename ) = 409;
      void R_SET_ACT( void ) = 501;
      void R_SET_TEMP( void ) = 502;
      void R_SET_HIST( void ) = 503;
      void R_SET_ACT_TEMP( void ) = 504;
      void R_SET_ACT_HIST( void ) = 505;
      void R_SET_OVERRULE_TEMP( void ) = 506;
      void R_SET_OVERRULE_ACT( void ) = 507;
      void R_SET_OVERRULE_TEMP_TELL( void ) = 508;
      void R_SET_OVERRULE_TEMP_UNTELL( void ) = 509;
      void R_SET_OLD_DB( void ) = 510;
      void R_SET_NEW_DB( void ) = 511;
      void R_SET_CURRENT_DB( void ) = 512;
      out_get_sys_class R_GET_SYS_CLASS( in_get_sys_class ) = 601;
      out_get_prop_id R_GET_PROP_ID( void ) = 602;
      void R_SET_TIME_POINT(in_set_time_point)=701;
      void R_SET_SEARCH_POINT(in_set_time_point)=702;
      void R_DELETE_HISTORY_DB(in_set_time_point)=703;
      out_zaehler R_UPDATE_ZAEHLER(in_zaehler)=801;
      out_zaehler R_GET_ZAEHLER(in_zaehler)=802;
      int R_START_GET_HISTOGRAMM(in_zaehler)=803;
      out_get_histogramm R_GET_HISTOGRAMM( void )=804;
      int R_UPDATE_HISTOGRAMM(in_zaehler) = 805;
      int R_UPDATE_HISTOGRAMM_WITH_RESTR(in_upd_restr_hist) = 806;
      out_zaehler R_UPDATE_ZAEHLER_OHNE_HUELLE(in_zaehler)=807;
      int R_SET_MODULE(in_module)=901;      	    
      int R_SET_OVERRULE_MODULE(in_module)=902;
      int R_SYSTEM_MODULE(in_module)=903; 	    
      int R_INITIALIZE_MODULE(in_module)=904;      	    
      int R_NEW_EXPORT(in_module)=905;	    
      int R_DELETE_EXPORT(in_module)=906;
      int R_NEW_IMPORT(in_module)=907;
      int R_DELETE_IMPORT(in_module)=908;      	    
      out_getquery R_GETQUERYM( in_getqueryM ) = 909;
      out_findM R_FINDM( in_find ) = 910;
   } = 1;
} = 1000000000;




