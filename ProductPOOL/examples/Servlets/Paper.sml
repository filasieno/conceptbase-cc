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
Class Paper with
attribute
	title : String;
	authors : String;
	conf : String;
	type : String;
	abstract : String
end

DefaultPaper in Paper with
title
	title0 : "Enter Title here"
authors
	authors0 : "Enter Authors here"
conf
	conf0 : "Enter Conference/Journal/Book Title here"
type
	type0 : "Conference"
abstract
	abstract0 : "Abstract goes here"
end

	
QueryClass AllPapers isA Paper with
retrieved_attribute
	title : String;
	authors : String;
	conf : String;
	type : String;
	abstract : String
constraint c : $ not (this == DefaultPaper) $	
end
	
GenericQueryClass GetUpdateFormPaper isA Paper with
parameter
	objname : Paper
retrieved_attribute
	title : String;
	authors : String;
	conf : String;
	type : String;
	abstract : String
constraint
	c : $ this == ~objname $
end

Order in Class end

ascending in Order end

descending in Order end


Individual AnswerFormat in Class with 
  attribute
     forQuery : QueryClass;
     order : Order;
     orderBy : String;
     head : String;
     tail : String;
     pattern : String;
     split : Boolean
end

PaperList in AnswerFormat with
forQuery
	fq: AllPapers
order	
	order : ascending
orderBy	
	orderBy : "this.authors"
head
	h : "<html><head><title> Publications </title>
</head><body background=\"http://www-i5.informatik.rwth-aachen.de/lehrstuhl/icons/i5-bg.gif\">
<BLOCKQUOTE>
<h1><a href=\"http://www-i5.informatik.rwth-aachen.de/\"><img border=0 src=\"http://www-i5.informatik.rwth-aachen.de/lehrstuhl/icons/info5logo.gif\"></a>
<P>Lehrstuhl f&uuml;r Informatik V (Informationssysteme)</P></h1>
<hr>
<h1> Publications </h1><ul>"

tail
	t: "</ul><hr>
<a href=\"http://www-i5.informatik.rwth-aachen.de/lehrstuhl/starter.html\"> <img  border=0 src=\"http://www-i5.informatik.rwth-aachen.de/lehrstuhl/icons/home.gif\">  Homepage Informatik V</a>
</BLOCKQUOTE>
</body>
</html>"
pattern
	p: "<li> {STRINGDECODING({this.authors})}:
	{STRINGDECODING({this.title})}, <i> {STRINGDECODING({this.conf})} </i>"
end


PaperHtmlForm in AnswerFormat with
forQuery
	fq: GetUpdateFormPaper
head
	h: "<html>"
tail 
	t: "</html>"
pattern
	p : "<head>
<title>Update Paper</title></head>
    
<body>
<h1>Update Paper</h1>
<form action=/servlet/cbforminsert method=POST>
<input type=hidden name=classname value=Paper>
<input type=hidden name=query value=AllPapers>
<input type=hidden name=objname value={this}>
<input type=hidden name=untell value=yes>

<BR><BR>
<table>
<tr>
<td>Title: <td><input type=text size=60 name=title value={this.title}>
<tr>
<td>Authors: <td><input type=text size=60 name=authors value={this.authors}>
<tr>
<td>Conference/Journal: <td><input type=text size=60 name=conf value={this.conf}>
<tr>
<td>Type of Publication:
<td>
Conference<input type=radio name=type value=Conference 
{IFTHENELSE({EQUAL({this.type},\"Conference\")}, checked, unchecked)}><br>
Journal<input type=radio name=type value=Journal 
{IFTHENELSE({EQUAL({this.type},\"Journal\")}, checked, unchecked)}><br>
Workshop<input type=radio name=type value=Workshop 
{IFTHENELSE({EQUAL({this.type},\"Workshop\")}, checked, unchecked)}><br>
Technical Report<input type=radio name=type value=TechReport 
{IFTHENELSE({EQUAL({this.type},\"TechReport\")}, checked, unchecked)}><br>
Book<input type=radio name=type value=Book 
{IFTHENELSE({EQUAL({this.type},\"Book\")}, checked, unchecked)}><br>

<tr><td>Abstract:
<td><textarea name=abstract rows=10 cols=60>
{STRINGDECODING({this.abstract})}
</textarea>
</table>

<BR><BR><input type=submit value=Update><input type=reset>
</form>
</body>
"
end


	
