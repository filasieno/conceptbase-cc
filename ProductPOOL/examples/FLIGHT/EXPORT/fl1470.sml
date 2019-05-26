{*
The ConceptBase.cc Copyright

Copyright 1987-2014 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{$set syntax=PlainAachen}

leningrad!F1 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2235
flnr
   flight_number: "lh345"
end 

kobenhavn!F2 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1820
flnr
   flight_number: "sk649"
end 

bremen!F3 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1525
flnr
   flight_number: "lh976"
end 

frankfurt!F4 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1040
flnr
   flight_number: "lh370"
end 

frankfurt!F5 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1040
flnr
   flight_number: "lh374"
end 

stuttgart!F6 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 945
flnr
   flight_number: "lh1843"
end 

paris!F7 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 845
flnr
   flight_number: "af740"
end 

frankfurt!F8 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1755
flnr
   flight_number: "lh248"
end 

koeln_bonn!F9 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1800
flnr
   flight_number: "lh1382"
end 

frankfurt!F10 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1151
flnr
   flight_number: "lh1002"
end 

frankfurt!F11 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2120
flnr
   flight_number: "lh774"
end 

hannover!F12 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 755
flnr
   flight_number: "lh720"
end 

hannover!F13 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1700
flnr
   flight_number: "ba774"
end 

hannover!F14 in city!con_to with
departure
   dept_time: 1725
arrival
   arr_time: 1830
flnr
   flight_number: "dw097"
end 

napoli!F15 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1320
flnr
   flight_number: "az454"
end 

newyork!F16 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 640
flnr
   flight_number: "lh409"
end 

juist!F17 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1200
flnr
   flight_number: "du014"
end 

muenchen!F18 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1515
flnr
   flight_number: "lh757"
end 

berlin!F19 in city!con_to with
departure
   dept_time: 1905
arrival
   arr_time: 1945
flnr
   flight_number: "ba3067"
end 

birmingham!F20 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1120
flnr
   flight_number: "ba974"
end 

nice!F21 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1745
flnr
   flight_number: "af1760"
end 

berlin!F22 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 920
flnr
   flight_number: "pa91"
end 

muenchen!F23 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1340
flnr
   flight_number: "ba755"
end 

stuttgart!F24 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1330
flnr
   flight_number: "lh920"
end 

hannover!F25 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1810
flnr
   flight_number: "ba955"
end 

kobenhavn!F26 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 835
flnr
   flight_number: "sk641"
end 

muenchen!F27 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1500
flnr
   flight_number: "lh1930"
end 

sofia!F28 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1110
flnr
   flight_number: "lz127"
end 

helsinki!F29 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1835
flnr
   flight_number: "lh029"
end 

stuttgart!F30 in city!con_to with
departure
   dept_time: 2035
arrival
   arr_time: 2130
flnr
   flight_number: "lh923"
end 

nuernberg!F31 in city!con_to with
departure
   dept_time: 655
arrival
   arr_time: 845
flnr
   flight_number: "lh056"
end 

muenchen!F32 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1505
flnr
   flight_number: "lh1936"
end 

roma!F33 in city!con_to with
departure
   dept_time: 1530
arrival
   arr_time: 1700
flnr
   flight_number: "az476"
end 

kobenhavn!F34 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1820
flnr
   flight_number: "sk649"
end 

frankfurt!F35 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 2120
flnr
   flight_number: "ba957"
end 

frankfurt!F36 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1650
flnr
   flight_number: "dw135"
end 

frankfurt!F37 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1745
flnr
   flight_number: "lh150"
end 

milano!F38 in city!con_to with
departure
   dept_time: 1205
arrival
   arr_time: 1320
flnr
   flight_number: "az454"
end 

berlin!F39 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1235
flnr
   flight_number: "ba3005"
end 

milano!F40 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 840
flnr
   flight_number: "az450"
end 

muenchen!F41 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1215
flnr
   flight_number: "lh716"
end 

oslo!F42 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 1840
flnr
   flight_number: "sk623"
end 

bucuresti!F43 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1620
flnr
   flight_number: "lh371"
end 

muenchen!F44 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1215
flnr
   flight_number: "lh621"
end 

dublin!F45 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1220
flnr
   flight_number: "ei652"
end 

frankfurt!F46 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1745
flnr
   flight_number: "lh366"
end 

hannover!F47 in city!con_to with
departure
   dept_time: 1055
arrival
   arr_time: 1140
flnr
   flight_number: "lh722"
end 

hannover!F48 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1520
flnr
   flight_number: "lh723"
end 

frankfurt!F49 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1800
flnr
   flight_number: "lh114"
end 

nuernberg!F50 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2145
flnr
   flight_number: "pa676"
end 

zagreb!F51 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1955
flnr
   flight_number: "lh367"
end 

bruxelles!F52 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 825
flnr
   flight_number: "lh101"
end 

ljubljana!F53 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1605
flnr
   flight_number: "ju354"
end 

muenchen!F54 in city!con_to with
departure
   dept_time: 2035
arrival
   arr_time: 2150
flnr
   flight_number: "pa692"
end 

wien!F55 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2225
flnr
   flight_number: "lh263"
end 

geneve!F56 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1215
flnr
   flight_number: "lh247"
end 

berlin!F57 in city!con_to with
departure
   dept_time: 630
arrival
   arr_time: 735
flnr
   flight_number: "ba3001"
end 

koeln_bonn!F58 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 905
flnr
   flight_number: "ba3005"
end 

nuernberg!F59 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1850
flnr
   flight_number: "lh929"
end 

berlin!F60 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1420
flnr
   flight_number: "pa611"
end 

stuttgart!F61 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1155
flnr
   flight_number: "lh154"
end 

berlin!F62 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2120
flnr
   flight_number: "pa695"
end 

oslo!F63 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 1840
flnr
   flight_number: "sk623"
end 

lapaz!F64 in city!con_to with
departure
   dept_time: 530
arrival
   arr_time: 645
flnr
   flight_number: "lh513"
end 

paris!F65 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 2040
flnr
   flight_number: "af748"
end 

frankfurt!F66 in city!con_to with
departure
   dept_time: 1605
arrival
   arr_time: 1655
flnr
   flight_number: "lh822"
end 

paris!F67 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1535
flnr
   flight_number: "af744"
end 

bremen!F68 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1900
flnr
   flight_number: "ba3044"
end 

hannover!F69 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 2235
flnr
   flight_number: "lh286"
end 

frankfurt!F70 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1400
flnr
   flight_number: "lh112"
end 

glasgow!F71 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 1320
flnr
   flight_number: "ba980"
end 

berlin!F72 in city!con_to with
departure
   dept_time: 1205
arrival
   arr_time: 1315
flnr
   flight_number: "ba3039"
end 

frankfurt!F73 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1415
flnr
   flight_number: "lh370"
end 

dublin!F74 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1220
flnr
   flight_number: "ei652"
end 

malaga!F75 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1725
flnr
   flight_number: "lh189"
end 

zagreb!F76 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 2220
flnr
   flight_number: "lh367 / lh972"
end 

bremen!F77 in city!con_to with
departure
   dept_time: 710
arrival
   arr_time: 805
flnr
   flight_number: "lh714"
end 

berlin!F78 in city!con_to with
departure
   dept_time: 1410
arrival
   arr_time: 1450
flnr
   flight_number: "ba3061"
end 

hannover!F79 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 2235
flnr
   flight_number: "lh286"
end 

frankfurt!F80 in city!con_to with
departure
   dept_time: 1810
arrival
   arr_time: 1910
flnr
   flight_number: "pa652"
end 

bogota!F81 in city!con_to with
departure
   dept_time: 1055
arrival
   arr_time: 1605
flnr
   flight_number: "lh517"
end 

paris!F82 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 835
flnr
   flight_number: "lh111"
end 

luxembourg!F83 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1130
flnr
   flight_number: "lg305"
end 

malaga!F84 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1725
flnr
   flight_number: "lh189"
end 

muenchen!F85 in city!con_to with
departure
   dept_time: 820
arrival
   arr_time: 925
flnr
   flight_number: "lh450"
end 

frankfurt!F86 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1905
flnr
   flight_number: "tp593"
end 

berlin!F87 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1830
flnr
   flight_number: "ba877"
end 

budapest!F88 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1100
flnr
   flight_number: "ma520"
end 

milano!F89 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1205
flnr
   flight_number: "lh273"
end 

frankfurt!F90 in city!con_to with
departure
   dept_time: 1155
arrival
   arr_time: 1255
flnr
   flight_number: "pa640"
end 

paris!F91 in city!con_to with
departure
   dept_time: 2050
arrival
   arr_time: 2155
flnr
   flight_number: "lh137"
end 

muenchen!F92 in city!con_to with
departure
   dept_time: 1220
arrival
   arr_time: 1315
flnr
   flight_number: "lh755"
end 

tanger!F93 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 2030
flnr
   flight_number: "lh385"
end 

london!F94 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1145
flnr
   flight_number: "ba754"
end 

frankfurt!F95 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2040
flnr
   flight_number: "pa654"
end 

muenchen!F96 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1815
flnr
   flight_number: "lh839"
end 

frankfurt!F97 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1525
flnr
   flight_number: "pa644"
end 

frankfurt!F98 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1420
flnr
   flight_number: "lh082"
end 

moskva!F99 in city!con_to with
departure
   dept_time: 2025
arrival
   arr_time: 2200
flnr
   flight_number: "lh357"
end 

frankfurt!F100 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1140
flnr
   flight_number: "pa636"
end 

muenchen!F101 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 815
flnr
   flight_number: "lh750"
end 

berlin!F102 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1630
flnr
   flight_number: "da785"
end 

frankfurt!F103 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1305
flnr
   flight_number: "lh032"
end 

stuttgart!F104 in city!con_to with
departure
   dept_time: 2100
arrival
   arr_time: 2210
flnr
   flight_number: "lh261"
end 

hannover!F105 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 905
flnr
   flight_number: "lh721"
end 

berlin!F106 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1630
flnr
   flight_number: "da785"
end 

manchester!F107 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1250
flnr
   flight_number: "lh077"
end 

hannover!F108 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2010
flnr
   flight_number: "lh724"
end 

amsterdam!F109 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1940
flnr
   flight_number: "lh087"
end 

milano!F110 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 1035
flnr
   flight_number: "lh1353"
end 

koeln_bonn!F111 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1105
flnr
   flight_number: "ba3004"
end 

helsinki!F112 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1110
flnr
   flight_number: "ay825"
end 

berlin!F113 in city!con_to with
departure
   dept_time: 1805
arrival
   arr_time: 1910
flnr
   flight_number: "pa655"
end 

frankfurt!F114 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1000
flnr
   flight_number: "pa634"
end 

istanbul!F115 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 2020
flnr
   flight_number: "lh321"
end 

berlin!F116 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 850
flnr
   flight_number: "ba771"
end 

frankfurt!F117 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1035
flnr
   flight_number: "snlh982"
end 

frankfurt!F118 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 1935
flnr
   flight_number: "ba957"
end 

frankfurt!F119 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1015
flnr
   flight_number: "os422"
end 

frankfurt!F120 in city!con_to with
departure
   dept_time: 2130
arrival
   arr_time: 2220
flnr
   flight_number: "lh827"
end 

kobenhavn!F121 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1700
flnr
   flight_number: "lh1333"
end 

zuerich!F122 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1040
flnr
   flight_number: "srlh566"
end 

nuernberg!F123 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 855
flnr
   flight_number: "lh928"
end 

laspalmas!F124 in city!con_to with
departure
   dept_time: 750
arrival
   arr_time: 1515
flnr
   flight_number: "ib538"
end 

frankfurt!F125 in city!con_to with
departure
   dept_time: 1846
arrival
   arr_time: 1725
flnr
   flight_number: "lh1006"
end 

dublin!F126 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1855
flnr
   flight_number: "ei698"
end 

wien!F127 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 835
flnr
   flight_number: "os401"
end 

stuttgart!F128 in city!con_to with
departure
   dept_time: 2125
arrival
   arr_time: 2210
flnr
   flight_number: "lh289"
end 

berlin!F129 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1155
flnr
   flight_number: "pa643"
end 

stuttgart!F130 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1700
flnr
   flight_number: "lh791"
end 

hannover!F131 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1745
flnr
   flight_number: "sr583"
end 

palma!F132 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1520
flnr
   flight_number: "lh181"
end 

frankfurt!F133 in city!con_to with
departure
   dept_time: 2135
arrival
   arr_time: 2240
flnr
   flight_number: "lh086"
end 

dublin!F134 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1855
flnr
   flight_number: "ei698"
end 

berlin!F135 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1930
flnr
   flight_number: "pa657"
end 

athine!F136 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1215
flnr
   flight_number: "oa191"
end 

frankfurt!F137 in city!con_to with
departure
   dept_time: 2155
arrival
   arr_time: 2255
flnr
   flight_number: "pa658"
end 

ljubljana!F138 in city!con_to with
departure
   dept_time: 1530
arrival
   arr_time: 1650
flnr
   flight_number: "jp950"
end 

duesseldorf!F139 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1555
flnr
   flight_number: "lh980"
end 

thessaloniki!F140 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1735
flnr
   flight_number: "lh313"
end 

frankfurt!F141 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1015
flnr
   flight_number: "lh401"
end 

dortmund!F142 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 935
flnr
   flight_number: "vg138"
end 

koeln_bonn!F143 in city!con_to with
departure
   dept_time: 1725
arrival
   arr_time: 1745
flnr
   flight_number: "lh058"
end 

frankfurt!F144 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1620
flnr
   flight_number: "lh769"
end 

amsterdam!F145 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1155
flnr
   flight_number: "lh083"
end 

muenchen!F146 in city!con_to with
departure
   dept_time: 1105
arrival
   arr_time: 1530
flnr
   flight_number: "lh412"
end 

frankfurt!F147 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1735
flnr
   flight_number: "pa650"
end 

stuttgart!F148 in city!con_to with
departure
   dept_time: 655
arrival
   arr_time: 820
flnr
   flight_number: "lh1350"
end 

frankfurt!F149 in city!con_to with
departure
   dept_time: 2125
arrival
   arr_time: 2220
flnr
   flight_number: "lh805"
end 

birmingham!F150 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1835
flnr
   flight_number: "ba950"
end 

hannover!F151 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1645
flnr
   flight_number: "lh1981"
end 

athine!F152 in city!con_to with
departure
   dept_time: 505
arrival
   arr_time: 700
flnr
   flight_number: "lh611"
end 

berlin!F153 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2125
flnr
   flight_number: "ba3073"
end 

roma!F154 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1625
flnr
   flight_number: "az416"
end 

zuerich!F155 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1555
flnr
   flight_number: "lh225"
end 

helsinki!F156 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1110
flnr
   flight_number: "ay825"
end 

beograd!F157 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1100
flnr
   flight_number: "ju350"
end 

stockholm!F158 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1845
flnr
   flight_number: "sk655"
end 

manchester!F159 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1840
flnr
   flight_number: "ba876"
end 

dortmund!F160 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1155
flnr
   flight_number: "vg132"
end 

frankfurt!F161 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1740
flnr
   flight_number: "az1457"
end 

frankfurt!F162 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1920
flnr
   flight_number: "lh588"
end 

birmingham!F163 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1235
flnr
   flight_number: "ba954"
end 

luxembourg!F164 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1130
flnr
   flight_number: "lg305"
end 

bruxelles!F165 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1950
flnr
   flight_number: "sn987"
end 

casablanca!F166 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1545
flnr
   flight_number: "lh383"
end 

casablanca!F167 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1545
flnr
   flight_number: "lh381"
end 

hamburg!F168 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1720
flnr
   flight_number: "ay854"
end 

nuernberg!F169 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1140
flnr
   flight_number: "lh404"
end 

nuernberg!F170 in city!con_to with
departure
   dept_time: 630
arrival
   arr_time: 725
flnr
   flight_number: "lh927"
end 

innsbruck!F171 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1455
flnr
   flight_number: "vo443"
end 

frankfurt!F172 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 905
flnr
   flight_number: "pa632"
end 

berlin!F173 in city!con_to with
departure
   dept_time: 610
arrival
   arr_time: 715
flnr
   flight_number: "pa633"
end 

frankfurt!F174 in city!con_to with
departure
   dept_time: 1625
arrival
   arr_time: 1740
flnr
   flight_number: "vo444"
end 

koeln_bonn!F175 in city!con_to with
departure
   dept_time: 825
arrival
   arr_time: 845
flnr
   flight_number: "lh056"
end 

muenchen!F176 in city!con_to with
departure
   dept_time: 750
arrival
   arr_time: 845
flnr
   flight_number: "lh731"
end 

zuerich!F177 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1750
flnr
   flight_number: "sr584"
end 

frankfurt!F178 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1010
flnr
   flight_number: "lh080"
end 

salzburg!F179 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2015
flnr
   flight_number: "os421"
end 

zuerich!F180 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 915
flnr
   flight_number: "sr580"
end 

hannover!F181 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1950
flnr
   flight_number: "sr585"
end 

frankfurt!F182 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 935
flnr
   flight_number: "lh423"
end 

frankfurt!F183 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1035
flnr
   flight_number: "snlh982"
end 

frankfurt!F184 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1055
flnr
   flight_number: "lh208"
end 

kobenhavn!F185 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1120
flnr
   flight_number: "sk631"
end 

berlin!F186 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1455
flnr
   flight_number: "pa665"
end 

frankfurt!F187 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1215
flnr
   flight_number: "lh016"
end 

ankara!F188 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1830
flnr
   flight_number: "lh323"
end 

nuernberg!F189 in city!con_to with
departure
   dept_time: 655
arrival
   arr_time: 750
flnr
   flight_number: "lh056"
end 

stuttgart!F190 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1500
flnr
   flight_number: "lh790"
end 

muenchen!F191 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1450
flnr
   flight_number: "pa686"
end 

zuerich!F192 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1100
flnr
   flight_number: "srlh562"
end 

birmingham!F193 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1235
flnr
   flight_number: "ba956"
end 

frankfurt!F194 in city!con_to with
departure
   dept_time: 1215
arrival
   arr_time: 1310
flnr
   flight_number: "lh584"
end 

hannover!F195 in city!con_to with
departure
   dept_time: 1345
arrival
   arr_time: 1415
flnr
   flight_number: "lh048"
end 

muenchen!F196 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1215
flnr
   flight_number: "lh422"
end 

stuttgart!F197 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 945
flnr
   flight_number: "pa660"
end 

muenchen!F198 in city!con_to with
departure
   dept_time: 2010
arrival
   arr_time: 2115
flnr
   flight_number: "lh303"
end 

muenchen!F199 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1555
flnr
   flight_number: "lh796"
end 

london!F200 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1225
flnr
   flight_number: "lh033"
end 

stockholm!F201 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1845
flnr
   flight_number: "sk655"
end 

stuttgart!F202 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 755
flnr
   flight_number: "lh1867"
end 

koeln_bonn!F203 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 810
flnr
   flight_number: "lh1380"
end 

berlin!F204 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1455
flnr
   flight_number: "pa689"
end 

frankfurt!F205 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 40
flnr
   flight_number: "aylh824"
end 

athine!F206 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2025
flnr
   flight_number: "lh317"
end 

muenchen!F207 in city!con_to with
departure
   dept_time: 1125
arrival
   arr_time: 1410
flnr
   flight_number: "lh410"
end 

oslo!F208 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 2035
flnr
   flight_number: "sk661"
end 

muenchen!F209 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 945
flnr
   flight_number: "pa680"
end 

frankfurt!F210 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1020
flnr
   flight_number: "lh246"
end 

frankfurt!F211 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1725
flnr
   flight_number: "af747"
end 

frankfurt!F212 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1800
flnr
   flight_number: "ib525"
end 

bremen!F213 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 1950
flnr
   flight_number: "lh719"
end 

london!F214 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 950
flnr
   flight_number: "lh031"
end 

frankfurt!F215 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1135
flnr
   flight_number: "lh312"
end 

athine!F216 in city!con_to with
departure
   dept_time: 1555
arrival
   arr_time: 1735
flnr
   flight_number: "lh329"
end 

berlin!F217 in city!con_to with
departure
   dept_time: 620
arrival
   arr_time: 740
flnr
   flight_number: "pa681"
end 

nice!F218 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1405
flnr
   flight_number: "lh155"
end 

bremen!F219 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1145
flnr
   flight_number: "lh715"
end 

athine!F220 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2215
flnr
   flight_number: "lh317 / lh799"
end 

basel!F221 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1930
flnr
   flight_number: "lx598"
end 

moskva!F222 in city!con_to with
departure
   dept_time: 2115
arrival
   arr_time: 2245
flnr
   flight_number: "lh349"
end 

berlin!F223 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 825
flnr
   flight_number: "af763"
end 

frankfurt!F224 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 1750
flnr
   flight_number: "lh803"
end 

madrid!F225 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1550
flnr
   flight_number: "lh169"
end 

muenchen!F226 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1115
flnr
   flight_number: "lh753"
end 

berlin!F227 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1940
flnr
   flight_number: "pa693"
end 

oslo!F228 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 2035
flnr
   flight_number: "sk661"
end 

hannover!F229 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2055
flnr
   flight_number: "ba3068"
end 

hannover!F230 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1630
flnr
   flight_number: "ba955"
end 

wien!F231 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 830
flnr
   flight_number: "os439"
end 

frankfurt!F232 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1610
flnr
   flight_number: "sr535"
end 

frankfurt!F233 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1725
flnr
   flight_number: "ib511"
end 

hannover!F234 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2150
flnr
   flight_number: "lh991"
end 

berlin!F235 in city!con_to with
departure
   dept_time: 600
arrival
   arr_time: 700
flnr
   flight_number: "pa631"
end 

dublin!F236 in city!con_to with
departure
   dept_time: 1155
arrival
   arr_time: 1455
flnr
   flight_number: "lh079"
end 

valencia!F237 in city!con_to with
departure
   dept_time: 1225
arrival
   arr_time: 1440
flnr
   flight_number: "ib524"
end 

frankfurt!F238 in city!con_to with
departure
   dept_time: 1220
arrival
   arr_time: 1410
flnr
   flight_number: "ju351"
end 

muenchen!F239 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1920
flnr
   flight_number: "lh313"
end 

muenchen!F240 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2020
flnr
   flight_number: "lh323"
end 

berlin!F241 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 950
flnr
   flight_number: "pa637"
end 

berlin!F242 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1720
flnr
   flight_number: "pa653"
end 

berlin!F243 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 1840
flnr
   flight_number: "pa615"
end 

juist!F244 in city!con_to with
departure
   dept_time: 1525
arrival
   arr_time: 1620
flnr
   flight_number: "du034"
end 

langeoog!F245 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1620
flnr
   flight_number: "du032"
end 

frankfurt!F246 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1025
flnr
   flight_number: "sk630"
end 

muenchen!F247 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1700
flnr
   flight_number: "pa688"
end 

hof!F248 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 845
flnr
   flight_number: "ns100"
end 

frankfurt!F249 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1730
flnr
   flight_number: "lh883"
end 

hamburg!F250 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1830
flnr
   flight_number: "pa608"
end 

dortmund!F251 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1800
flnr
   flight_number: "vg134"
end 

moskva!F252 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1115
flnr
   flight_number: "su255"
end 

frankfurt!F253 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1735
flnr
   flight_number: "ju357"
end 

frankfurt!F254 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1820
flnr
   flight_number: "tp585"
end 

sofia!F255 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1620
flnr
   flight_number: "lh375"
end 

leipzig!F256 in city!con_to with
departure
   dept_time: 1945
arrival
   arr_time: 2105
flnr
   flight_number: "if6200"
end 

izmir!F257 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1555
flnr
   flight_number: "lh325"
end 

duesseldorf!F258 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1255
flnr
   flight_number: "lh362"
end 

berlin!F259 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1725
flnr
   flight_number: "ba3043"
end 

muenchen!F260 in city!con_to with
departure
   dept_time: 1810
arrival
   arr_time: 1920
flnr
   flight_number: "lh363"
end 

duesseldorf!F261 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1700
flnr
   flight_number: "lh302"
end 

berlin!F262 in city!con_to with
departure
   dept_time: 1905
arrival
   arr_time: 2015
flnr
   flight_number: "pa669"
end 

bucuresti!F263 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1050
flnr
   flight_number: "ro225"
end 

hannover!F264 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 1835
flnr
   flight_number: "ba3064"
end 

duesseldorf!F265 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2050
flnr
   flight_number: "ba3134"
end 

manchester!F266 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 1025
flnr
   flight_number: "ba962"
end 

frankfurt!F267 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1400
flnr
   flight_number: "sk632"
end 

hannover!F268 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 800
flnr
   flight_number: "ba3052"
end 

lisboa!F269 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 2005
flnr
   flight_number: "lh201"
end 

berlin!F270 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 740
flnr
   flight_number: "ba3035"
end 

paris!F271 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1025
flnr
   flight_number: "lh131"
end 

kobenhavn!F272 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2035
flnr
   flight_number: "lh399"
end 

bremen!F273 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1525
flnr
   flight_number: "lh718"
end 

frankfurt!F274 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1210
flnr
   flight_number: "lh360"
end 

kobenhavn!F275 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1620
flnr
   flight_number: "sk663"
end 

frankfurt!F276 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1015
flnr
   flight_number: "lh800"
end 

london!F277 in city!con_to with
departure
   dept_time: 1125
arrival
   arr_time: 1345
flnr
   flight_number: "lh047"
end 

hannover!F278 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 2110
flnr
   flight_number: "lh1975"
end 

kobenhavn!F279 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1915
flnr
   flight_number: "sk627"
end 

koeln_bonn!F280 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2045
flnr
   flight_number: "lh288"
end 

frankfurt!F281 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1430
flnr
   flight_number: "lh374"
end 

zuerich!F282 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 1940
flnr
   flight_number: "lh245"
end 

duesseldorf!F283 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2105
flnr
   flight_number: "af766"
end 

frankfurt!F284 in city!con_to with
departure
   dept_time: 1625
arrival
   arr_time: 1805
flnr
   flight_number: "lh354"
end 

berlin!F285 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1330
flnr
   flight_number: "ba3125"
end 

frankfurt!F286 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1555
flnr
   flight_number: "ba957"
end 

muenchen!F287 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 2215
flnr
   flight_number: "lh317"
end 

london!F288 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1750
flnr
   flight_number: "ba792"
end 

koeln_bonn!F289 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 805
flnr
   flight_number: "lh735"
end 

stuttgart!F290 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2010
flnr
   flight_number: "lh136"
end 

frankfurt!F291 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1400
flnr
   flight_number: "lh802"
end 

berlin!F292 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2130
flnr
   flight_number: "da787"
end 

london!F293 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 1025
flnr
   flight_number: "ba748"
end 

nuernberg!F294 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 1950
flnr
   flight_number: "lh744"
end 

berlin!F295 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2040
flnr
   flight_number: "ba3045"
end 

hannover!F296 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2105
flnr
   flight_number: "lh1984"
end 

barcelona!F297 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1450
flnr
   flight_number: "lh171"
end 

frankfurt!F298 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1735
flnr
   flight_number: "su256"
end 

nice!F299 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1805
flnr
   flight_number: "af1734"
end 

nice!F300 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1800
flnr
   flight_number: "af1734"
end 

paris!F301 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1935
flnr
   flight_number: "af746"
end 

wien!F302 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 2010
flnr
   flight_number: "lh1381"
end 

muenchen!F303 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1215
flnr
   flight_number: "pa684"
end 

berlin!F304 in city!con_to with
departure
   dept_time: 2030
arrival
   arr_time: 2130
flnr
   flight_number: "ba3135"
end 

berlin!F305 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 815
flnr
   flight_number: "ba3161"
end 

berlin!F306 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1315
flnr
   flight_number: "ba3163"
end 

amsterdam!F307 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 825
flnr
   flight_number: "lh081"
end 

hamburg!F308 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 905
flnr
   flight_number: "lh276"
end 

roma!F309 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2115
flnr
   flight_number: "lh303"
end 

kobenhavn!F310 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1915
flnr
   flight_number: "sk627"
end 

wien!F311 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 1815
flnr
   flight_number: "os405"
end 

tunis!F312 in city!con_to with
departure
   dept_time: 855
arrival
   arr_time: 1145
flnr
   flight_number: "tu748"
end 

frankfurt!F313 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1155
flnr
   flight_number: "sk630"
end 

hamburg!F314 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1005
flnr
   flight_number: "lh188"
end 

chicago!F315 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 830
flnr
   flight_number: "lh431"
end 

berlin!F316 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 815
flnr
   flight_number: "ba3115"
end 

muenchen!F317 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1145
flnr
   flight_number: "lh430"
end 

duesseldorf!F318 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 810
flnr
   flight_number: "lh728"
end 

bremen!F319 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 855
flnr
   flight_number: "ba3036"
end 

stuttgart!F320 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1735
flnr
   flight_number: "oa192"
end 

bremen!F321 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1530
flnr
   flight_number: "ba3042"
end 

hamburg!F322 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1800
flnr
   flight_number: "pa612"
end 

moskva!F323 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1900
flnr
   flight_number: "su259"
end 

frankfurt!F324 in city!con_to with
departure
   dept_time: 2135
arrival
   arr_time: 2215
flnr
   flight_number: "lh886"
end 

london!F325 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2225
flnr
   flight_number: "lh055"
end 

muenchen!F326 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 750
flnr
   flight_number: "lh933"
end 

london!F327 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 2040
flnr
   flight_number: "ba752"
end 

hamburg!F328 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1005
flnr
   flight_number: "lh188"
end 

hamburg!F329 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2005
flnr
   flight_number: "lh278"
end 

koeln_bonn!F330 in city!con_to with
departure
   dept_time: 2150
arrival
   arr_time: 2235
flnr
   flight_number: "lh059"
end 

london!F331 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 1030
flnr
   flight_number: "ba724"
end 

frankfurt!F332 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1735
flnr
   flight_number: "dw115"
end 

frankfurt!F333 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1530
flnr
   flight_number: "ro216"
end 

frankfurt!F334 in city!con_to with
departure
   dept_time: 1249
arrival
   arr_time: 1446
flnr
   flight_number: "lh1004"
end 

stuttgart!F335 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1235
flnr
   flight_number: "lh1925"
end 

duesseldorf!F336 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1150
flnr
   flight_number: "lh003"
end 

lapaz!F337 in city!con_to with
departure
   dept_time: 530
arrival
   arr_time: 1550
flnr
   flight_number: "lh513"
end 

berlin!F338 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1815
flnr
   flight_number: "ba3165"
end 

frankfurt!F339 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1430
flnr
   flight_number: "dw113"
end 

amsterdam!F340 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2050
flnr
   flight_number: "lh1393"
end 

muenchen!F341 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1000
flnr
   flight_number: "ba753"
end 

hamburg!F342 in city!con_to with
departure
   dept_time: 2030
arrival
   arr_time: 2145
flnr
   flight_number: "lh999"
end 

muenster!F343 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1930
flnr
   flight_number: "dw116"
end 

stuttgart!F344 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1655
flnr
   flight_number: "pa664"
end 

glasgow!F345 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1805
flnr
   flight_number: "ba924"
end 

frankfurt!F346 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1820
flnr
   flight_number: "lh344"
end 

frankfurt!F347 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1155
flnr
   flight_number: "ba963"
end 

hannover!F348 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1245
flnr
   flight_number: "lh1948"
end 

hannover!F349 in city!con_to with
departure
   dept_time: 1530
arrival
   arr_time: 1625
flnr
   flight_number: "ns125"
end 

basel!F350 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 905
flnr
   flight_number: "srlh520"
end 

nuernberg!F351 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 1010
flnr
   flight_number: "lh1380"
end 

duesseldorf!F352 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 755
flnr
   flight_number: "lh978"
end 

amsterdam!F353 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2100
flnr
   flight_number: "lh093"
end 

duesseldorf!F354 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1530
flnr
   flight_number: "lh408"
end 

frankfurt!F355 in city!con_to with
departure
   dept_time: 2130
arrival
   arr_time: 2240
flnr
   flight_number: "lh116"
end 

frankfurt!F356 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 2100
flnr
   flight_number: "ib519"
end 

newyork!F357 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 755
flnr
   flight_number: "lh401"
end 

frankfurt!F358 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1145
flnr
   flight_number: "lh332"
end 

koeln_bonn!F359 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 805
flnr
   flight_number: "lh983"
end 

london!F360 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2025
flnr
   flight_number: "lh037"
end 

bremen!F361 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1450
flnr
   flight_number: "ba3040"
end 

duesseldorf!F362 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1130
flnr
   flight_number: "ba749"
end 

athine!F363 in city!con_to with
departure
   dept_time: 1355
arrival
   arr_time: 1550
flnr
   flight_number: "lh311"
end 

paris!F364 in city!con_to with
departure
   dept_time: 1055
arrival
   arr_time: 1205
flnr
   flight_number: "lh113"
end 

kobenhavn!F365 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1915
flnr
   flight_number: "sk615"
end 

bucuresti!F366 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 1050
flnr
   flight_number: "ro225"
end 

bremen!F367 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 2215
flnr
   flight_number: "ba3046"
end 

frankfurt!F368 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1630
flnr
   flight_number: "ro226"
end 

duesseldorf!F369 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1855
flnr
   flight_number: "lh189"
end 

muenchen!F370 in city!con_to with
departure
   dept_time: 2025
arrival
   arr_time: 2140
flnr
   flight_number: "lh819"
end 

hannover!F371 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1735
flnr
   flight_number: "lh132"
end 

koeln_bonn!F372 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 945
flnr
   flight_number: "lh777"
end 

paris!F373 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1745
flnr
   flight_number: "af764"
end 

hannover!F374 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2225
flnr
   flight_number: "dw099"
end 

duesseldorf!F375 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 955
flnr
   flight_number: "lh358"
end 

paderborn!F376 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1105
flnr
   flight_number: "vg311"
end 

frankfurt!F377 in city!con_to with
departure
   dept_time: 835
arrival
   arr_time: 905
flnr
   flight_number: "lh030"
end 

frankfurt!F378 in city!con_to with
departure
   dept_time: 855
arrival
   arr_time: 1005
flnr
   flight_number: "lh110"
end 

muenchen!F379 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 915
flnr
   flight_number: "lh934"
end 

kobenhavn!F380 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1615
flnr
   flight_number: "lh013"
end 

milano!F381 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 835
flnr
   flight_number: "lh287"
end 

frankfurt!F382 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1705
flnr
   flight_number: "lh034"
end 

langeoog!F383 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1115
flnr
   flight_number: "du012"
end 

santa_decompostela!F384 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1435
flnr
   flight_number: "ib676"
end 

nuernberg!F385 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 740
flnr
   flight_number: "lh740"
end 

frankfurt!F386 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1005
flnr
   flight_number: "os408"
end 

milano!F387 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2210
flnr
   flight_number: "lh289"
end 

madrid!F388 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 1230
flnr
   flight_number: "ib548"
end 

kobenhavn!F389 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1915
flnr
   flight_number: "sk615"
end 

frankfurt!F390 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1600
flnr
   flight_number: "lh404"
end 

hannover!F391 in city!con_to with
departure
   dept_time: 1530
arrival
   arr_time: 1625
flnr
   flight_number: "ns125"
end 

duesseldorf!F392 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1650
flnr
   flight_number: "ba751"
end 

birmingham!F393 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1700
flnr
   flight_number: "ba956"
end 

tenerife!F394 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 1515
flnr
   flight_number: "ib540"
end 

helgoland!F395 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1045
flnr
   flight_number: "ol081"
end 

stuttgart!F396 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1245
flnr
   flight_number: "lh166"
end 

duesseldorf!F397 in city!con_to with
departure
   dept_time: 556
arrival
   arr_time: 840
flnr
   flight_number: "lh1001"
end 

duesseldorf!F398 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1755
flnr
   flight_number: "lh981"
end 

hamburg!F399 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 805
flnr
   flight_number: "lh910"
end 

nuernberg!F400 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1705
flnr
   flight_number: "dw096"
end 

madrid!F401 in city!con_to with
departure
   dept_time: 1735
arrival
   arr_time: 2130
flnr
   flight_number: "lh167"
end 

paris!F402 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1600
flnr
   flight_number: "af764"
end 

salzburg!F403 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 805
flnr
   flight_number: "os423"
end 

zuerich!F404 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1600
flnr
   flight_number: "sr526"
end 

zuerich!F405 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 850
flnr
   flight_number: "sr506"
end 

frankfurt!F406 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1520
flnr
   flight_number: "lh430"
end 

berlin!F407 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1915
flnr
   flight_number: "ba3131"
end 

frankfurt!F408 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 2230
flnr
   flight_number: "os406"
end 

nuernberg!F409 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1515
flnr
   flight_number: "lh743"
end 

hamburg!F410 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1100
flnr
   flight_number: "lh703"
end 

nuernberg!F411 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 850
flnr
   flight_number: "lh741"
end 

nuernberg!F412 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1600
flnr
   flight_number: "lh404"
end 

frankfurt!F413 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2305
flnr
   flight_number: "az421"
end 

sanjuan!F414 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 700
flnr
   flight_number: "lh517"
end 

hannover!F415 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 1000
flnr
   flight_number: "lh1976"
end 

kobenhavn!F416 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1155
flnr
   flight_number: "lh005"
end 

hannover!F417 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 935
flnr
   flight_number: "lh038"
end 

laspalmas!F418 in city!con_to with
departure
   dept_time: 1405
arrival
   arr_time: 1930
flnr
   flight_number: "lh191"
end 

london!F419 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1600
flnr
   flight_number: "ba756"
end 

duesseldorf!F420 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1900
flnr
   flight_number: "ba3130"
end 

duesseldorf!F421 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1455
flnr
   flight_number: "lh302"
end 

berlin!F422 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1530
flnr
   flight_number: "ba3127"
end 

duesseldorf!F423 in city!con_to with
departure
   dept_time: 1850
arrival
   arr_time: 1905
flnr
   flight_number: "ba793"
end 

dortmund!F424 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 825
flnr
   flight_number: "vg130"
end 

beograd!F425 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1235
flnr
   flight_number: "ju346"
end 

koeln_bonn!F426 in city!con_to with
departure
   dept_time: 1850
arrival
   arr_time: 1945
flnr
   flight_number: "lh781"
end 

milano!F427 in city!con_to with
departure
   dept_time: 750
arrival
   arr_time: 910
flnr
   flight_number: "lh271"
end 

stuttgart!F428 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 910
flnr
   flight_number: "lh810"
end 

milano!F429 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1425
flnr
   flight_number: "lh285"
end 

beograd!F430 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1920
flnr
   flight_number: "lh363"
end 

milano!F431 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1455
flnr
   flight_number: "lh279"
end 

stuttgart!F432 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1920
flnr
   flight_number: "lh811"
end 

paris!F433 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1135
flnr
   flight_number: "lh125"
end 

muenchen!F434 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1035
flnr
   flight_number: "vg231"
end 

stockholm!F435 in city!con_to with
departure
   dept_time: 1810
arrival
   arr_time: 2010
flnr
   flight_number: "lh021"
end 

frankfurt!F436 in city!con_to with
departure
   dept_time: 2035
arrival
   arr_time: 2145
flnr
   flight_number: "af749"
end 

frankfurt!F437 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1905
flnr
   flight_number: "sk638"
end 

berlin!F438 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1725
flnr
   flight_number: "ba3063"
end 

rotterdam!F439 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1850
flnr
   flight_number: "hx410"
end 

muenchen!F440 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1215
flnr
   flight_number: "lh935"
end 

frankfurt!F441 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1805
flnr
   flight_number: "lh825"
end 

porto!F442 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1530
flnr
   flight_number: "tp582"
end 

muenchen!F443 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1020
flnr
   flight_number: "lh327"
end 

hamburg!F444 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1205
flnr
   flight_number: "lh406"
end 

kobenhavn!F445 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1010
flnr
   flight_number: "lh009"
end 

koeln_bonn!F446 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 740
flnr
   flight_number: "ns120"
end 

goeteborg!F447 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2045
flnr
   flight_number: "sk639"
end 

frankfurt!F448 in city!con_to with
departure
   dept_time: 2049
arrival
   arr_time: 2248
flnr
   flight_number: "lh1008"
end 

duesseldorf!F449 in city!con_to with
departure
   dept_time: 1738
arrival
   arr_time: 2020
flnr
   flight_number: "lh1007"
end 

stockholm!F450 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1910
flnr
   flight_number: "sk637"
end 

frankfurt!F451 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1350
flnr
   flight_number: "lx565"
end 

duesseldorf!F452 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2055
flnr
   flight_number: "lh787"
end 

hannover!F453 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2035
flnr
   flight_number: "ns129"
end 

paris!F454 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 830
flnr
   flight_number: "af756"
end 

basel!F455 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 845
flnr
   flight_number: "lx562"
end 

milano!F456 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2115
flnr
   flight_number: "az448"
end 

frankfurt!F457 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1350
flnr
   flight_number: "lx569"
end 

bruxelles!F458 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1900
flnr
   flight_number: "sn733"
end 

paris!F459 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2020
flnr
   flight_number: "lh135"
end 

berlin!F460 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2105
flnr
   flight_number: "pa659"
end 

berlin!F461 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1405
flnr
   flight_number: "af765"
end 

frankfurt!F462 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 955
flnr
   flight_number: "dw111"
end 

bremen!F463 in city!con_to with
departure
   dept_time: 1105
arrival
   arr_time: 1215
flnr
   flight_number: "ba3038"
end 

kobenhavn!F464 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2020
flnr
   flight_number: "lh007"
end 

frankfurt!F465 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 2035
flnr
   flight_number: "ib525"
end 

frankfurt!F466 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1905
flnr
   flight_number: "sk638"
end 

muenchen!F467 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1415
flnr
   flight_number: "lh293"
end 

hannover!F468 in city!con_to with
departure
   dept_time: 825
arrival
   arr_time: 930
flnr
   flight_number: "dw091"
end 

stuttgart!F469 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2035
flnr
   flight_number: "sn734"
end 

koeln_bonn!F470 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1105
flnr
   flight_number: "lh986"
end 

frankfurt!F471 in city!con_to with
departure
   dept_time: 2050
arrival
   arr_time: 2130
flnr
   flight_number: "lh885"
end 

frankfurt!F472 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1405
flnr
   flight_number: "lh881"
end 

bruxelles!F473 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1925
flnr
   flight_number: "lh107"
end 

basel!F474 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 830
flnr
   flight_number: "lx592"
end 

muenchen!F475 in city!con_to with
departure
   dept_time: 1725
arrival
   arr_time: 1840
flnr
   flight_number: "pa690"
end 

frankfurt!F476 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 945
flnr
   flight_number: "lh582"
end 

frankfurt!F477 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1300
flnr
   flight_number: "lh310"
end 

frankfurt!F478 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1715
flnr
   flight_number: "lh578"
end 

frankfurt!F479 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 40
flnr
   flight_number: "lhay824"
end 

wien!F480 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 845
flnr
   flight_number: "lh251"
end 

frankfurt!F481 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2100
flnr
   flight_number: "pa654"
end 

berlin!F482 in city!con_to with
departure
   dept_time: 635
arrival
   arr_time: 730
flnr
   flight_number: "ba3055"
end 

muenster!F483 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 755
flnr
   flight_number: "dw110"
end 

nice!F484 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1600
flnr
   flight_number: "af1772"
end 

berlin!F485 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 2120
flnr
   flight_number: "af767"
end 

oslo!F486 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1700
flnr
   flight_number: "lh025"
end 

koeln_bonn!F487 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1645
flnr
   flight_number: "lh780"
end 

frankfurt!F488 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1540
flnr
   flight_number: "lh330"
end 

zuerich!F489 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2005
flnr
   flight_number: "sr538"
end 

zuerich!F490 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1545
flnr
   flight_number: "lh229"
end 

hannover!F491 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1600
flnr
   flight_number: "ns114"
end 

duesseldorf!F492 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 915
flnr
   flight_number: "ba747"
end 

koeln_bonn!F493 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1145
flnr
   flight_number: "lh778"
end 

zuerich!F494 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 905
flnr
   flight_number: "sr532"
end 

stuttgart!F495 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1025
flnr
   flight_number: "af757"
end 

koeln_bonn!F496 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 1010
flnr
   flight_number: "lh1380"
end 

paris!F497 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2155
flnr
   flight_number: "lh1327"
end 

berlin!F498 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2120
flnr
   flight_number: "ba3093"
end 

frankfurt!F499 in city!con_to with
departure
   dept_time: 2049
arrival
   arr_time: 2330
flnr
   flight_number: "lh1008"
end 

hannover!F500 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1355
flnr
   flight_number: "lh015"
end 

berlin!F501 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 810
flnr
   flight_number: "pa661"
end 

duesseldorf!F502 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 1120
flnr
   flight_number: "az417"
end 

hannover!F503 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1145
flnr
   flight_number: "lh1957"
end 

duesseldorf!F504 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1655
flnr
   flight_number: "lh785"
end 

nice!F505 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1600
flnr
   flight_number: "af1760"
end 

zuerich!F506 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1030
flnr
   flight_number: "lh241"
end 

duesseldorf!F507 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1855
flnr
   flight_number: "lh786"
end 

paris!F508 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1805
flnr
   flight_number: "lh145"
end 

frankfurt!F509 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1340
flnr
   flight_number: "lg306"
end 

london!F510 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1720
flnr
   flight_number: "lh043"
end 

frankfurt!F511 in city!con_to with
departure
   dept_time: 1249
arrival
   arr_time: 1531
flnr
   flight_number: "lh1004"
end 

stockholm!F512 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1125
flnr
   flight_number: "sk635"
end 

goeteborg!F513 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2045
flnr
   flight_number: "sk639"
end 

newyork!F514 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 815
flnr
   flight_number: "lh407"
end 

koeln_bonn!F515 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 745
flnr
   flight_number: "lh776"
end 

rotterdam!F516 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1045
flnr
   flight_number: "hx402"
end 

hamburg!F517 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1505
flnr
   flight_number: "lh915"
end 

frankfurt!F518 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 1945
flnr
   flight_number: "lh006"
end 

koeln_bonn!F519 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 740
flnr
   flight_number: "ns120"
end 

koeln_bonn!F520 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1210
flnr
   flight_number: "ba743"
end 

tampere!F521 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 855
flnr
   flight_number: "ay853"
end 

muenster!F522 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 955
flnr
   flight_number: "ba3162"
end 

stuttgart!F523 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1810
flnr
   flight_number: "lh1869"
end 

nuernberg!F524 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1440
flnr
   flight_number: "lh1896"
end 

bristol!F525 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1555
flnr
   flight_number: "lh1365"
end 

stuttgart!F526 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1105
flnr
   flight_number: "sn984"
end 

hannover!F527 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2035
flnr
   flight_number: "ns129"
end 

basel!F528 in city!con_to with
departure
   dept_time: 1745
arrival
   arr_time: 1910
flnr
   flight_number: "srlh528"
end 

frankfurt!F529 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1335
flnr
   flight_number: "lh480"
end 

hannover!F530 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 855
flnr
   flight_number: "ba3056"
end 

duesseldorf!F531 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1255
flnr
   flight_number: "lh784"
end 

nice!F532 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1325
flnr
   flight_number: "lh153"
end 

birmingham!F533 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1400
flnr
   flight_number: "ba978"
end 

muenchen!F534 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 840
flnr
   flight_number: "pa694"
end 

frankfurt!F535 in city!con_to with
departure
   dept_time: 2115
arrival
   arr_time: 2210
flnr
   flight_number: "lh264"
end 

duesseldorf!F536 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 945
flnr
   flight_number: "ba3116"
end 

koeln_bonn!F537 in city!con_to with
departure
   dept_time: 2030
arrival
   arr_time: 2040
flnr
   flight_number: "ba745"
end 

paris!F538 in city!con_to with
departure
   dept_time: 2035
arrival
   arr_time: 2205
flnr
   flight_number: "af770"
end 

paris!F539 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 2105
flnr
   flight_number: "af766"
end 

milano!F540 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 1055
flnr
   flight_number: "lh277"
end 

stockholm!F541 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1910
flnr
   flight_number: "sk637"
end 

hannover!F542 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1520
flnr
   flight_number: "lh392"
end 

roma!F543 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1230
flnr
   flight_number: "az422"
end 

frankfurt!F544 in city!con_to with
departure
   dept_time: 1649
arrival
   arr_time: 1926
flnr
   flight_number: "lh1006"
end 

stuttgart!F545 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 1845
flnr
   flight_number: "lh1959"
end 

hannover!F546 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1240
flnr
   flight_number: "ba3060"
end 

dallas!F547 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 2005
flnr
   flight_number: "lh439"
end 

muenster!F548 in city!con_to with
departure
   dept_time: 1840
arrival
   arr_time: 1955
flnr
   flight_number: "ba3166"
end 

praha!F549 in city!con_to with
departure
   dept_time: 1105
arrival
   arr_time: 1215
flnr
   flight_number: "lh351"
end 

glasgow!F550 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 1235
flnr
   flight_number: "ba956"
end 

muenster!F551 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1455
flnr
   flight_number: "ba3164"
end 

marseille!F552 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1915
flnr
   flight_number: "af1740"
end 

hannover!F553 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1520
flnr
   flight_number: "lh392"
end 

nice!F554 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1325
flnr
   flight_number: "lh153"
end 

duesseldorf!F555 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1700
flnr
   flight_number: "ba3128"
end 

berlin!F556 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1130
flnr
   flight_number: "ba3059"
end 

stockholm!F557 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1125
flnr
   flight_number: "sk635"
end 

zuerich!F558 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1405
flnr
   flight_number: "sr534"
end 

kobenhavn!F559 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2035
flnr
   flight_number: "sk661"
end 

london!F560 in city!con_to with
departure
   dept_time: 1510
arrival
   arr_time: 1740
flnr
   flight_number: "ba736"
end 

laspalmas!F561 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1550
flnr
   flight_number: "ib534"
end 

lyon!F562 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2035
flnr
   flight_number: "lh157"
end 

frankfurt!F563 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1530
flnr
   flight_number: "lh438"
end 

faro!F564 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1955
flnr
   flight_number: "tp552"
end 

glasgow!F565 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1835
flnr
   flight_number: "ba950"
end 

frankfurt!F566 in city!con_to with
departure
   dept_time: 1625
arrival
   arr_time: 1745
flnr
   flight_number: "lh298"
end 

warszawa!F567 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1115
flnr
   flight_number: "lo243"
end 

istanbul!F568 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 825
flnr
   flight_number: "lh327"
end 

napoli!F569 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 2010
flnr
   flight_number: "lh305"
end 

berlin!F570 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1730
flnr
   flight_number: "ba3129"
end 

hannover!F571 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1600
flnr
   flight_number: "ns114"
end 

newyork!F572 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 840
flnr
   flight_number: "lh413"
end 

frankfurt!F573 in city!con_to with
departure
   dept_time: 2040
arrival
   arr_time: 2135
flnr
   flight_number: "lh973"
end 

kobenhavn!F574 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2035
flnr
   flight_number: "sk661"
end 

birmingham!F575 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2030
flnr
   flight_number: "lh061"
end 

frankfurt!F576 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1120
flnr
   flight_number: "lh764"
end 

frankfurt!F577 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1405
flnr
   flight_number: "lo244"
end 

gdansk!F578 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1750
flnr
   flight_number: "lo253"
end 

hannover!F579 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 940
flnr
   flight_number: "ns123"
end 

muenster!F580 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1110
flnr
   flight_number: "dw112"
end 

duesseldorf!F581 in city!con_to with
departure
   dept_time: 1045
arrival
   arr_time: 1145
flnr
   flight_number: "ba3118"
end 

stuttgart!F582 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1300
flnr
   flight_number: "lh024"
end 

roma!F583 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1535
flnr
   flight_number: "lh291"
end 

frankfurt!F584 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1530
flnr
   flight_number: "lh322"
end 

stuttgart!F585 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1305
flnr
   flight_number: "lh1924"
end 

berlin!F586 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1015
flnr
   flight_number: "ba3117"
end 

bremen!F587 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1010
flnr
   flight_number: "lh046"
end 

zuerich!F588 in city!con_to with
departure
   dept_time: 2030
arrival
   arr_time: 2155
flnr
   flight_number: "lh231"
end 

duesseldorf!F589 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1055
flnr
   flight_number: "lh979"
end 

frankfurt!F590 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1340
flnr
   flight_number: "lg306"
end 

berlin!F591 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1235
flnr
   flight_number: "ba925"
end 

luxembourg!F592 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 820
flnr
   flight_number: "lg301"
end 

frankfurt!F593 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1235
flnr
   flight_number: "lh290"
end 

paris!F594 in city!con_to with
departure
   dept_time: 1215
arrival
   arr_time: 1345
flnr
   flight_number: "af772"
end 

stuttgart!F595 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 950
flnr
   flight_number: "sn732"
end 

nuernberg!F596 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 745
flnr
   flight_number: "lh844"
end 

wien!F597 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1230
flnr
   flight_number: "lh1381"
end 

stockholm!F598 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1750
flnr
   flight_number: "lh393"
end 

koeln_bonn!F599 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1455
flnr
   flight_number: "ns124"
end 

duesseldorf!F600 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1855
flnr
   flight_number: "lh328"
end 

wien!F601 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2210
flnr
   flight_number: "lh261"
end 

nuernberg!F602 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1605
flnr
   flight_number: "lh1928"
end 

stuttgart!F603 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1600
flnr
   flight_number: "lh1910"
end 

hannover!F604 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2035
flnr
   flight_number: "lh585"
end 

stuttgart!F605 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1030
flnr
   flight_number: "lh919"
end 

frankfurt!F606 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1710
flnr
   flight_number: "lh060"
end 

duesseldorf!F607 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 2010
flnr
   flight_number: "ba924"
end 

frankfurt!F608 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 2225
flnr
   flight_number: "os434"
end 

frankfurt!F609 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 740
flnr
   flight_number: "av011"
end 

koeln_bonn!F610 in city!con_to with
departure
   dept_time: 1505
arrival
   arr_time: 1605
flnr
   flight_number: "ba3016"
end 

athine!F611 in city!con_to with
departure
   dept_time: 505
arrival
   arr_time: 920
flnr
   flight_number: "lh611 / lh762"
end 

frankfurt!F612 in city!con_to with
departure
   dept_time: 1225
arrival
   arr_time: 1430
flnr
   flight_number: "sk636"
end 

stuttgart!F613 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2025
flnr
   flight_number: "ba763"
end 

muenchen!F614 in city!con_to with
departure
   dept_time: 1535
arrival
   arr_time: 1700
flnr
   flight_number: "lh302"
end 

bruxelles!F615 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1435
flnr
   flight_number: "lh1373"
end 

koeln_bonn!F616 in city!con_to with
departure
   dept_time: 1605
arrival
   arr_time: 1705
flnr
   flight_number: "lh988"
end 

duesseldorf!F617 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1500
flnr
   flight_number: "ba3126"
end 

venezia!F618 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1205
flnr
   flight_number: "lhaz293"
end 

venezia!F619 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 2000
flnr
   flight_number: "lh299"
end 

london!F620 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1330
flnr
   flight_number: "ba780"
end 

frankfurt!F621 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1045
flnr
   flight_number: "lh002"
end 

frankfurt!F622 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1205
flnr
   flight_number: "lh160"
end 

frankfurt!F623 in city!con_to with
departure
   dept_time: 1850
arrival
   arr_time: 2040
flnr
   flight_number: "sk1630"
end 

duesseldorf!F624 in city!con_to with
departure
   dept_time: 1345
arrival
   arr_time: 1400
flnr
   flight_number: "lh052"
end 

malaga!F625 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1445
flnr
   flight_number: "ib518"
end 

leningrad!F626 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1300
flnr
   flight_number: "su655"
end 

malmoe!F627 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1950
flnr
   flight_number: "sk657"
end 

frankfurt!F628 in city!con_to with
departure
   dept_time: 2130
arrival
   arr_time: 2210
flnr
   flight_number: "lh855"
end 

nuernberg!F629 in city!con_to with
departure
   dept_time: 655
arrival
   arr_time: 810
flnr
   flight_number: "dw080"
end 

paris!F630 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1905
flnr
   flight_number: "af732"
end 

stockholm!F631 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1750
flnr
   flight_number: "lh393"
end 

birmingham!F632 in city!con_to with
departure
   dept_time: 1155
arrival
   arr_time: 1445
flnr
   flight_number: "ba978"
end 

saarbruecken!F633 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1540
flnr
   flight_number: "dw136"
end 

berlin!F634 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1040
flnr
   flight_number: "ba3037"
end 

london!F635 in city!con_to with
departure
   dept_time: 1745
arrival
   arr_time: 2025
flnr
   flight_number: "ba782"
end 

manchester!F636 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1650
flnr
   flight_number: "ba876"
end 

hannover!F637 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1205
flnr
   flight_number: "lh1372"
end 

frankfurt!F638 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1400
flnr
   flight_number: "lh942"
end 

nice!F639 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1600
flnr
   flight_number: "lh155"
end 

stuttgart!F640 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1410
flnr
   flight_number: "lh1383"
end 

wangerooge!F641 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1610
flnr
   flight_number: "du030"
end 

hamburg!F642 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1705
flnr
   flight_number: "lh916"
end 

birmingham!F643 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1320
flnr
   flight_number: "ba980"
end 

hannover!F644 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 720
flnr
   flight_number: "ns110"
end 

muenchen!F645 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 1820
flnr
   flight_number: "lh937"
end 

frankfurt!F646 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1440
flnr
   flight_number: "oa172"
end 

frankfurt!F647 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1415
flnr
   flight_number: "lh258"
end 

tampere!F648 in city!con_to with
departure
   dept_time: 550
arrival
   arr_time: 830
flnr
   flight_number: "ay821"
end 

stuttgart!F649 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1405
flnr
   flight_number: "ba761"
end 

frankfurt!F650 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1110
flnr
   flight_number: "lh078"
end 

frankfurt!F651 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1525
flnr
   flight_number: "tp581"
end 

stuttgart!F652 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1305
flnr
   flight_number: "az443"
end 

frankfurt!F653 in city!con_to with
departure
   dept_time: 2025
arrival
   arr_time: 2255
flnr
   flight_number: "ib517"
end 

frankfurt!F654 in city!con_to with
departure
   dept_time: 1850
arrival
   arr_time: 2040
flnr
   flight_number: "sk1630"
end 

frankfurt!F655 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1525
flnr
   flight_number: "tp583"
end 

frankfurt!F656 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1655
flnr
   flight_number: "lh944"
end 

frankfurt!F657 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1810
flnr
   flight_number: "lh226"
end 

hannover!F658 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 940
flnr
   flight_number: "ns123"
end 

zuerich!F659 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 835
flnr
   flight_number: "sr570"
end 

london!F660 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1625
flnr
   flight_number: "lh035"
end 

budapest!F661 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2040
flnr
   flight_number: "lh355"
end 

duesseldorf!F662 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1815
flnr
   flight_number: "lh054"
end 

frankfurt!F663 in city!con_to with
departure
   dept_time: 1215
arrival
   arr_time: 1350
flnr
   flight_number: "ma521"
end 

frankfurt!F664 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1400
flnr
   flight_number: "lh942"
end 

berlin!F665 in city!con_to with
departure
   dept_time: 1530
arrival
   arr_time: 1635
flnr
   flight_number: "ba3023"
end 

frankfurt!F666 in city!con_to with
departure
   dept_time: 1225
arrival
   arr_time: 1430
flnr
   flight_number: "sk636"
end 

glasgow!F667 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1650
flnr
   flight_number: "ba876"
end 

bremen!F668 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1500
flnr
   flight_number: "du090"
end 

hamburg!F669 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2000
flnr
   flight_number: "lh712"
end 

frankfurt!F670 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1725
flnr
   flight_number: "lh853"
end 

tunis!F671 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1705
flnr
   flight_number: "lh335"
end 

frankfurt!F672 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1020
flnr
   flight_number: "lh763"
end 

warszawa!F673 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1445
flnr
   flight_number: "lh347"
end 

stuttgart!F674 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1040
flnr
   flight_number: "sr571"
end 

duesseldorf!F675 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 945
flnr
   flight_number: "lh050"
end 

bremen!F676 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2115
flnr
   flight_number: "lh977"
end 

nuernberg!F677 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1800
flnr
   flight_number: "lh845"
end 

hannover!F678 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1525
flnr
   flight_number: "lh571"
end 

frankfurt!F679 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1005
flnr
   flight_number: "lh940"
end 

muenchen!F680 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1735
flnr
   flight_number: "vg312"
end 

paderborn!F681 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1755
flnr
   flight_number: "vg232"
end 

koeln_bonn!F682 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1455
flnr
   flight_number: "ns124"
end 

saarbruecken!F683 in city!con_to with
departure
   dept_time: 1215
arrival
   arr_time: 1405
flnr
   flight_number: "da784"
end 

duesseldorf!F684 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 835
flnr
   flight_number: "lh941"
end 

saarbruecken!F685 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1905
flnr
   flight_number: "da786"
end 

oslo!F686 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2045
flnr
   flight_number: "sk639"
end 

hannover!F687 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1020
flnr
   flight_number: "lh572"
end 

duesseldorf!F688 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1155
flnr
   flight_number: "lh782"
end 

berlin!F689 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1840
flnr
   flight_number: "ba783"
end 

hamburg!F690 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 900
flnr
   flight_number: "lh701"
end 

london!F691 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1935
flnr
   flight_number: "ba768"
end 

oslo!F692 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2045
flnr
   flight_number: "sk639"
end 

antwerpen!F693 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 855
flnr
   flight_number: "snlh981"
end 

koeln_bonn!F694 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1515
flnr
   flight_number: "lh737"
end 

hamburg!F695 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1500
flnr
   flight_number: "lh707"
end 

frankfurt!F696 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1700
flnr
   flight_number: "lh074"
end 

frankfurt!F697 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1530
flnr
   flight_number: "lh312"
end 

frankfurt!F698 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1520
flnr
   flight_number: "lh768"
end 

frankfurt!F699 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1110
flnr
   flight_number: "sr533"
end 

zuerich!F700 in city!con_to with
departure
   dept_time: 1220
arrival
   arr_time: 1300
flnr
   flight_number: "sr576"
end 

koeln_bonn!F701 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 905
flnr
   flight_number: "lh984"
end 

koeln_bonn!F702 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1345
flnr
   flight_number: "lh779"
end 

malmoe!F703 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1950
flnr
   flight_number: "sk657"
end 

koeln_bonn!F704 in city!con_to with
departure
   dept_time: 2010
arrival
   arr_time: 2110
flnr
   flight_number: "af751"
end 

zagreb!F705 in city!con_to with
departure
   dept_time: 1135
arrival
   arr_time: 1235
flnr
   flight_number: "ju346"
end 

hannover!F706 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1650
flnr
   flight_number: "lh576"
end 

sevilla!F707 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 1200
flnr
   flight_number: "ib510"
end 

frankfurt!F708 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1005
flnr
   flight_number: "lh940"
end 

hannover!F709 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2255
flnr
   flight_number: "lh256"
end 

porto!F710 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1530
flnr
   flight_number: "lh209"
end 

frankfurt!F711 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1100
flnr
   flight_number: "os402"
end 

berlin!F712 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1305
flnr
   flight_number: "pa687"
end 

kobenhavn!F713 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1110
flnr
   flight_number: "sk625"
end 

duesseldorf!F714 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 815
flnr
   flight_number: "lh407"
end 

stuttgart!F715 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 945
flnr
   flight_number: "vg221"
end 

frankfurt!F716 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1130
flnr
   flight_number: "lh184"
end 

frankfurt!F717 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 2255
flnr
   flight_number: "lh516"
end 

frankfurt!F718 in city!con_to with
departure
   dept_time: 2125
arrival
   arr_time: 2215
flnr
   flight_number: "dw117"
end 

norderney!F719 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1200
flnr
   flight_number: "du013"
end 

birmingham!F720 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1125
flnr
   flight_number: "lh1363"
end 

budapest!F721 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1615
flnr
   flight_number: "lh359"
end 

newyork!F722 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 905
flnr
   flight_number: "lh411"
end 

hannover!F723 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2255
flnr
   flight_number: "lh256"
end 

frankfurt!F724 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1205
flnr
   flight_number: "lh022"
end 

hamburg!F725 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1125
flnr
   flight_number: "lh837"
end 

stuttgart!F726 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1030
flnr
   flight_number: "sk666"
end 

berlin!F727 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1355
flnr
   flight_number: "ba3041"
end 

hannover!F728 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 720
flnr
   flight_number: "ns110"
end 

frankfurt!F729 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1135
flnr
   flight_number: "lh308"
end 

muenchen!F730 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1940
flnr
   flight_number: "vg233"
end 

frankfurt!F731 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1745
flnr
   flight_number: "lh943"
end 

frankfurt!F732 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1750
flnr
   flight_number: "lg308"
end 

koeln_bonn!F733 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2015
flnr
   flight_number: "lh739"
end 

frankfurt!F734 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1109
flnr
   flight_number: "lh1002"
end 

frankfurt!F735 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1400
flnr
   flight_number: "lh334"
end 

rotterdam!F736 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2045
flnr
   flight_number: "hx406"
end 

wien!F737 in city!con_to with
departure
   dept_time: 1040
arrival
   arr_time: 1410
flnr
   flight_number: "lh1383"
end 

muenchen!F738 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1615
flnr
   flight_number: "lh758"
end 

palma!F739 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1720
flnr
   flight_number: "lh183"
end 

catania!F740 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1520
flnr
   flight_number: "lh297"
end 

stuttgart!F741 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1800
flnr
   flight_number: "lh1382"
end 

hamburg!F742 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1200
flnr
   flight_number: "lh704"
end 

bruxelles!F743 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 910
flnr
   flight_number: "sn983"
end 

luxembourg!F744 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1505
flnr
   flight_number: "lg307"
end 

malaga!F745 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1855
flnr
   flight_number: "lh189"
end 

malaga!F746 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1855
flnr
   flight_number: "lh189"
end 

koeln_bonn!F747 in city!con_to with
departure
   dept_time: 1805
arrival
   arr_time: 1905
flnr
   flight_number: "lh989"
end 

koeln_bonn!F748 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1140
flnr
   flight_number: "lh736"
end 

nuernberg!F749 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 805
flnr
   flight_number: "dw090"
end 

leningrad!F750 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2220
flnr
   flight_number: "lh353"
end 

zuerich!F751 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1120
flnr
   flight_number: "lh233"
end 

manchester!F752 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 2025
flnr
   flight_number: "lh075"
end 

stockholm!F753 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1505
flnr
   flight_number: "lh017"
end 

helsinki!F754 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 2005
flnr
   flight_number: "lh029"
end 

frankfurt!F755 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1020
flnr
   flight_number: "lg302"
end 

frankfurt!F756 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 2150
flnr
   flight_number: "lg304"
end 

stuttgart!F757 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2050
flnr
   flight_number: "lh591"
end 

antwerpen!F758 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1850
flnr
   flight_number: "snlh985"
end 

koeln_bonn!F759 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 1855
flnr
   flight_number: "lh238"
end 

bucuresti!F760 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1815
flnr
   flight_number: "lh371"
end 

stuttgart!F761 in city!con_to with
departure
   dept_time: 1905
arrival
   arr_time: 2005
flnr
   flight_number: "vg123"
end 

stuttgart!F762 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1030
flnr
   flight_number: "sk666"
end 

antwerpen!F763 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 855
flnr
   flight_number: "snlh981"
end 

koeln_bonn!F764 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1005
flnr
   flight_number: "lh985"
end 

salzburg!F765 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 805
flnr
   flight_number: "lh265"
end 

frankfurt!F766 in city!con_to with
departure
   dept_time: 2035
arrival
   arr_time: 2100
flnr
   flight_number: "lh036"
end 

duesseldorf!F767 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1355
flnr
   flight_number: "lh316"
end 

koeln_bonn!F768 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1620
flnr
   flight_number: "dw089"
end 

hamburg!F769 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1700
flnr
   flight_number: "lh709"
end 

koeln_bonn!F770 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1405
flnr
   flight_number: "lh987"
end 

frankfurt!F771 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1120
flnr
   flight_number: "af565"
end 

timisoara!F772 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1050
flnr
   flight_number: "ro225"
end 

muenchen!F773 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 900
flnr
   flight_number: "vg310"
end 

moskva!F774 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1130
flnr
   flight_number: "su201"
end 

oslo!F775 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1450
flnr
   flight_number: "lh023"
end 

frankfurt!F776 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1000
flnr
   flight_number: "ns101"
end 

london!F777 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1825
flnr
   flight_number: "ba728"
end 

frankfurt!F778 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1210
flnr
   flight_number: "lh180"
end 

split!F779 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1325
flnr
   flight_number: "ju356"
end 

duesseldorf!F780 in city!con_to with
departure
   dept_time: 750
arrival
   arr_time: 855
flnr
   flight_number: "lh292"
end 

stuttgart!F781 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1935
flnr
   flight_number: "ba3092"
end 

frankfurt!F782 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1545
flnr
   flight_number: "ju357"
end 

wangerooge!F783 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1220
flnr
   flight_number: "du010"
end 

frankfurt!F784 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1545
flnr
   flight_number: "ju363"
end 

bayreuth!F785 in city!con_to with
departure
   dept_time: 2205
arrival
   arr_time: 2220
flnr
   flight_number: "ns107"
end 

hannover!F786 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1425
flnr
   flight_number: "lh014"
end 

london!F787 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1145
flnr
   flight_number: "lh051"
end 

nuernberg!F788 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 815
flnr
   flight_number: "lhsr563"
end 

berlin!F789 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1755
flnr
   flight_number: "ba3091"
end 

split!F790 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 1105
flnr
   flight_number: "jp950"
end 

koeln_bonn!F791 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1945
flnr
   flight_number: "lh1899"
end 

hof!F792 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1835
flnr
   flight_number: "ns106"
end 

london!F793 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1240
flnr
   flight_number: "lh069"
end 

glasgow!F794 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 1120
flnr
   flight_number: "ba974"
end 

frankfurt!F795 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1150
flnr
   flight_number: "lh296"
end 

frankfurt!F796 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1400
flnr
   flight_number: "lh851"
end 

kobenhavn!F797 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1220
flnr
   flight_number: "lh015"
end 

frankfurt!F798 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1020
flnr
   flight_number: "lh850"
end 

frankfurt!F799 in city!con_to with
departure
   dept_time: 2130
arrival
   arr_time: 2235
flnr
   flight_number: "lh775"
end 

duesseldorf!F800 in city!con_to with
departure
   dept_time: 1259
arrival
   arr_time: 1539
flnr
   flight_number: "lh1005"
end 


sofia!F801 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1815
flnr
   flight_number: "lh375"
end 

saarbruecken!F802 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 905
flnr
   flight_number: "da782"
end 

istanbul!F803 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 1020
flnr
   flight_number: "lh327"
end 

berlin!F804 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1025
flnr
   flight_number: "ba781"
end 

stuttgart!F805 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 950
flnr
   flight_number: "vg121"
end 

beograd!F806 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1730
flnr
   flight_number: "lh363"
end 

hamburg!F807 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1905
flnr
   flight_number: "lh917"
end 

muenchen!F808 in city!con_to with
departure
   dept_time: 710
arrival
   arr_time: 820
flnr
   flight_number: "lh076"
end 

bayreuth!F809 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1755
flnr
   flight_number: "ns105"
end 

frankfurt!F810 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 2000
flnr
   flight_number: "tp585"
end 

frankfurt!F811 in city!con_to with
departure
   dept_time: 2115
arrival
   arr_time: 2220
flnr
   flight_number: "lh801"
end 

muenchen!F812 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 940
flnr
   flight_number: "az477"
end 

bayreuth!F813 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1235
flnr
   flight_number: "ns104"
end 

frankfurt!F814 in city!con_to with
departure
   dept_time: 1615
arrival
   arr_time: 1720
flnr
   flight_number: "lh770"
end 

stuttgart!F815 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1405
flnr
   flight_number: "sr577"
end 

frankfurt!F816 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1310
flnr
   flight_number: "oa172"
end 

lisboa!F817 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1530
flnr
   flight_number: "tp572"
end 

frankfurt!F818 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1225
flnr
   flight_number: "az425"
end 

atlanta!F819 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1530
flnr
   flight_number: "lh438"
end 

frankfurt!F820 in city!con_to with
departure
   dept_time: 1350
arrival
   arr_time: 1610
flnr
   flight_number: "ah2071"
end 

hamburg!F821 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1230
flnr
   flight_number: "lh717"
end 

frankfurt!F822 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1400
flnr
   flight_number: "lh384"
end 

manchester!F823 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1805
flnr
   flight_number: "ba924"
end 

oslo!F824 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 1120
flnr
   flight_number: "sk631"
end 

helgoland!F825 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1220
flnr
   flight_number: "du011"
end 

frankfurt!F826 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1735
flnr
   flight_number: "lh806"
end 

frankfurt!F827 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1410
flnr
   flight_number: "ei653"
end 

bayreuth!F828 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1945
flnr
   flight_number: "ns106"
end 

bayreuth!F829 in city!con_to with
departure
   dept_time: 1125
arrival
   arr_time: 1225
flnr
   flight_number: "ns104"
end 

frankfurt!F830 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 1825
flnr
   flight_number: "lh158"
end 

frankfurt!F831 in city!con_to with
departure
   dept_time: 2135
arrival
   arr_time: 2215
flnr
   flight_number: "lh945"
end 

koeln_bonn!F832 in city!con_to with
departure
   dept_time: 710
arrival
   arr_time: 810
flnr
   flight_number: "lh124"
end 

faro!F833 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1530
flnr
   flight_number: "tp552"
end 

stuttgart!F834 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2130
flnr
   flight_number: "sr579"
end 

frankfurt!F835 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2020
flnr
   flight_number: "lh773"
end 

frankfurt!F836 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2205
flnr
   flight_number: "ns107"
end 

stuttgart!F837 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 755
flnr
   flight_number: "lh062"
end 

paris!F838 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1340
flnr
   flight_number: "af760"
end 

frankfurt!F839 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1745
flnr
   flight_number: "os426"
end 

frankfurt!F840 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1220
flnr
   flight_number: "lh765"
end 

klagenfurt!F841 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1940
flnr
   flight_number: "os425"
end 

london!F842 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1355
flnr
   flight_number: "ba726"
end 

frankfurt!F843 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1730
flnr
   flight_number: "ns105"
end 

frankfurt!F844 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1920
flnr
   flight_number: "lh772"
end 

frankfurt!F845 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1405
flnr
   flight_number: "lh304"
end 

paris!F846 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 1000
flnr
   flight_number: "lh143"
end 

frankfurt!F847 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1310
flnr
   flight_number: "lh324"
end 

zagreb!F848 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1605
flnr
   flight_number: "ju358"
end 

koeln_bonn!F849 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1800
flnr
   flight_number: "ns126"
end 

paris!F850 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 910
flnr
   flight_number: "af730"
end 

muenchen!F851 in city!con_to with
departure
   dept_time: 2020
arrival
   arr_time: 2115
flnr
   flight_number: "lh760"
end 

frankfurt!F852 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1750
flnr
   flight_number: "lh807"
end 

muenster!F853 in city!con_to with
departure
   dept_time: 1725
arrival
   arr_time: 1840
flnr
   flight_number: "ba876"
end 

athine!F854 in city!con_to with
departure
   dept_time: 835
arrival
   arr_time: 1135
flnr
   flight_number: "oa171"
end 

manchester!F855 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 2010
flnr
   flight_number: "ba924"
end 

hannover!F856 in city!con_to with
departure
   dept_time: 2050
arrival
   arr_time: 2200
flnr
   flight_number: "lh1831"
end 

hannover!F857 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1205
flnr
   flight_number: "lh390"
end 

frankfurt!F858 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1420
flnr
   flight_number: "lh767"
end 

bruxelles!F859 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 815
flnr
   flight_number: "sn731"
end 

kobenhavn!F860 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1355
flnr
   flight_number: "lh015"
end 

frankfurt!F861 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1410
flnr
   flight_number: "ei653"
end 

helgoland!F862 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1600
flnr
   flight_number: "hx026"
end 

frankfurt!F863 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1535
flnr
   flight_number: "sk632"
end 

lisboa!F864 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1530
flnr
   flight_number: "tp552"
end 

zuerich!F865 in city!con_to with
departure
   dept_time: 1945
arrival
   arr_time: 2025
flnr
   flight_number: "sr578"
end 

hamburg!F866 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1105
flnr
   flight_number: "lh019"
end 

koeln_bonn!F867 in city!con_to with
departure
   dept_time: 1205
arrival
   arr_time: 1625
flnr
   flight_number: "lh168"
end 

frankfurt!F868 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 2225
flnr
   flight_number: "lh106"
end 

frankfurt!F869 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 920
flnr
   flight_number: "lh762"
end 

glasgow!F870 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1840
flnr
   flight_number: "ba876"
end 

hamburg!F871 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1900
flnr
   flight_number: "lh711"
end 

hamburg!F872 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1000
flnr
   flight_number: "lh702"
end 

hannover!F873 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1205
flnr
   flight_number: "lh390"
end 

hamburg!F874 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1400
flnr
   flight_number: "lh706"
end 

kobenhavn!F875 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2055
flnr
   flight_number: "lh011"
end 

frankfurt!F876 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1055
flnr
   flight_number: "os410"
end 

hamburg!F877 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 930
flnr
   flight_number: "lh726"
end 

basel!F878 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 2035
flnr
   flight_number: "lx568"
end 

nuernberg!F879 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1110
flnr
   flight_number: "lh1894"
end 

hamburg!F880 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1545
flnr
   flight_number: "lh996"
end 

berlin!F881 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1545
flnr
   flight_number: "pa651"
end 

helsinki!F882 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 855
flnr
   flight_number: "ay853"
end 

geneve!F883 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1940
flnr
   flight_number: "sr526"
end 

frankfurt!F884 in city!con_to with
departure
   dept_time: 905
arrival
   arr_time: 1015
flnr
   flight_number: "lx563"
end 

frankfurt!F885 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 915
flnr
   flight_number: "lh1829"
end 

bruxelles!F886 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1625
flnr
   flight_number: "sn759"
end 

koeln_bonn!F887 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1515
flnr
   flight_number: "lh1322"
end 

frankfurt!F888 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2130
flnr
   flight_number: "af1743"
end 

hannover!F889 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1000
flnr
   flight_number: "ba771"
end 

duesseldorf!F890 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 800
flnr
   flight_number: "ba3114"
end 

birmingham!F891 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1345
flnr
   flight_number: "ba954"
end 

bruxelles!F892 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1525
flnr
   flight_number: "sn757"
end 

sanjuan!F893 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 645
flnr
   flight_number: "lh513"
end 

stuttgart!F894 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1550
flnr
   flight_number: "af761"
end 

stuttgart!F895 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1600
flnr
   flight_number: "lh155"
end 

hannover!F896 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2000
flnr
   flight_number: "ba777"
end 

pisa!F897 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1440
flnr
   flight_number: "az426"
end 

geneve!F898 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1950
flnr
   flight_number: "lh221"
end 

hamburg!F899 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 800
flnr
   flight_number: "lh700"
end 

leningrad!F900 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1300
flnr
   flight_number: "su653"
end 

tenerife!F901 in city!con_to with
departure
   dept_time: 750
arrival
   arr_time: 1445
flnr
   flight_number: "ib518"
end 

frankfurt!F902 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1155
flnr
   flight_number: "lh170"
end 

bruxelles!F903 in city!con_to with
departure
   dept_time: 1045
arrival
   arr_time: 1125
flnr
   flight_number: "sn755"
end 

koeln_bonn!F904 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1545
flnr
   flight_number: "lh1382"
end 

bruxelles!F905 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2145
flnr
   flight_number: "lh109"
end 

koeln_bonn!F906 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2020
flnr
   flight_number: "lh288"
end 

frankfurt!F907 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1830
flnr
   flight_number: "tp555"
end 

geneve!F908 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1610
flnr
   flight_number: "lh434"
end 

duesseldorf!F909 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 1235
flnr
   flight_number: "lh028"
end 

koeln_bonn!F910 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1800
flnr
   flight_number: "ns126"
end 

paris!F911 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 900
flnr
   flight_number: "af776"
end 

hamburg!F912 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1530
flnr
   flight_number: "lh406"
end 

frankfurt!F913 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1805
flnr
   flight_number: "lh004"
end 

milano!F914 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 1015
flnr
   flight_number: "lh281"
end 

paris!F915 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 845
flnr
   flight_number: "af762"
end 

hamburg!F916 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1145
flnr
   flight_number: "lh994"
end 

luxembourg!F917 in city!con_to with
departure
   dept_time: 1840
arrival
   arr_time: 1920
flnr
   flight_number: "lg303"
end 

basel!F918 in city!con_to with
departure
   dept_time: 1510
arrival
   arr_time: 1620
flnr
   flight_number: "lx596"
end 

frankfurt!F919 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1835
flnr
   flight_number: "tp575"
end 

frankfurt!F920 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1410
flnr
   flight_number: "lh222"
end 

hannover!F921 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1730
flnr
   flight_number: "lh1396"
end 

berlin!F922 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1050
flnr
   flight_number: "ba925"
end 

amsterdam!F923 in city!con_to with
departure
   dept_time: 2040
arrival
   arr_time: 2155
flnr
   flight_number: "lh097"
end 

frankfurt!F924 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 715
flnr
   flight_number: "av011"
end 

hannover!F925 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 930
flnr
   flight_number: "lh1394"
end 

sanjuan!F926 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 700
flnr
   flight_number: "lh515"
end 

berlin!F927 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 1000
flnr
   flight_number: "ba771"
end 

frankfurt!F928 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1450
flnr
   flight_number: "ro226"
end 

paris!F929 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1705
flnr
   flight_number: "lh1323"
end 

zuerich!F930 in city!con_to with
departure
   dept_time: 1430
arrival
   arr_time: 1545
flnr
   flight_number: "sr582"
end 

rotterdam!F931 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1610
flnr
   flight_number: "hx404"
end 

muenchen!F932 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1045
flnr
   flight_number: "lh068"
end 

kobenhavn!F933 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1550
flnr
   flight_number: "sk647"
end 

leipzig!F934 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2120
flnr
   flight_number: "if6240"
end 

luxembourg!F935 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1920
flnr
   flight_number: "lg303"
end 

paris!F936 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2005
flnr
   flight_number: "lh117"
end 

hamburg!F937 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1300
flnr
   flight_number: "lh705"
end 

hamburg!F938 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2045
flnr
   flight_number: "lh932"
end 

hamburg!F939 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1800
flnr
   flight_number: "lh710"
end 

frankfurt!F940 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1645
flnr
   flight_number: "lh026"
end 

frankfurt!F941 in city!con_to with
departure
   dept_time: 2110
arrival
   arr_time: 2200
flnr
   flight_number: "lg304"
end 

dortmund!F942 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1125
flnr
   flight_number: "vg136"
end 

zuerich!F943 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1155
flnr
   flight_number: "lh223"
end 

goeteborg!F944 in city!con_to with
departure
   dept_time: 1600
arrival
   arr_time: 1740
flnr
   flight_number: "lh1311"
end 

stuttgart!F945 in city!con_to with
departure
   dept_time: 735
arrival
   arr_time: 845
flnr
   flight_number: "ba3082"
end 

stuttgart!F946 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1100
flnr
   flight_number: "lh789"
end 

frankfurt!F947 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1640
flnr
   flight_number: "su260"
end 

saarbruecken!F948 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1805
flnr
   flight_number: "dw016"
end 

frankfurt!F949 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1820
flnr
   flight_number: "lh516"
end 

paderborn!F950 in city!con_to with
departure
   dept_time: 1755
arrival
   arr_time: 1915
flnr
   flight_number: "vg313"
end 

frankfurt!F951 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1005
flnr
   flight_number: "lh429"
end 

bruxelles!F952 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1055
flnr
   flight_number: "lh099"
end 

hannover!F953 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1925
flnr
   flight_number: "lh1392"
end 

frankfurt!F954 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1710
flnr
   flight_number: "ib533"
end 

bologna!F955 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1440
flnr
   flight_number: "az426"
end 

frankfurt!F956 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1820
flnr
   flight_number: "lh514"
end 

muenster!F957 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1220
flnr
   flight_number: "lh1360"
end 

heraklion!F958 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1520
flnr
   flight_number: "lh315"
end 

berlin!F959 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1105
flnr
   flight_number: "ba3083"
end 

hannover!F960 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 900
flnr
   flight_number: "lh1390"
end 

bruxelles!F961 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 745
flnr
   flight_number: "sn751"
end 

bremen!F962 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2035
flnr
   flight_number: "ba769"
end 

leipzig!F963 in city!con_to with
departure
   dept_time: 2020
arrival
   arr_time: 2135
flnr
   flight_number: "if6240"
end 

frankfurt!F964 in city!con_to with
departure
   dept_time: 1525
arrival
   arr_time: 1850
flnr
   flight_number: "ib677"
end 

frankfurt!F965 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1720
flnr
   flight_number: "lh320"
end 

paderborn!F966 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 840
flnr
   flight_number: "vg230"
end 

warszawa!F967 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 945
flnr
   flight_number: "l0255"
end 

frankfurt!F968 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1750
flnr
   flight_number: "su256"
end 

nuernberg!F969 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 1800
flnr
   flight_number: "dw086"
end 

muenster!F970 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 1830
flnr
   flight_number: "ba877"
end 

frankfurt!F971 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1335
flnr
   flight_number: "lh418"
end 

frankfurt!F972 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1055
flnr
   flight_number: "af743"
end 

manchester!F973 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1455
flnr
   flight_number: "lh077"
end 

zuerich!F974 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1925
flnr
   flight_number: "lh239"
end 

frankfurt!F975 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1615
flnr
   flight_number: "oa170"
end 

bruxelles!F976 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1540
flnr
   flight_number: "lh105"
end 

faro!F977 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1955
flnr
   flight_number: "lh211"
end 

graz!F978 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 830
flnr
   flight_number: "os433"
end 

berlin!F979 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 1030
flnr
   flight_number: "pa685"
end 

frankfurt!F980 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2200
flnr
   flight_number: "af1741"
end 

frankfurt!F981 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1335
flnr
   flight_number: "lh438"
end 

frankfurt!F982 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1245
flnr
   flight_number: "af1565"
end 

muenchen!F983 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1945
flnr
   flight_number: "lh352"
end 

london!F984 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1205
flnr
   flight_number: "ba732"
end 

frankfurt!F985 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1055
flnr
   flight_number: "az425"
end 

dortmund!F986 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 735
flnr
   flight_number: "vg110"
end 

duesseldorf!F987 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 855
flnr
   flight_number: "lh028"
end 

stuttgart!F988 in city!con_to with
departure
   dept_time: 820
arrival
   arr_time: 905
flnr
   flight_number: "lh738"
end 

koeln_bonn!F989 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2105
flnr
   flight_number: "lh990"
end 

frankfurt!F990 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1810
flnr
   flight_number: "lh342"
end 

stockholm!F991 in city!con_to with
departure
   dept_time: 1810
arrival
   arr_time: 2155
flnr
   flight_number: "lh021"
end 

hannover!F992 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1110
flnr
   flight_number: "af775"
end 

koeln_bonn!F993 in city!con_to with
departure
   dept_time: 820
arrival
   arr_time: 930
flnr
   flight_number: "lh1955"
end 

koeln_bonn!F994 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 820
flnr
   flight_number: "lh1352"
end 

zuerich!F995 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2210
flnr
   flight_number: "srlh568"
end 

casablanca!F996 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 2030
flnr
   flight_number: "lh385"
end 

paris!F997 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1920
flnr
   flight_number: "af766"
end 

hamburg!F998 in city!con_to with
departure
   dept_time: 1355
arrival
   arr_time: 1820
flnr
   flight_number: "su654"
end 

kobenhavn!F999 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1550
flnr
   flight_number: "sk647"
end 

frankfurt!F1000 in city!con_to with
departure
   dept_time: 2130
arrival
   arr_time: 2245
flnr
   flight_number: "lh282"
end 

hamburg!F1001 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 830
flnr
   flight_number: "lh725"
end 

amsterdam!F1002 in city!con_to with
departure
   dept_time: 1805
arrival
   arr_time: 1905
flnr
   flight_number: "lh1397"
end 

frankfurt!F1003 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1745
flnr
   flight_number: "ib529"
end 

stuttgart!F1004 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 835
flnr
   flight_number: "if6270"
end 

hamburg!F1005 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1830
flnr
   flight_number: "lh727"
end 

bremen!F1006 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1030
flnr
   flight_number: "du070"
end 

hannover!F1007 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1815
flnr
   flight_number: "ns116"
end 

london!F1008 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2155
flnr
   flight_number: "ba730"
end 

frankfurt!F1009 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1410
flnr
   flight_number: "lh252"
end 

muenchen!F1010 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1720
flnr
   flight_number: "lh020"
end 

nuernberg!F1011 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1935
flnr
   flight_number: "lhsr565"
end 

frankfurt!F1012 in city!con_to with
departure
   dept_time: 1415
arrival
   arr_time: 1745
flnr
   flight_number: "ju363"
end 

frankfurt!F1013 in city!con_to with
departure
   dept_time: 1645
arrival
   arr_time: 1805
flnr
   flight_number: "lh254"
end 

frankfurt!F1014 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1510
flnr
   flight_number: "az1457"
end 

muenchen!F1015 in city!con_to with
departure
   dept_time: 630
arrival
   arr_time: 745
flnr
   flight_number: "lh817"
end 

berlin!F1016 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 2155
flnr
   flight_number: "af1761"
end 

innsbruck!F1017 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1940
flnr
   flight_number: "vo453"
end 

frankfurt!F1018 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2125
flnr
   flight_number: "sk634"
end 

frankfurt!F1019 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1530
flnr
   flight_number: "tu745"
end 

muenster!F1020 in city!con_to with
departure
   dept_time: 1510
arrival
   arr_time: 1605
flnr
   flight_number: "dw114"
end 

torino!F1021 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2115
flnr
   flight_number: "lh1351"
end 

hamburg!F1022 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1745
flnr
   flight_number: "lh997"
end 

frankfurt!F1023 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1045
flnr
   flight_number: "vg211"
end 

dortmund!F1024 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1840
flnr
   flight_number: "vg122"
end 

tunis!F1025 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1205
flnr
   flight_number: "tu744"
end 

hannover!F1026 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2215
flnr
   flight_number: "os440"
end 

koeln_bonn!F1027 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1915
flnr
   flight_number: "lo256"
end 

stuttgart!F1028 in city!con_to with
departure
   dept_time: 820
arrival
   arr_time: 1235
flnr
   flight_number: "lh454"
end 

milano!F1029 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 2040
flnr
   flight_number: "az440"
end 

frankfurt!F1030 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1510
flnr
   flight_number: "ba727"
end 

nuernberg!F1031 in city!con_to with
departure
   dept_time: 2040
arrival
   arr_time: 2145
flnr
   flight_number: "lh1381"
end 

hamburg!F1032 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1945
flnr
   flight_number: "lh998"
end 

stuttgart!F1033 in city!con_to with
departure
   dept_time: 1535
arrival
   arr_time: 1630
flnr
   flight_number: "lh922"
end 

zuerich!F1034 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 845
flnr
   flight_number: "sr550"
end 

birmingham!F1035 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1350
flnr
   flight_number: "ba956"
end 

berlin!F1036 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1835
flnr
   flight_number: "ba3025"
end 

madrid!F1037 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1540
flnr
   flight_number: "lh161"
end 

roma!F1038 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1955
flnr
   flight_number: "az1456"
end 

muenchen!F1039 in city!con_to with
departure
   dept_time: 1555
arrival
   arr_time: 1710
flnr
   flight_number: "lh818"
end 

frankfurt!F1040 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 820
flnr
   flight_number: "lh761"
end 

dortmund!F1041 in city!con_to with
departure
   dept_time: 710
arrival
   arr_time: 810
flnr
   flight_number: "vg120"
end 

zuerich!F1042 in city!con_to with
departure
   dept_time: 2015
arrival
   arr_time: 2125
flnr
   flight_number: "srlh564"
end 

paris!F1043 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 840
flnr
   flight_number: "af774"
end 

tunis!F1044 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1845
flnr
   flight_number: "lh335"
end 

bayreuth!F1045 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 845
flnr
   flight_number: "ns100"
end 

paris!F1046 in city!con_to with
departure
   dept_time: 1805
arrival
   arr_time: 2025
flnr
   flight_number: "lh133"
end 

frankfurt!F1047 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2005
flnr
   flight_number: "ba729"
end 

roma!F1048 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 2215
flnr
   flight_number: "lh303 / lh760"
end 

london!F1049 in city!con_to with
departure
   dept_time: 2005
arrival
   arr_time: 2225
flnr
   flight_number: "lh045"
end 

muenchen!F1050 in city!con_to with
departure
   dept_time: 1510
arrival
   arr_time: 1615
flnr
   flight_number: "lh359"
end 

manchester!F1051 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1855
flnr
   flight_number: "ba952"
end 

frankfurt!F1052 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1225
flnr
   flight_number: "ba975"
end 

westerland!F1053 in city!con_to with
departure
   dept_time: 1225
arrival
   arr_time: 1305
flnr
   flight_number: "hx114"
end 

frankfurt!F1054 in city!con_to with
departure
   dept_time: 1215
arrival
   arr_time: 1320
flnr
   flight_number: "lh766"
end 

paris!F1055 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1555
flnr
   flight_number: "lh115"
end 

muenchen!F1056 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1755
flnr
   flight_number: "ba757"
end 

innsbruck!F1057 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 915
flnr
   flight_number: "vo441"
end 

frankfurt!F1058 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 930
flnr
   flight_number: "ba723"
end 

hannover!F1059 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1815
flnr
   flight_number: "ns116"
end 

milano!F1060 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1120
flnr
   flight_number: "az442"
end 

zuerich!F1061 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2045
flnr
   flight_number: "sr558"
end 

nuernberg!F1062 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2100
flnr
   flight_number: "dw098"
end 

stuttgart!F1063 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1510
flnr
   flight_number: "lh828"
end 

muenster!F1064 in city!con_to with
departure
   dept_time: 640
arrival
   arr_time: 815
flnr
   flight_number: "dw120"
end 

klagenfurt!F1065 in city!con_to with
departure
   dept_time: 635
arrival
   arr_time: 900
flnr
   flight_number: "os419"
end 

frankfurt!F1066 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1010
flnr
   flight_number: "lh220"
end 

wien!F1067 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1545
flnr
   flight_number: "os403"
end 

frankfurt!F1068 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1820
flnr
   flight_number: "lh771"
end 

frankfurt!F1069 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1410
flnr
   flight_number: "ba975"
end 

paris!F1070 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 1030
flnr
   flight_number: "af762"
end 

frankfurt!F1071 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1155
flnr
   flight_number: "lh346"
end 

roma!F1072 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1700
flnr
   flight_number: "az476"
end 

hamburg!F1073 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 945
flnr
   flight_number: "lh993"
end 

zuerich!F1074 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2035
flnr
   flight_number: "lh227"
end 

nuernberg!F1075 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 840
flnr
   flight_number: "pa694"
end 

tanger!F1076 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1545
flnr
   flight_number: "lh383"
end 

frankfurt!F1077 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2125
flnr
   flight_number: "sk634"
end 

madrid!F1078 in city!con_to with
departure
   dept_time: 810
arrival
   arr_time: 1220
flnr
   flight_number: "ib546"
end 

roma!F1079 in city!con_to with
departure
   dept_time: 1800
arrival
   arr_time: 1930
flnr
   flight_number: "lh303"
end 

leipzig!F1080 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2100
flnr
   flight_number: "if6220"
end 

stuttgart!F1081 in city!con_to with
departure
   dept_time: 1135
arrival
   arr_time: 1245
flnr
   flight_number: "ba3084"
end 

newyork!F1082 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 1050
flnr
   flight_number: "lh403"
end 

frankfurt!F1083 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1040
flnr
   flight_number: "lh938"
end 

frankfurt!F1084 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1200
flnr
   flight_number: "lh338"
end 

madrid!F1085 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1735
flnr
   flight_number: "lh169"
end 

muenchen!F1086 in city!con_to with
departure
   dept_time: 1815
arrival
   arr_time: 1915
flnr
   flight_number: "lh070"
end 

london!F1087 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1550
flnr
   flight_number: "ba750"
end 

frankfurt!F1088 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1150
flnr
   flight_number: "ba725"
end 

frankfurt!F1089 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2040
flnr
   flight_number: "snlh986"
end 

hamburg!F1090 in city!con_to with
departure
   dept_time: 630
arrival
   arr_time: 745
flnr
   flight_number: "lh992"
end 

frankfurt!F1091 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1500
flnr
   flight_number: "lh212"
end 

koeln_bonn!F1092 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1805
flnr
   flight_number: "ba3024"
end 

frankfurt!F1093 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 1800
flnr
   flight_number: "dw137"
end 

frankfurt!F1094 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1500
flnr
   flight_number: "lh212"
end 

muenster!F1095 in city!con_to with
departure
   dept_time: 1745
arrival
   arr_time: 1920
flnr
   flight_number: "dw126"
end 

paris!F1096 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1825
flnr
   flight_number: "af758"
end 

duesseldorf!F1097 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2055
flnr
   flight_number: "lh982"
end 

koeln_bonn!F1098 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2030
flnr
   flight_number: "lh1805"
end 

frankfurt!F1099 in city!con_to with
departure
   dept_time: 710
arrival
   arr_time: 800
flnr
   flight_number: "lh959"
end 

helsinki!F1100 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 830
flnr
   flight_number: "ay821"
end 

frankfurt!F1101 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 1945
flnr
   flight_number: "vg113"
end 

genova!F1102 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 2010
flnr
   flight_number: "lh305"
end 

duesseldorf!F1103 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1030
flnr
   flight_number: "af762"
end 

frankfurt!F1104 in city!con_to with
departure
   dept_time: 1740
arrival
   arr_time: 1835
flnr
   flight_number: "lh969"
end 

venezia!F1105 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1415
flnr
   flight_number: "lh293"
end 

laspalmas!F1106 in city!con_to with
departure
   dept_time: 755
arrival
   arr_time: 1440
flnr
   flight_number: "ib524"
end 

muenchen!F1107 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1955
flnr
   flight_number: "lh329"
end 

frankfurt!F1108 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 255
flnr
   flight_number: "lh480"
end 

glasgow!F1109 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 1235
flnr
   flight_number: "ba956"
end 

leningrad!F1110 in city!con_to with
departure
   dept_time: 2145
arrival
   arr_time: 2250
flnr
   flight_number: "lh343"
end 

stuttgart!F1111 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2020
flnr
   flight_number: "lh748"
end 

duesseldorf!F1112 in city!con_to with
departure
   dept_time: 1400
arrival
   arr_time: 1455
flnr
   flight_number: "lh018"
end 

zuerich!F1113 in city!con_to with
departure
   dept_time: 1155
arrival
   arr_time: 1245
flnr
   flight_number: "sr554"
end 

hannover!F1114 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1600
flnr
   flight_number: "ba3062"
end 

hamburg!F1115 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 920
flnr
   flight_number: "lh040"
end 

wien!F1116 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 2145
flnr
   flight_number: "lh1381"
end 

frankfurt!F1117 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1220
flnr
   flight_number: "az425"
end 

hamburg!F1118 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 945
flnr
   flight_number: "lh326"
end 

kobenhavn!F1119 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1610
flnr
   flight_number: "sk633"
end 

nuernberg!F1120 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1030
flnr
   flight_number: "ns203"
end 

nuernberg!F1121 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1125
flnr
   flight_number: "dw088"
end 

stuttgart!F1122 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 1020
flnr
   flight_number: "dw074"
end 

helgoland!F1123 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1610
flnr
   flight_number: "du031"
end 

duesseldorf!F1124 in city!con_to with
departure
   dept_time: 2050
arrival
   arr_time: 2155
flnr
   flight_number: "lh021"
end 

dubrovnik!F1125 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1325
flnr
   flight_number: "ju362"
end 

stuttgart!F1126 in city!con_to with
departure
   dept_time: 1730
arrival
   arr_time: 1805
flnr
   flight_number: "lh066"
end 

hamburg!F1127 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2005
flnr
   flight_number: "lh029"
end 

bogota!F1128 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1800
flnr
   flight_number: "av010"
end 

nuernberg!F1129 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1330
flnr
   flight_number: "pa672"
end 

zagreb!F1130 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1325
flnr
   flight_number: "ju356"
end 

frankfurt!F1131 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1930
flnr
   flight_number: "vg213"
end 

berlin!F1132 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1130
flnr
   flight_number: "da783"
end 

stuttgart!F1133 in city!con_to with
departure
   dept_time: 1045
arrival
   arr_time: 1130
flnr
   flight_number: "lh746"
end 

nuernberg!F1134 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1700
flnr
   flight_number: "lh1898"
end 

frankfurt!F1135 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 2050
flnr
   flight_number: "lh382"
end 

hannover!F1136 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1120
flnr
   flight_number: "lh1977"
end 

alger!F1137 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1525
flnr
   flight_number: "lh339"
end 

milano!F1138 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2055
flnr
   flight_number: "az428"
end 

frankfurt!F1139 in city!con_to with
departure
   dept_time: 1655
arrival
   arr_time: 2050
flnr
   flight_number: "lh380"
end 

hannover!F1140 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 905
flnr
   flight_number: "lh957"
end 

atlanta!F1141 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 1125
flnr
   flight_number: "lh419"
end 

muenchen!F1142 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1350
flnr
   flight_number: "lh809"
end 

kobenhavn!F1143 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1235
flnr
   flight_number: "sk645"
end 

stuttgart!F1144 in city!con_to with
departure
   dept_time: 835
arrival
   arr_time: 945
flnr
   flight_number: "lh260"
end 

bruxelles!F1145 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 835
flnr
   flight_number: "sn735"
end 

glasgow!F1146 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 2010
flnr
   flight_number: "ba924"
end 

london!F1147 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1255
flnr
   flight_number: "lh041"
end 

stuttgart!F1148 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1755
flnr
   flight_number: "dw076"
end 

frankfurt!F1149 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 2040
flnr
   flight_number: "az455"
end 

frankfurt!F1150 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 910
flnr
   flight_number: "af741"
end 

ljubljana!F1151 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1110
flnr
   flight_number: "jp950"
end 

berlin!F1152 in city!con_to with
departure
   dept_time: 855
arrival
   arr_time: 1100
flnr
   flight_number: "pa671"
end 

stuttgart!F1153 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 745
flnr
   flight_number: "lh745"
end 

paris!F1154 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 1020
flnr
   flight_number: "lh121"
end 

stuttgart!F1155 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2220
flnr
   flight_number: "lh288"
end 

frankfurt!F1156 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1025
flnr
   flight_number: "ns101"
end 

frankfurt!F1157 in city!con_to with
departure
   dept_time: 740
arrival
   arr_time: 835
flnr
   flight_number: "lh960"
end 

stuttgart!F1158 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1345
flnr
   flight_number: "pa90"
end 

manchester!F1159 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1245
flnr
   flight_number: "ba960"
end 

graz!F1160 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1950
flnr
   flight_number: "lh269"
end 

praha!F1161 in city!con_to with
departure
   dept_time: 1345
arrival
   arr_time: 1450
flnr
   flight_number: "ok730"
end 

stuttgart!F1162 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1525
flnr
   flight_number: "lh747"
end 

berlin!F1163 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2035
flnr
   flight_number: "ba3027"
end 

bruxelles!F1164 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1925
flnr
   flight_number: "lh107"
end 

koeln_bonn!F1165 in city!con_to with
departure
   dept_time: 1505
arrival
   arr_time: 1605
flnr
   flight_number: "lh832"
end 

budapest!F1166 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1725
flnr
   flight_number: "ma530"
end 

atlanta!F1167 in city!con_to with
departure
   dept_time: 2115
arrival
   arr_time: 1125
flnr
   flight_number: "lh439"
end 

frankfurt!F1168 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 950
flnr
   flight_number: "os410"
end 

frankfurt!F1169 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1755
flnr
   flight_number: "lh268"
end 

basel!F1170 in city!con_to with
departure
   dept_time: 1055
arrival
   arr_time: 1205
flnr
   flight_number: "lx5654"
end 

muenchen!F1171 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1055
flnr
   flight_number: "lh812"
end 

frankfurt!F1172 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1055
flnr
   flight_number: "lh350"
end 

frankfurt!F1173 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1010
flnr
   flight_number: "lhsn100"
end 

frankfurt!F1174 in city!con_to with
departure
   dept_time: 1650
arrival
   arr_time: 1745
flnr
   flight_number: "lh104"
end 

zagreb!F1175 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1325
flnr
   flight_number: "ju362"
end 

hamburg!F1176 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1105
flnr
   flight_number: "pa604"
end 

bilbao!F1177 in city!con_to with
departure
   dept_time: 1110
arrival
   arr_time: 1435
flnr
   flight_number: "ib676"
end 

kobenhavn!F1178 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1935
flnr
   flight_number: "sk651"
end 

frankfurt!F1179 in city!con_to with
departure
   dept_time: 1440
arrival
   arr_time: 1535
flnr
   flight_number: "lh965"
end 

borkum!F1180 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1620
flnr
   flight_number: "du035"
end 

koeln_bonn!F1181 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1130
flnr
   flight_number: "lh1989"
end 

berlin!F1182 in city!con_to with
departure
   dept_time: 1315
arrival
   arr_time: 1430
flnr
   flight_number: "ba3087"
end 

berlin!F1183 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 955
flnr
   flight_number: "pa605"
end 

helsinki!F1184 in city!con_to with
departure
   dept_time: 1805
arrival
   arr_time: 1940
flnr
   flight_number: "aylh823"
end 

madrid!F1185 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1515
flnr
   flight_number: "ib542"
end 

oslo!F1186 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1620
flnr
   flight_number: "sk663"
end 

madrid!F1187 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1515
flnr
   flight_number: "ib538"
end 

london!F1188 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1700
flnr
   flight_number: "ba774"
end 

kobenhavn!F1189 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1235
flnr
   flight_number: "sk645"
end 

bruxelles!F1190 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1905
flnr
   flight_number: "sn739"
end 

madrid!F1191 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1515
flnr
   flight_number: "ib540"
end 

bogota!F1192 in city!con_to with
departure
   dept_time: 1055
arrival
   arr_time: 700
flnr
   flight_number: "lh517"
end 

pisa!F1193 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1440
flnr
   flight_number: "az424"
end 

amsterdam!F1194 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1025
flnr
   flight_number: "lh1391"
end 

frankfurt!F1195 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1530
flnr
   flight_number: "ib529"
end 

saarbruecken!F1196 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 935
flnr
   flight_number: "dw010"
end 

barcelona!F1197 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1240
flnr
   flight_number: "ib528"
end 

frankfurt!F1198 in city!con_to with
departure
   dept_time: 1325
arrival
   arr_time: 1530
flnr
   flight_number: "ib533"
end 

barcelona!F1199 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1240
flnr
   flight_number: "ib532"
end 

goeteborg!F1200 in city!con_to with
departure
   dept_time: 835
arrival
   arr_time: 1010
flnr
   flight_number: "lh003"
end 

duesseldorf!F1201 in city!con_to with
departure
   dept_time: 1405
arrival
   arr_time: 1920
flnr
   flight_number: "lh348"
end 

oslo!F1202 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1900
flnr
   flight_number: "lh025"
end 

budapest!F1203 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1420
flnr
   flight_number: "lh359"
end 

wien!F1204 in city!con_to with
departure
   dept_time: 1020
arrival
   arr_time: 1145
flnr
   flight_number: "lh253"
end 

oslo!F1205 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1620
flnr
   flight_number: "sk663"
end 

frankfurt!F1206 in city!con_to with
departure
   dept_time: 2115
arrival
   arr_time: 2220
flnr
   flight_number: "os436"
end 

manchester!F1207 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1325
flnr
   flight_number: "ba958"
end 

stuttgart!F1208 in city!con_to with
departure
   dept_time: 1210
arrival
   arr_time: 1510
flnr
   flight_number: "az443"
end 

lisboa!F1209 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1530
flnr
   flight_number: "tp582"
end 

berlin!F1210 in city!con_to with
departure
   dept_time: 910
arrival
   arr_time: 955
flnr
   flight_number: "pa605"
end 

paris!F1211 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 845
flnr
   flight_number: "af752"
end 

tunis!F1212 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1510
flnr
   flight_number: "lh333"
end 

torino!F1213 in city!con_to with
departure
   dept_time: 701
arrival
   arr_time: 815
flnr
   flight_number: "lh283"
end 

amsterdam!F1214 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1055
flnr
   flight_number: "lh1395"
end 

oslo!F1215 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1420
flnr
   flight_number: "lh391"
end 

frankfurt!F1216 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1325
flnr
   flight_number: "lh906"
end 

kobenhavn!F1217 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1935
flnr
   flight_number: "sk651"
end 

frankfurt!F1218 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1555
flnr
   flight_number: "lz128"
end 

hamburg!F1219 in city!con_to with
departure
   dept_time: 1025
arrival
   arr_time: 1105
flnr
   flight_number: "pa604"
end 

paderborn!F1220 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 925
flnr
   flight_number: "vg210"
end 

amsterdam!F1221 in city!con_to with
departure
   dept_time: 1455
arrival
   arr_time: 1600
flnr
   flight_number: "lh085"
end 

muenster!F1222 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 1005
flnr
   flight_number: "dw122"
end 

frankfurt!F1223 in city!con_to with
departure
   dept_time: 1220
arrival
   arr_time: 1350
flnr
   flight_number: "ju359"
end 

frankfurt!F1224 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1635
flnr
   flight_number: "lh966"
end 

berlin!F1225 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 730
flnr
   flight_number: "pa603"
end 

stuttgart!F1226 in city!con_to with
departure
   dept_time: 1915
arrival
   arr_time: 2015
flnr
   flight_number: "lh843"
end 

stuttgart!F1227 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1655
flnr
   flight_number: "lh1946"
end 

glasgow!F1228 in city!con_to with
departure
   dept_time: 1855
arrival
   arr_time: 2210
flnr
   flight_number: "lh1367"
end 

stuttgart!F1229 in city!con_to with
departure
   dept_time: 635
arrival
   arr_time: 735
flnr
   flight_number: "lh840"
end 

frankfurt!F1230 in city!con_to with
departure
   dept_time: 1940
arrival
   arr_time: 2035
flnr
   flight_number: "lh971"
end 

faro!F1231 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1545
flnr
   flight_number: "tp590"
end 

milano!F1232 in city!con_to with
departure
   dept_time: 1145
arrival
   arr_time: 1310
flnr
   flight_number: "lh279"
end 

frankfurt!F1233 in city!con_to with
departure
   dept_time: 1220
arrival
   arr_time: 1350
flnr
   flight_number: "ju369"
end 

frankfurt!F1234 in city!con_to with
departure
   dept_time: 2030
arrival
   arr_time: 2125
flnr
   flight_number: "sr539"
end 

birmingham!F1235 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1545
flnr
   flight_number: "ba956"
end 

moskva!F1236 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1150
flnr
   flight_number: "su257"
end 

frankfurt!F1237 in city!con_to with
departure
   dept_time: 805
arrival
   arr_time: 850
flnr
   flight_number: "lh900"
end 

madrid!F1238 in city!con_to with
departure
   dept_time: 1735
arrival
   arr_time: 1955
flnr
   flight_number: "lh167"
end 

sanjuan!F1239 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2255
flnr
   flight_number: "lh516"
end 

frankfurt!F1240 in city!con_to with
departure
   dept_time: 1545
arrival
   arr_time: 1840
flnr
   flight_number: "ib519"
end 

barcelona!F1241 in city!con_to with
departure
   dept_time: 1030
arrival
   arr_time: 1220
flnr
   flight_number: "ib546"
end 

koeln_bonn!F1242 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1220
flnr
   flight_number: "lo256"
end 

geneve!F1243 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 820
flnr
   flight_number: "lh249"
end 

hamburg!F1244 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1850
flnr
   flight_number: "ba737"
end 

milano!F1245 in city!con_to with
departure
   dept_time: 1435
arrival
   arr_time: 1555
flnr
   flight_number: "lh275"
end 

hamburg!F1246 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1915
flnr
   flight_number: "lh044"
end 

frankfurt!F1247 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1100
flnr
   flight_number: "az427"
end 

frankfurt!F1248 in city!con_to with
departure
   dept_time: 900
arrival
   arr_time: 1020
flnr
   flight_number: "lh250"
end 

oslo!F1249 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1420
flnr
   flight_number: "lh391"
end 

hamburg!F1250 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1405
flnr
   flight_number: "lh042"
end 

zuerich!F1251 in city!con_to with
departure
   dept_time: 735
arrival
   arr_time: 845
flnr
   flight_number: "sr510"
end 

zuerich!F1252 in city!con_to with
departure
   dept_time: 1945
arrival
   arr_time: 2055
flnr
   flight_number: "lh237"
end 

bayreuth!F1253 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1025
flnr
   flight_number: "ns101"
end 

dallas!F1254 in city!con_to with
departure
   dept_time: 2255
arrival
   arr_time: 1525
flnr
   flight_number: "lh481"
end 

wien!F1255 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 2005
flnr
   flight_number: "os443"
end 

stuttgart!F1256 in city!con_to with
departure
   dept_time: 820
arrival
   arr_time: 905
flnr
   flight_number: "lh454"
end 

borkum!F1257 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1200
flnr
   flight_number: "du015"
end 

duesseldorf!F1258 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 745
flnr
   flight_number: "lh829"
end 

moskva!F1259 in city!con_to with
departure
   dept_time: 945
arrival
   arr_time: 1115
flnr
   flight_number: "su255"
end 

frankfurt!F1260 in city!con_to with
departure
   dept_time: 1250
arrival
   arr_time: 1555
flnr
   flight_number: "lh304"
end 

hannover!F1261 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2215
flnr
   flight_number: "af777"
end 

amsterdam!F1262 in city!con_to with
departure
   dept_time: 2040
arrival
   arr_time: 2135
flnr
   flight_number: "lh091"
end 

bologna!F1263 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1440
flnr
   flight_number: "az424"
end 

frankfurt!F1264 in city!con_to with
departure
   dept_time: 1405
arrival
   arr_time: 1520
flnr
   flight_number: "az465"
end 

hamburg!F1265 in city!con_to with
departure
   dept_time: 1930
arrival
   arr_time: 2010
flnr
   flight_number: "pa614"
end 

wien!F1266 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1945
flnr
   flight_number: "os413"
end 

milano!F1267 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 930
flnr
   flight_number: "lh277"
end 

hamburg!F1268 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1530
flnr
   flight_number: "pa610"
end 

berlin!F1269 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 935
flnr
   flight_number: "ba3003"
end 

frankfurt!F1270 in city!con_to with
departure
   dept_time: 1235
arrival
   arr_time: 1650
flnr
   flight_number: "lh314"
end 

athine!F1271 in city!con_to with
departure
   dept_time: 1555
arrival
   arr_time: 1955
flnr
   flight_number: "lh329"
end 

stuttgart!F1272 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1730
flnr
   flight_number: "lh921"
end 

stuttgart!F1273 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1930
flnr
   flight_number: "lh923"
end 

frankfurt!F1274 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1020
flnr
   flight_number: "lh902"
end 

frankfurt!F1275 in city!con_to with
departure
   dept_time: 2120
arrival
   arr_time: 2210
flnr
   flight_number: "dw139"
end 

wien!F1276 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2025
flnr
   flight_number: "lh261"
end 

helsinki!F1277 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1500
flnr
   flight_number: "lh027"
end 

stuttgart!F1278 in city!con_to with
departure
   dept_time: 635
arrival
   arr_time: 730
flnr
   flight_number: "lh918"
end 

hamburg!F1279 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 2145
flnr
   flight_number: "pa616"
end 

frankfurt!F1280 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2140
flnr
   flight_number: "lh907"
end 

wien!F1281 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 900
flnr
   flight_number: "os411"
end 

hamburg!F1282 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1240
flnr
   flight_number: "pa606"
end 

hamburg!F1283 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1045
flnr
   flight_number: "lh939"
end 

wien!F1284 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 900
flnr
   flight_number: "os419"
end 

hamburg!F1285 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 840
flnr
   flight_number: "pa602"
end 

frankfurt!F1286 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1330
flnr
   flight_number: "pa672"
end 

frankfurt!F1287 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1345
flnr
   flight_number: "lh903"
end 

duesseldorf!F1288 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1150
flnr
   flight_number: "lh732"
end 

stockholm!F1289 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 1105
flnr
   flight_number: "lh019"
end 

porto!F1290 in city!con_to with
departure
   dept_time: 830
arrival
   arr_time: 1220
flnr
   flight_number: "tp580"
end 

muenchen!F1291 in city!con_to with
departure
   dept_time: 2100
arrival
   arr_time: 2215
flnr
   flight_number: "lh799"
end 

bruxelles!F1292 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 925
flnr
   flight_number: "sn753"
end 

london!F1293 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1710
flnr
   flight_number: "lh053"
end 

casablanca!F1294 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1405
flnr
   flight_number: "lh381"
end 

berlin!F1295 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1120
flnr
   flight_number: "pa607"
end 

duesseldorf!F1296 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1755
flnr
   flight_number: "su202"
end 

frankfurt!F1297 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1710
flnr
   flight_number: "tp583"
end 

ibiza!F1298 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1455
flnr
   flight_number: "lh185"
end 

frankfurt!F1299 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1235
flnr
   flight_number: "lh400"
end 

hamburg!F1300 in city!con_to with
departure
   dept_time: 915
arrival
   arr_time: 1005
flnr
   flight_number: "lh912"
end 

frankfurt!F1301 in city!con_to with
departure
   dept_time: 2125
arrival
   arr_time: 2230
flnr
   flight_number: "sr545"
end 

warszawa!F1302 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1635
flnr
   flight_number: "l0255"
end 

hamburg!F1303 in city!con_to with
departure
   dept_time: 1125
arrival
   arr_time: 1205
flnr
   flight_number: "hx113"
end 

muenchen!F1304 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1845
flnr
   flight_number: "lh335"
end 

hamburg!F1305 in city!con_to with
departure
   dept_time: 935
arrival
   arr_time: 1235
flnr
   flight_number: "lh028"
end 

leipzig!F1306 in city!con_to with
departure
   dept_time: 1335
arrival
   arr_time: 1500
flnr
   flight_number: "lh589"
end 

koeln_bonn!F1307 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1405
flnr
   flight_number: "ba3006"
end 

berlin!F1308 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1220
flnr
   flight_number: "af765"
end 

frankfurt!F1309 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1655
flnr
   flight_number: "lh904"
end 

stockholm!F1310 in city!con_to with
departure
   dept_time: 745
arrival
   arr_time: 920
flnr
   flight_number: "lh019"
end 

frankfurt!F1311 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1650
flnr
   flight_number: "ok731"
end 

muenchen!F1312 in city!con_to with
departure
   dept_time: 835
arrival
   arr_time: 955
flnr
   flight_number: "lh794"
end 

stuttgart!F1313 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2150
flnr
   flight_number: "pa668"
end 

muenchen!F1314 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1715
flnr
   flight_number: "lh734"
end 

hamburg!F1315 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1315
flnr
   flight_number: "ba733"
end 

muenchen!F1316 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1520
flnr
   flight_number: "lh430"
end 

muenchen!F1317 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1955
flnr
   flight_number: "lh798"
end 

bogota!F1318 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1605
flnr
   flight_number: "lh515"
end 

venezia!F1319 in city!con_to with
departure
   dept_time: 800
arrival
   arr_time: 920
flnr
   flight_number: "az464"
end 

stuttgart!F1320 in city!con_to with
departure
   dept_time: 2020
arrival
   arr_time: 2155
flnr
   flight_number: "sn988"
end 

dortmund!F1321 in city!con_to with
departure
   dept_time: 1735
arrival
   arr_time: 1820
flnr
   flight_number: "vg112"
end 

berlin!F1322 in city!con_to with
departure
   dept_time: 1520
arrival
   arr_time: 1635
flnr
   flight_number: "ba877"
end 

duesseldorf!F1323 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1745
flnr
   flight_number: "af764"
end 

paderborn!F1324 in city!con_to with
departure
   dept_time: 1700
arrival
   arr_time: 1745
flnr
   flight_number: "vg212"
end 

frankfurt!F1325 in city!con_to with
departure
   dept_time: 1245
arrival
   arr_time: 1345
flnr
   flight_number: "pa642"
end 

kobenhavn!F1326 in city!con_to with
departure
   dept_time: 1625
arrival
   arr_time: 1750
flnr
   flight_number: "sk1635"
end 

muenchen!F1327 in city!con_to with
departure
   dept_time: 1120
arrival
   arr_time: 1215
flnr
   flight_number: "lh754"
end 

stuttgart!F1328 in city!con_to with
departure
   dept_time: 650
arrival
   arr_time: 800
flnr
   flight_number: "lh788"
end 

hannover!F1329 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1945
flnr
   flight_number: "lhsr569"
end 

hannover!F1330 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 920
flnr
   flight_number: "lhsr567"
end 

muenchen!F1331 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1715
flnr
   flight_number: "lh759"
end 

frankfurt!F1332 in city!con_to with
departure
   dept_time: 1405
arrival
   arr_time: 1855
flnr
   flight_number: "su656"
end 

berlin!F1333 in city!con_to with
departure
   dept_time: 855
arrival
   arr_time: 1000
flnr
   flight_number: "pa671"
end 

palma!F1334 in city!con_to with
departure
   dept_time: 1450
arrival
   arr_time: 1855
flnr
   flight_number: "lh183"
end 

hannover!F1335 in city!con_to with
departure
   dept_time: 1745
arrival
   arr_time: 1845
flnr
   flight_number: "lh398"
end 

koeln_bonn!F1336 in city!con_to with
departure
   dept_time: 1205
arrival
   arr_time: 1305
flnr
   flight_number: "lh168"
end 

barcelona!F1337 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1230
flnr
   flight_number: "ib548"
end 

muenchen!F1338 in city!con_to with
departure
   dept_time: 1635
arrival
   arr_time: 1755
flnr
   flight_number: "lh797"
end 

hamburg!F1339 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1345
flnr
   flight_number: "lh995"
end 

berlin!F1340 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1935
flnr
   flight_number: "af767"
end 

kobenhavn!F1341 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2030
flnr
   flight_number: "sk665"
end 

berlin!F1342 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2035
flnr
   flight_number: "pa617"
end 

berlin!F1343 in city!con_to with
departure
   dept_time: 1910
arrival
   arr_time: 2015
flnr
   flight_number: "pa677"
end 

nuernberg!F1344 in city!con_to with
departure
   dept_time: 1905
arrival
   arr_time: 2030
flnr
   flight_number: "af759"
end 

norderney!F1345 in city!con_to with
departure
   dept_time: 1515
arrival
   arr_time: 1620
flnr
   flight_number: "du033"
end 

hannover!F1346 in city!con_to with
departure
   dept_time: 1015
arrival
   arr_time: 1130
flnr
   flight_number: "sr581"
end 

ibiza!F1347 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 1240
flnr
   flight_number: "ib532"
end 

koeln_bonn!F1348 in city!con_to with
departure
   dept_time: 2105
arrival
   arr_time: 2205
flnr
   flight_number: "ba3028"
end 

duesseldorf!F1349 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2025
flnr
   flight_number: "lh733"
end 

bogota!F1350 in city!con_to with
departure
   dept_time: 1830
arrival
   arr_time: 1605
flnr
   flight_number: "av010"
end 

frankfurt!F1351 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 1700
flnr
   flight_number: "lh598"
end 

muenchen!F1352 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1415
flnr
   flight_number: "lh756"
end 

berlin!F1353 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1435
flnr
   flight_number: "ba3015"
end 

frankfurt!F1354 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1410
flnr
   flight_number: "lh242"
end 

frankfurt!F1355 in city!con_to with
departure
   dept_time: 1330
arrival
   arr_time: 1420
flnr
   flight_number: "dw133"
end 

koeln_bonn!F1356 in city!con_to with
departure
   dept_time: 1905
arrival
   arr_time: 2005
flnr
   flight_number: "ba3026"
end 

hannover!F1357 in city!con_to with
departure
   dept_time: 645
arrival
   arr_time: 750
flnr
   flight_number: "lh833"
end 

hamburg!F1358 in city!con_to with
departure
   dept_time: 2000
arrival
   arr_time: 2100
flnr
   flight_number: "lh713"
end 

frankfurt!F1359 in city!con_to with
departure
   dept_time: 1240
arrival
   arr_time: 1335
flnr
   flight_number: "lh451"
end 

stuttgart!F1360 in city!con_to with
departure
   dept_time: 1750
arrival
   arr_time: 1900
flnr
   flight_number: "lh792"
end 

frankfurt!F1361 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2150
flnr
   flight_number: "lh006"
end 

wien!F1362 in city!con_to with
departure
   dept_time: 1850
arrival
   arr_time: 2015
flnr
   flight_number: "lh257"
end 

zuerich!F1363 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 840
flnr
   flight_number: "sr586"
end 

hannover!F1364 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1505
flnr
   flight_number: "ay826"
end 

hannover!F1365 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2015
flnr
   flight_number: "sk616"
end 

geneve!F1366 in city!con_to with
departure
   dept_time: 1835
arrival
   arr_time: 1945
flnr
   flight_number: "sr544"
end 

hamburg!F1367 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1600
flnr
   flight_number: "lh708"
end 

saarbruecken!F1368 in city!con_to with
departure
   dept_time: 1845
arrival
   arr_time: 1935
flnr
   flight_number: "dw138"
end 

london!F1369 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 2105
flnr
   flight_number: "lh071"
end 

berlin!F1370 in city!con_to with
departure
   dept_time: 720
arrival
   arr_time: 1015
flnr
   flight_number: "af763"
end 

athine!F1371 in city!con_to with
departure
   dept_time: 1355
arrival
   arr_time: 1750
flnr
   flight_number: "lh311 / lh807"
end 

milano!F1372 in city!con_to with
departure
   dept_time: 1955
arrival
   arr_time: 2050
flnr
   flight_number: "lh289"
end 

frankfurt!F1373 in city!con_to with
departure
   dept_time: 950
arrival
   arr_time: 1035
flnr
   flight_number: "vg111"
end 

hannover!F1374 in city!con_to with
departure
   dept_time: 1925
arrival
   arr_time: 2055
flnr
   flight_number: "lh1958"
end 

bordeaux!F1375 in city!con_to with
departure
   dept_time: 1620
arrival
   arr_time: 1845
flnr
   flight_number: "af1742"
end 

frankfurt!F1376 in city!con_to with
departure
   dept_time: 1610
arrival
   arr_time: 1700
flnr
   flight_number: "lh967"
end 

paris!F1377 in city!con_to with
departure
   dept_time: 1825
arrival
   arr_time: 1925
flnr
   flight_number: "af750"
end 

stuttgart!F1378 in city!con_to with
departure
   dept_time: 1150
arrival
   arr_time: 1455
flnr
   flight_number: "lh024"
end 

frankfurt!F1379 in city!con_to with
departure
   dept_time: 1320
arrival
   arr_time: 1400
flnr
   flight_number: "lh455"
end 

berlin!F1380 in city!con_to with
departure
   dept_time: 2100
arrival
   arr_time: 2145
flnr
   flight_number: "pa619"
end 

hannover!F1381 in city!con_to with
departure
   dept_time: 1725
arrival
   arr_time: 1825
flnr
   flight_number: "lh958"
end 

frankfurt!F1382 in city!con_to with
departure
   dept_time: 2125
arrival
   arr_time: 2220
flnr
   flight_number: "lh972"
end 

lyon!F1383 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 840
flnr
   flight_number: "af1780"
end 

duesseldorf!F1384 in city!con_to with
departure
   dept_time: 1425
arrival
   arr_time: 1515
flnr
   flight_number: "lh730"
end 

duesseldorf!F1385 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1055
flnr
   flight_number: "lh783"
end 

frankfurt!F1386 in city!con_to with
departure
   dept_time: 840
arrival
   arr_time: 935
flnr
   flight_number: "lh961"
end 

kobenhavn!F1387 in city!con_to with
departure
   dept_time: 1625
arrival
   arr_time: 1750
flnr
   flight_number: "sk1635"
end 

hamburg!F1388 in city!con_to with
departure
   dept_time: 715
arrival
   arr_time: 755
flnr
   flight_number: "pa600"
end 

nice!F1389 in city!con_to with
departure
   dept_time: 1840
arrival
   arr_time: 2010
flnr
   flight_number: "lh151"
end 

berlin!F1390 in city!con_to with
departure
   dept_time: 1605
arrival
   arr_time: 1650
flnr
   flight_number: "pa613"
end 

berlin!F1391 in city!con_to with
departure
   dept_time: 955
arrival
   arr_time: 1100
flnr
   flight_number: "pa641"
end 

frankfurt!F1392 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1125
flnr
   flight_number: "vo442"
end 

wien!F1393 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1540
flnr
   flight_number: "lh267"
end 

kobenhavn!F1394 in city!con_to with
departure
   dept_time: 930
arrival
   arr_time: 1035
flnr
   flight_number: "sk643"
end 

saarbruecken!F1395 in city!con_to with
departure
   dept_time: 700
arrival
   arr_time: 750
flnr
   flight_number: "dw130"
end 

duesseldorf!F1396 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1220
flnr
   flight_number: "lh1003"
end 

stuttgart!F1397 in city!con_to with
departure
   dept_time: 1115
arrival
   arr_time: 1530
flnr
   flight_number: "lh408"
end 

muenster!F1398 in city!con_to with
departure
   dept_time: 1710
arrival
   arr_time: 2020
flnr
   flight_number: "ba877"
end 

kobenhavn!F1399 in city!con_to with
departure
   dept_time: 1900
arrival
   arr_time: 2030
flnr
   flight_number: "sk665"
end 

frankfurt!F1400 in city!con_to with
departure
   dept_time: 1305
arrival
   arr_time: 1405
flnr
   flight_number: "lh102"
end 

hannover!F1401 in city!con_to with
departure
   dept_time: 1950
arrival
   arr_time: 2015
flnr
   flight_number: "sk616"
end 

bruxelles!F1402 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1150
flnr
   flight_number: "lh103"
end 

frankfurt!F1403 in city!con_to with
departure
   dept_time: 2135
arrival
   arr_time: 2220
flnr
   flight_number: "lh908"
end 

frankfurt!F1404 in city!con_to with
departure
   dept_time: 1005
arrival
   arr_time: 1315
flnr
   flight_number: "af565"
end 

saarbruecken!F1405 in city!con_to with
departure
   dept_time: 1155
arrival
   arr_time: 1240
flnr
   flight_number: "dw134"
end 

athine!F1406 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1915
flnr
   flight_number: "oa169"
end 

nuernberg!F1407 in city!con_to with
departure
   dept_time: 1125
arrival
   arr_time: 1245
flnr
   flight_number: "lh1927"
end 

linz!F1408 in city!con_to with
departure
   dept_time: 1445
arrival
   arr_time: 1550
flnr
   flight_number: "lh259"
end 

muenchen!F1409 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1155
flnr
   flight_number: "lh795"
end 

frankfurt!F1410 in city!con_to with
departure
   dept_time: 2055
arrival
   arr_time: 2220
flnr
   flight_number: "ns107"
end 

sanjuan!F1411 in city!con_to with
departure
   dept_time: 1935
arrival
   arr_time: 2115
flnr
   flight_number: "lh514"
end 

wien!F1412 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 840
flnr
   flight_number: "os441"
end 

muenchen!F1413 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1815
flnr
   flight_number: "lh375"
end 

muenchen!F1414 in city!con_to with
departure
   dept_time: 1720
arrival
   arr_time: 1815
flnr
   flight_number: "lh371"
end 

beograd!F1415 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1500
flnr
   flight_number: "lh361"
end 

barcelona!F1416 in city!con_to with
departure
   dept_time: 1525
arrival
   arr_time: 1735
flnr
   flight_number: "lh175"
end 

leipzig!F1417 in city!con_to with
departure
   dept_time: 1550
arrival
   arr_time: 1915
flnr
   flight_number: "lh599"
end 

berlin!F1418 in city!con_to with
departure
   dept_time: 1535
arrival
   arr_time: 1655
flnr
   flight_number: "pa691"
end 

hannover!F1419 in city!con_to with
departure
   dept_time: 1200
arrival
   arr_time: 1505
flnr
   flight_number: "ay826"
end 

bremen!F1420 in city!con_to with
departure
   dept_time: 815
arrival
   arr_time: 930
flnr
   flight_number: "lh975"
end 

frankfurt!F1421 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 2020
flnr
   flight_number: "tp555"
end 

milano!F1422 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1625
flnr
   flight_number: "az416"
end 

linz!F1423 in city!con_to with
departure
   dept_time: 655
arrival
   arr_time: 800
flnr
   flight_number: "os435"
end 

berlin!F1424 in city!con_to with
departure
   dept_time: 615
arrival
   arr_time: 700
flnr
   flight_number: "pa601"
end 

duesseldorf!F1425 in city!con_to with
departure
   dept_time: 1135
arrival
   arr_time: 1225
flnr
   flight_number: "lh729"
end 

frankfurt!F1426 in city!con_to with
departure
   dept_time: 1840
arrival
   arr_time: 1935
flnr
   flight_number: "lh970"
end 

hannover!F1427 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1920
flnr
   flight_number: "lh590"
end 

london!F1428 in city!con_to with
departure
   dept_time: 1715
arrival
   arr_time: 1955
flnr
   flight_number: "ba758"
end 

koeln_bonn!F1429 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1025
flnr
   flight_number: "sr587"
end 

frankfurt!F1430 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1310
flnr
   flight_number: "ay822"
end 

warszawa!F1431 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1750
flnr
   flight_number: "l0253"
end 

stuttgart!F1432 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1445
flnr
   flight_number: "lh1842"
end 

muenchen!F1433 in city!con_to with
departure
   dept_time: 920
arrival
   arr_time: 1015
flnr
   flight_number: "lh752"
end 

muenchen!F1434 in city!con_to with
departure
   dept_time: 635
arrival
   arr_time: 750
flnr
   flight_number: "lh793"
end 

frankfurt!F1435 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1725
flnr
   flight_number: "lh905"
end 

frankfurt!F1436 in city!con_to with
departure
   dept_time: 725
arrival
   arr_time: 825
flnr
   flight_number: "pa656"
end 

frankfurt!F1437 in city!con_to with
departure
   dept_time: 2100
arrival
   arr_time: 2150
flnr
   flight_number: "lh826"
end 

berlin!F1438 in city!con_to with
departure
   dept_time: 1745
arrival
   arr_time: 1850
flnr
   flight_number: "pa655"
end 

stuttgart!F1439 in city!con_to with
departure
   dept_time: 850
arrival
   arr_time: 1045
flnr
   flight_number: "lh1806"
end 

frankfurt!F1440 in city!con_to with
departure
   dept_time: 1300
arrival
   arr_time: 1350
flnr
   flight_number: "lh821"
end 

wien!F1441 in city!con_to with
departure
   dept_time: 1105
arrival
   arr_time: 1225
flnr
   flight_number: "lh255"
end 

stuttgart!F1442 in city!con_to with
departure
   dept_time: 1500
arrival
   arr_time: 1610
flnr
   flight_number: "ba3088"
end 

berlin!F1443 in city!con_to with
departure
   dept_time: 1230
arrival
   arr_time: 1335
flnr
   flight_number: "pa645"
end 

duesseldorf!F1444 in city!con_to with
departure
   dept_time: 1540
arrival
   arr_time: 2045
flnr
   flight_number: "lh340"
end 

hof!F1445 in city!con_to with
departure
   dept_time: 1820
arrival
   arr_time: 1945
flnr
   flight_number: "ns106"
end 

frankfurt!F1446 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1435
flnr
   flight_number: "lh964"
end 

hof!F1447 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1225
flnr
   flight_number: "ns104"
end 

moskva!F1448 in city!con_to with
departure
   dept_time: 1920
arrival
   arr_time: 2040
flnr
   flight_number: "lh341"
end 

kobenhavn!F1449 in city!con_to with
departure
   dept_time: 730
arrival
   arr_time: 835
flnr
   flight_number: "sk641"
end 

frankfurt!F1450 in city!con_to with
departure
   dept_time: 1310
arrival
   arr_time: 1510
flnr
   flight_number: "lh200"
end 

torino!F1451 in city!con_to with
departure
   dept_time: 845
arrival
   arr_time: 1010
flnr
   flight_number: "lh1355"
end 

frankfurt!F1452 in city!con_to with
departure
   dept_time: 1050
arrival
   arr_time: 1530
flnr
   flight_number: "lh512"
end 

frankfurt!F1453 in city!con_to with
departure
   dept_time: 2045
arrival
   arr_time: 2150
flnr
   flight_number: "lh808"
end 

frankfurt!F1454 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1015
flnr
   flight_number: "lh820"
end 

madrid!F1455 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1200
flnr
   flight_number: "ib510"
end 

frankfurt!F1456 in city!con_to with
departure
   dept_time: 1630
arrival
   arr_time: 1755
flnr
   flight_number: "ns105"
end 

frankfurt!F1457 in city!con_to with
departure
   dept_time: 1340
arrival
   arr_time: 1435
flnr
   flight_number: "lh620"
end 

frankfurt!F1458 in city!con_to with
departure
   dept_time: 940
arrival
   arr_time: 1035
flnr
   flight_number: "lh322"
end 

frankfurt!F1459 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1735
flnr
   flight_number: "lh968"
end 

nice!F1460 in city!con_to with
departure
   dept_time: 1420
arrival
   arr_time: 1740
flnr
   flight_number: "af1772"
end 

dallas!F1461 in city!con_to with
departure
   dept_time: 1705
arrival
   arr_time: 1125
flnr
   flight_number: "lh439"
end 

frankfurt!F1462 in city!con_to with
departure
   dept_time: 1010
arrival
   arr_time: 1105
flnr
   flight_number: "lh334"
end 

frankfurt!F1463 in city!con_to with
departure
   dept_time: 925
arrival
   arr_time: 1010
flnr
   flight_number: "dw131"
end 

helgoland!F1464 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1215
flnr
   flight_number: "hx024"
end 

saarbruecken!F1465 in city!con_to with
departure
   dept_time: 1035
arrival
   arr_time: 1125
flnr
   flight_number: "dw132"
end 

frankfurt!F1466 in city!con_to with
departure
   dept_time: 1140
arrival
   arr_time: 1235
flnr
   flight_number: "lh962"
end 

madrid!F1467 in city!con_to with
departure
   dept_time: 1640
arrival
   arr_time: 1915
flnr
   flight_number: "ib516"
end 

berlin!F1468 in city!con_to with
departure
   dept_time: 705
arrival
   arr_time: 810
flnr
   flight_number: "pa635"
end 

paris!F1469 in city!con_to with
departure
   dept_time: 1130
arrival
   arr_time: 1325
flnr
   flight_number: "lh1325"
end 

hof!F1470 in city!con_to with
departure
   dept_time: 1100
arrival
   arr_time: 1235
flnr
   flight_number: "ns104"
end 

frankfurt!F1471 in city!con_to with
departure
   dept_time: 1255
arrival
   arr_time: 1525
flnr
   flight_number: "ib511"
end 

duesseldorf!F1472 in city!con_to with
departure
   dept_time: 1000
arrival
   arr_time: 1055
flnr
   flight_number: "lh277"
end 
