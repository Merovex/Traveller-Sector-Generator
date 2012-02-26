Traveller Sector Generator
==========================

The **Traveller Sector Generator** (TSG) creates random Traveller star maps intended for YOTS.

The maps are generated using an amalgam of Mongoose and Classic Traveller rules, with some Gurps Space 4e and 3e.
Mongoose rules are used when generating the World characteristics. Classic Traveller is used when fleshing out star system details such as stars, non-world orbits, presence of companion stars. Gurps is used to flesh out star characteristics and the impact of a companion star on the primary's orbits.

* Sector: 40x32 hex grid
* Tract:  8x10 hex grid (Traveller Subsector)
* Volume: 1-hex
* World: primary inhabited planet.
* Orbit: A

ASCII Output
------------

The block below shows TSG's ASCII output. The top row is the key system aspects: Volume ID, World UWP, Temperature, Presence of Bases & Gas Giants, Trade Codes, Stars, Primary Star's Orbits, Name. The rows that follow elaborate the primary star's orbits. Rows with two dashes are the Primary's orbits, orbit type, UWP, and orbit distance (usable for travel and year length). Other rows with the '/' are that orbit's satellites. When the UWP is dots, that orbit is empty.

```
1201 E949556-5 T ..G.. ..	Lt,NI          	        	F0IV/DB           R..WGG..S       	Secundus
  --  1.    R // X600000-0 //  0.4 au
                            /    7 rad. X420000
                            /    9 rad. X620000
  --  2.    . // .......-. //  0.7 au
  --  3.    . // .......-. //  1.4 au
  --  4. *  W // E949556-5 //  2.8 au
  --  5.    G // Large GG  //  5.6 au
  --  6.    G // Large GG  // 11.2 au
                            /    1 rad. XR00000
                            /    6 rad. X402000
                            /    7 rad. X405000
                            /    9 rad. X100000
                            /   10 rad. X302000
  --  7.    . // .......-. // 22.4 au
  --  8.    . // .......-. // 44.8 au
  --  9. -  S // DB        // 89.6 au
```

SVG Output
----------

TSG converts the ASCII output as described above to create an SVG file describing the key aspects of a volume. This includes the Star type, Starport, Name and the presence of bases (Navy, Scout, etc.) and Gas Giants.

Installation
============

This software relies upon Ruby 1.9.2+. To convert from SVG to JPG, PNG, GIF you will need to install Imagemagick with -rsvg flag.

Operating Instructions
======================

TSG is a command-line tool using the rake command. Use 'rake -T' to see options.

Configuration
=============

```yaml
genre: normal
pregen: false
density: 'scattered'
giant_on: !ruby/range 0..9
tech_cap: 11
svg_theme: lite
```

* **density** Can be [dense, standard, scattered, sparse, rift]. Determines the likelihood of a volume having a habitable star system. (Non-habitable star systems are ignored.) Default is standard.
* **tech_cap** sets a maximum technology level for those wishing to limit tech.
* **genre** Can be [normal, firm, opera], which primarily affects the World. Described in _Mongoose Traveller_ (MgT) p. 173. Default is **normal**.
* **svg_theme** Can be [lite, dark] and determines the color scheme for the SVG output.

Copyright
=========

Copyright 2012, Benjamin C. Wilson. All Rights Reserved. You may not use this work for commercial purposes. You may not alter, transform or build upon this work. You may not copy, distribute or transmit the work without the author's prior written approval.

Credits
=======

SVG Output based on [phreeow.net Perl mapping software](http://www.phreeow.net/wiki/tiki-index.php?page=Subsector+mapping+and+generating+software), though heavily modified.

Changelog
=========

Version 0.1 (1 March 2012) 
--------------------------
* Initially written
* Generate Sector Map
* Convert to SVG


* Copyright and licensing information
* Contact information for the distributor or programmer
* Known bugs
* Troubleshooting
* Credits and acknowledgments

* A News sections might also be include to lists project updates for users.