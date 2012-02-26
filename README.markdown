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

Changelog
=========

Version 0.1 (1 March 2012) 
--------------------------
* Initially written
* Generate Sector Map
* Convert to SVG


* Configuration instructions
* Installation instructions
* Operating instructions

* Copyright and licensing information
* Contact information for the distributor or programmer
* Known bugs
* Troubleshooting
* Credits and acknowledgments
* A changelog lists project changes. This is usually intended for programmers
* A News sections might also be include to lists project updates for users.