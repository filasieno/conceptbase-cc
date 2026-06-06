/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
//@Include:startAlg.h

#ifndef ALGEBRA_H
#define ALGEBRA_H

#include "tuple.h"
#include "tuple.STLSet.h"
#include "tuple.STLBag.h"
#include <string.h>
#include "C_Functor.h"

/**das ist die standard tuple set. 
  *Internally ist sie als hash table (TupelSTLSet) built.
  */
#define TUPELSET TupelSTLSet

/**Container for tuple. Der Bag is used, if man ein faster    *"Set" haben will. Here can duplicate solutions in Kauf 
  *used are.
  */
#define TUPELBAG TupelSTLBag

/** Class for eine select condition*/
class Condition : public Tupel
{
public:
        /** Der constructor creates eine empty condition.
         *  @param c Die condition ist ein c-tuple */
    Condition(char c) 
            : Tupel(c) 
    {}
        /** Der constructor creates eine new select condition*/ 
    Condition(const TupelElement& el1= TUPEL_UNDEF,
              const TupelElement& el2= TUPEL_UNDEF,
              const TupelElement& el3= TUPEL_UNDEF)
            :Tupel(el1,el2,el3) 
    {}
    
};

/** Class for eine join condition */
class JoinCondition
{
    int anz;
    
    int *conditions;
    
public:
    JoinCondition(int n) 
            :anz(0)
    {
        conditions=new int [2*n];
    }
     /** Inserts join condition a=b ein.
      * @param a attribute from der ersten relation
      * @param b attribute from der second relation
      */
    int add(int a,int b);
     /**Returns a join condition return
      * @param cn Nummer der join condition
      * @param pos 0 for die left side, 1 for die right side
      */
    int get(int cn,int pos);
     /**returns the number of stored join conditionen*/
    int length()
    {
        return anz;
    }
     /**returns the Laenge des Tupels nach dem join (without projection) return 
       * @param l1 Laenge der ersten relation des joins
         @param l2 Laenge der second relation des Joins
       */
    int result_length(int l1=0,int l2=0);
     /**returns true, if the given attribute is still present after the join; false, if a join condition refers to the attribute 
      * @param f2 bezeichet die Position of a attributees in der second relation of a joins.
      */
    int result_contains(int f2);
    
};


/**Das ist a "DatenSammelObjekt". Es is durch die structure des expressions gereicht and jeder tr\"agt etwas ein. 
   Auf dieser basis arbeitet der partiallye join in AlgDescription.
   @see AlgDescription::join_proj,AlgDescription::start_join_proj
 */
class DataCollector
{    
     /**data structure for die Literale*/
    class Relation **LITs;
     /**data structure for die JoinConditions*/
    JoinCondition **JCs;
     /**data structure for die attributeelistn*/
    AttrList **ALs;
     /**data structure for die Links*/
    class AlgDescription **LINKs;
     /**data structure for die Simplecrosses*/
    class SIMPLECROSS **SCs;

public:
     /**creates einen emptyn DataCollector*/
    DataCollector() 
    {
        LITs=NULL;
        JCs=NULL;
        ALs=NULL;
        LINKs=NULL;
        SCs=NULL;
    };
     /**memoryt ein Datum.
      * For example: datacollector.saveData(datacollector.literals(),MyLiteral)
      * @param where ein pointer auf eine data structure (siehe oben)
      * @param what ein pointer auf das, was stored are should
      */
    void saveData(void*** where,void* what);
     /**Gives die data auf console from. 
      * @param pos indicates, ab welcher Pos begonnen are should
      */
    void print(int pos);
    void test(){print(0);};
     /**Sind Links stored?
        @see AlgDescription::LohntBerechnung
      */
    int HasGotLinks();
     /**Ist ein Simplecross stored?
        @see AlgDescription::join_proj
      */
    int HasGotSimpleCross();
     /**Returns ein Datum return.
       *for example: MyLiteral=datacollecotor.getNrOf(datacollector.literals(),0)
       * @param whatever pointer auf eine data structure
       * @param nr Position des requested in the list der data structure
       */
    void* DataCollector::getNrOf(void*** whatever,int nr);
     /**returns ae pointer auf die data structure der Literale return.
        Wird getNrOf or saveData als erster Parameter \"ubergeben
      */
    void*** Literals(){return (void***)(&LITs);};
     ///siehe literals()
    void*** AttrLists(){return (void***)(&ALs);};
     ///siehe literals()
    void*** JoinConditions(){return (void***)(&JCs);};
     ///siehe literals()
    void*** Links(){return (void***)(&LINKs);};
     ///siehe literals()
    void*** SimpleCross(){return (void***)(&SCs);};
};


/**Fortschrittsbalken.
 *Kleines Hilfsobjekt zur Darstellung of Fortschrittbalken auf der console.
 *  
 * sieht so from: \#\#\#\#\#\#======(30/60)
 */
class ProgressView
{
    int zaehler,max,divisor;
public:
     /** Constructor creates ein neues Object
      * @param i number of Schritte
      * @param a Laenge des Balkens in character
      */
    ProgressView(int i,int a);
    ~ProgressView();
     /**anz Schritte weiter gehen
      * @param anz number of Schritte
      */
    void step(int anz);
     /**Zeichnet sich auf die console. Nach dem Zeichnen stands der Cursor again am Anfang der selben Zeile!
      */
    void draw();
};

    
/** Class for eine relation (algebra)*/
class Relation : public TUPELSET
{
     /** Stelligkeit der relation */
    char tupel_size;
     /* Typen der relation */
    char *types;
    
     /**die Belegung der tuple. Jedes Argument is durch ein Bit codiert. Ist es gesetzt, then ist die variable frei */
    int Belegung;
    
public:
     /**indicates, ob beim Zurueckliefern of solutions mit firstGetAll,nextGetAll and operator []
      * only die lokalen or die gelinkten lsg ger\"uckgegeben are.
      *
      * Sollte of aussen only read are!
      */
    int lokal;
     /**If ae relation den token besitzt, can compute with its deltas,
      * andernfalls are alle solutions mit einbezogen.
      * Der token is bei of a Kette of Literalen (join)
      * of relation zu relation weitergegeben.
      * @see JoinProjNode::TakeTokenFrom(relation* relation)
      * @see Erlaeuterungen
      */
    class JoinProjNode *Token;
     /**Ist in relation nonsensical (placeholder), is erst ab JoinProjNode uses.
       * @see JoinProjNode::RepeatCalc
      */
    int RepeatCalc;
    
     /**Das delta of a relation. 
      * Es contains alle solutions, die bei der letzten Berechnung neu hingekommen are.
      */
    TUPELSET delta;
    
     /** Gives an, ob ein gesetzter link (link!=NULL) auf eine relation within des eigenen Fixpointes zeigt or not. 
      * This flag determines in particular, whether link->RestoreDelta() must be called before using the link data
      * @see AlgDescription::RestoreDeltas()
      */
    int LinkZeigtAufEigenenFixpoint;
     /** link zu of a Rule (AlgDescription).
      *  Eine relation can sowohl eigene, als also gelinkte solutions haben. 
      *  Ist link==NULL, hat sie only eigene solutions and OwnSolution must TRUE sein
      * @see Erlaeuterungen
      */
    class AlgDescription *link;    
    char key;
     /**Gives an ob eine relation ausgerechnet ist or not */
    char not_calculated:1;
     /** Dieser pointer auf eine Rule indicates, wo die Lsg stored are.
      *  If it is the top-level relation, points always to the rule, 
      *  in welcher the relation definiert ist and die AlgDescription entscheidet 
      *  then, wo sie solutions hinkommen. 
      *  If it is a relation in e.g. a JoinProj, then solutions==NULL 
      *  Das bedeutet then, that die solutions in sich selber stored are.
      *  @see AlgDescription::add(tuple)
      */
    class AlgDescription *solutions;
     /**indicates, whether a relation has its own solutions. If not, its link!=NULL! */
    char OwnSolutions:1;
    
     /**statischer link zur Datenbank */
    static class TDB *database;
     /**statische variable contains den time point der Erzeugung*/
    static TIMEPOINT timepoint;
     /**statische variable contains den current Suchraum*/
    static int searchspace;
     /**statische variable contains das Modul in dem the relation stands*/
    static TOID module;
     /**das ist eine Entwicklervariable, um Ausgaben zu kontrollieren...*/
    static int zumuelln;
     /**Ist eine relation negated, then is das im Falle of a joins beachtet */
    int negation;    
    
     /**creates eine empty relation (Definition in algebra.h) */
    Relation() 
            : TUPELSET(), tupel_size(0), types(NULL),Belegung(0), link(NULL), key(0),
              not_calculated(1), solutions(NULL), OwnSolutions(1), negation(0)
    { token=NULL;isAdotLabel=0;}
     /**creates eine empty relation
      * es can bis zu 10 verschiedene Typen for die tuple elements angegeben are (alle weiteren are "free")  
      * @param new_size laenge der tuple, die stored are sollen
      * @param new_key  key
     */
    Relation(char new_size,char new_key, char=0,char=0,char=0,char=0,
             char=0,char=0,char=0,char=0,char=0,char=0);
    
    ~Relation(){};
     /**setzt einige parameter der relation
      * @param db die Datenbank, auf die sich die Berechnungen beziehen sollen
      * @param point den time point
      * @param set den Searchspace
      * @param module das zugehoerige Modul
      *
      * Alles static!!!!
     */
    void Set(class TDB* db,TIMEPOINT point,int set,TOID module);
     /**Inserts ein tuple (eine Berechnung) hinzu. 
      * Es darf actually only always eine Berechnung pro relation sein */
    int AddCalc(Tupel);
     /**does anyone know, was das for ein Key is (is probably used nowhere)? */
    int SetKey(int newkey)
    {
        key=newkey;
        return key;
    }
     /**schreibt viele info auf die console (now sogar in color (im Falle of a xterm-color!)) */
    virtual void test();
     /**schreibt eine Kurzausgabe of test auf die console*/
    virtual void structureTest();
     /**Gives die Belegung der tuple in this relation return.
        Ist ein Bit set ist this Stelle frei.
      */
    int GetBelegung() { return Belegung; };
     /**Gives true zureck, if eine relation berechnet is.
      * Wenn sie no solutions hat, is always true returned.
      * @see not_calculated
      */
    int IsCalculated() { if (OwnSolutions) return !not_calculated; else return 1;}
     /**Returns die Tupellaenge der relation.
      * If the relation has no own solutions, the linked AlgDescription is used.
       */
    int GetSize();
     /**Setzt bei relations mit eigenen solutions die Tupellaenge*/
    int SetSize(int size) {tupel_size=size;return size;};
     /**setzt bei Realtion mit eigenen Lsg die Belegung*/
    int SetBelegung(int bel) {Belegung=bel;return Belegung;};
     /**Returns die number an neuen solutions seit der letzten Berechnung*/
    int NewSolutions();
    
     /**memoryt ein solutionstupel.
      * If solutions is set, the solutions are stored in the AlgDescription, to which solutions points. If solution==NULL, the solution is stored in the relation itself.*/
    virtual Pix add(Tupel);
     ///this function wurde not further developed
    int select(class Relation &ergebnis, const Condition& cond);
     ///this function wurde not further developed
    int proj(class Relation &ergebis, const AttrList& attrlist);
     ///this function wurde not further developed
    int unite(class Relation &relation2);
     ///this function wurde not further developed
    int diff(class Relation &relation2,int mode);
     ///this function wurde not further developed
    int join(class Relation &ergebnis, class Relation &relation2,
             class JoinCondition &jc);
  
     /**das ist eine der beiden lauffaehigen join-proj-Methoden*/
    int join_proj2(class JoinProjNode &ergebnis, class Relation &relation2,
                   class JoinCondition &jc, class AttrList &al);
     /** rechnet eine relation from */
    virtual int calc();
     /** rechnet also from, aber speichert die Lsg in TUPELBAG 
       * and hinterlaesst die relation voellig unveraendert*/
    virtual int calc(Tupel&,TUPELBAG&,int);
     /**setzt link */
    virtual void set_link(class AlgDescription *nlink) { link = nlink; }
     /** Checks the rule auf dependencies of anderen rulen.\\
         In der Class Fixpoint sind the rulek"opfe (bzw. Funktoren) der
         ableitbaren rulen abstored */
    virtual void CheckForRule( class Fixpoint *fixpoint) {fixpoint=fixpoint;}
     /**tupel enthalten?*/
    int           contains(Tupel  item);
     /**Search solutions zu a Muster.
      * Die relation is hierbei not veraendert. In particular gilt sie after that not als ausgerechnet! 
      * @param tupel contains das Muster, das den solutions entsprechen must
      * @param ergebnis darin are die solutions abstored
      */
    int query(Tupel tupel,TUPELBAG& ergebnis);
     /**leert relation*/
    virtual void clear();
     /**returns Pix auf first tuple*/
    virtual Pix first();
     /**returns Pix auf next tuple (end if !Pix)*/
    virtual void next(Pix& i);
     /**wie first, returns but also die gelinkten Lsg. in relation mit eigenen Lsg */
    virtual Pix firstGetAll();
     /**siehe firstgetall*/
    virtual void nextGetAll(Pix&);
     /**returns tuple zu a pix*/
    virtual Tupel& operator () (Pix i);
     /**addiert alle tupel from dem set zu a anderen*/
    virtual void operator |=(TUPELSET& y);
     /**pix enthalten?*/
    virtual int owns(Pix i);
     /**anzahl der tupel in relation*/
    virtual int length();
     /**loescht das delta*/
    void deltaclear();
     /**kopiert das delta in ein TUPELSET*/
    virtual void GetDelta(TUPELSET&);
     /**kopiert das delta in ein TUPELBAG*/
    virtual void GetDelta(TUPELBAG&);
     /**this token is beim berechnen of JoinProjNodes uses. um effektiv mit dem deltas rechnen zu can*/
    virtual int TakeTokenFrom(Relation *relation) {if ((!link) || (!LinkZeigtAufEigenenFixpoint)) return 0;Token=relation->Token;relation->Token=NULL;return 1;};
     /**returns true, if the last call of nextGetAll or firstGetAll returned local solutions*/
    int SolutionsLocal() {if (!OwnSolutions) return 0; else return lokal;};
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta();
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta();
     /**for den Spezialfall, that Adot\_Label also Lsg of Adots bekommen*/
    int isAdotLabel;
     /**DataCollector is for join uses. joins finden aber erst ab literal statt*/
    virtual void CollectData(DataCollector* jdc) {if (4==5) jdc=jdc;};
};


/** unbekanntes literal or durch rule definiertes literal*/
class Literal : public Relation
{
     /** head des literals*/
    C_Functor functor;
     //char **konstanten;
    
public:
     /**Constructor of literal
      * @param tupel_size Stelligeit des literals
      * @param key no ahnung :-/
      * @param t1 typ des ersten Elements
      * @param t2 typ des zweiten Elements
      */
    Literal(int tupel_size, int key, char t1=0,char t2=0,char t3=0,char t4=0,char t5=0,char t6=0,char t7=0,char t8=0,char t9=0,char t10=0)
            : Relation(tupel_size,key,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10){}
     /**Constructor creates ein emptys literal*/
    Literal():Relation(0,0){}
    
        /** Checks the rule auf dependencies of anderen rulen.\\
         *In der Class fixpoint sind the rulek"opfe (or Funktoren) der
         *ableitbaren rulen abstored */
    void CheckForRule( class Fixpoint *fixpoint);
     /** returns the data of a literals nicely colored auf der console from */
    void test();
     /** ist eine verkuerzte Fassung of test() */
    void structureTest();
     /** Setzt einige wichige variables. 
      * @param name Name als String
      * @param anz number of parameter
      * @param konst die Konstanten des literals
      */
    void SetHead(char* name,int anz,char** konst);
     /** literal hat ein eigenes add bekommen, because otherwise without JoinProjNode (also eine rule mit only a literal) not gemappt are wuerde*/
     /**F\"ugt eine solution hinzu. */
    virtual Pix add(Tupel item);
     /**wie relation::firstGetAll() aber beim umschalten auf den link, is das gesetzte Patten (SetPattern()) beruecksichtigt*/
    virtual Pix firstGetAll();
     /**siehe firstGetAll()*/
    virtual void nextGetAll(Pix&);
     /* setzt die Konstanten of a literals. Diese are beim returnliefern der Lsgen beruecksichtigt*/
//    void SetKonstanten(char** blub) {konstanten=blub;};
    virtual Tupel& operator () (Pix);
     /**kopier das delta in ein TUPELSET*/
    virtual void GetDelta(TUPELSET&);
     /**kopiert das delta in ein TUPELBAG*/
    virtual void GetDelta(TUPELBAG&);
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta();        
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta();
     /**zeigt auf ein Adot, if man selbst ein Adot\_Label ist*/
    AlgDescription *AdotLink;
     /**Ist gesetzt, if obiger AdotLink auf den own fixpoint zeigt*/
    int AdotLinkZeigtAufEigenenFixpoint;
     /**Adots nehmen also solutions of Adot\_Label!*/
    void AdotAusnahmeBehandeln();
     /**traegt die eigenen data in DataCollector ein*/
    virtual void CollectData(DataCollector*);
     /**returns the literal-head return*/
    C_Functor& Functor() {return functor;};
     /**@see relation::query(tuple tupel,TUPELBAG& ergebnis)*/
    int query(Tupel t,TUPELBAG &bag){Relation::query(t,bag);};
};

/// internes literal
class BuiltinLiteral : public Literal
{
public:
    BuiltinLiteral(int tupel_size, int key, char t1=0,char t2=0,char t3=0,char t4=0,char t5=0,char t6=0,char t7=0,char t8=0,char t9=0,char t10=0)
            : Literal(tupel_size,key,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10) {};  
     /** ist identisch mit dem relation::add() */
    virtual Pix add(Tupel item);
    virtual Pix firstGetAll();
    virtual void nextGetAll(Pix&);
     /**@see literal::GetDelta(TUPELSET&)*/
    virtual void GetDelta(TUPELSET& d) {Literal::GetDelta(d);};
     /**@see literal::GetDelta(TUPELBAG&)*/
    virtual void GetDelta(TUPELBAG& d) {Literal::GetDelta(d);};
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta() {Literal::RestoreDelta();};        
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta() {Literal::RemoveDelta();};
     /**@see literal::query(tuple t,TUEPLBAG &bag)*/
    int query(Tupel t,TUPELBAG &bag){Literal::query(t,bag);};
};

    


/// General algebra node im derivation tree
class AlgebraNode : public Relation
{
};

/** node im derivation tree. \\
 *Wird from a join berechnet. 
 *Hat only symbolischen Charakter, um den Vererbungsbaum aufzubauen.
 */
class JoinNode : public AlgebraNode
{
    Relation *rel1, *rel2;
    JoinCondition *jc;
    
public:
    JoinNode(Relation *nrel1, Relation *nrel2, JoinCondition *njc) :
            AlgebraNode(), rel1(nrel1), rel2(nrel2), jc(njc) { not_calculated=1; }
    
    Relation& Rel1() { return *rel1; }
    Relation& Rel2() { return *rel2; }
        /// Gives die evaluation rule or the result auf stdout from
    void test();
     /** die verkuerzte fassung of test()*/
    void structureTest() {};
        /// Rechnet the relation entspechend der join condition from
    int calc();
        /// Checks die beiden Teil-relations auf Abh\"angigkeit
    void CheckForRule( class Fixpoint *fixpoint );
};

/** node im derivation tree. 
 * So etwas kommt in der Praxis not vor, da always ein JoinProj rauskommt.
 */
class ProjNode : public AlgebraNode
{
    Relation *rel;
    AttrList *al;
public:
    ProjNode(Relation *nrel, AttrList *nal) :
            AlgebraNode(), rel(nrel), al(nal) { not_calculated = 1; }
    Relation& Rel() { return *rel; }
    void test();
    int calc();
    void CheckForRule( class Fixpoint *fixpoint );
};

/**
 *node im derivation tree. 
 *Wird from of a join/Projektions-Kombination berechnet.\\
 *In der current version is this structure only durch einen DataCollector ausgelesen and die Berechnung auf this basis in der AlgDescription partially ausgef\"uhrt.
 *@see DataCollector, AlgDescription::join_proj, AlgDescription::start_join_proj
*/
class JoinProjNode : public AlgebraNode
{
    Relation *rel1;
    Relation *rel2;
    JoinCondition *jc;
    AttrList *al;
    TUPELBAG *bag;
    TUPELBAG *deltabag;

    Relation *Litlist;
    JoinCondition *Condlist;
    AttrList *Attrlist;    
    
public:
    JoinProjNode(Relation *nrel1, Relation *nrel2, JoinCondition *njc, AttrList *nal) :
            AlgebraNode(), rel1(nrel1), rel2(nrel2), jc(njc), al(nal) { not_calculated=1; }
    
    Relation& Rel1() { return *rel1; }
    Relation& Rel2() { return *rel2; }
     /** Gives die evaluation rule or the result auf stdout from*/
    void test();
     /** die verkuerzte fassung of test()*/
    void structureTest();
     /**rechnet los...*/
    int calc();
    void CheckForRule( class Fixpoint *fixpoint );
        //die Berechnung (bei Beruecksichtigung der Deltas mehrere Durchlaeufe) can so of
        //aussen (last JoinProjNode) gestoppt are
        ///hat only intere Bedeutung
    int weiter;
    virtual int TakeTokenFrom(Relation*);
     /**schaltet, if possible, auf TupelBag um. so that are duplicate Lsg in Kauf used, aber bei grossen lsg-mengen eine viel hoeher geschwindigkeit erzielt*/
    void AufBagUmschalten();
     /** leitet auf eigene relation or auf Bag um...*/
    virtual Pix add(Tupel);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual int           contains(Tupel);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual void          clear(); 
     /** leitet auf eigene relation or auf Bag um...*/
    virtual Pix           first();
     /** leitet auf eigene relation or auf Bag um...*/
    virtual void          next(Pix&);          
     /** leitet auf eigene relation or auf Bag um...*/
    virtual Pix           firstGetAll();
     /** leitet auf eigene relation or auf Bag um...*/
    virtual void          nextGetAll(Pix&);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual Tupel&        operator () (Pix);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual void          operator |=(TUPELSET&);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual int           owns(Pix);
     /** leitet auf eigene relation or auf Bag um...*/
    virtual int           length();
     /** leitet auf eigene relation or auf Bag um...*/
    virtual void          GetDelta(TUPELSET&);
    virtual void          GetDelta(TUPELBAG&);
    virtual void RestoreDelta();
    virtual void RemoveDelta();
    int GenerateOnTheFlyParms();
    virtual void CollectData(DataCollector*);
};

/**F\"ugt Konstanten zu of a solution hinzu.
 * Simplecross dient dem verknuepfen of literalen and konstanten zu of a lsg.
 * Die Konstanten are alle hinten angeh\"angt and durch die Mapping-information der Rules an die richtige Stellen gemappt.
 */
class SIMPLECROSS : public AlgebraNode
{
public:
     ///die betreffende relation
    Relation* rel;   
     ///number of Konstanten
    int laenge;
     ///ein Array of Strings (Konstanten)
    TupelElement **konstanten;
     ///creates ein Simplecross zu of a relation
    SIMPLECROSS(Relation*);
     ///verknuepft alle Lsg of rel and speichert die neuen Lsg in sich selbst
    int calc();
     ///wie calc(), only are die Lsg in \"ubergebener relation stored
    int calc(Relation&);
     ///gives alle data auf der console from
    void test();
     ///kurze version of test()
    void structureTest();
     ///f\"ugt eine constant hinzu
    void addKonst(TupelElement*);
    void CheckForRule( class Fixpoint *fixpoint );
     //siehe relation::RestoreDelta()
    virtual void RestoreDelta();
    //siehe relation::RemoveDelta()
    virtual void RemoveDelta();
     ///returns the delta der relation zur\"ueck
    virtual void GetDelta(TUPELSET&);
     ///returns the delta der relation zur\"ueck
    virtual void GetDelta(TUPELBAG&);
     ///collects information about sich and the relation
    virtual void CollectData(DataCollector*);
};


/** Beschreibt einen algebra expression. Besteht from rule head, -body and ggf -ergebnis.\\
 * Eine rule contains eine relation (body). Diese can entweder ein JoinProjNode sein or
 * ein literal (or abgeleitet BuitlinLiterals...). \\ 
 * Im ersten Fall can der JoinProjNode again einen JoinProNode enthalten. Damit can beliebig
 * (naja, fast beliebig) lange Terme built are. \\
 * Unabhaengig of der Art des Bodies can still ein Simplecross dazwischengeschoben sein. \\
 * rule --body--> SimpleCross ---rel--> JoinProjNode (or literal) \\
 * Es can rulen mit dem same Namen geben. Diese are then in CheckForRule() durch ihre 
 * Links (siehe AlgDescription *link) zu a Kreis verbunden. \\
 * Werden then solutions abgefragt (siehe first(),next(),operator()), fragt the rule also bei
 * allen gelinkten rulen nach and returns their solutions mit return, if the constant pattern
 * kompatibel is (siehe match(...))
 * Bevor man solutions of of a rule abfragt, sollte man mit SetPattern() angeben, welche tuple man
 * haben will. example:\\
 *   Adot(id\_1234,\_,\_,id\_999) :- dummy(\_,\_,\_,id\_999)\\
 *   Adot(\_,\_,\_,id\_999) :- dummy(\_,\_,\_,id\_999)\\
 * If rule1 is now queried for its solutions, then returns also solutions of rule2 mit. However
 * must sie before mit match \"uberpr\"ufen, ob der first parameter also id\_1234 is.
 * If a literal Adot(id\_666,\_,\_,\_) solutions wants to return. If it has a link to rule2, 
 * must aber before unbedingt rule2->SetPattern() aufrufen, so that rule2 no solutions der rule1 mitliefert!\\ \\
 * Das Ausrechnen of a rule can auf 2 Arten geschehen. Die currently uses. possibility ist about join\_proj\_start
 * das join\_proj anzustossen. Dabei is die first relation ausgerechnet and this is then solution for solution durch
 * join\_proj mit allen anderen joined. Damit das funktioniert, must before ein DataCollector built worden sein.\\
 * Die zweite possibility w\"are JoinProjNode::calc() auszuf\"uhren. Dabei is
 * pairwise joined. Same result, aber es entstehen larger intermediate results.
  */
class AlgDescription : public JoinCondition
{
     /** Der head der rule (als BIM-Prolog structure).
      * Muss still gecastet are: (BP\_Term)head 
      */
    long unsigned int head;
     /**Der head der rule (als C structure)*/
    C_Functor functor;
        /**Der body der rule.\\
         * Der body can from of a Kette of relations bestehen, 
         * if the of relation abstammende Class AlgebraNode uses is. 
         */
    Relation *body;
     /**Ist ein pointer auf die Rule, deren solutions geliefert are.
        @see first(),next(Pix),operator()(Pix)
      */
    AlgDescription *alg;
/*    
      char **konstanten;
      int arity;
*/

     /**@see SetPattern(int,char**)*/
    int PatternArity;
     /**@see SetPattern(int,char**)*/
    char **PatternKonstanten;
     /**Soll PatternArity and PatternKonstanten mal ersetzen*/
    C_Functor *Pattern;
    
     ///Enth\"alt data about die ganze Rule
    DataCollector *jdc;
    
     /**rule contains no eigenen solutions.
        Ist gesetzt, if the AlgDescription only eine Relation without eigene Lsg(OwnSolutions) hat.\\
      * Wird in operator()(Pix) uses. um zu entscheiden, ob still gemappt are must.\\
      * @see operator() 
     */
    int KeineLsg;
   
public:
    int ok;
    
     /**Ist ein pointer aufs delta the rule*/
    TUPELSET* globDelta;   
     /**Rules mit gleichem head sind zu a Kreis gelinkt.
        @see Erlaeuterungen (Links)
      */
    AlgDescription *link;
     /**Pointer auf die AlgDescription die die solutions this AlgDescription speichert.
        @see Erlaeuterungen
      */
    AlgDescription *solutions;
     /**St\"osst CheckForRule() im body an*/
    void CheckForRule(class Fixpoint *fixpoint);
     /**Schreibt die data the rule auf die console.*/
    void test();
     /**Wie test(), only less.*/
    void structureTest();
     /**Constructor creates eine empty AlgDecsription.*/
    AlgDescription(int n) : JoinCondition(n),body(NULL) {}
     /**Setzt den head the rule.*/
    void SetHead(char*,int,char**);
     /**Setzt den head als Bim-structure (before casten)*/
    void SetHead(long unsigned int);
     /**Setzt den body.*/
    void SetBody(Relation*);
     /**Returns die BIM-structure des Kopfes return.*/
    long unsigned int GetHead();
     /**Returns an pointer auf den body return.*/
    Relation* GetBody();
     /**Returns den head the rule als C\_Functor zur\"ueck.*/
    C_Functor& Functor();
/*  
    void Map();
*/
     /**Returns die first solution the rule.\\
      * Dabei are also die Lsg der gelinken Rules mitgeliefert.
      */
    Pix first();
     /**Returns die next Lsg, or NULL, if es no more gives.\\
        Dabei are also die Lsg der gelinken Rules mitgeliefert.
      */
    void next(Pix&);
     /**Returns das tuple zu a Pix.*/
    Tupel& operator () (Pix);
     /**Kopiert alle tuple from y nach sich selbst.
      *@param y Source-TUPELSET
      */
    void operator |=(TUPELSET& y);
     /**l\"oscht alle tuple des Bodies.*/
    void clear();
     /**tuple enthalten?*/
    int contains(Tupel);
     /**Pix enthalten?*/
    int owns(Pix);
     /**Returns die tuple-L\"ange.*/
    int GetSize();
     /**Returns die Abzahl der stored solutions.*/
    int length();
     /**Ermittelt die number an neuen solutions inklusive der gelinkten.\\
      * Die number ist not always richtig and should only als Indikator dienen.
      */
    int NewSolutions();
     /**Vergleicht konstanten2/arity3 mit eigenem Functor
      *Passt das eigene Tupelmuster zu the \"ubergeben? 
      *@param arity2 Stelligkeit des Mustertupels
      *@param konstanten2 die Konstanten des Mustertupels
      *@return true, if alle Konstanten entweder gleich are, or eins of beiden frei(NULL) ist
      */
    int match(int arity2,char** konstanten2);
     /**Vergleicht the \"ubergebene Tupelmuster mit dem tuple.
      *@param arity2 Stelligkeit des Mustertupels
      *@param konstanten2 die Konstanten des Mustertupels
      *@param tupel so that is arity2 and konstanten2 verglichen
      *@return true, if alle Konstanten des Tupels entweder gleich der jeweiligen Elemente of konstanten2 are, or eins of beiden frei(NULL) ist
      */
    int match(int arity2, char** konstanten2, Tupel &tupel);
     /**Passt der Functor zu dem tuple?\\
      * Diese Function ist besonders schnell, da sie Stringvergleiche minimiert.
      *@param Func der to \"uberpr\"ufende Functor
      *@param tupel so that is Func verglichen
      *@return true, if alle Konstanten of Func entweder gleich der Konstanten of GetFunctor() are, or eins of beiden frei(NULL) ist
      */
    int match(C_Functor& Func,Tupel& tupel);
     /**f\"ugt eine solution hinzu.\\ 
      * Ausserdem is still das delta aktualisiert.
      */
    Pix add(Tupel);
     /**L\"oscht das delta des Bodies*/
    void deltaclear();
     /**mappt ein tuple auf den head the rule*/
    Tupel map(Tupel);
     /**wie oben, only anderer R\"uckgabetyp*/
    Tupel& map2(Tupel);    
/*
    Tupel mapNegativ(Tupel);    
*/
     /**St\"osst Berechnung an.
      */
    int calc();
     /**Ist the body already berechnet?*/
    int IsCalculated() {return GetBody()->IsCalculated();}
/*
    Pix add_mapping(Tupel tupel);
*/
     /**Setzt das Muster mit dem solutions \"ubereinstimmen m\"ussen,
      * die returngeliefert are.
      * @param arity2 Stelligkeit des Tupels
      * @param konstanten die Konstanten den Tupels (NULL=>frei)
      */
    void SetPattern(int arity2,char** konstanten2);
     /**Creates a String from dem Rule-head*/
    char* GetHeadline();
     /**Returns das delta des Bodies and der gelinkten Rules*/
    void GetDelta(TUPELSET&);
     /**Wie oben only anderer Container*/
    void GetDelta(TUPELBAG&);
     /**Enth\"alt die Rule ein AdotLabel?*/
    int isAdotLabel;
     /**Ermittelt, ob eine new Berechnung also new solutions bringen w\"urde*/
    int LohntBerechnung();
     /**Partielle Berechnung der JoinProjektion. 
      * @param ergebnis relation for die solutions
      * @param MainTupel dieses tuple is mit of a relation joined
      * @param jdc der object, that die data for den join contains
      * @param pos Nummer der relation im jdc, mit dem MainTupel gejoinr are should
      */
    int join_proj(Relation &ergebnis,Tupel MainTupel,DataCollector* jdc,int pos);
     /**st\"osst join\_proj an.
      *@see join_proj(relation &ergebnis,tuple MainTupel,DataCollector* jdc,int pos)
      */
    int start_join_proj();
};

   

/** Ein node in der fixpoint list.\\
  Jeder node zeigt auf einen completen algebra expression. 
  @see AlgDescription
*/
class FixpointNode
{
        /// der konkrete algebra expression
    AlgDescription *ad;
        /// die next algebra.\\ (es gives no Ende der list, d.h. the list ist ein Kreis)
    FixpointNode *next;

public:
        /** constructor.\\
          Creates a neuen fixpoint node mit
          @param nad algebra expression
          @param nnext neues listnende
          */
    FixpointNode(AlgDescription* nad,class FixpointNode *nnext)
            :ad(nad),next(nnext) {}
        /// \overwrites the end der list
    FixpointNode*& Next() { return next; };
        /// returns the functor der zugeh\"orgen rule
    C_Functor GetFunctor();
        /// returns the body der zugeh\"orgen rule
    Relation *GetBody();
        /** Checks the rule auf dependencies of anderen rulen.\\
          In der Class Fixpoint sind the rulek"opfe (bzw. Funktoren) der
          ableitbaren rulen abstored */
    void CheckForRule(class Fixpoint* fixpoint);
     ///returns a pointer auf die Rule return
    AlgDescription* GetAlgDescr() { return ad; };
};


/** Eine list of algebra-Ausd\"ucken. Sie beschreibt eine Fixpunkt-Iteration.
 * Die list ist actually eine Kette and zwar eine im Kreis gelinkte.
 * Die rulen are einfach so lange im Kreis ausgewertet, bis no more new
 * solutions geliefert hat.
 */
class Fixpoint
{
     /// die actual list
    FixpointNode *start,*fpn;
    Fixpoint *next;
     ///ein pointer auf stratification. Wird needed, um queries mit GetAlgDescr(...) an die stratification forward zu can
    class stratified_rules *stratified;
    
public:
     ///ist false, if the fixpoint einen ung\"ultige FixpointNode contains (NULL)
    int ok;
     /// initializes the list auf NULL
    Fixpoint() : fpn(NULL),stratified(NULL),ok(1) {};
    Fixpoint*& Next() { return next; };    

        /// f\"ugt ein neues Element in the list ein
    void add(AlgDescription* ad);
        /** returns the first rule (AlgDescription) for den gegebenen functor or NULL, if es
          no matching rule gibt\\
          Dies is in particular uses um in CheckRules die dependencies zu berechnen.*/
    AlgDescription *GetAlgDescr(C_Functor &functor);
     /**Search first in allen anderen fixpoint nach dem Functor, then erst im eigenen. This is necessary, to link AlgDescriptions meaningfully */
    AlgDescription *GetAlgDescrReverse(C_Functor &functor);
     ///Searches only im own fixpoint nach Rules die dem Functor entsprechen and returns a pointer auf sie or NULL return.
    AlgDescription *GetAlgDescr_WO_advancedCheck(C_Functor&);
     /** Checks alle in der fixpoint-evaluation rule enthaltenen rulen auf
         dependencies of anderen rulen. */
    void CheckRules(stratified_rules*);
     ///nochmal die alte version, als es still no stratification gab.
    void CheckRules();
     ///gives alle data auf der console from
    void test();
     ///Kurzform of test()
    void structureTest();
     ///st\"osst die Berechnung an
    void calc();
     ///setzt this Werte in der ersten Rule, da aber static, ist es for alle relations
    void Set(class TDB*,TIMEPOINT,int,TOID);
    FixpointNode* Start() { return start; };  
     /**Durchsucht den fixpoint nach of a Rule. Wird uses. um in literal::CheckForRule() die variable (Adot)LinkZeigtAufEigenenFixpoint setzen zu can
      *@see Erlaeuterungen (Deltas)
      */
    int ContainsAlgDescr(AlgDescription*);
     /**st\"osst Wiederherstellung der Deltas in the relations an
      * @see Erlaeuterungen  
      */
    void RestoreDeltas();
     ///Macht RestoreDeltas r\"uckg\"angig
    void RemoveDeltas();
};

/**Stratifiezierte Fixpunkte. Enth\"alt alle Fixpoints in der Reihenfolge, wie sie also berechnet are m\"ussen. 
 */
class stratified_rules
{
    Fixpoint *start,*fp;
    
public:
     ///ist false, if the stratification einen ung\"ultige fixpoint contains (NULL)
    int ok;
     ///initializes stratification mit NULL
    stratified_rules() : fp(NULL),ok(1) {};

     ///f\"ugt einen fixpoint hinzu
    void add(Fixpoint* fix);
     ///gives alle data auf console from
    void test();
     ///kurze Fassung of test()
    void structureTest();
     ///st\"osst Berechnung an
    void calc();
    Fixpoint* Start() { return start; };
     ///st\"osst CheckRules() for alle Fixpoints an
    void CheckRules();
     ///sucht in allen Fixpoints ausser im \"ubergebenen (this) nach dem functor
    AlgDescription* GetAlgDescr(C_Functor&,Fixpoint*);
     ///returns the first rule des letzten Fixpoints return. Das ist die, die die solutions contains.
    AlgDescription* GetMainRule();
};

/**
 *Enth\"alt weiterf\"uhrende Erkl\"arungen zum Code.
 *
 *AdotAnormalie: 
 *
 *Alle Rules, die den same Functor haben, are zu a Kreis gelinkt. Eine Ausnahme bilden AdotLabel-Literale. \\
 *Diese are trotz unterschiedlichen Functoren bei Adot-Literalen mit ber\"ucksichtigt. 
 *Da ein direktes Einbilden in the Kreis zu sehr vielen Problemen f\"uhrt, is dieses Problem nachtr\"aglich in AlgeDescription::calc gel\"ost. 
 *Weiterhin is in literal::firstGetAll die AdotAusnahme behandelt. Zu diesem Zweck existieren still AdotLink and AdotLinkZeigtNichtAufEigenenFixpoint.\\
 *siehe (literal::AdotAusnahmeBehandeln)
 *
 *
 *Deltas:
 *
 *Die Deltas are for jede relation getrennt stored. Etwas komplizierter ist es mit den Rules (AlgDescription). 
 *Here is only ein delta pro Kreis stored. Wo das ist and wo die solutions hinkommen, is beim ersten AlgDescription::add entschieden. 
 *Bei jeder Berechnung entfernt jede Rule from den Deltas diejenigen solutions, die es eine Runde before hineingetan hat.\\
 *siehe AlgDescription::calc
 *Ein weiter Besonderheit entsteht durch Links, die not auf den own fixpoint zeigen. Dessen Deltas sind nach Bearbeitung dieses Fixpoints always leer.
 *F\"ur den current fixpoint sind es jedoch new solutions. Deshalb is in diesem Falle RestoreDeltas aufgerufen (stratified\_rules::calc). 
 *After the first use of the delta these solutions are removed again by RemoveDeltas (fixpoint::calc). \\
 *siehe fixpoint::RestoreDeltas, fixpoint::RemoveDeltas
 *
 *Tokens:
 *
 *Beim Berechnen einen joins are, if m\"oglich only die Deltas uses. Das geht aber in jedem join only always mit of a relation. 
 *Welche das ist bestimmt der token, der so of Berechnung zu Brerechnung durch den join wandert (JoinProjNode::TakeTokenFrom, relation::TakeTokenFrom).
 *(AlgDescription::start\_join\_proj)
 *
 *
 *Rule-Verknuepfung (link):
 *
 *Rules (AlgDescription) mit dem same Functor, are durch link zu a Kreis verbunden. Sie teilen sich ein delta (globDelta) and ihre solutions (solutions).
 *
 *(Adot)LinkZeigtAufEigenenFixpoint:
 *
 *Diese variables sind dazu da zu bestimmen, ob ein Restore or RemoveDelta noetig is, or not.\\
 *siehe first,next,operator()
 *
 *Es can zu St\"orungen kommen, if man eine relation abfragt and mittendrin (vielleicht about einen link) again ein first or next auf sie executes, 
 *because for jede relation only ein iterator gefuehrt is. 
 *Wenn das passieren k\"onnte, die solutions before unbedingt in a set (or bag) zwischenspeichern and then dessen solutions druchlaufen.
*/
class Erlaeuterungen
{};


#endif
