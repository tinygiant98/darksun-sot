# Dark Sun Scripter's Manual

If you are scripting for us, you should also be familiar with the [player's manual](playersmanual.md), the [dungeon master's manual](dmmanual.md) and [builder's manual](buildersmanual.md).  Each of these publications build on each other.  Everything in those manuals will ensure you're familiar with the systems present in this module and how they are used.  This manual will specifically introduce you to the expected scripting style as well as some of the advanced features of the framework and other systems.

* [Expectations](#expectations)
* [Data Management](#data-management)
* [Systems](#systems)
    * [Core Framework](#core-framework)
    * [HCR2](#hcr2)
    * [DMFI](#dmfi)

## Expectations

As a volunteer project, we fully expect that any person that works on this project will not be around forever.  With that in mind, we expect everyone that contributes to the project to adhere to specific customs and styles so that future contributors can easily read the code and understand what is going on.  Here's a list of general expectations for scripting:

* As a general philosophy, and I cannot emphasize this enough, a scripter's job is to make the builder/storyteller's life easier, not to force them to bend to your will.  Remember, role-play is about story immersion, and those stories are created by the writers, builders and storytellers, not the scripters.

* All functions, including internal functions, will be prototyped and documented.  We do not expect, nor desire, comments for every line of code, but we do expect that the function description associated with the function prototype give the next programmer enough information to know what's going on.  Here's an example of bad prototyping and documentation:

    ```

    ```

    Yep, there's nothing there.  That's bad.  Here's an example of good prototyping and documentation.  This is a simple procedure, so not much is required.  For more complicated procedures, you either need more documentation, or you need to break the procedure up.

    ```c
    // ---< ActivatePlugin >---
    // ---< core_i_framework >---
    // Runs oPlugin's OnPluginActivate script and sets its status to ON. Returns
    // whether the activation was successful. If bForce is TRUE, will activate the
    // plugin even if its status is already ON.
    int ActivatePlugin(object oPlugin, int bForce = FALSE);
    ```

* All functions will contain debugging and logging messages, as required, to aid in future changes/debugging and to inform the module ownership, DMs and players (as appropriate) what is going on.  We have several tools to accomplish this easily.  See [debug messaging](#debug-messaging) and [module communication](#module-communication).  Here's are examples of the debug messaging available in the module:

    ``` c
    Debug("Successfully created encounter with ID " + sEncounterID);
    ```

    ``` c
    Warning("Cannot activate plugin '" + sPlugin + "': denied");
    ```

    This message will be sent to all destinations as opted in `core_c_config`.  You are not necessarily limited to basic data message, though.  Here's an example of a more complicated Debug message that will help everyone determine exactly what is happening within a system:

    ``` c
    Debug("Checking " + sEvent + " script " + IntToString(i + 1) + sCount +
        "\n    Script: " + sScript +
        "\n    Priority: " + PriorityToString(fPriority) +
        "\n    Source: " + GetName(oSource));
    ```

    Although there is nothing wrong with simple debug messages, ensure there is enough information available to allow any scripter to determine where the issues may lie.  
    *Note: **We DO NOT send debug messages with the SendMessageToPC() function.***

* Data (primarily variables) intended for the module or any player will be handled by our [data handling functions](#data-handling) instead of setting variables on the Module or on the PC.

* Where feasible, use wrapper functions instead of requiring the builder to know every possible variable or option they can send to a function.  The debug system is a great example of this.  The `Debug()` function handles the heavy lifting for sending debug messages where they need to go, but it has four wrapper/alias functions:  `Notice()`, `Warning()`, `Error()`, and `Critical()`.  Each one sets specific variables to allow coloring of the variaous messages, but all the builder/scripter has to know is the function name.  Another good example of this is the data management functions.  `_GetLocalInt` replaces Bioware's `GetLocalInt` and HCR2's `h2_SetPlayerPersistenInt` and `h2_SetModuleLocalInt`, thus preventing potential errors.

* As much as possible, error detection, prevention, trapping and mitigation will be included in your code.  NWScript has a nasty habit of failing without anyone noticing and allowing the scripts to just continue.  That can be seamless for the player, but horrible for the builders.  If you've just retrieved an object, ensure it's valid before using it.  If you're jumping a player to an object, ensure the object is valid and, after the jump, check the player is there.  Build the 'what-ifs' and think about paths to take when a piece of code fails to execute for whatever reason.  `Debug()` messages go a long way in identifying failed code, but doesn't actually prevent errors.

* Most code should be provided as a library and/or plugin.  Do not send in 27 scripts to handle 27 different items.  It will be rejected.  There are numerous examples throughout the module on how to use and implement the framework's library system.  Learn them.

* All of our major subsystems/plugins are divided into six scripts each, which become one compiled script each at compile time.  All six of these files are expected to exist if you provide a plugin or library with your code.  This is for future expansion and to provide a standard set of scripts so builders and other scripts know where to find what they're looking for.  Here's a summary of the expected scripts:

  * `*_i_config` - this is a configuration file for the subsystem meant for the builder's attention.  The builder should be able to put any value or setting they want in these constants and the system will still work fine.  The comments in these files should be extensive, providing information to the builder on what each setting does, what the possible values are for each setting and, if necessary, and example of what the various values do to the system.  This is the only file that a builder is expected to look in while setting up their systems and the only file that any non-scripter should be changing.  All other files are meant only for the scripting team.  This file is included in `*_i_main`.

  * `*_i_const` - this a constants file, containing all of the constants that are used in the system, except for the configurable constants in the `*_i_config` file.  For the most part, there should be no literal strings used in your code.  If you're used to coding `GetLocalInt(oPlayer, "myVariable");`, get used to creating constants for your variable names and writing more like `_GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);`.  This file is included in `*_i_main`.

  * `*_i_events` - this handles all of the events in your system and other module-public functions, such as tag-based scripts and Bioware overrides.  If your system has any events, tag-based scripting or Bioware overrides associated with it, such as OnAreaExit, OnTimerExpire, etc., those functions belong here.  Those are the only functions that belong here.  This file is included in the library script, such as `*_l_plugin`.

  * `*_i_main` - this does the heavy lifting of the subsystem or library.  All the custom functions that are called by the functions in `*_i_events` should reside here.  This file is included in `*_i_events`.

  * `*_i_text` - if you're system contains string literals that are used to provide feedback or otherwise communicate directly with the player about in-character events, those string literals belong here.  This is separated out to allow for easily translation to other languages without searching hundreds of scripts looking for each literal to translate.  This file is included in `*_i_main`.

  * `*_l_plugin` or `*_l_library` or similar - these are the library registration functions that tie it all together and expose your events to the (module) public.  It's the primary function that allows the event handling function to work so well.  There are many examples in the module of very simple versions and very complicated versions.  All of your event functions in `*_i_events` should be included in some way in this file, whether it's to register them to an event or simply to make them module-public by registering them to the library.

## Data Management System

Variable handling methods have been included that control where the variables will be saved.  With organic sqlite functionality, variables can be saved persistently or by session (volatile).  `util_i_variables` (which is included in `util_i_data`), contains two methods for storing persistent data:
* For players -> [Get|Set|Delete]Player* functions will save to the player's sqlite db in their .bic file
* For the module -> [Get|Set|Delete]Database* functions will save to an external campaign sqlite database

To store volatile session-only data, there are two more options:
* For any game object -> [Get|Set|Delete]Local*, which are the standard game functions for variable handling
* For module-specific -> [Get|Set|Delete]Module* funtions will store volatile data to the module's sqlite db

Here are the basic functions `util_i_data` provides:
* `_GetIsPC()` - a replacement for nwscript's `GetIsPC()`.  Our version determines whether the character is player-controlled (PC) and not a DM.  So if you're trying to determine if a player is a PC and not a DM, use this function.
* `_GetIsDM()` - a replacement for nwscript's `GetIsDM()`.  Our version determines whether the passes character object is a DM or a DM possessing an NPC.
* `_GetIsPartyMember()` - will return whether the first passed object is a party member of the second passed object.
* `GetIsRegisteredDM()` - will return whether the passed object is registered to the DM logs.  This check is done during login, so if a logging in DM is not registed, they will be booted.  Any PC that returns TRUE to `_GetIsDM()` after logging in *should* be a registered DM.
* `GetIsDeveloper()` - will return whether the passed object is on the development team.  `IS_DEVELOPER` is set during the client entry process and `GetIsDeveloper` checks this variables.  If the variable is not found, it will re-check the database/2da to ensure the pc wasn't missed during the client enter event.

It also provide variables handling methods, and show below.

#### Variable Handling

Best practices for the various variable handling functions:

* For PCs, use [Get|Set|Delete]Player* functions to hold persistent data.  Never save data meant to be volatile (such as timer ids, etc) to the player database, always save those using standard bioware variable handling methods.
* For the module, use [Get|Set|Delete]Module* and pass the `MODULE` (literally -> `GetModuleInt(MODULE, ...);`).  You can also pass INVALID_OBJECT and the variable handling system will use the module object.  The MODULE object is a module-wide wrapper for `GetModule()` and will be avaialable for any script that includes `util_i_data`.  We are not storing module variables directly on the module object normally obtained by `GetModule()`.  All data stored via [Get|Set|Delete]Module* functions is session-only and will not survive a server restart, so if you need 
* For all other objects, just pass the arguments normally to [Get|Set|Delete]Local* functions.  This data is also volatile.  Never save data meant to be assigned to a specific object to a persistent database, unless that object is the module object or a specific pc.  Object identifier *will change* on every server restart, so object ids saved in one session may not refer to the same object in the next session.  If you absolutely must save persistent data for general game objects, assign them in the toolset, or save via a unique tag instead of object id.

Available functions within `util_i_data`:
* `_GetIsDM`, `_GetIsDM`: Each PC has a variable set OnClientEnter to demarcate their status.  This prevents having to go through the rigamarole of figuring out if a creature is DM-possessed, a regular PC, etc.  These functions work on all creatures and will return correctly, even if they are possessed.
* `_GetIsPartyMemeber`: Will return whether the first object is a member of the second object's party.

To learn more and understand exactly how the functions work, open [`util_i_data`](../utilities/util_i_data.nss) and [`util_i_variables](../utilities/util_i_variables.nss) and take a look!

## Framework System

The entire module rests on the core framework developed, maintained and continuously improved by Michael Sinclair (squattingmonk).  The framework does an amazing job of organizing code and managing events, as well as providing access to efficient list management, debugging utilities, datapoints, text coloring, database interface and script library functions.  This is all done inside of nwscript with the exception of the database interface, which uses NWNXEE. I cannot say enough about how well this framework handles the basic functionality of the module.  In order to successfully script here, you must understand how the framework works and the various methods to call functions, events, etc.  If you are familiar with how HCR2 (NWN1) and CSF (NWN2) worked, then you'll have a head start on understanding this framework.

***Note:  No pull requests will be accepted that involve modification to any file in the `framework` folder without extensive testing and prior coordination.***

* [Math](#math-functions)
* [Lists](#list-functions)
* [Datapoints](#datapoint-functions)
* [Debugging](#debug-functions)
* [Color](#coloring-functions)
* [Library](#library-functions)
* [Event Management](#event-management)

#### Math Functions

[`util_i_math`](../framework/src/utils/util_i_math) provides access to some useful basic math functions such as mod, min, max, clamps, etc.  None of these require detailed explanation.  These functions are currently only consumed by `util_i_color`, but you can use them anywhere they appear useful.  Open up the file and take a look at what's available.

#### List Functions

The framework provides access to two types of lists:  comma separated values (CSVs) and psuedo-arrays (varlists).  These lists are extensively used throughout the module.

An example of the power of these lists is the way in which languages are added into the DMFI language system.  When initiated, the language system searches for all items in a CSV, which are references to game objects (items) that contain the appropriate variables to allow language translation.  As each object is found, it is added to an object varlist on the DMFI data point.  Simultaneously, a CSV is created with the names of each of the languages.  This allows a quick way to create an index of languages.  The CSV is searched by language name to determine its index, then the object list is refernced by index to get the required object and its variables.  In this way, new languages can be added to the module without any scripting at all.  A new language initializer item simply needs to be created with the appropriate variables and the expected tag.

#### Datapoint Functions

Datapoints are used extensively by the framework as well os other module systems, such as DMFI, travel area encounters, etc.  Using datapoints allows us to provide module-wide access to various variables without overloading the module object.

#### Debugging Functions

The debugging and messaging system is extensive and customizable.  Debug message levels can be changed per object indepedently from the module setting.  This allows the production module to have a higher setting, thus reducing messaging, while allowing specific objects to maintain lower settings, allowing maintainers to view debug messages during development.

#### Coloring Functions

Another utility, `util_i_color`, provides function for coloring various strings for presentation to players.  Many of the functions in this script are dependent on `util_i_math`.  These functions can be sued to color strings for debugging presentation, messaging around the module and within custom conversations.  Your primary use will probably be `HexColorString()` which allows you to use one of the many pre-defined colors within the script.

#### Library Functions

//TODO - this is not very explanatory.  Rewrite.
//TODO - take out tag-based and override scripts from this section and make them their own section.  This should just be how the library functions work.

The library system allows the framework's [event management system](#event-management) to do what it does so well.  The gist of the system, however, is that you expose the functions you wish to be public through the library and pointers to those functions are stored in varlists on various datapoints in the module.  When any of those functions are called from any part of the module (generally through an event hook), the library system is able to find the function and run it, without the scripter/builder having to know which library it's in.  This does not mean you can call a function from another script directly without an `#include` reference, but it does mean that you can run an event script (such as `OnAreaExit`) that resides in the HCR2 fugue system from any and all areas without having to point the event directly to the script.

Here are some notes from our implementation of the library system:
* All scripts associated with a library, if written correctly, become part of one large script at compile time.  This is the primary reason each our libraries has only six different scripts in them (configuration, text, constants, events, main, and plugin/library).
* Bioware override scripts can be housed in any library and don't need to have the same name as the script they're overriding, only the event name passed through the library does.  Here's an example of a library exposure that override Bioware's nw_s2_animalcom:

    ``` c
    void OnLibraryLoad()
    {
        RegisterLibraryScript("nw_s2_animalcom", 1);
    }

    void OnLibraryScript(string sScript, int nEntry)
    {
        switch (nEntry)
        {
            case 1:  MyAnimalCompanionScript(); break;
            default: CriticalError("Library function " + sScript + " not found");
        }
    }
    ```

* The same can be done with tag-based scripting.  For both cases, separate, specially named scripts are not required, just expose your function to the library system with the correct name and you can run any function or script that you want.  Here's an example of tag-based scripting from HCR2's torch subsystem.  This isn't the entire script, it just shows the portion necessary to understand tag-based scripting.  The actual name of the items are carried inside constants (H2_LANTERN and H2_OILFLASK, in this case), so you can change the tag of the item and not have the system break.  When any player uses an item tagged as a lantern (`h2_lantern`), the system looks for a script with that item name, which matches the constant we passed (`H2_LANTERN = "h2_lantern"`).  Once found, it looks into the library for the nEntry that matches the one we assigned (`2` in this case).  

    ``` c
    void OnLibraryLoad()
    {
        ...

        // ----- Tag-based Scripting -----
        RegisterLibraryScript(H2_LANTERN,            2);
        RegisterLibraryScript(H2_OILFLASK,           3);

        ...
    }

    void OnLibraryScript(string sScript, int nEntry)
    {
        switch (nEntry)
        {
            ...

            // ----- Tag-based Scripting -----
            case 2: torch_lantern();       break;
            case 3: torch_oilflask();      break;

            ...
        }
    }
    ```

    It then runs the script associated with that entry (`torch_lantern()`), which contains all the scripting you would normally keep in its own .nss, without having to maintain another file.

    ``` c
    void torch_lantern()
    {
        int nEvent = GetUserDefinedItemEventNumber();

        // * This code runs when the item is equipped
        // * Note that this event fires PCs only
        if (nEvent ==  X2_ITEM_EVENT_EQUIP)
        {
            h2_EquippedLightSource(FALSE);
        }
        // * This code runs when the item is unequipped
        // * Note that this event fires for PCs only
        else if (nEvent == X2_ITEM_EVENT_UNEQUIP)
        {
            h2_UnEquipLightSource(FALSE);
        }
    }
    ```
    
* 
* 
* 
* 





#### Event Management




## Dialog/Conversation System


## Quest Management System

Quest management system operations are detailed in [quest.md](#quest.md).  This section will only cover how the quest management system interacts with the core framework.

The quest system exposes four new functions:
* QUEST_EVENT_ON_ACCEPT - runs on quest assignment
* QUEST_EVENT_ON_ADVANCE - runs every time the PC advances a step, including the first step
* QUEST_EVENT_ON_COMPLETE - runs when a PC successfully completes a quest
* QUEST_EVENT_ON_FAIL - runs when a PC meets a defined failure condition

You can assign global events against these functions just like your would any other game event.
```c
RegisterEventScripts(oPlugin, QUEST_EVENT_ON_ACCEPT", "myScriptName", 5.0);
```
Just like any other event, global registration should be limited to scripts that will affect all potential quests that can be run.  Generally, this will be very limited as the quest system itself controls quests via prerequisites and quest-specific scripts can be run.  Since quest scripting tends to be very compartmentalized, globally running scripts against quest events is not a best practice.

You can also assign a specific script to run against a specific event.  This can be defined as a variable, but most likely, scripts will be defined this way during the quest definition process:
```c
SetQuestScriptOnAccept("myScriptName");
```
Any quests assigned by this method will be run after the global event scripts, and the global event scripts can cancel quest-assigned scripts by setting the event state to EVENT_STATE_DENIED.  Quest-assigned scripts can cancel subsequent tag-based scripting by setting the libray return value to EVENT_STATE_ABORT or EVENT_STATE_DENIED.

The final method, and probably the most likely method to be used, is tag-based scripting.  After the global events and quest-assigned scripts are run, the system will call a library function with the same name as the questTag.  Much like any other tag-based scripting method (such as for items), you can identify the current quest event and current step and run code based on that data.  See an example of this in [ds_l_quest.nss](#../plugins/ds/ds_tagbased/ds_l_quest.nss).

# Timers

Timers are an organic function within the core framework, but they can take up a lot of resources, so use them only when necessary.  Use the follwoing procedure to set up a timer:

1. Create a script that will be executed when the timer expires.  This is an event script and you are not limited in how you name it, however our convention is `<system>_<subsystem>_OnTimerExpire()`.  As an event, it should be located in the `*_i_events` file of the system or module area you are working on.  Supporting functions can be placed in `*_i_main`.  Here's an example of one of our current prototypes.  As evidenced by the name, it's part of the module travel system and designated for the encounter subsystem.

    ```c
    void tr_encounter_OnTimerExpire();
    ```

2. Register this script in the library/plugin file so the event management system can find it when the timer expires.  You will need to register it to a custom event as well as to the library in general.  Create a constant for the name of the custom event.  Here's an example:

    ```c
    RegisterEventScripts(oPlugin, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, "tr_encounter_OnTimerExpire");
    
    ...

    RegisterLibraryScript("tr_encounter_OnTimerExpire", 1);

    ...

        case 1: tr_encounter_OnTimerExpire(); break;
    ```

3. Create the timer.  You'll need to know the name of the event you want to run (`TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE`, in this case), what interval you want to run it at




## Questions

If you have any questions about installing these tools, and you're sure you followed the instructions above correctly, you're best bet is to get onto the [Dark Sun discord](https://discordapp.com/channels/468225176773984256/468225176773984258) and ask a question about installing the tools.  If you're not a member of our discord, you can [join](https://discord.gg/8ZxgMRc).  If you tag me (@tinygiant) in your post, I'll likely answer pretty quickly.  If you don't tag me, I may not see the question at all, but one of our many other team members might be able to help.  I'm happy to answer discord DMs also if you don't want to join the discord.

## Conclusion

I know this was a lot of information, but, again, it all boils down to just a few commands once you're used to it.  The majority of this tutorial is aimed at our audience that is new to this process.  If you've decided to use VS Code, which can accomplish a lot of these steps in a visual environment, please read the [~~VS Code Tutorial~~coming soon](vscode.md).  This is not really necessary for most content developers, but if you're a scripter, I highly recommend your consider VS Code as your primary development environment for this module.