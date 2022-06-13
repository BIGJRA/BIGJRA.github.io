#==============================================================================

# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre.  Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5.  Music can
# now be defined.  Credits can't be skipped during their first play.
#==============================================================================

class Scene_Credits
  CreditsBackgroundList = ["creditsbg"]
  CreditsMusic          = "begin"
  CreditsScrollSpeed    = 1             # At least 1; keep below 5 for legibility.
  CreditsFrequency      = 8             # Number of seconds per credits slide.
  CREDITS_OUTLINE       = [Color.new(32,32,32, 255),Color.new(16,40,36, 255),Color.new(29,26,55, 255),Color.new(66,25,16, 255),Color.new(41,10,35, 255)]
  CREDITS_SHADOW        = Color.new(0,0,0, 100)
  CREDITS_FILL          = [Color.new(255,255,255, 255),Color.new(123,142,132, 255),Color.new(130,93,177, 255),Color.new(248,95,84, 255),Color.new(102,26,48, 255)]

# This next piece of code is the credits.

#<A> for Anna
#<H> for Shade
#<L> for Lin
#<T> for Terra
#<left>
#<right>
#<s> for space

#Start Editing
CREDIT=<<_END_
*  ~  Core Development  ~  *
Amethyst 
andracass
Ikaru
Autumn
Marcello
Smeargletail
VulpesDraconis
Toothpastefairy
Crim
Azzie

- - Prior Developers - -

Kurotsune
Blind Guardian
Guhorden
Mike
Walpurgis
Mde2001
Azery
Kanaya
Lin
Koyoss

Pokémon Reborn is created using RPG Maker XP 
and the Pokémon Essentials Starter Kit. 

We do not claim ownership of the Pokémon
franchise, IP, or any associated content.

All original characters, artwork and 
media remain the property of their 
respective authors.	

*  ~  Tilesets & Mapping  ~  *
Amethyst
Crim
Smeargletail

- - Mapping Support - -
Ikaru
Autumn
Lin
Kanaya 

- - Tilesets - -
Pokémon Essentials
princess-phoenix
Lin


*  ~  Sprites  ~  *
Amethyst	
Crim
Jan	

- - 6th Gen Battlers - -
Amethyst<s>Noscium			
Quanyails<s>Zermonious		
GeoIsEvil<s>Kyle Dove	
dDialgaDiamondb<s>N-kin		
Misterreno<s>Lin
Xtreme1992<s>Vale98PM 		
MrDollSteak<s>Crim

- - 7th Gen Battlers - -
Amethyst<s>Jan			
Zumi<s>Bazaro		
Koyo<s>Smeargletail
Lin<s>Noscium		
Leparagon<s>N-kin	
fishbowlsoul90<s>princess-phoenix	
DatLopunnyTho<s>Another Lin 	
kaji atsu<s>The cynical poet	
Still Lin<s>Pokefan2000
Actually it was all Lin
Lord-Myre<s>Crim	

- - Mega Sprites - -
Still Lin<s>Bazaro			
Greyenna<s>Gardrow		
FlameJow<s>Lin	
The Cynical Poet<s>Brylark			
Lin<s>Lin	
Lin<s>Lin		
Lin<s>Lin	
Lin<s>Lin

- - Icons - -
Klaptrap
Lin	

- - Miscellaneous Sprites - -
Lin<s>Lin		
Lin<s>Lin
Lin<s>Lin			
Lin<s>Lin
Lin<s>Lin		

- - Shiny Spriting - -
Lin<s>Lin		
Lin<s>Lin
Lin<s>Lin			
Lin<s>Lin
Lin<s>Lin	
Lin<s>Lin		
Lin<s>Lin
Lin<s>Lin			
Lin<s>Lin
Lin<s>Lin	
and just liiiittle more Lin


*  ~  Animations  ~  *
Lin

...okay, i'm over it.





<L> congratulations!


<L> you're done with the game!


<L> but did you consider that maybe...

<L> ...the game's not done with you?

_END_


CREDIT1=<<_END_
*  ~  Core Development  ~  *
Amethyst 
andracass
Ikaru
Autumn
Marcello
Smeargletail
VulpesDraconis
Toothpastefairy
Crim
Azzie

- - Prior Developers - -

Kurotsune
Blind Gu rdian
Guhorden
Mike
Walpurgis
Mde2001
Azery
Kanaya
Jan
Ko oss

Po émon Reborn is created using  PG Maker XP 
and the Pokémon Essen ials St rter Kit. 

We d  not claim owners ip of  he Pokémon
fran hise, IP, or a y associat d cont nt.

A l orig nal char  ters, artw rk a d 
me ia re ain t e pro erty of their 
r s e ive aut ors.	

*  ~  T le et  & Ma pi  g  ~  *
Ame hys 
C  m
Sm a  le  i 

- - M  p ng S pport - -
Ika u
Au umn
K  a a 

- - T l se   - -
P ké  n Es  nti ls
p  n e -p o n  


*  ~   p  te   ~  *
A th s 
C i 
  n	

- - 6th Gen Battlers - -
A th s <s> o i m			
Q ny i <s> e ni s		
   I vi <s>K e D e	
 D lg Di on b<s>  k n		
Mi terr o<s>K vf  
X m 1  2<s>V e9  		
M Do   te  <s>   m

- - 7th Gen Battlers - -
A   h   <s>  n			
Z   <s>   a  
K  o<s>S   r  et   
   x<s>    i  		
    r    <s>  i 	
      w   ul 0<s>p   c   ph  n 
D   p    T  <s>    j    
     a   <s>  e      a      	
L      a   <s>    a     
     i       o               p       
      y  <s>  i 	

- -       p       - -
       t<s> 
 r     a<s>      w		
     J  <s>  n      
      c      <s> 	
          <s>      s           			
         d <s> 		
      <s>     n	
       2<s> 

- -  c     - -
           l	
   n           

- -            u         - -
    <s> e        		
    
     6  <s> 			
           <s>    h     		
 e       <s>         
    l  <s>            
    
   p        

- -             - -
 m       <s> 
 
       <s>    e      

       
      <s>   r 
      
      
      
      
      
          7<s>   
          




*  ~          s  ~  *





<A>Actually, it doesn't matter...





<A>As long as you, 
<A>No matter what,
<A>Please don't forget me...?


_END_





                                              # Cuttoff
CREDIT2=<<_END_

*  ~  Core Development  ~  *
Amethyst 
<L><left> omg, wow, big surprise
<L><left> randos, please send her dms about the game
<L><left> she loves it
andracass
<L><left> who?
Ikaru
Autumn
Marcello
Smeargletail
VulpesDraconis
Toothpastefairy
<L><left> what even is that???
<L><left> you a dentist?
<L><left> CEO of crest?
<L><left> were you a mint spirit and you just 
<L><left> stuck through the whole process?
<L><left> seriously help me out i don't understand
Crim
Azzie
<A><right> Thanks to everyone for
<A><right> helping bring us all to life!

- - Prior Developers - -
<L> where i'm from we call them "quitters"
Kurotsune
Blind Guardian
<A><right> Without him, we might not have field effects!
Guhorden
Mike
Walpurgis
Mde2001
Azery
Kanaya
Jan
<L> probably didn't have it in him
<L> not everyone can make a pokemon game!
Koyoss

<A><right>I hope you're all doing well out there!
<L> only took 'em 10 years to make this thing!

Pokémon Reborn is created using RPG Maker XP 
and the Pokémon Essentials Starter Kit. 
<A><right>Thanks for doing most of the work for us!
<L><left>taken inspiration from" is probably 
<L><left>more accurate!

We do not claim ownership of the Pokémon
franchise, IP, or any associated content.
<L><left> thanks reggy for not suing us!!!!!

All original characters, artwork and 
media remain the property of their 
respective authors.	
<A><right>Like me!
<L><left> thanks for letting me borrow your shit!
<L><left> hope you didn't hate what we did with it!

*  ~  Tilesets & Mapping  ~  *
Amethyst
Crim
Smeargletail

- - Mapping Support - -
Ikaru
Autumn
Kanaya 
<A><right>Do you KNOW how many cliffs had to be
<A><right> mapped into Tourmaline?!!
<A>
<A>
<A>
<A><right> A lot!!!
- - Tilesets - -
Pokémon Essentials
princess-phoenix
<A><right>Just for the museum, but still!


*  ~  Sprites  ~  *
Amethyst	
Crim
<A><right>Everything Crim makes is so pretty!
Jan	

- - 6th Gen Battlers - -
Amethyst<s>Noscium			
Quanyails<s>Zermonious		
GeoIsEvil<s>Kyle Dove	
dDialgaDiamondb<s>N-kin		
Misterreno<s>Kevfin
Xtreme1992<s>Vale98PM 		
MrDollSteak<s>Crim

- - 7th Gen Battlers - -
Amethyst<s>Jan			
Zumi<s>Bazaro		
Koyo<s>Smeargletail
Alex<s>Noscium		
Leparagon<s>N-kin	
fishbowlsoul90<s>princess-phoenix	
DatLopunnyTho<s>Conyjams 	
kaji atsu<s>The cynical poet	
LuigiPlayer<s>Pokefan2000
Falgaia (Smogon SuMo sprite project)
Lord-Myre<s>Crim	

- - Mega Sprites - -
Amethyst<s>Bazaro			
Greyenna<s>Gardrow		
FlameJow<s>Minhnerd	
The Cynical Poet<s>Brylark			
Leparagon<s>princess-phoenix			
Gnomowladn<s>Bryancct		
Tinivi<s>Julian	
Dante52<s>Crim
<L><left> oh my GOD how many sprites are there
<A><right> I don't know most of you people,
<A><right> But you did great!!

- - Icons - -
smeargletail	
<A><right>Seriously, do you know how many icons there are!?
ARandomTalkingBush
<A><right> A lot!!!!!!

- - Miscellaneous Sprites - -
Will<s>Veenerick		
Mektar (Pokémon Amethyst)	
JoshR691<s>kidkatt	
<A><left>He did the Steelix!
<A><left>The really big one, you know?		
ShinxLuver<s>Dr Shellos		
Getsuei-H<s>Kidkatt		
Nefalem<s>Piphybuilder88	
<A><left>We mixed you up with smeargletail at first
<A><left>But I guess it worked out!?
SageDeoxys<s>chasemortier
PurpleZaffre
<L><left> please tell me we're done

- - Shiny Spriting - -
Amethyst<s>Crim
UnprofessionalAmateur	
Nefalem<s>Jacze	Freya
Calvius<s>Flux	
Thirdbird<s>Mike		
Bazaro<s>Azery
Bakerlite<s>Gamien	
Rielly987<s>smeargletail	
Nsuprem<s>15gamer2000		
dragon in night<s>Nova		
Night Fighter<s>Serythe		
MetalKing1417<s>roqi	
Jan<s>MMM		
Kelazi5<s>Player_Null_Name	
Khrona<s>Sir_Bagel	
Pixl
<A><right>Making all the recolors as 
<A><right>a community was a lot of fun!
<A><right>Thanks for chipping in!
<L><left> finally

*  ~  Animations  ~  *
<L> the real heroes
Smeargletail
<A><right>He's the senior veteran!
Mde2001
<A><right>He made the most total!!
Autumn
<A><right>She made how many Z-moves?!
VulpesDraconis
<A><right>She's just really good at this?!
Amethyst
Crim
andracass
<L><left> lol you made like one 
<L><left> what are you doing here
Koyoss
Jan

<A><right>You know, it's kind of getting 
<A><right>a little lonely in here?
- - Sound - -
Pokémon Mystery Universe	
Amethyst
<A><right>I know!
<A><right>Mr.Shadow!!!
<A><right>You're still lurking around, right?
<A><right>Come say "Hi"!
<H>
<H>
<H>
<H><left>...
<H>
<A><right>That's kind of like "Hi"!

- - Original Rip - -
Neslug	
<A><right>Okay but you have to actually talk!
<A><right>Otherwise it's no fun.
<H><left>...?
<A><right>You can be broody on the overworld later
<A><right>Just talk a little bit for now!!!
<H>
<H>
<H>
<H>
<H><left>...Fine.
<H><left>But just for now.

*  ~  Programming  ~  *
andracass
<A><right>She basically redid half the code!
<H><left>Maybe more.
Toothpastefairy
<A><right>No, it's PERRY, get it right!!!
Marcello
Amethyst
Kurotsune
<A><right> Some say if you listen close on a quiet
<A><right> night, you can still find Kuro watching
<A><right> from the distance!
<H><left> ...
Blind Guardian
Mike
Azery
Walpurgis
<L><left> please
<L><left> they're just a bunch of text file editors

- - External Scripting Support - -
Woobowiz<s>FL				
XmarkXalanX<s>JV			
madf0x<s>Joeyhugg	
Nickaloose<s>mej71		
Suzerain<s>Rayd2smitty
Beba<s>worldslayer89	
the dekay<s>saving raven	
Truegee<s>Wootius		
Waynolt<s>AiedailEclipsed		 
enumag<s>KleinStudido
<A><left> He helped us git good!
Aeodyn<s>bluetowel
Rainbow Dash<s>Nuems
Olxinos
<A><right>Whether you knew it or not, 
<A><right>thanks for helping us out!
<L><left> if you're here, your code was probably 
<L><left> in the game at some point!

*  ~  Scenario & Eventing  ~  *
Amethyst
<L><left> yeah okay we get it you do everything
<L><left> go take a nap or something
Crim
Smeargletail
Marcello
<A><right>From writing code to writing bangers!
<T>TERRAWRRRRR!!!!!!!!
<T>
<T>
<T><right> the restraining order finally expired
<T><right> we BACK bayBEEEE
<T>RAWWWWWWWWWWWWWWWWWRRRRRRRRRRRRRRRRRRRRRR!!!!!!!!!!!!!!!!

_END_



CREDIT4=<<_END_

*  ~  Writing  ~  *
Amethyst
Azzie
<A><right>In all the myriad infinite realities,
<A><right>across all the possible dimensions,
<A><right>can anyone else but her quite ever
<A><right>be so keenly aware
<A><right>of just how much dialogue was needed
<A><right>in and around the Nightclub alone?!
andracass
Marcello
<T><right>lmao nerd
Crim


*  ~  Battle Design  ~  *
andracass
<A><right>Cass seriously made like hundreds of full teams!
Amethyst
Autumn
Crim
<L><right> where am i???????
<L><left> booooo
<L> these credits suck
<T>
<T>
<T>
<T>
<T>
<T><right> if u no what she means ;))))


*  ~  Sound & Music  ~  *
GlitchxCity
Amethyst
<A><right>Check out Glitch's Youtube channel!
<A><right>She has so many jams, you won't know
<A><right>what to spread on your toast anymore!
<H><left>I don't think that makes sense.
<A><right>It's called a play on words!!!
<A><right>I know you're allergic to words, 
<A><right>But you can still at least play!
<H><left>...Uh huh.

- - Guest Composers - - 
Dragon-Tamer795<s>O Colosso	
<A><left>Beryl Ward!
<A><right>Title screen!
RichViola
<A><left>Pokécenter!
Darius & DaforLynx
<A><right>Kiki's theme!
<T>ur mum last nite GOTT33M	


*  ~  External Resources  ~  *
Phasma<s>SunakazeKun	

- - Tile Puzzle Artists - - 
germy21<s>Macuarrorro 
Ramiro Maldini<s>Otonashi 
iamherecozidraw<s>syansyan 
Sires J Black 
<L><left> they made the pictures you checked in the folders

*  ~  Community Support  ~  *
<A><right>It's really general but it's just people 
<A><right>who helped out!
bluebomberdude<s>Ikaru	
<A><right>Dr. Double  Space!!!	
zelient<s>Jacze		
Flux<s>jeroen4923
Khayoz<s>Cobrakill
Ryan C<s>Cowtao
Manes<s>Calvius	
garchomp550<s>MattMadnesS
Guigui<s>DarkLucario79		
grasssnake485<s>Acquiescence
SonOfRed<s>Rimmintine	
Arkhidon<s>Mike		
Tacos&Flowers<s>Vinny				
chase_breaker<s>Sheep!	
Kalzuna<s>Pyrolusite
<A><right>Thanks for the UI!
Alex<s>cybershell12		
BIGJRA<s>Haru	
<A><right>Also thanks for the randomizer!
TheInsurgent
Many, many, many more!

<T><right> im am living in ur credits

*  ~  Meme Consultant  ~  *
Autumn
<L>Lin

*  ~  Quality Assurance  ~  *
Thanks so much to the community and our 
supporters for all the care and 
patience demonstrated with testing and 
reporting issues over the years!
<A><right>By the way, why do we call glitches bugs?
<H><left>The earliest technical issues were caused
<H><left>by literal insects that would get stuck
<H><left>inside servers. It was literal.
<A><right>Okay, sure, that's cool and all
<A><right>But consider this, right?
<A><right>Cats.
<A><right>It's both cuter and funnier to imagine
<A><right>problems as Cats instead of Bugs.
<A><right>By the power vested in me by
<A><right>Um, me but from before the credits rolled--
<A><right>I hereby declare the words reversed
<A><right>and hence forth bugs are to be called
<A><right>cats from now on!
<H><left> ...

- - On-board QA - - 
Ikaru
<A><right>He suffered so you didn't have to,
<A><right>By finding CATS!!!

- - Supervised Guinea Pigs - - 
Ikaru
Autumn
Blind Guardian
<L><left>he can't be very good at it if he's blind!!

- - Superstar Modders - - 
enumag
AiedailEclipsed
<A><right>Thank you for the patcher~ <3  
Bluetowel
<A><right> Oh, that's where the dishes went!
Waynolt
Haru
<T><left> so RAndOM xD spork !!

- - Support Squad - - 
Ikaru
enumag
AiedailEclipsed
AyTales
Azery
Felicity


*  ~  Pokémon Essentials  ~  *
Maruno
Poccil
Flameguru

- - With contributions from - - 
AvatarMonkeyKirby<s>MiDas Mike
Boushy<s>Near Fantastica
Brother1440<s>PinkMan
FL.<s>Popper
Genzai Kawakami<s>Rataime
Harshboy<s>SoundSpawn
help-14<s>the__end
IceGod64<s>Venom12
Jacob O. Wobbrock<s>Wachunga
KitsuneKouta<s>xLeD
<T>a drugged-up pENGUIN !?!
Lisa Anthony<s>P.Sign
And everyone else who helped out
<T><right> lyk......
<T><right> u cant prove a druggie penguin DIDNT contribute
<T><right> have you seen some of this backend code?
<T>
<T>
<T><right> and by "backend code", i mean dis B000TY
<A><right>This wouldn't have been possible 
<A><right> without all their hard work! 

*  ~  MKXP Support  ~  *
Inori
Ancurio
<A><right>Together with Cass,
<A><right>They teamed up to defeat the evil
<A><right>forces of Lag once and for all!
<H><left>It may not be perfect...
<A><right>But then, nothing ever is!
<A><right>And maybe it was good enough?

_END_



CREDIT5=<<_END_
*  ~  Supporters  ~  *
<L><left>check out all these cool people
<A><right>We never got this far without you!!!
Tartar<s>Robert Lou
<T><right> OOH ME IM A COOL PEOPLE
Luis C. Morales<s>Michael Manning
Hachilio (Busti)<s>Dragon116
<A><right>Also thanks for making a cool app!
Reni Donovan<s>Zumi		
<A><right>Yeah, that Zumi!!! 
Ania Zajac<s>Leon Janßen		
Yannik Thiele<s>Daan Karma	
Simon Khoang<s>Franz Reimer
Nelio Alves<s>chranokil	
Thamos Spanu<s>Jan
<A><right> Yeah, that Jan!!! 
Paul Steinbrück<s>Peanuts		
<T><right> just a bag of peanuts i left in there
<T><right> mb
Noir<s>Ramiru
Jacob<s>Dillon Holmes		
Pascal P.<s>Fullmoon	
Layla K<s>Cameron Andrews		
Marshall Mann<s>Will Dodge		
<A><right>He and Ice made some of Team Meteor!
<H><left>To be specific: 
<H><left>Sirius, Solaris, Taka, ZEL,
<H><left>And Aster & Eclipse.
<T><right> OBVIOUSLY i will dodge, duhhhh
Naoman Arif<s>Jakob Thaler		
Thomas Landauer<s>Erikaru		
Autumn<s>Daniel McCormick	
Eric Therrien<s>Hoodless	
Mey<s>Spencer Basinger	
Sean<s>Nicky
<A><right> Didn't you get the wiki going!? 
Jim Knicker, Ace detective		
Tom Hobbs<s>Gredler Andreas		
Christian Casanova<s>Sardines
<T><right> c o n s u m e    s a r d i n e
Shamish Sergey<s>lilbegestjake		
Juan Hildago Arancibia		
Casim Bahadar<s>Winter		
CrossImpact<s>Joonas Kivi		
Gabby<s>Hammertime
Elin Ölund Forsling<s>aspectoflife
Budew........
<L><left>lol gottem
ChaosReaperPein<s>Addi Sanders		
Candy<s>whomst'd'ven't		
<T><left>*eat's the candy*
Vatelin<s>Geoffery Nelson
The Drunken Dragonite
Shadowstar<s>Noivy		
<A><right>He's been around forever?! 
AiedailEclipsed<s>isognio 	
<A><left> Byxbysion restoration when??
aries<s>cakeofdoom
<A><right>Okay, but can I eat the cake?		 
Jonatas<s>Matt Shephard 		
ssbCasper<s>Winter Erikson		
Alistair<s>Alexandre Eira
Kouhai Xmas<s>TharTV		
Leo<s>ogur0007
Friz<s>Ama			
Zarc<s>Outside Indoorsman
cybershell12<s>Wossad		
herbuhduhflergen<s>2moe4this
<T><right>sry that was my alt
Sir Issac<s>DiLimiter			
Elkhen<s>The Bells Toll
Aal<s>steelpenguins		
RockInTheDark<s>keyblade336
Kero Kanyo<s>Zargerth		
It's Still Magicarp Inside
<T><right>;)
Hark<s>Awbawlisk 		
<A><left>Another veteran holdover!
<A><left>Look for the Flareon!
Jompa<s>Jay Taylor
Red Tyranitar<s>Pietvergiet		
Splargle<s>Nakoles
shteve<s>ridiculus		
Nisa Bernal<s>riceinabowl
<T><right>NOM NOM NOM
Elite Four Daniel<s>Ninjaneois		
Imperial<s>Zanshouken
Magraga<s>Semiramis		
Masked Aura<s>Reignited'Light
Tacos&Flowers<s>Joshuar_00	
<A><left> A maestro of ancient Mac support...
punkeev softpaws steffi<s>GS Ball
Ross_Andrews<s>EdgarHasFreed	
Syglory<s>About 42 Bears
<T><right>  AND NOT ONE BEAR MORE
<T><right>  RAWWRRRRRRRRR
DefaultDevers<s>Blaze_Lumini		
Sham (Wilson)<s>RocketRiddle	
SkabbtheHunter109<s>Dasuper11		
SmK<s>Potwom		
McZ<s>Tempest		
Nadrel<s>BLaZn
<L><left> this list is really long.
<T><right>  jus' like me ;)
Andrew Parekh<s>Mastercatcher00X	
ProjectIceman<s>Kevin Silva		
LucasDukas<s>andracass	
BIGJRA<s>Arcin
<A><left> Thanks for the in-depth guide!
Launce<s>Dark_Absol		
CielDiVine<s>	E.L.Y	
<T>more like CielDiKetchup AYYY
Valerie<s>Mimon Hamed Mohamed 
Posty<s>RubyRed		
<A><right>  I told you I could still save him!!
<T><left> i seen you around the circus, innit?
chaoticangel97<s>Kirixah
Trevore<s>Aldrich Faithful		
Apostolos Palavras<s>Winter Angel		
MarsupialJr<s>jaden582
BigShotJoe<s>JapaneseWallpaper	
Azery<s>TU84	
<A><right>  I'm pretty sure he has the   
<A><right>  metagame memorized?  
<T><left> what's that smell ?????
Ghost141<s>Foster Davis	
Mayflower896<s>AyTales
<A><right> Another patron saint of guides!  
Ceratisa<s>Zorekky 		
Ryan Stiles<s>Zeroyue			
advesha<s>ToDie		
Yumi_uwu<s>Lily Awaka		
Kevin O'Keeffe<s>Bryan Barlitt
Pyroclast<s>Colette			
<T><right>  NOM
lavalampflamingo<s>Zoey Elaine Greer	
<T><left> smh gamefreak why no 
<T><left> lavalamp flamingo pokemon	
Alva Akasha<s>Blind Guardian
Paul White II<s>Goldjoz			
Rising Sun Reviews<s>Raphael Soares		
Spika Patate<s>Chameleon109
boomdiada<s>Just Yes		
Boiger<s>derpingmudkip
Jetasd<s>Matt Pissaris		
Kamu<s>Abyssreaper99
TurtleBear<s>bubblegum		
Ctracha<s>Zack Fair
FloRoux<s>Endstrom		
tektonic<s>Eirik Graves
Azzie<s>klover47	
EternalLight95<s>Birb		
Taranis Blackstorm<s>DrGustave		
RedLumain<s>Mason Graves
BlazingAngel123<s>pjplatypus
Monkeydog<s>Anthony Laster	
<T><left> well which is it
Malignant<s>Vanner		
Epharam<s>qwop9992
hamfam000<s>CharredBrown		
Kim Rinaldo<s>Artstyle		
Lua<s>LisaX 		
~(^.^)~<s>pyrostar		
<A><left> A speedrun superstar!
Cad48<s>Alex Rose		
lester tay<s>Tibi Radu		
pyrromanis<s>ShiroOkazaki
<L><left> *mashes the A button
steelpenguins<s>iMadMatthew		
Fehish<s>ajefk12555
3333percent<s>bluetowel		
Ryan Beaulne<s>J P
Odis<s>Tate Hamilton	
Alexander Dean<s>Meridian
Kyublivion<s>Victorywithice	
Shad0<s>Logintomylife
Elijah<s>Ditiamed		
LeoYT<s>Motoko
<A><left> Guide videos, check!
Joboshy<s>Crim		
Hachimaki<s>KORMA
Rob28<s>Michael Miranda	
Blazerburst<s>Cyrikyty
JB<s>hcsa	
Youkai Nep<s>Logan the balalaika
<T><right> omg like the digimon ???
Kithas<s>Bellona et Pax	
camelCaseD<s>Joseph Torres
Wolfox<s>Liam Lucas		
Seal<s>zervixen	
<T><left> MORE LIKE SEALDIKETCHUP AMIRITE	
GeoEngel<s>radoslav573			
Felicity<s>Alexis Bernatchez 
Verville<s>Sean		
Stordeur<s>Christopher Horon 		
Nerozard22<s>Chris
Lukan Hardin<s>Arthur Rouillé		
Bjarne Nehring<s>Spoon		
Wyliewb13<s>Seyon		
Joshua2200<s>Lloyd Hale		
Riley Maxwell Somers<s>Alex Schiavetto
Gawerty<s>CeriseBlossome		
<H><left> Lower down is more recent.
<H><left> Less time to make an impact.
<A><right> But each of you are still   
<A><right> every bit as loved!   
Beck<s>Fawn
Ryan Nasser<s>Baraayas		
Ron<s>UptonPickman
alex goerz<s>Jacob Deutsch		
Adam A<s>Fenceperson
Kyle<s>ShinyBlade		
Sethur<s>Aman Didwania
Emmett Gaiman<s>DDBlue666		
<T><right>  the DD stands for double donkey
Thomas<s>Habbo		
<T><right>  okay i lied
<T><right>  but it would be funny if it did
jenna jonica<s>Jac		
BeoWulf<s>Alexander Kozlov	 
maxime busc<s>Jacob Metzker
Chase<s>Sakura Sis 		
Frostiliscious<s>PaulMSZ-006
Christopher Chambliss
Dewfall<s>Tom Hobbs			
William Minnimin<s>Vicky Chen		
Megan Blincoe<s>Cuddles		
Cameron Mcevoy<s>Eevee 		
Anthony Szmyhol<s>Drakyle			
<L><left> mooooom are we there yet
Greg<s>Shane Zoppellaro		
Artist<s>foamy		
<T><right>  MOOOOOOOM UR STICKS
crispy<s>Dream		
Aurora<s>Sage TheRoserade		
<T><right>  sage sage sage sage sage sage
Bruno Macedo<s>Bassem		
Captain Momo<s>Tim I		
<T><right>  but you can just call him timmy
Adrien Lange<s>Veno Zen		
Yeicx<s>Henry Nguyen		
Ian McSweeney<s>John Thillted Jr	
<T><right>  finna B John Tilted Jr by the time we done	
Namelesssimp<s>Georginio Lois
Pedro Villar<s>Sinikuro			
Evan Gross<s>alec joseph
<T><left> lmAO u CANT JUST CALL PEOPLE GROSS
Pacifist Games<s>Ruthger Dijt		
A<s>Geoffrey Chen
spleen17<s>Joel Woolley		
Forneus<s>simon anderson
Tim<s>mortifiedbitch		
<T><right>ay qqurl same
Fiwam<s>FunnyBone48
Saraphimwolf<s>Azrael		
evilginger27<s>NS Flash-Fire
Matty<s>Lindinator666	
Fezzdog<s>Nick D			
サゲル<s>Ainsley Robbins		
Spiff<s>Mahendran		
Katurayan<s>Michal		
Raven Dragon<s>Tom Sayer	
Haze<s>Kino		
enzzzzzz<s>Josh Peck		
Martijn Spiegels<s>Ben Knight			
Dan<s>violet thunder		
Ngoc Nguyen<s>OverlordMatt
enumag
<A><right>  It's so many!!! 
<A><right>  You all rock!!!!!!  
<L><left> finally!!!!!!!!

Thank you all so, so much!!
<T><right>  so long and thx 4 all the fisshh
<T>
<T>
<T>
<T>
<T><right>  the so long refers to something else tho

_END_



CREDIT3=<<_END_
<H><left>...We're still here?
<A><right>  Yeah, there's more people to thank! 
*  ~  Special Thanks  ~  *
<A><right>  Don't worry, it's not too much more though! 
<L><left> oh my GOD there's still MORE???
STK Patrick 
for sparking the project in the first place!
<A><right> He first said he'd make it,  
<A><right> And then Ame totally stole his thunder!  

To all of the Reborn Line Leaders 
for helping kick this all off!
<A><right>Especially the ones who played me!  
<T><right>bitches lose braincells playing me lmao 

All current and former community staff 
for helping keep things sane all this time...
<H><left> "Sane" may be a generous estimation...
<H><left> But nonetheless, each keeper has been
<H><left> paramount in order for us to have
<H><left> the freedom to move forward. 

The community as a whole 
<T><right>OH SHIT THAT'S ME
for being so engaged and lively!
<T><right>rararararararararararara
<A><right>Even if you just downloaded the game
<A><right>And have never interacted...
<A><right>Give yourself a hand for being some
<A><right>small part of this still!
<A><right>Also, it's never too late!
<A><right>The funny thing about the future
<A><right>Is that you can never tell where it's
<A><right>Going to end up, 
<A><right>No matter how hard you try...
<A><right>But I have a feeling we'll be around
<A><right>For a long time yet,
<A><right>So maybe come say "Hi"?!

Shout out to all of my lovely patrons 
for being the ones to make this happen!
<A><right>You all are the very, very
<A><right>very, very,
<A><right>veryveryvery
<A><right>Best!!!!!

Nintendo 
for not sniping us dead before we could finish?
<A><right>This project was made out of love,
<A><right>Passion, and respect for what we saw
<A><right>Was missing in the series!
<A><right>We hope it can be something that
<A><right>Everyone enjoys and contributes
<A><right>To the brand and franchise rather
<A><right>Than taking away from it!
<A><right>If you've let us go until now willingly,
<A><right>Thank you!!!
<A><right>And if you still have a choice,
<A><right>...Maybe you made it this far, right?
<A><right>Maybe leave it for someone else to enjoy still?
<H><left>Regardless, we're done now. No more.
<L><left>i'm willing to bet money 
<L><left>that one of you plays it

And one very special NO thanks 
to the jerk who lied to me as a kid and
swore that you could get to the Orange
Islands in Crystal Version if you surfed on
a Lapras at exactly the right obscure rock!!! 
Boo!!!
<L><left> ok but my uncle works at nintendo 
<L><left> and he said......
<L><left> ...also wait did i write this line

Finally, one big thanks to YOU
for playing and making it all the way here!
<A><right>Never forget the perseverance it 
<A><right>took to get here!
<A><right>After everything, you still made it!
<A><right>Thank you so, so, so much!!!
<L><left> yeah for fuck's sake how long IS this game
<L><left> scratch that, how long are these credits?????
<L><left> no one is reading this
<L><left> so i can say whatever i want!!
<L><left> game was better with me around and you know it!
<L><left> sorry anna everyone knows i'm the cool kid
<L><left> everyone out there all like
<L><left> (please imagine this in a whiny, nasaly voice)
<L><left> "leik, omjay, lin is like the worst villain"
<L><left> "game is SO edgy"
<L><left> "i have good opinions"
<L><left> how's it feel to be wrong!!!!
<L><left> it's ok!
<L><left> i forgive you.
<L><left> but only if you repent.
<L><left>take responsibility for your actions!
<L> i look forward to seeing myself at the top 
<L><left> of your tierlists.
<L> you can split the doll off if that makes you feel better!


Reborn was always, first and 
foremost, its community.
And we are as but simple trees--
<T>
<T>
<T>
<T><right>TREES NUTS
Nothing without a forest to fall in.






_END_




#Stop Editing


  def main
#-------------------------------
# Animated Background Setup
#-------------------------------
    @sprite = IconSprite.new(0,0)
    @backgroundList = CreditsBackgroundList
    @backgroundGameFrameCount = 0
    # Number of game frames per background frame.
    @backgroundG_BFrameCount = CreditsFrequency * Graphics.frame_rate
    @sprite.setBitmap("Graphics/Titles/"+@backgroundList[0])
#------------------
# Credits text Setup
#------------------
    creditArray =[CREDIT,CREDIT1,CREDIT2,CREDIT3,CREDIT4,CREDIT5]
    active_credit = creditArray[$game_variables[747]]
    credit_lines = active_credit.split(/\n/)
    credit_lines.delete_if { |line| line.match(/^<L>/) || line.match(/^<T>/) }  if $game_switches[:Anna_Smiles] == true
    credit_lines.delete_if { |line| line.match(/^<A>/) || line.match(/^<H>/) }  if $game_switches[:Anna_Smiles] == false && $game_switches[1941] == false
    credit_bitmap = Bitmap.new(Graphics.width,32 * credit_lines.size)
    credit_lines.each_index do |i|
      line = credit_lines[i]
      speaker = 0
      if line.include?("<L>")
        speaker= 1
        line["<L>"] = ""
      elsif line.include?("<A>")
        speaker= 2
        line["<A>"] = ""
      elsif line.include?("<T>")
        speaker= 3
        line["<T>"] = ""
      elsif line.include?("<H>")
        speaker= 4
        line["<H>"] = ""
      end
      align = 1 # Centre align
      if line.include?("<left>")
        align = 0
        line["<left>"] = ""
      elsif line.include?("<right>")
        align= 2
        line["<right>"] = ""
      end
      line = line.split("<s>")
      # LINE ADDED: If you use in your own game, you should remove this line
      pbSetSystemFont(credit_bitmap) # <--- This line was added # ame: ok look it says remove this line but the font is fuggles without it
      x = 0
      xpos = 0
      linewidth = Graphics.width
      for j in 0...line.length
        if line.length>1
          xpos = (j==0) ? 0 : 20 + Graphics.width/2
          align = (j==0) ? 2 : 0 # Right align : left align
          linewidth = Graphics.width/2 - 20
        end
        credit_bitmap.font.color = CREDITS_SHADOW
        credit_bitmap.draw_text(xpos,i * 32 + 8,linewidth,32,line[j],align)
        credit_bitmap.font.color = CREDITS_OUTLINE[speaker]
        credit_bitmap.draw_text(xpos + 2,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32 - 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos + 2,i * 32,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos + 2,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.draw_text(xpos - 2,i * 32 + 2,linewidth,32,line[j],align)
        credit_bitmap.font.color = CREDITS_FILL[speaker]
        credit_bitmap.draw_text(xpos,i * 32,linewidth,32,line[j],align)
      end
    end
    @trim=Graphics.height/18
    @credit_sprite = Sprite.new(Viewport.new(0,@trim,Graphics.width,Graphics.height-(@trim*2)))
    @credit_sprite.bitmap = credit_bitmap
    @credit_sprite.z = 9998
    @credit_sprite.oy = -(Graphics.height-@trim) #-430
    @frame_index = 0
    @bg_index = 0
    @pixels_banked = 0
    @zoom_adjustment = 1/$ResizeFactor
    @last_flag = false
#--------
# Setup
#--------
    #Stops all audio but background music.
    @PreviousBGM = $game_system.getPlayingBGM
    pbMEStop()
    pbBGSStop()
    pbSEStop()
  #  pbBGMFade(2.0)
  #  pbBGMPlay(CreditsMusic)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @sprite.dispose
    @credit_sprite.dispose
    $PokemonGlobal.creditsPlayed=true
    #pbBGMPlay(@PreviousBGM)
  end

##Checks if credits bitmap has reached it's ending point
  def last?
    if @frame_index > (@credit_sprite.bitmap.height + Graphics.height + (@trim/2))
      $scene = ($game_map) ? Scene_Map.new : nil
     # pbBGMFade(2.0)
      return true
    end
    return false
  end

#Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::B) #&& $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
    #  pbBGMFade(1.0)
      return true
    end
    return false
  end

  def update
    @backgroundGameFrameCount += 1
    if @backgroundGameFrameCount >= @backgroundG_BFrameCount        # Next slide
      @backgroundGameFrameCount = 0
      @bg_index += 1
      @bg_index = 0 if @bg_index >= @backgroundList.length
      @sprite.setBitmap("Graphics/Titles/"+@backgroundList[@bg_index])
    end
    return if cancel?
    return if last?
    @pixels_banked += CreditsScrollSpeed
    if @pixels_banked>=@zoom_adjustment
      @credit_sprite.oy += (@pixels_banked - @pixels_banked%@zoom_adjustment)
      @pixels_banked = @pixels_banked%@zoom_adjustment
    end
    @frame_index += CreditsScrollSpeed # This should fix the non-self-ending credits
  end
end