                       The True Story of SINTERKLAAS
                           narrated in O-Telos
                                  by
                  M. Jeusfeld, 1-Dec-2004 (24-Nov-2010)

Sinterklaas (or Santa Claus or Hl. Nikolaus) is visiting all persons
in the world with a gift to make them happy. But: Is there a Sinterklaas?
Maybe there are many! And if he comes, does he always come with a gift!
These centuries-old questions can now be answered with O-Telos and
ConceptBase ...

To play the story with ConceptBase (V6.1.2 or later) you
should follow these steps:

1) make sure that your computer is connected to the Internet; otherwise you miss
   the message

2) Start a ConceptBase user interface CBiva and connect it to a CBserver
   (e.g. by using the option File/Start CBserver)

3) Tell the Telos models sinterklaas.sml amd sc-gts.sml

4) Start a Graph Editor with start object 'Agent' and Palette 'Sinterklaas_Palette'

5) Show the instances of Agent: Sinterklaas and Person.
   Display Sinterklaas in a Telos Editor: you see the three main 
   requirements for a sinterklaas to exist ...

6) Show the attributes between Sinterklaas and Person: sinterklaas_visit
   Show the instances of Sinterklaas: THE_SINTERKLAAS

7) Try to enter another Sinterklaas, e.g. FAKESINTER as instance of Sinterklaas
   --> NO! There is only one!

8) Show the attributes visits of THE_SINTERKLAAS: two happy persons show up.

9) Show the attributes of the visits: both have gifts! Sinterklaas will not
    come with empty hands.

10) Show all instances of Person: Manfred will show up as unhappy person.

11) Tell the model makemehappy.sml and select
    Current connection/Validate shown objects
    --> Now, Manfred is also happy

So, what about Sinterklaas himself? Is he possibly human? Check it out:

12) Hold the shift key and click in THE_SINTERKLAAS and Person. Then press the
    button "In" right to the "Create" bar. This declares THE_SINTERKLAAS
    as instance of Person. Confirm with OK and then press 
    the symbol "->CB" to commit changes to ConceptBase.

Now, THE_SINTERKLAAS becomes an unhappy person because he would
expect himself a gift!