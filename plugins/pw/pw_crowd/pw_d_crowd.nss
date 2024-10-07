// -----------------------------------------------------------------------------
//    File: pw_d_crowd.nss
//  System: Dynamic Dialogs (library script)
//     URL: 
// Authors: Edward Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// This library contains some simlple dialogs for the crowd system.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "pw_i_crowd"

// -----------------------------------------------------------------------------
//                                  Crowd Dialog
// -----------------------------------------------------------------------------
// This dialog is assigned to randomly-generated crowd members, who may either
//  speak to the PC or walk away, depending on time of day and gender comparison.
// -----------------------------------------------------------------------------

const string CROWD_DIALOG       = "CrowdDialog";
const string CROWD_DIALOG_INIT  = "CrowdDialog_Init";
const string CROWD_DIALOG_PAGE  = "CrowdDialog_Page";
const string CROWD_DIALOG_NODE  = "CrowdDialog_Node";
const string CROWD_DIALOG_END   = "CrowdDialog_End";

const string CROWD_PAGE_MAIN    = "CrowdMain";
const string CROWD_PAGE_INFO    = "CrowdInfo";
const string CROWD_PAGE_LODGING = "CrowdLodging";
const string CROWD_PAGE_TEMPLE  = "CrowdTemple";
const string CROWD_PAGE_POOR    = "CrowdPoor";

object oNPC = OBJECT_SELF;
object oPC = GetPCSpeaker();

void SpeakOneLiner(string sResponse)
{
    ClearAllActions();
    ActionDoCommand(SetFacingPoint(GetPosition(oPC)));
    SpeakString(sResponse, TALKVOLUME_TALK);
    ActionWait(1.5f);
}

int GetSpeakOneLine()
{
    int nResponse = Random(10) + 1;
    string sResponse;

    if (nResponse >= 8)
        return FALSE;

    if (GetIsDusk() || GetIsNight())
    {
        if (GetGender(oNPC) && !GetGender(oPC))
        {
            switch (nResponse)
            {
                case 1:  sResponse = "Sorry, sir, I was taught never to speak to strangers, especially at night.  Please be on your way and I'll be on mine.";          break;
                case 2:  sResponse = "Good evening, sir. Please, it's much too late for conversation.  Good night.";                                                    break;
                case 3:  sResponse = "I'm sorry, sir, I don't talk to strangers at night.";                                                                             break;
                case 4:  sResponse = "Mama!  A strange man is trying to talk to me!";                                                                                   break;
                case 5:  sResponse = "Please sir, I mean no harm.  Where's the guard.  Guard!  I must be going.";                                                       break;
                case 6:  sResponse = "It's much too late for a conversation, I must get home.  Good night.";                                                            break;
                case 7:  sResponse = "It's not a good idea to be randomly talking to young women walking alone at night.  Please move along before I call the guards."; break;
                case 8:  sResponse = "Sir, night time is not the right time.  Good evening.";                                                                           break;
                case 9:  sResponse = "Not now, my husband will be along soon.  You best be gone by the time he gets here.";                                             break;
                case 10: sResponse = "Good evening, sir.  I know you may not be from around here, but we don't appreciate strangers speaking to our women at night.";   break;
                default: sResponse = "Not now, sir.  I must be going.";
            }
        }
        else if (GetGender(oNPC) && GetGender(oPC))
        {
            switch (nResponse)
            {
                case 1:  sResponse = "Good evening ma'am.  It is nice to see other ladies roaming around, but I have to be going.";                                     break;
                case 2:  sResponse = "Hello, ma'am.  You might be new here.  Roaming around at night alone here can be bad for your health.";                           break;
                case 3:  sResponse = "I'm sorry, ma'am, I don't talk to strangers at night.";                                                                           break;
                case 4:  sResponse = "Mama!  A strange lady is trying to talk to me!";                                                                                  break;
                case 5:  sResponse = "Please, I mean no harm.  Where's the guard.  Guard!  I must be going.";                                                           break;
                case 6:  sResponse = "It's much too late for a conversation, I must get home.  Good night.";                                                            break;
                case 7:  sResponse = "It's not a good idea to be talking to young women walking alone at night.  Please move along before I call the guards.";          break;
                case 8:  sResponse = "Ma'am, night time is not the right time.  Good evening.";                                                                         break;
                case 9:  sResponse = "Not now, my husband will be along soon.  You best be gone by the time he gets here.";                                             break;
                case 10: sResponse = "*whispers* I know you may not be from around here, but our men-folk don't take kindly to strangers conversing with our women.";   break;
                default: sResponse = "Not now, ma'am.  I must be going.";
            }                
        }
        else
        {
            switch (nResponse)
            {
                case 1:  sResponse = "Good evening.  I hope you like our town.  It can be quite dangerous at night, so get moving along.";                              break;
                case 2:  sResponse = "Hello.  You might be new here.  Roaming around at night alone here can be bad for your health.";                                  break;
                case 3:  sResponse = "I'm sorry, but we prefer to meet our strangers during the day.  You might want to find a place to stay for the night.";           break;
                case 4:  sResponse = "Best not be walking around armed here at night.  And stay away from our women!";                                                  break;
                case 5:  sResponse = "Please, I mean no harm.  Where's the guard.  Guard!  I must be going.";                                                           break;
                case 6:  sResponse = "It's much too late for a conversation, I must get home.  Good night.";                                                            break;
                case 7:  sResponse = "It's not a good idea to be skulking about at night.  Please move along before I call the guards.";                                break;
                case 8:  sResponse = "Night time is not the right time.  Good evening.";                                                                                break;
                case 9:  sResponse = "Not now, the guards will be along soon.  You best be gone by the time they get here.";                                            break;
                case 10: sResponse = "Best be seeking some shelter for the night, if you know what's good for you.";                                                    break;
                default: sResponse = "Not now.  I must be going.";
            }                
        }

        SpeakOneLiner(sResponse);
        return TRUE;        
    }
    else
    {
        if (nResponse < 8)
        {
            switch (Random(10) + 1)
            {
                case 1:  sResponse = "It's a lovely day here!  I hope I get off work early today.";                                                                     break;
                case 2:  sResponse = "These guards can be quite nasty.  Keep your wits about you.";                                                                     break;
                case 3:  sResponse = "We don't see too many strangers around these parts.  People here aren't very trusting, best keep your wits about you.";           break;
                case 4:  sResponse = "Welcome to town, stranger!  Please, visit our shops.  We could really use the business.";                                         break;
                case 5:  sResponse = "Please, I mean no harm.  Where's the guard.  Guard!  I must be going.";                                                           break;
                case 6:  sResponse = "Good to see some new faces around, but I must be going.  Work is work!";                                                          break;
                case 7:  sResponse = "Have you visited the temple yet?  It's so nice there this time of day.";                                                          break;
                case 8:  sResponse = "I don't have time for this right now.  I need to get home!";                                                                      break;
                case 9:  sResponse = "Not now, the guards will be along soon.  You best be gone by the time they get here.";                                            break;
                case 10: sResponse = "I hope you find our small town accommodating to your needs.  Good day, stranger!";                                                break;
                default: sResponse = "Not now.  I must be going.";                
            }

            SpeakOneLiner(sResponse);
            return TRUE; 
        }

        return FALSE;
    }
}

void CrowdDialog_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(CROWD_PAGE_MAIN);
    AddDialogPage(CROWD_PAGE_MAIN, "Hello <sir/madam>!  Welcome to our small town.  We don't get to see strangers much " +
        "around here.  I'm so glad you could join us.  Please ... visit our merchants, lord knows we could use the business. " +
        "And speaking of the lord, the temples here are quite splendid.  Do take some time from your journey to visit them " +
        "and maybe drop a tithing or two on your way out.  The people here are very much in need and we would really " +
        "appreciate it.\n\nIs there anything I can tell you about our little berg?");
    AddDialogNode(CROWD_PAGE_MAIN, CROWD_PAGE_LODGING, "Is there any place to stay around here?");
    AddDialogNode(CROWD_PAGE_MAIN, CROWD_PAGE_TEMPLE, "Tell me more about those temples.");
    AddDialogNode(CROWD_PAGE_MAIN, CROWD_PAGE_POOR, "You plight worries me, how can I help?");
    EnableDialogEnd("Your problems are not mine.  Get away from me!", CROWD_PAGE_MAIN);
    
    AddDialogPage(CROWD_PAGE_LODGING, "Yes, quite a few, though they may not be up to your standards.  If you're looking " +
        "for something economical, the no-tell motel is just around the corner.  If you have a little more coin in your " +
        "pocket that you're willing to part with, the Astoria is just up the road and around the corner.  Tell Margie " +
        "I said hi!");
    SetDialogNodes(CROWD_PAGE_LODGING, CROWD_PAGE_MAIN);
    EnableDialogEnd("Thanks for the info, I'll be on my way.", CROWD_PAGE_LODGING);

    AddDialogPage(CROWD_PAGE_TEMPLE, "Oh yes!  Brother John up in the Sun Temple is having quite the hard time keeping " +
        "his followers.  Seems the constant heat here makes people question the veracity of his God.  He could use some " +
        "help.  Or maybe Father Jacob down in the Earth temple.  Quite dusty there, they could use some help cleaning up." +
        "\n\n Of course, really, any of the temples here would be quite grateful for your patronage and support.  With the " +
        "wars and famine that have swept through in recent years, everyone is on their heels.");
    SetDialogNodes(CROWD_PAGE_TEMPLE, CROWD_PAGE_MAIN);
    EnableDialogEnd("Thanks for the info, I'll be sure to visit one of your temples.", CROWD_PAGE_TEMPLE);

    AddDialogPage(CROWD_PAGE_POOR, "Well, you'll likely find many beggars and street performers here.  Please support them " +
        "with whatever you can.  Their families will really appreciate it.  Also, if you have any work you can provide to " +
        "our men, they would be most appreciative.\n\nWe are quite poor, but many here are skilled in smithing and have had " +
        "military experience.  I'm sure they would love to accompany you on your adventures if you pay well enough to make it " +
        "worth their while.");
    SetDialogNodes(CROWD_PAGE_POOR, CROWD_PAGE_MAIN);
    EnableDialogEnd("Thanks for the information, I'll do what I can.", CROWD_PAGE_POOR);
}

void CrowdDialog_Page()
{
    string sPage = GetDialogPage();

    if (sPage == CROWD_PAGE_MAIN)
    {
        if (GetSpeakOneLine())
            SetDialogState(DLG_STATE_ENDED);
        else if (GetDialogNode() == DLG_NODE_NONE)
            ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING);
    }
    else if (sPage == CROWD_PAGE_LODGING)
        FilterDialogNodes(0);
    else if (sPage == CROWD_PAGE_TEMPLE)
        FilterDialogNodes(1);
    else if (sPage == CROWD_PAGE_POOR)
        FilterDialogNodes(2);

    ClearDialogHistory();
}

void CrowdDialog_End()
{
    ResumeCrowdMemberActivity(oNPC);
}

// -----------------------------------------------------------------------------
//                                  Guard Default
// -----------------------------------------------------------------------------
// This dialog is assigned as a demonstration dialog for the crowd designated
//  as guards in the start area.
// -----------------------------------------------------------------------------

const string GUARD_DIALOG    = "GuardDialog";
const string GUARD_PAGE_NULL = "GUARD_PAGE_NULL";

void GuardDialog()
{
    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
            SetDialogPage(GUARD_PAGE_NULL);
            AddDialogPage(GUARD_PAGE_NULL, ""); 
        case DLG_EVENT_PAGE:
            SpeakOneLiner("Can't you see I'm a guard?  I've got guarding to do.  " +
                "Go away.  guard guard guard");
            SetDialogState(DLG_STATE_ENDED);
            break;
        case DLG_EVENT_ABORT:
            ResumeCrowdMemberActivity(oNPC);
            break;
        default:
            break;
    }
}

// -----------------------------------------------------------------------------
//                                  Noble Dialog
// -----------------------------------------------------------------------------
// This dialog is assigned as a demonstration dialog for the crowd designated
//  as nobles in the start area.
// -----------------------------------------------------------------------------

const string NOBLE_DIALOG    = "NobleDialog";
const string NOBLE_PAGE_NULL = "NOBLE_PAGE_NULL";

void NobleDialog()
{
    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
            SetDialogPage(NOBLE_PAGE_NULL);
            AddDialogPage(NOBLE_PAGE_NULL, ""); 
        case DLG_EVENT_PAGE:
            SpeakOneLiner("I'm too busy for the likes of you.  I've got much too much " +
                "nobilitying, er..., nobling, er.. " +
                "Shut up, those are words!  Bah!  I'm richer than you, go away!");
            SetDialogState(DLG_STATE_ENDED);
            break;
        case DLG_EVENT_ABORT:
            ResumeCrowdMemberActivity(oNPC);
            break;
        default:
            break;
    }
}

// -----------------------------------------------------------------------------
//                                  Crowd Default
// -----------------------------------------------------------------------------
// This dialog is assigned to crowd members when the builder did not assign a
//  custom conversation.  The NPC will speak a one-liner, then resume their
//  previous activity.
// -----------------------------------------------------------------------------
const string CROWD_DEFAULT_DIALOG       = "CrowdDefaultDialog";
const string CROWD_DEFAULT_PAGE_NULL    = "CROWD_DEFAULT_PAGE_NULL";

void CrowdDefault()
{
    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
            SetDialogPage(CROWD_DEFAULT_PAGE_NULL);
            AddDialogPage(CROWD_DEFAULT_PAGE_NULL, ""); 
        case DLG_EVENT_PAGE:
            SpeakOneLiner("I'm sorry, I must be going.");
            SetDialogState(DLG_STATE_ENDED);
            break;
        case DLG_EVENT_ABORT:
            ResumeCrowdMemberActivity(oNPC);
            break;
        default:
            break;
    }
}

void OnLibraryLoad()
{
    RegisterLibraryScript(CROWD_DIALOG);
    RegisterLibraryScript(CROWD_DIALOG_INIT);
    RegisterLibraryScript(CROWD_DIALOG_PAGE);
    RegisterLibraryScript(CROWD_DIALOG_END);

    RegisterDialogScript(CROWD_DIALOG, CROWD_DIALOG_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(CROWD_DIALOG, CROWD_DIALOG_PAGE, DLG_EVENT_PAGE);
    RegisterDialogScript(CROWD_DIALOG, CROWD_DIALOG_END,  DLG_EVENT_END | DLG_EVENT_ABORT);

    RegisterLibraryScript(GUARD_DIALOG);
    RegisterDialogScript (GUARD_DIALOG);

    RegisterLibraryScript(NOBLE_DIALOG);
    RegisterDialogScript (NOBLE_DIALOG);

    RegisterLibraryScript(CROWD_DEFAULT_DIALOG);
    RegisterDialogScript (CROWD_DEFAULT_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if      (sScript == CROWD_DIALOG_INIT)  CrowdDialog_Init();
    else if (sScript == CROWD_DIALOG_PAGE)  CrowdDialog_Page();
    else if (sScript == CROWD_DIALOG_END)   CrowdDialog_End();

    else if (sScript == GUARD_DIALOG)           GuardDialog();
    else if (sScript == NOBLE_DIALOG)           NobleDialog();
    else if (sScript == CROWD_DEFAULT_DIALOG)   CrowdDefault();
}
