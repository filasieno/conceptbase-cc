{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
*}
{
*
* File:        Empl_woRuleIc.sml
* Version:     2.0
* Creation:    1-May-1989, Eva Krueger (UPA)
* Last Change: 2-Jul-1991, Manfred Jeusfeld (UPA)
* -----------------------------------------------------------------------------
*
* Example model of employees, managers and departments with some instances.
*
}
{$set syntax=PlainToronto}

Individual Employee in Class with
   attribute
      name : String;
      salary : Integer;
      dept : Department;
      boss : Manager
end Employee
 

Individual Manager in Class isA Employee with
end Manager


Individual Department in Class with
   attribute
      head : Manager
end Department


Individual Produktion in Department with
  head
    Produktionsleiter : Hubert
end Produktion

Individual Vertrieb in Department with
  head
    Vertrieblerchef : Konrad
end Vertrieb

Individual Verwaltung in Department with
  head
    Hauptbeamte : Eleonore
end Verwaltung

Individual Forschung in Department with
  head
    Obertueftler : Albert
end Forschung

Individual Hubert in Manager with
  salary
    HubisGehalt : 100000
end Hubert

Individual Konrad in Manager with
  salary
    KonnisGehalt : 120000
end Konrad

Individual Eleonore in Manager with
  salary
    EllisGehalt : 20000
end Eleonore

Individual Albert in Manager with
  salary
    BertsGehalt : 110000
end Albert




Individual Michael in Employee with
  dept
    MichaelsAbteilung : Produktion
  salary 
    MichaelsLohn : 30000
end Michael

Individual Hans in Employee with
  dept
    HansAbteilung : Produktion
  salary 
    HansLohn : 30500
end Hans

Individual Josef in Employee with
  dept
    JosefsAbteilung : Produktion
  salary 
    JosefsLohn : 35000
end Josef

Individual Max in Employee with
  dept
    MaxsAbteilung : Produktion
  salary 
    MaxsLohn : 40000
end Max

Individual Rita in Employee with
  dept
    RitasAbteilung : Produktion
  salary 
    RitasLohn : 50000
end Rita



Individual Herbert in Employee with
  dept
    HerbertsAbteilung : Vertrieb
  salary 
    HerbertsGehalt : 60000
end Herbert

Individual Susi in Employee with
  dept
    SusisAbteilung : Vertrieb
  salary 
    SusisGehalt : 62000
end

Individual Silvia in Employee with
  dept
    SilviasAbteilung : Vertrieb
  salary 
    SilviasGehalt : 65000
end Silvia

Individual Thomas in Employee with
  dept
    ThomasAbteilung : Vertrieb
  salary 
    ThomasGehalt : 70000
end Thomas

Individual Christoph in Employee with
  dept
    ChristophsAbteilung : Vertrieb
  salary 
    ChristophsGehalt : 90000
end Christoph



Individual Maria in Employee with
  dept
    MariasAbteilung : Verwaltung
  salary 
    MariasGehalt : 10000
end Maria

Individual Felix in Employee with
  dept
    FelixsAbteilung : Verwaltung
  salary 
    FelixsGehalt : 12000
end Felix



Individual Robert in Employee with
  dept
    RobertsLabor : Forschung
  salary 
    RobertsGrundgehalt : 70000
end Robert

Individual Edward in Employee with
  dept
    EdwarsLabor : Forschung
  salary 
    EdwardsGrundgehalt : 50000
end Edward

