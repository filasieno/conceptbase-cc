/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
//@Include:startAlg.h

#ifndef ALGEBRA_H
#define ALGEBRA_H

#include "Tupel.h"
#include "Tupel.STLSet.h"
#include "Tupel.STLBag.h"
#include <string.h>
#include "C_Functor.h"

/**das ist die Standart-Tupelmenge. 
  *Intern ist sie als HashTabelle (TupelSTLSet) aufgebaut.
  */
#define TUPELSET TupelSTLSet

/**Container fuer Tupel. Der Bag wird genommen, wenn man ein schnelleres    *"Set" haben will. Hier koennen doppelte L\"osungen in Kauf 
  *genommen werden.
  */
#define TUPELBAG TupelSTLBag

/** Klasse fuer eine select-Bedingung*/
class Condition : public Tupel
{
public:
        /** Der Konstruktor erzeugt eine leere Bedingung.
         *  @param c Die Bedingung ist ein c-Tupel */
    Condition(char c) 
            : Tupel(c) 
    {}
        /** Der Konstruktor erzeugt eine neue Selectbedingung*/ 
    Condition(const TupelElement& el1= TUPEL_UNDEF,
              const TupelElement& el2= TUPEL_UNDEF,
              const TupelElement& el3= TUPEL_UNDEF)
            :Tupel(el1,el2,el3) 
    {}
    
};

/** Klasse fuer eine Join-Bedingung */
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
     /** Fuegt JoinBedingung a=b ein.
      * @param a Attribut aus der ersten Relation
      * @param b Attribut aus der zweiten Relation
      */
    int add(int a,int b);
     /**Liefert eine JoinBedingung zur\"uck
      * @param cn Nummer der Joinbedingung
      * @param pos 0 fuer die linke Seite, 1 fuer die rechte Seite
      */
    int get(int cn,int pos);
     /**liefert die Anzahl der gespeicherten JoinBedingungen*/
    int length()
    {
        return anz;
    }
     /**liefert die Laenge des Tupels nach dem join (ohne Projektion) zurueck 
       * @param l1 Laenge der ersten Relation des Joins
         @param l2 Laenge der zweiten Relation des Joins
       */
    int result_length(int l1=0,int l2=0);
     /**liefert true, wenn das angegebene Attribut nach dem Join noch da ist; false, wenn sich eine join-condition auf das attribut bezieht 
      * @param f2 bezeichet die Position eines Attributes in der zweiten Relation eines Joins.
      */
    int result_contains(int f2);
    
};


/**Das ist ein "DatenSammelObjekt". Es wird durch die Struktur des Ausdrucks gereicht und jeder tr\"agt etwas ein. 
   Auf dieser Grundlage arbeitet der partielle join in AlgDescription.
   @see AlgDescription::join_proj,AlgDescription::start_join_proj
 */
class DataCollector
{    
     /**Datenstruktur f\"ur die Literale*/
    class Relation **LITs;
     /**Datenstruktur f\"ur die JoinConditions*/
    JoinCondition **JCs;
     /**Datenstruktur f\"ur die AttributeListen*/
    AttrList **ALs;
     /**Datenstruktur f\"ur die Links*/
    class AlgDescription **LINKs;
     /**Datenstruktur f\"ur die Simplecrosses*/
    class SIMPLECROSS **SCs;

public:
     /**erzeugt einen leeren DataCollector*/
    DataCollector() 
    {
        LITs=NULL;
        JCs=NULL;
        ALs=NULL;
        LINKs=NULL;
        SCs=NULL;
    };
     /**Speichert ein Datum.
      * Zum Beispiel: datacollector.saveData(datacollector.Literals(),MyLiteral)
      * @param where ein Zeiger auf eine Datenstruktur (siehe oben)
      * @param what ein Zeiger auf das, was gespeichert werden soll
      */
    void saveData(void*** where,void* what);
     /**Gibt die Daten auf Console aus. 
      * @param pos gibt an, ab welcher Pos begonnen werden soll
      */
    void print(int pos);
    void test(){print(0);};
     /**Sind Links gespeichert?
        @see AlgDescription::LohntBerechnung
      */
    int HasGotLinks();
     /**Ist ein Simplecross gespeichert?
        @see AlgDescription::join_proj
      */
    int HasGotSimpleCross();
     /**Liefert ein Datum zur\"uck.
       *zum Beispiel: MyLiteral=datacollecotor.getNrOf(datacollector.Literals(),0)
       * @param whatever Zeiger auf eine Datenstruktur
       * @param nr Position des gesuchten in der Liste der Datenstruktur
       */
    void* DataCollector::getNrOf(void*** whatever,int nr);
     /**liefert eine Zeiger auf die Datenstruktur der Literale zur\"uck.
        Wird getNrOf oder saveData als erster Parameter \"ubergeben
      */
    void*** Literals(){return (void***)(&LITs);};
     ///siehe Literals()
    void*** AttrLists(){return (void***)(&ALs);};
     ///siehe Literals()
    void*** JoinConditions(){return (void***)(&JCs);};
     ///siehe Literals()
    void*** Links(){return (void***)(&LINKs);};
     ///siehe Literals()
    void*** SimpleCross(){return (void***)(&SCs);};
};


/**Fortschrittsbalken.
 *Kleines Hilfsobjekt zur Darstellung von Fortschrittbalken auf der Console.
 *  
 * sieht so aus: \#\#\#\#\#\#======(30/60)
 */
class ProgressView
{
    int zaehler,max,divisor;
public:
     /** Constructor erzeugt ein neues Object
      * @param i Anzahl der Schritte
      * @param a Laenge des Balkens in character
      */
    ProgressView(int i,int a);
    ~ProgressView();
     /**anz Schritte weiter gehen
      * @param anz Anzahl der Schritte
      */
    void step(int anz);
     /**Zeichnet sich auf die Console. Nach dem Zeichnen steht der Cursor wieder am Anfang der selben Zeile!
      */
    void draw();
};

    
/** Klasse fuer eine Relation (Algebra)*/
class Relation : public TUPELSET
{
     /** Stelligkeit der Relation */
    char tupel_size;
     /* Typen der Relation */
    char *types;
    
     /**die Belegung der Tupel. Jedes Argument wird durch ein Bit codiert. Ist es gesetzt, dann ist die Variable frei */
    int Belegung;
    
public:
     /**gibt an, ob beim Zurueckliefern von L\"osungen mit firstGetAll,nextGetAll und operator []
      * nur die lokalen oder die gelinkten lsg ger\"uckgegeben werden.
      *
      * Sollte von aussen nur gelesen werden!
      */
    int lokal;
     /**Falls eine Relation den Token besitzt, kann sie mit ihren deltas rechnen,
      * andernfalls werden alle L\"osungen mit einbezogen.
      * Der Token wird bei einer Kette von Literalen (Join)
      * von Relation zu Relation weitergegeben.
      * @see JoinProjNode::TakeTokenFrom(Relation* relation)
      * @see Erlaeuterungen
      */
    class JoinProjNode *Token;
     /**Ist in Relation unsinnig (Platzhalter), wird erst ab JoinProjNode benutzt.
       * @see JoinProjNode::RepeatCalc
      */
    int RepeatCalc;
    
     /**Das Delta einer Relation. 
      * Es enth\"alt alle L\"osungen, die bei der letzten Berechnung neu hingekommen sind.
      */
    TUPELSET delta;
    
     /** Gibt an, ob ein gesetzter Link (link!=NULL) auf eine Relation innerhalb des eigenen Fixpointes zeigt oder nicht. 
      * Dieses Flag bestimmt insbesondere, ob link->RestoreDelta() vor der Benutzung der Daten des Links aufgerufen werden muss
      * @see AlgDescription::RestoreDeltas()
      */
    int LinkZeigtAufEigenenFixpoint;
     /** Link zu einer Rule (AlgDescription).
      *  Eine Relation kann sowohl eigene, als auch gelinkte L\"osungen haben. 
      *  Ist link==NULL, hat sie nur eigene L\"osungen und OwnSolution muss TRUE sein
      * @see Erlaeuterungen
      */
    class AlgDescription *link;    
    char key;
     /**Gibt an ob eine Relation ausgerechnet ist oder nicht */
    char not_calculated:1;
     /** Dieser Zeiger auf eine Rule gibt an, wo die Lsg gespeichert werden.
      *  Falls es die "oberste" Relation ist, zeigt er immer auf die Rule, 
      *  in welcher die Relation definiert ist und die AlgDescription entscheidet 
      *  dann, wo sie L\"osungen hinkommen. 
      *  Falls es eine Relation in z.B. einer JoinProj ist, dann ist solutions==NULL 
      *  Das bedeutet dann, dass die L\"osungen in sich selber gespeichert werden.
      *  @see AlgDescription::add(Tupel)
      */
    class AlgDescription *solutions;
     /**gibt an, ob eine Relation eigene Lsg hat. Falls nein, ist ihr link!=NULL! */
    char OwnSolutions:1;
    
     /**statischer Link zur Datenbank */
    static class TDB *database;
     /**statische Variable enthaelt den Zeitpunkt der Erzeugung*/
    static TIMEPOINT timepoint;
     /**statische Variable enthaelt den aktuellen Suchraum*/
    static int searchspace;
     /**statische Variable enthaelt das Modul in dem die Relation steht*/
    static TOID module;
     /**das ist eine Entwicklervariable, um Ausgaben zu kontrollieren...*/
    static int zumuelln;
     /**Ist eine Relation negiert, dann wird das im Falle eines Joins beachtet */
    int negation;    
    
     /**erzeugt eine leere Relation (Definition in Algebra.h) */
    Relation() 
            : TUPELSET(), tupel_size(0), types(NULL),Belegung(0), link(NULL), key(0),
              not_calculated(1), solutions(NULL), OwnSolutions(1), negation(0)
    { Token=NULL;isAdotLabel=0;}
     /**erzeugt eine leere Relation
      * es koennen bis zu 10 verschiedene Typen fuer die TupelElemente angegeben werden (alle weiteren sind "free")  
      * @param new_size laenge der Tupel, die gespeichert werden sollen
      * @param new_key  key
     */
    Relation(char new_size,char new_key, char=0,char=0,char=0,char=0,
             char=0,char=0,char=0,char=0,char=0,char=0);
    
    ~Relation(){};
     /**setzt einige Parameter der Relation
      * @param db die Datenbank, auf die sich die Berechnungen beziehen sollen
      * @param point den Zeitpunkt
      * @param set den Searchspace
      * @param module das zugehoerige Modul
      *
      * Alles static!!!!
     */
    void Set(class TDB* db,TIMEPOINT point,int set,TOID module);
     /**Fuegt ein Tupel (eine Berechnung) hinzu. 
      * Es darf eigentlich nur immer eine Berechnung pro Relation sein */
    int AddCalc(Tupel);
     /**weiss einer, was das fuer ein Key is (wird wohl nirgends benutzt)? */
    int SetKey(int newkey)
    {
        key=newkey;
        return key;
    }
     /**schreibt viele Infos auf die Console (jetzt sogar in Farbe (im Falle eines xterm-color!)) */
    virtual void test();
     /**schreibt eine Kurzausgabe von test auf die Console*/
    virtual void StrukturTest();
     /**Gibt die Belegung der Tupel in dieser Relation zurueck.
        Ist ein Bit gesetzt ist diese Stelle frei.
      */
    int GetBelegung() { return Belegung; };
     /**Gibt true zureck, falls eine Relation berechnet ist.
      * Wenn sie keine L\"osungen hat, wird immer true zur\"uckgegeben.
      * @see not_calculated
      */
    int IsCalculated() { if (OwnSolutions) return !not_calculated; else return 1;}
     /**Liefert die Tupellaenge der Relation.
      * Falls die Relation keine eigenen L\"osungen hat, wird die gelinkte AlgDescription gefragt.
       */
    int GetSize();
     /**Setzt bei Relationen mit eigenen L\"osungen die Tupellaenge*/
    int SetSize(int size) {tupel_size=size;return size;};
     /**setzt bei Realtion mit eigenen Lsg die Belegung*/
    int SetBelegung(int bel) {Belegung=bel;return Belegung;};
     /**Liefert die Anzahl an neuen L\"osungen seit der letzten Berechnung*/
    int NewSolutions();
    
     /**Speichert ein L\"osungstupel.
      * Falls solutions gesetzt ist, werden die L\"osungen in der AlgDescription gespeichert, auf die solutions zeigt. Wenn solution==NULL ist, wird die L\"osung in der eigenen Relation gspeichert.*/
    virtual Pix add(Tupel);
     ///diese Funktion wurde nicht weiterentwickelt
    int select(class Relation &ergebnis, const Condition& cond);
     ///diese Funktion wurde nicht weiterentwickelt
    int proj(class Relation &ergebis, const AttrList& attrlist);
     ///diese Funktion wurde nicht weiterentwickelt
    int unite(class Relation &relation2);
     ///diese Funktion wurde nicht weiterentwickelt
    int diff(class Relation &relation2,int mode);
     ///diese Funktion wurde nicht weiterentwickelt
    int join(class Relation &ergebnis, class Relation &relation2,
             class JoinCondition &jc);
  
     /**das ist eine der beiden lauffaehigen join-proj-Methoden*/
    int join_proj2(class JoinProjNode &ergebnis, class Relation &relation2,
                   class JoinCondition &jc, class AttrList &al);
     /** rechnet eine Relation aus */
    virtual int calc();
     /** rechnet auch aus, aber speichert die Lsg in TUPELBAG 
       * und hinterlaesst die relation voellig unveraendert*/
    virtual int calc(Tupel&,TUPELBAG&,int);
     /**setzt link */
    virtual void set_link(class AlgDescription *nlink) { link = nlink; }
     /** \"Uberpr\"uft die Regel auf Abh\"angigkeiten von anderen Regeln.\\
         In der Klasse Fixpoint sind die Regelk"opfe (bzw. Funktoren) der
         ableitbaren Regeln abgespeichert */
    virtual void CheckForRule( class Fixpoint *fixpoint) {fixpoint=fixpoint;}
     /**tupel enthalten?*/
    int           contains(Tupel  item);
     /**Sucht L\"osungen zu einem Muster.
      * Die Relation wird hierbei nicht veraendert. Insbesondere gilt sie danach nicht als ausgerechnet! 
      * @param tupel enthaelt das Muster, das den L\"osungen entsprechen muss
      * @param ergebnis darin werden die L\"osungen abgespeichert
      */
    int Anfrage(Tupel tupel,TUPELBAG& ergebnis);
     /**leert relation*/
    virtual void clear();
     /**liefert Pix auf erstes Tupel*/
    virtual Pix first();
     /**liefert Pix auf naechstes Tupel (ende falls !Pix)*/
    virtual void next(Pix& i);
     /**wie first, liefert aber auch die gelinkten Lsg. in relation mit eigenen Lsg */
    virtual Pix firstGetAll();
     /**siehe firstgetall*/
    virtual void nextGetAll(Pix&);
     /**liefert tupel zu einem pix*/
    virtual Tupel& operator () (Pix i);
     /**addiert alle tupel aus dem set zu einem anderen*/
    virtual void operator |=(TUPELSET& y);
     /**pix enthalten?*/
    virtual int owns(Pix i);
     /**anzahl der tupel in relation*/
    virtual int length();
     /**loescht das Delta*/
    void deltaclear();
     /**kopiert das Delta in ein TUPELSET*/
    virtual void GetDelta(TUPELSET&);
     /**kopiert das Delta in ein TUPELBAG*/
    virtual void GetDelta(TUPELBAG&);
     /**dieser Token wird beim berechnen von JoinProjNodes benutzt, um effektiv mit dem deltas rechnen zu koennen*/
    virtual int TakeTokenFrom(Relation *relation) {if ((!link) || (!LinkZeigtAufEigenenFixpoint)) return 0;Token=relation->Token;relation->Token=NULL;return 1;};
     /**liefert true, falls beim letzen aufruf von nextGetAll oder firstGetAll lokale lsg geliefert wurden*/
    int SolutionsLocal() {if (!OwnSolutions) return 0; else return lokal;};
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta();
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta();
     /**fuer den Spezialfall, dass Adot\_Label auch Lsg von Adots bekommen*/
    int isAdotLabel;
     /**DataCollector wird zum join benutzt. Joins finden aber erst ab Literal statt*/
    virtual void CollectData(DataCollector* jdc) {if (4==5) jdc=jdc;};
};


/** unbekanntes Literal oder durch Regel definiertes Literal*/
class Literal : public Relation
{
     /** Kopf des Literals*/
    C_Functor functor;
     //char **konstanten;
    
public:
     /**Constructor von Literal
      * @param tupel_size Stelligeit des Literals
      * @param key keine ahnung :-/
      * @param t1 typ des ersten Elements
      * @param t2 typ des zweiten Elements
      */
    Literal(int tupel_size, int key, char t1=0,char t2=0,char t3=0,char t4=0,char t5=0,char t6=0,char t7=0,char t8=0,char t9=0,char t10=0)
            : Relation(tupel_size,key,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10){}
     /**Constructor erzeugt ein leeres Literal*/
    Literal():Relation(0,0){}
    
        /** \"Uberpr\"uft die Regel auf Abh\"angigkeiten von anderen Regeln.\\
         *In der Klasse Fixpoint sind die Regelk"opfe (bzw. Funktoren) der
         *ableitbaren Regeln abgespeichert */
    void CheckForRule( class Fixpoint *fixpoint);
     /** gibt die Daten eines Literals schoen farbig auf der Console aus */
    void test();
     /** ist eine verkuerzte Fassung von test() */
    void StrukturTest();
     /** Setzt einige wichige Variablen. 
      * @param name Name als String
      * @param anz Anzahl der Parameter
      * @param konst die Konstanten des Literals
      */
    void SetHead(char* name,int anz,char** konst);
     /** Literal hat ein eigenes add bekommen, weil sonst ohne JoinProjNode (also eine Regel mit nur einem Literal) nicht gemappt werden wuerde*/
     /**F\"ugt eine L\"osung hinzu. */
    virtual Pix add(Tupel item);
     /**wie Relation::firstGetAll() aber beim umschalten auf den link, wird das gesetzte Patten (SetPattern()) beruecksichtigt*/
    virtual Pix firstGetAll();
     /**siehe firstGetAll()*/
    virtual void nextGetAll(Pix&);
     /* setzt die Konstanten eines Literals. Diese werden beim zurueckliefern der Lsgen beruecksichtigt*/
//    void SetKonstanten(char** blub) {konstanten=blub;};
    virtual Tupel& operator () (Pix);
     /**kopier das Delta in ein TUPELSET*/
    virtual void GetDelta(TUPELSET&);
     /**kopiert das Delta in ein TUPELBAG*/
    virtual void GetDelta(TUPELBAG&);
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta();        
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta();
     /**zeigt auf ein Adot, falls man selbst ein Adot\_Label ist*/
    AlgDescription *AdotLink;
     /**Ist gesetzt, wenn obiger AdotLink auf den eigenen Fixpoint zeigt*/
    int AdotLinkZeigtAufEigenenFixpoint;
     /**Adots nehmen auch L\"osungen von Adot\_Label!*/
    void AdotAusnahmeBehandeln();
     /**traegt die eigenen Daten in DataCollector ein*/
    virtual void CollectData(DataCollector*);
     /**liefert den Literal-Kopf zur\"uck*/
    C_Functor& Functor() {return functor;};
     /**@see Relation::Anfrage(Tupel tupel,TUPELBAG& ergebnis)*/
    int Anfrage(Tupel t,TUPELBAG &bag){Relation::Anfrage(t,bag);};
};

/// internes Literal
class BuiltinLiteral : public Literal
{
public:
    BuiltinLiteral(int tupel_size, int key, char t1=0,char t2=0,char t3=0,char t4=0,char t5=0,char t6=0,char t7=0,char t8=0,char t9=0,char t10=0)
            : Literal(tupel_size,key,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10) {};  
     /** ist identisch mit dem Relation::add() */
    virtual Pix add(Tupel item);
    virtual Pix firstGetAll();
    virtual void nextGetAll(Pix&);
     /**@see Literal::GetDelta(TUPELSET&)*/
    virtual void GetDelta(TUPELSET& d) {Literal::GetDelta(d);};
     /**@see Literal::GetDelta(TUPELBAG&)*/
    virtual void GetDelta(TUPELBAG& d) {Literal::GetDelta(d);};
     /**kopiert alle werte der relation erneut ins delta*/
    virtual void RestoreDelta() {Literal::RestoreDelta();};        
     /**macht RestoreDelta rueckgaengig*/
    virtual void RemoveDelta() {Literal::RemoveDelta();};
     /**@see Literal::Anfrage(Tupel t,TUEPLBAG &bag)*/
    int Anfrage(Tupel t,TUPELBAG &bag){Literal::Anfrage(t,bag);};
};

    


/// Allgemeiner Algebra-Knoten im Ableitungsbaum
class AlgebraNode : public Relation
{
};

/** Knoten im Ableitungsbaum. \\
 *Wird aus einem Join berechnet. 
 *Hat nur symbolischen Charakter, um den Vererbungsbaum aufzubauen.
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
        /// Gibt die Rechenvorschrift bzw. das Ergebnis auf stdout aus
    void test();
     /** die verkuerzte fassung von test()*/
    void StrukturTest() {};
        /// Rechnet die Relation entspechend der Join-Bedingung aus
    int calc();
        /// \"Uberpr\"uft die beiden Teil-Relationen auf Abh\"angigkeit
    void CheckForRule( class Fixpoint *fixpoint );
};

/** Knoten im Ableitungsbaum. 
 * So etwas kommt in der Praxis nicht vor, da immer ein JoinProj rauskommt.
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
 *Knoten im Ableitungsbaum. 
 *Wird aus einer Join/Projektions-Kombination berechnet.\\
 *In der aktuellen Version wird diese Struktur nur durch einen DataCollector ausgelesen und die Berechnung auf dieser Grundlage in der AlgDescription partiell ausgef\"uhrt.
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

    Relation *LitListe;
    JoinCondition *CondListe;
    AttrList *AttrListe;    
    
public:
    JoinProjNode(Relation *nrel1, Relation *nrel2, JoinCondition *njc, AttrList *nal) :
            AlgebraNode(), rel1(nrel1), rel2(nrel2), jc(njc), al(nal) { not_calculated=1; }
    
    Relation& Rel1() { return *rel1; }
    Relation& Rel2() { return *rel2; }
     /** Gibt die Rechenvorschrift bzw. das Ergebnis auf stdout aus*/
    void test();
     /** die verkuerzte fassung von test()*/
    void StrukturTest();
     /**rechnet los...*/
    int calc();
    void CheckForRule( class Fixpoint *fixpoint );
        //die Berechnung (bei Beruecksichtigung der Deltas mehrere Durchlaeufe) kann so von
        //aussen (letzte JoinProjNode) gestoppt werden
        ///hat nur intere Bedeutung
    int weiter;
    virtual int TakeTokenFrom(Relation*);
     /**schaltet, wenn moeglich, auf TupelBag um. damit werden doppelte Lsg in Kauf genommen, aber bei grossen lsg-mengen eine viel hoeher geschwindigkeit erzielt*/
    void AufBagUmschalten();
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual Pix add(Tupel);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual int           contains(Tupel);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual void          clear(); 
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual Pix           first();
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual void          next(Pix&);          
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual Pix           firstGetAll();
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual void          nextGetAll(Pix&);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual Tupel&        operator () (Pix);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual void          operator |=(TUPELSET&);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual int           owns(Pix);
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual int           length();
     /** leitet auf eigene Relation oder auf Bag um...*/
    virtual void          GetDelta(TUPELSET&);
    virtual void          GetDelta(TUPELBAG&);
    virtual void RestoreDelta();
    virtual void RemoveDelta();
    int GenerateOnTheFlyParms();
    virtual void CollectData(DataCollector*);
};

/**F\"ugt Konstanten zu einer L\"osung hinzu.
 * Simplecross dient dem verknuepfen von literalen und konstanten zu einer lsg.
 * Die Konstanten werden alle hinten angeh\"angt und durch die Mapping-Informationen der Rules an die richtige Stellen gemappt.
 */
class SIMPLECROSS : public AlgebraNode
{
public:
     ///die betreffende Relation
    Relation* rel;   
     ///Anzahl der Konstanten
    int laenge;
     ///ein Array von Strings (Konstanten)
    TupelElement **konstanten;
     ///erzeugt ein Simplecross zu einer Relation
    SIMPLECROSS(Relation*);
     ///verknuepft alle Lsg von rel und speichert die neuen Lsg in sich selbst
    int calc();
     ///wie calc(), nur werden die Lsg in \"ubergebener Relation gespeichert
    int calc(Relation&);
     ///gibt alle Daten auf der Console aus
    void test();
     ///kurze Version von test()
    void StrukturTest();
     ///f\"ugt eine Konstante hinzu
    void addKonst(TupelElement*);
    void CheckForRule( class Fixpoint *fixpoint );
     //siehe Relation::RestoreDelta()
    virtual void RestoreDelta();
    //siehe Relation::RemoveDelta()
    virtual void RemoveDelta();
     ///liefert das Delta der Relation zur\"ueck
    virtual void GetDelta(TUPELSET&);
     ///liefert das Delta der Relation zur\"ueck
    virtual void GetDelta(TUPELBAG&);
     ///sammelt Informationen \"uber sich und die Relation
    virtual void CollectData(DataCollector*);
};


/** Beschreibt einen Algebra-Ausdruck. Besteht aus Regelkopf, -body und ggf -ergebnis.\\
 * Eine Regel enth\"alt eine Relation (body). Diese kann entweder ein JoinProjNode sein oder
 * ein Literal (bzw. abgeleitet BuitlinLiterals...). \\ 
 * Im ersten Fall kann der JoinProjNode wieder einen JoinProNode enthalten. Damit k\"onnen beliebig
 * (naja, fast beliebig) lange Terme aufgebaut werden. \\
 * Unabhaengig von der Art des Bodies kann noch ein Simplecross dazwischengeschoben sein. \\
 * Regel --body--> SimpleCross ---rel--> JoinProjNode (bzw. Literal) \\
 * Es kann Regeln mit dem gleichen Namen geben. Diese werden dann in CheckForRule() durch ihre 
 * Links (siehe AlgDescription *link) zu einem Kreis verbunden. \\
 * Werden dann L\"osungen abgefragt (siehe first(),next(),operator()), fragt die Regel auch bei
 * allen gelinkten Regeln nach und liefert deren L\"osungen mit zur\"uck, sofern das KonstantenMuster
 * kompatibel ist (siehe match(...))
 * Bevor man L\"osungen von einer Regel abfragt, sollte man mit SetPattern() angeben, welche Tupel man
 * haben will. Beispiel:\\
 *   Adot(id\_1234,\_,\_,id\_999) :- dummy(\_,\_,\_,id\_999)\\
 *   Adot(\_,\_,\_,id\_999) :- dummy(\_,\_,\_,id\_999)\\
 * Fragt man jetzt Regel1 nach ihren L\"osungen, dann liefert sie auch L\"osungen von Regel2 mit. Allerdings
 * muss sie vorher mit match \"uberpr\"ufen, ob der erste Parameter auch id\_1234 ist.
 * Falls ein Literal Adot(id\_666,\_,\_,\_) L\"osungen liefert will. Hat es einen Link auf Regel2, 
 * muss aber vorher unbedingt Regel2->SetPattern() aufrufen, damit Regel2 keine L\"osungen der Regel1 mitliefert!\\ \\
 * Das Ausrechnen einer Regel kann auf 2 Arten geschehen. Die zur Zeit benutzte M\"oglichkeit ist \"uber join\_proj\_start
 * das join\_proj anzustossen. Dabei wird die erste Relation ausgerechnet und diese wird dann L\"osung f\"ur L\"osung durch
 * join\_proj mit allen anderen gejoint. Damit das funktioniert, muss vorher ein DataCollector aufgebaut worden sein.\\
 * Die zweite M\"oglichkeit w\"are JoinProjNode::calc() auszuf\"uhren. Dabei wird
 * paarweise gejoint. Gleiches Ergebnis, aber es entstehen gr\"ossere Zwischenergebnisse.
  */
class AlgDescription : public JoinCondition
{
     /** Der Kopf der Regel (als BIM-Prolog Struktur).
      * Muss noch gecastet werden: (BP\_Term)head 
      */
    long unsigned int head;
     /**Der Kopf der Regel (als C Struktur)*/
    C_Functor functor;
        /**Der Body der Regel.\\
         * Der Body kann aus einer Kette von Relationen bestehen, 
         * wenn die von Relation abstammende Klasse AlgebraNode benutzt wird. 
         */
    Relation *body;
     /**Ist ein Zeiger auf die Rule, deren L\"osungen geliefert werden.
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
     /**Soll PatternArity und PatternKonstanten mal ersetzen*/
    C_Functor *Pattern;
    
     ///Enth\"alt Daten \"uber die ganze Rule
    DataCollector *jdc;
    
     /**Regel enth\"alt keine eigenen L\"osungen.
        Ist gesetzt, wenn die AlgDescription nur eine Relation ohne eigene Lsg(OwnSolutions) hat.\\
      * Wird in operator()(Pix) benutzt, um zu entscheiden, ob noch gemappt werden muss.\\
      * @see operator() 
     */
    int KeineLsg;
   
public:
    int ok;
    
     /**Ist ein Zeiger aufs Delta der Rule*/
    TUPELSET* globDelta;   
     /**Rules mit gleichem Kopf sind zu einem Kreis gelinkt.
        @see Erlaeuterungen (Links)
      */
    AlgDescription *link;
     /**Pointer auf die AlgDescription die die L\"osungen dieser AlgDescription speichert.
        @see Erlaeuterungen
      */
    AlgDescription *solutions;
     /**St\"osst CheckForRule() im Body an*/
    void CheckForRule(class Fixpoint *fixpoint);
     /**Schreibt die Daten der Rule auf die Console.*/
    void test();
     /**Wie test(), nur weniger.*/
    void StrukturTest();
     /**Constructor erzeugt eine leere AlgDecsription.*/
    AlgDescription(int n) : JoinCondition(n),body(NULL) {}
     /**Setzt den Kopf der Rule.*/
    void SetHead(char*,int,char**);
     /**Setzt den Kopf als Bim-Struktur (vorher casten)*/
    void SetHead(long unsigned int);
     /**Setzt den Body.*/
    void SetBody(Relation*);
     /**Liefert die BIM-Struktur des Kopfes zur\"uck.*/
    long unsigned int GetHead();
     /**Liefert einen Zeiger auf den Body zur\"uck.*/
    Relation* GetBody();
     /**Liefert den Kopf der Rule als C\_Functor zur\"ueck.*/
    C_Functor& Functor();
/*  
    void Map();
*/
     /**Liefert die erste L\"osung der Rule.\\
      * Dabei werden auch die Lsg der gelinken Rules mitgeliefert.
      */
    Pix first();
     /**Liefert die naechste Lsg, oder NULL, falls es keine mehr gibt.\\
        Dabei werden auch die Lsg der gelinken Rules mitgeliefert.
      */
    void next(Pix&);
     /**Liefert das Tupel zu einem Pix.*/
    Tupel& operator () (Pix);
     /**Kopiert alle Tupel aus y nach sich selbst.
      *@param y Source-TUPELSET
      */
    void operator |=(TUPELSET& y);
     /**l\"oscht alle Tupel des Bodies.*/
    void clear();
     /**Tupel enthalten?*/
    int contains(Tupel);
     /**Pix enthalten?*/
    int owns(Pix);
     /**Liefert die Tupel-L\"ange.*/
    int GetSize();
     /**Liefert die Abzahl der gespeicherten L\"osungen.*/
    int length();
     /**Ermittelt die Anzahl an neuen L\"osungen inklusive der gelinkten.\\
      * Die Anzahl ist nicht immer richtig und sollte nur als Indikator dienen.
      */
    int NewSolutions();
     /**Vergleicht konstanten2/arity3 mit eigenem Functor
      *Passt das eigene Tupelmuster zu dem \"ubergeben? 
      *@param arity2 Stelligkeit des Mustertupels
      *@param konstanten2 die Konstanten des Mustertupels
      *@return true, falls alle Konstanten entweder gleich sind, oder eins von beiden frei(NULL) ist
      */
    int match(int arity2,char** konstanten2);
     /**Vergleicht das \"ubergebene Tupelmuster mit dem Tupel.
      *@param arity2 Stelligkeit des Mustertupels
      *@param konstanten2 die Konstanten des Mustertupels
      *@param tupel damit wird arity2 und konstanten2 verglichen
      *@return true, falls alle Konstanten des Tupels entweder gleich der jeweiligen Elemente von konstanten2 sind, oder eins von beiden frei(NULL) ist
      */
    int match(int arity2, char** konstanten2, Tupel &tupel);
     /**Passt der Functor zu dem Tupel?\\
      * Diese Function ist besonders schnell, da sie Stringvergleiche minimiert.
      *@param Func der zu \"uberpr\"ufende Functor
      *@param tupel damit wird Func verglichen
      *@return true, falls alle Konstanten von Func entweder gleich der Konstanten von GetFunctor() sind, oder eins von beiden frei(NULL) ist
      */
    int match(C_Functor& Func,Tupel& tupel);
     /**f\"ugt eine L\"osung hinzu.\\ 
      * Ausserdem wird noch das Delta aktualisiert.
      */
    Pix add(Tupel);
     /**L\"oscht das Delta des Bodies*/
    void deltaclear();
     /**mappt ein Tupel auf den Kopf der Rule*/
    Tupel map(Tupel);
     /**wie oben, nur anderer R\"uckgabetyp*/
    Tupel& map2(Tupel);    
/*
    Tupel mapNegativ(Tupel);    
*/
     /**St\"osst Berechnung an.
      */
    int calc();
     /**Ist der Body schon berechnet?*/
    int IsCalculated() {return GetBody()->IsCalculated();}
/*
    Pix add_mapping(Tupel tupel);
*/
     /**Setzt das Muster mit dem L\"osungen \"ubereinstimmen m\"ussen,
      * die zur\"uckgeliefert werden.
      * @param arity2 Stelligkeit des Tupels
      * @param konstanten die Konstanten den Tupels (NULL=>frei)
      */
    void SetPattern(int arity2,char** konstanten2);
     /**Erzeugt einen String aus dem Rule-Kopf*/
    char* GetHeadline();
     /**Liefert das Delta des Bodies und der gelinkten Rules*/
    void GetDelta(TUPELSET&);
     /**Wie oben nur anderer Container*/
    void GetDelta(TUPELBAG&);
     /**Enth\"alt die Rule ein AdotLabel?*/
    int isAdotLabel;
     /**Ermittelt, ob eine neue Berechnung auch neue L\"osungen bringen w\"urde*/
    int LohntBerechnung();
     /**Partielle Berechnung der JoinProjektion. 
      * @param ergebnis Relation f\"ur die L\"osungen
      * @param MainTupel dieses Tupel wird mit einer Relation gejoint
      * @param jdc der Objekt, dass die Daten f\"ur den Join enth\"alt
      * @param pos Nummer der Relation im jdc, mit dem MainTupel gejoinr werden soll
      */
    int join_proj(Relation &ergebnis,Tupel MainTupel,DataCollector* jdc,int pos);
     /**st\"osst join\_proj an.
      *@see join_proj(Relation &ergebnis,Tupel MainTupel,DataCollector* jdc,int pos)
      */
    int start_join_proj();
};

   

/** Ein Knoten in der Fixpoint-Liste.\\
  Jeder Knoten zeigt auf einen vollst\"andigen Algebra-Ausdruck. 
  @see AlgDescription
*/
class FixpointNode
{
        /// der konkrete Algebra-Ausdruck
    AlgDescription *ad;
        /// die n\"achste Algebra.\\ (es gibt kein Ende der Liste, d.h. die Liste ist ein Kreis)
    FixpointNode *next;

public:
        /** Konstruktor.\\
          Erzeugt einen neuen Fixpoint-Knoten mit
          @param nad Algebra-Ausdruck
          @param nnext neues Listenende
          */
    FixpointNode(AlgDescription* nad,class FixpointNode *nnext)
            :ad(nad),next(nnext) {}
        /// \"uberschreibt das Ende der Liste
    FixpointNode*& Next() { return next; };
        /// liefert den Funktor der zugeh\"orgen Regel
    C_Functor GetFunctor();
        /// liefert den Body der zugeh\"orgen Regel
    Relation *GetBody();
        /** \"Uberpr\"uft die Regel auf Abh\"angigkeiten von anderen Regeln.\\
          In der Klasse Fixpoint sind die Regelk"opfe (bzw. Funktoren) der
          ableitbaren Regeln abgespeichert */
    void CheckForRule(class Fixpoint* fixpoint);
     ///liefert einen Zeiger auf die Rule zur\"uck
    AlgDescription* GetAlgDescr() { return ad; };
};


/** Eine Liste von Algebra-Ausd\"ucken. Sie beschreibt eine Fixpunkt-Iteration.
 * Die Liste ist eigentlich eine Kette und zwar eine im Kreis gelinkte.
 * Die Regeln werden einfach so lange im Kreis ausgewertet, bis keine mehr neue
 * L\"osungen geliefert hat.
 */
class Fixpoint
{
     /// die eigentliche Liste
    FixpointNode *start,*fpn;
    Fixpoint *next;
     ///ein Zeiger auf Stratifizierung. Wird ben\"otigt, um Anfragen mit GetAlgDescr(...) an die Stratifizierung weiterleiten zu koennen
    class stratified_rules *stratified;
    
public:
     ///ist false, wenn der Fixpoint einen ung\"ultige FixpointNode enthaelt (NULL)
    int ok;
     /// initialisiert die Liste auf NULL
    Fixpoint() : fpn(NULL),stratified(NULL),ok(1) {};
    Fixpoint*& Next() { return next; };    

        /// f\"ugt ein neues Element in die Liste ein
    void add(AlgDescription* ad);
        /** liefert die erste Regel (AlgDescription) f\"ur den gegebenen Funktor bzw. NULL, falls es
          keine passende Regel gibt\\
          Dies wird insbesondere benutzt um in CheckRules die Abh\"angigkeiten zu berechnen.*/
    AlgDescription *GetAlgDescr(C_Functor &functor);
     /**Sucht zuerst in allen anderen Fixpoint nach dem Functor, dann erst im eigenen. Das ist noetig, um die AlgDescriptions sinnvoll zu verknuepfen */
    AlgDescription *GetAlgDescrReverse(C_Functor &functor);
     ///Sucht nur im eigenen Fixpoint nach Rules die dem Functor entsprechen und gibt einen Zeiger auf sie bzw NULL zur\"uck.
    AlgDescription *GetAlgDescr_WO_advancedCheck(C_Functor&);
     /** \"Uberpr\"uft alle in der Fixpoint-Rechenvorschrift enthaltenen Regeln auf
         Abh\"angigkeiten von anderen Regeln. */
    void CheckRules(stratified_rules*);
     ///nochmal die alte Version, als es noch keine Stratifizierung gab.
    void CheckRules();
     ///gibt alle Daten auf der Console aus
    void test();
     ///Kurzform von test()
    void StrukturTest();
     ///st\"osst die Berechnung an
    void calc();
     ///setzt diese Werte in der ersten Rule, da aber static, ist es fuer alle Relationen
    void Set(class TDB*,TIMEPOINT,int,TOID);
    FixpointNode* Start() { return start; };  
     /**Durchsucht den Fixpoint nach einer Rule. Wird benutzt, um in Literal::CheckForRule() die Variable (Adot)LinkZeigtAufEigenenFixpoint setzen zu koennen
      *@see Erlaeuterungen (Deltas)
      */
    int ContainsAlgDescr(AlgDescription*);
     /**st\"osst Wiederherstellung der Deltas in den Relationen an
      * @see Erlaeuterungen  
      */
    void RestoreDeltas();
     ///Macht RestoreDeltas r\"uckg\"angig
    void RemoveDeltas();
};

/**Stratifiezierte Fixpunkte. Enth\"alt alle Fixpoints in der Reihenfolge, wie sie auch berechnet werden m\"ussen. 
 */
class stratified_rules
{
    Fixpoint *start,*fp;
    
public:
     ///ist false, wenn der Stratifizierung einen ung\"ultige Fixpoint enthaelt (NULL)
    int ok;
     ///initialisiert Stratifizierung mit NULL
    stratified_rules() : fp(NULL),ok(1) {};

     ///f\"ugt einen Fixpoint hinzu
    void add(Fixpoint* fix);
     ///gibt alle Daten auf Console aus
    void test();
     ///kurze Fassung von test()
    void StrukturTest();
     ///st\"osst Berechnung an
    void calc();
    Fixpoint* Start() { return start; };
     ///st\"osst CheckRules() f\"ur alle Fixpoints an
    void CheckRules();
     ///sucht in allen Fixpoints ausser im \"ubergebenen (this) nach dem functor
    AlgDescription* GetAlgDescr(C_Functor&,Fixpoint*);
     ///liefert die erste Regel des letzten Fixpoints zurueck. Das ist die, die die L\"osungen enth\"alt.
    AlgDescription* GetMainRule();
};

/**
 *Enth\"alt weiterf\"uhrende Erkl\"arungen zum Code.
 *
 *AdotAnormalie: 
 *
 *Alle Rules, die den gleichen Functor haben, werden zu einem Kreis gelinkt. Eine Ausnahme bilden AdotLabel-Literale. \\
 *Diese werden trotz unterschiedlichen Functoren bei Adot-Literalen mit ber\"ucksichtigt. 
 *Da ein direktes Einbilden in den Kreis zu sehr vielen Problemen f\"uhrt, wird dieses Problem nachtr\"aglich in AlgeDescription::calc gel\"ost. 
 *Weiterhin wird in Literal::firstGetAll die AdotAusnahme behandelt. Zu diesem Zweck existieren noch AdotLink und AdotLinkZeigtNichtAufEigenenFixpoint.\\
 *siehe (Literal::AdotAusnahmeBehandeln)
 *
 *
 *Deltas:
 *
 *Die Deltas werden f\"ur jede Relation getrennt gespeichert. Etwas komplizierter ist es mit den Rules (AlgDescription). 
 *Hier wird nur ein Delta pro Kreis gespeichert. Wo das ist und wo die L\"osungen hinkommen, wird beim ersten AlgDescription::add entschieden. 
 *Bei jeder Berechnung entfernt jede Rule aus den Deltas diejenigen L\"osungen, die es eine Runde vorher hineingetan hat.\\
 *siehe AlgDescription::calc
 *Ein weiter Besonderheit entsteht durch Links, die nicht auf den eigenen Fixpoint zeigen. Dessen Deltas sind nach Bearbeitung dieses Fixpoints immer leer.
 *F\"ur den aktuellen Fixpoint sind es jedoch neue L\"osungen. Deshalb wird in diesem Falle RestoreDeltas aufgerufen (stratified\_rules::calc). 
 *Nach der ersten Benutzung des Deltas werden diese L\"osungen durch RemoveDeltas wieder entfernt (Fixpoint::calc). \\
 *siehe Fixpoint::RestoreDeltas, Fixpoint::RemoveDeltas
 *
 *Tokens:
 *
 *Beim Berechnen einen Joins werden, wenn m\"oglich nur die Deltas benutzt. Das geht aber in jedem Join nur immer mit einer Relation. 
 *Welche das ist bestimmt der Token, der so von Berechnung zu Brerechnung durch den Join wandert (JoinProjNode::TakeTokenFrom, Relation::TakeTokenFrom).
 *(AlgDescription::start\_join\_proj)
 *
 *
 *Rule-Verknuepfung (Link):
 *
 *Rules (AlgDescription) mit dem gleichen Functor, werden durch link zu einem Kreis verbunden. Sie teilen sich ein Delta (globDelta) und ihre L\"osungen (solutions).
 *
 *(Adot)LinkZeigtAufEigenenFixpoint:
 *
 *Diese Variablen sind dazu da zu bestimmen, ob ein Restore bzw. RemoveDelta noetig ist, oder nicht.\\
 *siehe first,next,operator()
 *
 *Es kann zu St\"orungen kommen, falls man eine Relation abfragt und mittendrin (vielleicht ueber einen link) wieder ein first oder next auf sie ausfuehrt, 
 *weil fuer jede Relation nur ein iterator gefuehrt wird. 
 *Wenn das passieren k\"onnte, die L\"osungen vorher unbedingt in einem set (oder bag) zwischenspeichern und dann dessen L\"osungen druchlaufen.
*/
class Erlaeuterungen
{};


#endif
