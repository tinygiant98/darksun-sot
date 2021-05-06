// -----------------------------------------------------------------------------
//    File: test_l_plugin.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_chat"
#include "core_i_framework"
#include "test_i_events"

#include "nwnx_events"
#include "nwnx_creature"
#include "nwnx_player"

void nwnx_WalkTest()
{
    int bRun = StringToInt(NWNX_Events_GetEventData("RUN_TO_POINT"));

    if (bRun)
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
}

void test_run_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (GetLocalInt(oPC, "ALWAYS_WALK") == TRUE)
        DeleteLocalInt(oPC, "ALWAYS_WALK");
    else
        SetLocalInt(oPC, "ALWAYS_WALK", TRUE);

    if (GetLocalInt(oPC, "ALWAYS_WALK") == TRUE)
        Notice("We're walking, people!");
    else
        Notice("Get your groove on, we're running up in this bitch!");

    NWNX_Player_SetAlwaysWalk(oPC, GetLocalInt(oPC, "ALWAYS_WALK"));
}

void nwnx_KeyboardTest()
{
    string sKey = NWNX_Events_GetEventData("KEY");
    if (sKey == "W")
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
}

void test_pc_OnPlayerHeartbeat()
{
    DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
}

void test_pc_CheckMovementRate()
{
    object oPC = OBJECT_SELF;
    int nType = NWNX_Creature_GetMovementType(oPC);

    if (nType == NWNX_CREATURE_MOVEMENT_TYPE_RUN)
    {
        if (GetLocalInt(oPC, "RUNNING") == FALSE)
        {
            SetLocalInt(oPC, "RUNNING", TRUE);
            Notice(HexColorString("You're running; HTF rate increased", COLOR_RED_LIGHT));
        }
    }
    else
    {
        if (GetLocalInt(oPC, "RUNNING") == TRUE)
        {
            DeleteLocalInt(oPC, "RUNNING");
            Notice(HexColorString("You're not running; HTF rate normal", COLOR_GREEN_LIGHT));
        }
    }

}

string buildbar(int nCurrent, int nMax, int nWidth)
{
    string bar;
    float unitsPerWidth = (IntToFloat(nMax) / IntToFloat(nWidth));

    int x, currentNumber = FloatToInt(nCurrent / unitsPerWidth);
    object oPC = GetPCChatSpeaker();

    // When the anchor is at the right, the drawing is backwards.
    // We still need to add spaces to the end of the bar to ensure it's showing the empty space.
    for (x = 0; x < nWidth; x++)
    {
        if (x < currentNumber)
        {
            bar += "k";
        }
        else
        {
            bar += " ";
        }
    }

    return bar;
}


int RGBAToHex(int nRGB)
{
    int nResult = nRGB << 8;
    return nResult + 0x000000FF;
}

void test_poststring_OnPlayerChat()
{
    object oTarget = GetPCChatSpeaker();
    int nObjectNumber = 20;

    int nHunger = 63;
    int nThirst = 90;
    int nFatigue = 45;

    int nPixels = FloatToInt(42 * (nHunger / 100.0));
    int nWholeBars = nPixels / 12;
    int nRemainder = nPixels % 12;

    //H
    string sRemainder = "L,K,J,I,H,G,F,E,D,C,B,A";
    int n, x = 6;

    for (n = 0; n < nWholeBars; n++)
    {
        PostString(oTarget, GetListItem(sRemainder, 11), 3, x--, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");
    }

    PostString(oTarget, GetListItem(sRemainder, nRemainder - 1), 3, x, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");

    //T
    nPixels = FloatToInt(42 * (nThirst / 100.0));
    nWholeBars = nPixels / 12;
    nRemainder = nPixels % 12;
    
    sRemainder = "l,k,j,i,h,g,f,e,d,c,b,a";
    x = 6;
    for (n = 0; n < nWholeBars; n++)
    {
        PostString(oTarget, GetListItem(sRemainder, 11), 2, x--, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");
    }

    PostString(oTarget, GetListItem(sRemainder, nRemainder - 1), 2, x, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");

    //F
    nPixels = FloatToInt(42 * (nFatigue / 100.0));
    nWholeBars = nPixels / 12;
    nRemainder = nPixels % 12;

    sRemainder = "x,w,v,u,t,s,r,q,p,o,n,m";
    x = 6;
    for (n = 0; n < nWholeBars; n++)
    {
        PostString(oTarget, GetListItem(sRemainder, 11), 1, x--, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");
    }

    PostString(oTarget, GetListItem(sRemainder, nRemainder - 1), 1, x, SCREEN_ANCHOR_TOP_RIGHT, 10.0, 0xFFFFFFFF, 0xFFFFFFFF, nObjectNumber++, "ds_bars");
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

string sEvents = "ADD_ASSOCIATE,REMOVE_ASSOCIATE,STEALTH_ENTER,STEALTH_EXIT,DETECT_ENTER,DETECT_EXIT," +
                 "EXAMINE_OBJECT,SET_NPC_FACTION_REPUTATION,VALIDATE_USE_ITEM,USE_ITEM," +
                 "ITEM_INVENTORY_OPEN,ITEM_INVENTORY_CLOSE,ITEM_AMMO_RELOAD,ITEM_SCROLL_LEARN," +
                 "VALIDATE_ITEM_EQUIP,ITEM_EQUIP,ITEM_UNEQUIP,ITEM_DESTROY_OBJECT,ITEM_DECREMENT_STACKSIZE," +
                 "ITEM_USE_LORE,ITEM_PAY_TO_IDENTIFY,ITEM_SPLIT,ITEM_ACQUIRE,USE_FEAT," +
                 "HAS_FEAT,DM_GIVE_GOLD,DM_GIVE_XP,DM_GIVE_LEVEL,DM_GIVE_ALIGNMENT,DM_SPAWN_OBJECT," +
                 "DM_GIVE_ITEM,DM_HEAL,DM_KILL,DM_TOGGLE_INVULNERABLE,DM_FORCE_REST,DM_LIMBO," +
                 "DM_TOGGLE_AI,DM_TOGGLE_IMMORTAL,DM_GOTO,DM_POSSESS,DM_POSSESS_FULL,DM_TOGGLE_LOCK," +
                 "DM_DISABLE_TRAP,DM_JUMP_TO_POINT,DM_JUMP_TARGET_TO_POINT,DM_JUMP_ALL_PLAYERS_TO_POINT," +
                 "DM_CHANGE_DIFFICULTY,DM_VIEW_INVENTORY,DM_SPAWN_TRAP_ON_OBJECT,DM_DUMP_LOCALS," +
                 "DM_PLAYERDM_LOGIN,DM_PLAYERDM_LOGOUT,DM_APPEAR,DM_DISAPPEAR,DM_SET_FACTION," +
                 "DM_TAKE_ITEM,DM_SET_STAT,DM_GET_VARIABLE,DM_SET_VARIABLE,DM_SET_TIME,DM_SET_DATE," +
                 "DM_SET_FACTION_REPUTATION,DM_GET_FACTION_REPUTATION,CLIENT_DISCONNECT,CLIENT_CONNECT," +
                 "COMBAT_ENTER,COMBAT_EXIT,START_COMBAT_ROUND,DISARM,CAST_SPELL,SPELL_INTERRUPTED," +
                 "HEALER_KIT,HEAL,PARTY_LEAVE,PARTY_KICK,PARTY_TRANSFER_LEADERSHIP,PARTY_INVITE," +
                 "PARTY_IGNORE_INVITATION,PARTY_ACCEPT_INVITATION,PARTY_REJECT_INVITATION,PARTY_KICK_HENCHMAN,"+
                 "USE_SKILL,MAP_PIN_ADD_PIN,MAP_PIN_CHANGE_PIN,MAP_PIN_DESTROY_PIN,DO_LISTEN_DETECTION," +
                 "DO_SPOT_DETECTION,POLYMORPH,UNPOLYMORPH,EFFECT_APPLIED,EFFECT_REMOVED,QUICKCHAT," +
                 "INVENTORY_OPEN,INVENTORY_SELECT_PANEL,BARTER_START,BARTER_END,TRAP_DISARM,TRAP_ENTER," +
                 "TRAP_EXAMINE,TRAP_FLAG,TRAP_RECOVER,TRAP_SET,TIMING_BAR_START,TIMING_BAR_STOP," +
                 "TIMING_BAR_CANCEL,CHECK_STICKY_PLAYER_NAME_RESERVED,SERVER_CHARACTER_SAVE," +
                 "CLIENT_EXPORT_CHARACTER,LEVEL_UP,LEVEL_UP_AUTOMATIC,LEVEL_DOWN,INVENTORY_ADD_ITEM," +
                 "INVENTORY_REMOVE_ITEM,INVENTORY_ADD_GOLD,INVENTORY_REMOVE_GOLD,PVP_ATTITUDE_CHANGE," +
                 "INPUT_WALK_TO_WAYPOINT,MATERIALCHANGE,INPUT_ATTACK_OBJECT,INPUT_FORCE_MOVE_TO_OBJECT," +
                 "INPUT_CAST_SPELL,INPUT_KEYBOARD_BEFORE,INPUT_TOGGLE_PAUSE,OBJECT_LOCK,OBJECT_UNLOCK," +
                 "UUID_COLLISION,ELC_VALIDATE_CHARACTER,QUICKBAR_SET_BUTTON,BROADCAST_CAST_SPELL," +
                 "DEBUG_RUN_SCRIPT,DEBUG_RUN_SCRIPT_CHUNK,STORE_REQUEST_BUY,STORE_REQUEST_SELL," +
                 "SERVER_SEND_AREA,JOURNAL_OPEN,JOURNAL_CLOSE";

string sSpecial = "NWNX_SET_MEMORIZED_SPELL_SLOT_BEFORE,NWNX_SET_MEMORIZED_SPELL_SLOT_AFTER," +
                  "NWNX_CLEAR_MEMORIZED_SPELL_SLOT_BEFORE,NWNX_CLEAR_MEMORIZED_SPELL_SLOT_AFTER," +
                  "NWNX_ON_COMBAT_MODE_ON,NWNX_ON_COMBAT_MODE_OFF," +
                  "NWNX_ON_WEBHOOK_SUCCESS,NWNX_ON_WEBHOOK_FAILURE," +
                  "NWNX_ON_RESOURCE_ADDED,NWNX_ON_RESOURCE_REMOVED,NWNX_ON_RESOURCE_MODIFIED," +
                  "NWNX_ON_CALENDAR_HOUR,NWNX_ON_CALENDAR_DAY,NWNX_ON_CALENDAR_MONTH,NWNX_ON_CALENDAR_YEAR," +
                  "NWNX_ON_CALENDAR_DAWN,NWNX_ON_CALENDAR_DUSK";

void nwnx_CreateEventsDatabase()
{
    string sQuery = "CREATE TABLE IF NOT EXISTS nwnx_event (" +
                        "id INTEGER AUTOINCREMENT, " +
                        "event_name TEXT NOT NULL"
}


void OnLibraryLoad()
{
    if (!TEST_USE_TEST_SYSTEM)
        return;

    if (!GetIfPluginExists("test"))
    {
        object oPlugin = GetPlugin("test", TRUE);
        SetName(oPlugin, "[Plugin] System :: Module Testing System");
        SetDescription(oPlugin,
            "This plugin provides functionality for testing various module systems.");
        SetPluginLibraries(oPlugin, "test_l_dialog");
    
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "test_OnClientEnter", 10.0);
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!convo", "test_convo_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!go", "test_go_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!get", "test_get_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!stake", "test_stake_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!items", "test_items_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!level", "test_level_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!identify", "test_identify_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!unlock", "test_unlock_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!libraries", "test_libraries_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!time", "test_time_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!var", "test_var_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!script", "test_script_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!debug", "test_debug_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!destroy", "test_destroy_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!run", "test_run_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!test", "test_test_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!ps", "test_poststring_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!spells", "test_spells");

        RegisterEventScripts(oPlugin, "NWNX_ON_INPUT_WALK_TO_WAYPOINT_BEFORE", "nwnx_WalkTest");
        RegisterEventScripts(oPlugin, "NWNX_ON_INPUT_KEYBOARD_BEFORE", "nwnx_KeyboardTest");

        RegisterEventScripts(oPlugin, "NWNX_ON_POLYMORPH_BEFORE", "test_polymorph");
        RegisterEventScripts(oPlugin, "NWNX_ON_UNPOLYMORPH_AFTER", "test_polymorph");

        RegisterEventScripts(oPlugin, PLAYER_EVENT_ON_HEARTBEAT, "test_pc_OnPlayerHeartbeat", 10.0);

        //RegisterEventScripts(oPlugin, "NWNX_ON_VALIDATE_USE_ITEM_BEFORE", "test_validate");
        //RegisterEventScripts(oPlugin, "NWNX_ON_VALIDATE_USE_ITEM_AFTER", "test_validate");

        int TEST_NWNX_EVENTS = TRUE;

        if (TEST_NWNX_EVENTS)
        {
            // Testing all nwnx events
            int n;
            string sEvent;
            while (n < CountList(sEvents))
            {
                sEvent = GetListItem(sEvents, n++);
                if (sEvent == "VALIDATE_USE_ITEM")
                    continue;

                RegisterNWNXEventScripts("NWNX_ON_" + sEvent + "_BEFORE");
                RegisterNWNXEventScripts("NWNX_ON_" + sEvent + "_AFTER");            
            }

            n = 0;
            while (n < CountList(sSpecial))
            {
                sEvent = GetListItem(sSpecial, n++);
                RegisterNWNXEventScripts(sEvent);
            }

            // End NWNX Testing
        }
    }

    RegisterLibraryScript("test_OnClientEnter", 0);
    RegisterLibraryScript("test_convo_OnPlayerChat", 1);
    RegisterLibraryScript("test_go_OnPlayerChat", 2);
    RegisterLibraryScript("test_get_OnPlayerChat", 3);
    RegisterLibraryScript("test_stake_OnPlayerChat", 4);
    RegisterLibraryScript("test_level_OnPlayerChat", 5);
    RegisterLibraryScript("test_items_OnPlayerChat", 6);
    RegisterLibraryScript("test_identify_OnPlayerChat", 7);
    RegisterLibraryScript("test_unlock_OnPlayerChat", 8);
    RegisterLibraryScript("test_libraries_OnPlayerChat", 9);
    RegisterLibraryScript("test_time_OnPlayerChat", 10);
    RegisterLibraryScript("test_var_OnPlayerChat", 11);
    RegisterLibraryScript("test_script_OnPlayerChat", 12);
    RegisterLibraryScript("test_debug_OnPlayerChat", 13);
    RegisterLibraryScript("test_destroy_OnPlayerChat", 14);
    RegisterLibraryScript("test_run_OnPlayerChat", 15);
    RegisterLibraryScript("test_test_OnPlayerChat", 16);
    RegisterLibraryScript("test_poststring_OnPlayerChat", 17);

    RegisterLibraryScript("nwnx_WalkTest", 100);
    RegisterLibraryScript("nwnx_KeyboardTest", 101);

    RegisterLibraryScript("test_pc_OnPlayerHeartbeat", 102);
    RegisterLibraryScript("test_pc_CheckMovementRate", 103);

    RegisterLibraryScript("test_polymorph", 200);
    RegisterLibraryScript("test_spells", 201);

    // Tag-based Scripting
    RegisterLibraryScript("util_playerdata", 30);
}

void OnLibraryScript(string sScript, int nEntry)
{
    object oPC = GetEventTriggeredBy();
    object oArea = GetArea(oPC);

    switch (nEntry)
    {
        case 0:  test_OnClientEnter(); break;
        case 1:  test_convo_OnPlayerChat(); break;
        case 2:  test_go_OnPlayerChat(); break;
        case 3:  test_get_OnPlayerChat(); break;
        case 4:  test_stake_OnPlayerChat(); break;
        case 5:  test_level_OnPlayerChat(); break;
        case 6:  test_items_OnPlayerChat(); break;
        case 7:  test_identify_OnPlayerChat(); break;
        case 8:  test_unlock_OnPlayerChat(); break;
        case 9:  test_libraries_OnPlayerChat(); break;
        case 10: test_time_OnPlayerChat(); break;
        case 11: test_var_OnPlayerChat(); break;
        case 12: test_script_OnPlayerChat(); break;
        case 13: test_debug_OnPlayerChat(); break;
        case 14: test_destroy_OnPlayerChat(); break;
        case 15: test_run_OnPlayerChat(); break;
        case 16: test_test_OnPlayerChat(); break;
        case 17: test_poststring_OnPlayerChat(); break;

        case 100: nwnx_WalkTest(); break;
        case 101: nwnx_KeyboardTest(); break;
        case 102: test_pc_OnPlayerHeartbeat(); break;
        case 103: test_pc_CheckMovementRate(); break;

        case 30: test_PlayerDataItem(); break;

        case 200: test_polymorph(); break;
        case 201: test_spells(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
