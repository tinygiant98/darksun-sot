# Acknowledgements

Suffice it to say that very few people create original works without the guidance, direction or aid of others.  You'll find many of the scripts and systems in Dark Sun are similar, if not outright copies, or other systems available to the NWN community.  In order to make these systems work either within the library system or within the Dark Sun World, many of these scripts had to be modified, chopped up or, in some cases, parts of them deleted.  In no way do we intend any disrespect to the original authors of these works.  Many of the modified scripts do not carry the original author's name within the script.  Therefore, this document is meant to serve as acknowledge-central for any and all scripts and systems that were in any way, and to any degree, incorporated into the Dark Sun module.

* [HCR2](#hcr2)
* [Framework](#core-framework,-nasher)
* [Shapes](#shapes)
* [The Vault](#neverwinter-vault-forums)

## HCR2

Way back in the olden days (2008-ish), **Edward Beck** created an updated persistent world handling system that provided all kinds of player-handling and event-handling functions.  It was great for its time and the subsystems associated with and created for HCR2 are amazing.  Most of HCR2's code is present in this module, although chopped up and moved around to make it work with the library system.  The majority of his background code (player handling and persistent world admin) can be found in the plugin files `pw_i_*`.  The event handling and database interface functions were removed in favor of the core framework's systems and the data management portions (setting module and player variables) have been modified and placed in `util_i_data`, where they now interact with datapoints.  The various subsystems that were distributed with HCR2, such as bleed, corpse, corpse loot, htf, fugue, torch, unid on drop and rest, are all contained in their own plugins that start with `pw_*`.  Most of these plugins have not been modified at all, we simply moved the code around to fit in our and reduced the number of scripts to maintain.  Anytime you see a function that starts with `h2_*`, that's his work.  We did not rename any of his functions.  If you are familiar with HCR2 and are unable to find one of his original functions, it is because it was removed, never because it was renamed.  So, to Edward Beck, wherever you are, salute!  Thanks for all the work you put into HCR2 and many more thanks for making it publicly available.

## Core Framework, Nasher

Over the last several years (2018-present), **Michael Sinclair (squattingmonk)** has been developing a framework very similar to HCR2 and the Common Scripting Framework, but in one all-encompassing package and using a different methodology.  It incorporates a library-based module-wide event handler, list management, a custom (zz-dialog-based) dialog system, timer functions, a persistent quest/journal system and database interface (both the campaign database and external databases through NWNXEE).  It cannot be overemphasized how efficent and versatile this system is.  It is the only system of its kind for NWNEE that is based completely within nwscript making the NWNXEE interface completely optional.  However, the absolute best part of this system is that he is still actively maintaining it.  This module uses his code directly, without any changes or overrides. All of his original code can be found as a submodule (`framework`) in the Dark Sun repository.  This submodule has a direct link to the master branch of the author's original repository.  So, to squattingmonk, thanks for all the work you've put into this system, for allowing us to use it, for not ignoring (some of) our midnight bug reports, and for not (publicly) laughing at all of our mistakes!

Additionally, **Michael Sinclair (squattingmonk)** authored an amazing tool for managing module files (nasher.nim), allowing us to do the majority of our development work outside of the Aurora toolset and its inherent limitations.  It's very likely the only reason this module exists in its current form is because of this tool.  

## Shapes

As we were looking to create a system to draw various runes and other shapes, I ran across **Tarot Redhand**'s Other Shapes on the Neverwinter Vault.  He has done an awesome job of creating a system with a simple interace that allows these shapes to be drawn with just about any beam effect, in any location, and sized, shaped, rotated and orbited to meet the requirements of the builder.  I don't have his name, but if you contact me, I'll be glad to add it.  Thanks for making this system and for making it public.

## Neverwinter Vault Forums

The [Neverwinter Vault](neverwintervault.org) forums are a bottomless resource of knowledge and expertise.  Since Bioware took down their forums and guild systems many moons again, the community has struggled to find a new central nexus for sharing ideas and finding help.  Neverwinter Vault is the result of many failed reincarnations and has held stable for the last half-decaded, recovering and storing most of the data held on the old IGN system.  If you haven't seen the resources or forums there, go.  They also have a discord channel to stay updated on forum posts.

## More - still a work in progress ...

