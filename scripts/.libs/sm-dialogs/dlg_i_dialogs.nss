/// -----------------------------------------------------------------------------
/// @file   dlg_i_dialogs.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (include script)
/// -----------------------------------------------------------------------------
/// This is the main include file for the Dynamic Dialogs system. It should not be
/// edited by the builder. Place all customization in dlg_c_dialogs instead.
/// -----------------------------------------------------------------------------
/// Acknowledgements:
/// This system is inspired by Acaos's HG Dialog system and Greyhawk0's
/// ZZ-Dialog, which is itself based on pspeed's Z-dialog.
/// -----------------------------------------------------------------------------
/// System Design:
/// A dialog is made up of pages (NPC text) and nodes (PC responses). Both pages
/// and nodes have text which is displayed to the player. Nodes also have a
/// target, a page that will be shown when the player clicks the node. By
/// default, all nodes added to a page will be shown, but they can be filtered
/// based on conditions (see below).
///
/// The system is event-driven, with the following events accessible from the
/// dialog script using GetDialogEvent():
///   - DLG_EVENT_INIT: Initial setup. Pages and nodes are added to map the
///     dialog.
///   - DLG_EVENT_PAGE: A page is shown to the PC. Text can be altered before
///     being shown, nodes can be filtered out using FilterDialogNodes(), and you
///     can even change the page being shown.
///   - DLG_EVENT_NODE: A node was clicked. The page and node are accessible
///     using GetDialogPage() and GetDialogNode(), respectively. You can set a
///     new target for the page if you do not want the one that was already
///     assigned to the node.
///   - DLG_EVENT_END: The dialog was ended normally (through an End Dialog node
///     or a page with no responses).
///   - DLG_EVENT_ABORT: The dialog was aborted by the player.
/// -----------------------------------------------------------------------------

#include "util_i_datapoint"
#include "util_i_debug"
#include "util_i_libraries"
#include "util_i_lists"
#include "dlg_c_dialogs"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DLG_SYSTEM = "Dynamic Dialogs System";
const string DLG_PREFIX = "Dynamic Dialog: ";

const string DLG_RESREF_ZOOM   = "dlg_convzoom";
const string DLG_RESREF_NOZOOM = "dlg_convnozoom";

// ----- VarNames --------------------------------------------------------------

const string DLG_DIALOG        = "*Dialog";
const string DLG_CURRENT_PAGE  = "*CurrentPage";
const string DLG_CURRENT_NODE  = "*CurrentNode";
const string DLG_INITIALIZED   = "*Initialized";
const string DLG_HAS           = "*Has";
const string DLG_NODE          = "*Node";
const string DLG_NODES         = "*Nodes";
const string DLG_TEXT          = "*Text";
const string DLG_DATA          = "*Data";
const string DLG_TARGET        = "*Target";
const string DLG_ENABLED       = "*Enabled";
const string DLG_COLOR         = "*Color";
const string DLG_CONTINUE      = "*Continue";
const string DLG_HISTORY       = "*History";
const string DLG_OFFSET        = "*Offset";
const string DLG_FILTER        = "*Filter";
const string DLG_FILTER_MAX    = "*FilterMax";
const string DLG_SPEAKER       = "*Speaker";
const string DLG_PRIVATE       = "*Private";
const string DLG_NO_ZOOM       = "*NoZoom";
const string DLG_NO_HELLO      = "*NoHello";
const string DLG_TOKEN         = "*Token";
const string DLG_TOKEN_CACHE   = "*TokenCache";
const string DLG_TOKEN_VALUES  = "*TokenValues";
const string DLG_TOKEN_SCRIPT  = "*TokenScript";
const string DLG_ACTION        = "*Action";
const string DLG_ACTION_CHECK  = "*Check";
const string DLG_ACTION_NODE   = "*Node";
const string DLG_ACTION_PAGE   = "*Page";

// ----- Automated Node IDs ----------------------------------------------------

const int DLG_NODE_NONE     = -1;
const int DLG_NODE_CONTINUE = -2;
const int DLG_NODE_END      = -3;
const int DLG_NODE_PREV     = -4;
const int DLG_NODE_NEXT     = -5;
const int DLG_NODE_BACK     = -6;

// ----- Dialog States ---------------------------------------------------------

const string DLG_STATE = "*State";
const int    DLG_STATE_INIT    = 0; // Dialog is new and uninitialized
const int    DLG_STATE_RUNNING = 1; // Dialog is running normally
const int    DLG_STATE_ENDED   = 2; // Dialog has ended

// ----- Dialog Events ---------------------------------------------------------

const string DLG_EVENT = "*Event";
const int    DLG_EVENT_NONE  = 0x00;
const int    DLG_EVENT_INIT  = 0x01; // Dialog setup and initialization
const int    DLG_EVENT_PAGE  = 0x02; // Page choice and action
const int    DLG_EVENT_NODE  = 0x04; // Node selected action
const int    DLG_EVENT_END   = 0x08; // Dialog ended normally
const int    DLG_EVENT_ABORT = 0x10; // Dialog ended abnormally
const int    DLG_EVENT_ALL   = 0x1f;

const string DIALOG_EVENT_ON_INIT  = "OnDialogInit";
const string DIALOG_EVENT_ON_PAGE  = "OnDialogPage";
const string DIALOG_EVENT_ON_NODE  = "OnDialogNode";
const string DIALOG_EVENT_ON_END   = "OnDialogEnd";
const string DIALOG_EVENT_ON_ABORT = "OnDialogAbort";

// ----- Event Prioroties ------------------------------------------------------

const float DLG_PRIORITY_FIRST   = 10.0;
const float DLG_PRIORITY_DEFAULT =  5.0;
const float DLG_PRIORITY_LAST    =  0.0;

// ----- Event Script Processing -----------------------------------------------
const int DLG_SCRIPT_OK    = 0;
const int DLG_SCRIPT_ABORT = 1;

// ----- Custom Token Reservation ----------------------------------------------

const int DLG_CUSTOM_TOKEN = 20000;

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

object DIALOGS  = GetDatapoint(DLG_SYSTEM);
object DIALOG   = GetLocalObject(GetPCSpeaker(), DLG_SYSTEM);
object DLG_SELF = GetLocalObject(GetPCSpeaker(), DLG_SPEAKER);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Utility Functions -----------------------------------------------------

/// @brief Converts a DLG_EVENT_* constant to its string representation.
/// @param nEvent DLG_EVENT_* constant.
/// @returns DLG_EVENT_ON_* constant.
string DialogEventToString(int nEvent);

/// @brief Initiates a conversation.
/// @param oPC The player character to speak with.
/// @param oTarget The object (usually a creature) that oPC will speak with.
/// @param sDialog The library script to use for the conversation.  If blank,
///     the system will look for the string variable `*Dialog` on oTarget.
/// @param bPrivate If TRUE, prevents other players from hearing the conversation.
/// @param bNoHello If TRUE, prevents the "hello" voicechat from playing on dialog
///     start.
/// @param bNoZoom If TRUE, prevents zooming in towards oPC on dialog start.
/// @note If oTarget is not a creature or placeable, oPC will talk to themselves.
void StartDialog(object oPC, object oTarget = OBJECT_SELF, string sDialog = "", int bPrivate = FALSE, int bNoHello = FALSE, int bNoZoom = FALSE);

// ----- Dialog Setup ----------------------------------------------------------

/// @brief Returns whether sPage exists in the dialog.
/// @param sPage The page name to search for.
int HasDialogPage(string sPage);

/// @brief Adds a dialog page.
/// @param sPage The name of the page to add.  If sPage already exists, a new
///     page of a continuation chain is added.
/// @param sText The body text to add to sPage.
/// @param sData An arbitrary string used to store additional information.
/// @returns The name of the added page.
/// @warning Page names should not contain a `#` symbol.
string AddDialogPage(string sPage, string sText = "", string sData = "");

/// @brief Links a page to a target using a continue node.
/// @param sPage Page name to link to sTarget.
/// @param sTarget Page name to link to sPage.
/// @note This function is called automatically when adding multiple pages of
///     the same name with AddDialogPage(), but this function can be called
///     separately to end a continue chain.
void ContinueDialogPage(string sPage, string sTarget);

/// @brief Add a response node to a dialog page.
/// @param sPage Page to add the response node to.
/// @param sTarget Page to link to the dialog node.
/// @param sText Text to display on the dialog node.
/// @param sData An arbitrary string used to store additional information.
int AddDialogNode(string sPage, string sTarget, string sText, string sData = "");

/// @brief Returns the number of dialog nodes on a dialog page.
/// @param sPage Page name to count dialog nodes on.
int CountDialogNodes(string sPage);

/// @brief Copy a dialog node from one page to another.
/// @param sSource Page to copy a dialog node from.
/// @param nSource Index of dialog node to copy from.
/// @param sTarget Page to copy dialog node to.
/// @param nTarget Index of dialog node to copy to.
/// @returns Index of the copied node; -1 on error.
/// @note If nTarget = DLG_NODE_NONE, the copied node will be added to
///     the end of sTarget's dialog node list.
int CopyDialogNode(string sSource, int nSource, string sTarget, int nTarget = DLG_NODE_NONE);

/// @brief Copy all dialog nodes from one page to another.
/// @param sSource Page to copy dialog nodes from.
/// @param sTarget Page to copy dialog nodes to.
/// @returns sTarget's dialog node count after the copy operation.
int CopyDialogNodes(string sSource, string sTarget);

/// @brief Delete a dialog node.
/// @param sPage Page to delete dialog node from.
/// @param nNode Index of dialog node to delete.
/// @returns sPage's dialog node count after the delete operation.
int DeleteDialogNode(string sPage, int nNode);

/// @brief Delete all dialog nodes on a page.
/// @param sPage Page to delete all dialog nodes from.
void DeleteDialogNodes(string sPage);

/// @brief Hide specific dialog nodes from the conversation window.
/// @param nStart Index of dialog node to begin hiding from.
/// @param nEnd Index of dialog node to end hiding at.
/// @note Dialog nodes will be hidden on the currently displayed page.
/// @note If nEnd < 0, only the dialog node at nStart will be hidden.
void FilterDialogNodes(int nStart, int nEnd = -1);

// ----- Accessor Functions ----------------------------------------------------

/// @brief Returns the name of the current dialog.
string GetDialog();

/// @brief Determine the source of a page's dialog nodes.
/// @param sPage Page whose dialog node source is to be determined.
string GetDialogNodes(string sPage);

/// @brief Force a page to use dialog nodes from another page.
/// @param sPage Page whose dialog nodes will be overwritten.
/// @param sSource Page where dialog nodes will be sourced from.
/// @note If sSource = "", sPage will return to using its original dialog nodes.
void SetDialogNodes(string sPage, string sSource = "");

/// @brief Get the text from a specific dialog node.
/// @param sPage Page to search dialog nodes on.
/// @param nNode Index of dialog node to search.
/// @note If nNode = DLG_NODE_NONE, text from sPage will be retrieved.
string GetDialogText(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the text on a specific dialog node.
/// @param sText Dialog node text.
/// @param sPage Page to set dialog node text on.
/// @param nNode Index of dialog node to set text on.
/// @note If nNode = DLG_NODE_NONE, sPage's text will be set to sText.
void SetDialogText(string sText, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Get the dialog data from a dialog node.
/// @param sPage Page to retrieve dialog node data from.
/// @param nNode Index of dialog node to retrieve data from.
/// @note If nNode = DLG_NODE_NONE, data from sPage will be retrieved.
string GetDialogData(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the dialog data on a dialog node.
/// @param sData Data to set.
/// @param sPage Page to set dialog data on.
/// @param nNode Index of dialog node to set data on.
/// @note If nNode = DLG_NODE_NONE, sData will be set on sPage.
void SetDialogData(string sData, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Find the target of a dialog node.
/// @param sPage Page containing the dialog node to search for.
/// @param nNode Index of dialog node to search for.
/// @returns Page name of dialog node's target.
/// @note If nNode = DLG_NODE_NONE, sPage's target will be retrieved.
string GetDialogTarget(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the target of a dialog node.
/// @param sTarget Page name of target to set on dialog node.
/// @param spage Page containing dialog node to set target on.
/// @param nNode Index of dialog node to set target on.
/// @note If nNode = DLG_NODE_NONE, sTarget will be set on sPage.
void SetDialogTarget(string sTarget, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Get the state of the currently running dialog.
/// @returns DLG_STATE_* constant:
///     DLG_STATE_INIT: the dialog is new and uninitialized.
///     DLG_STATE_RUNNING: the dialog has been initialized or is in progress.
///     DLG_STATE_ENDED: the dialog has finished.
int GetDialogState();

/// @brief Set the state of the currently running dialog:
/// @param nState DLG_STATE_* constant:
///     DLG_STATE_INIT: the dialog is new and uninitialized.
///     DLG_STATE_RUNNING: the dialog has been initialized or is in progress.
///     DLG_STATE_ENDED: the dialog has finished.
void SetDialogState(int nState);

/// @brief Returns a comma-separated list of previously visited page names, in
///     reverse order of visitation.
string GetDialogHistory();

/// @brief Sets the currently running dialog's history.
/// @param sHistory A comma-separated list of previously visited pages, in reverse
///     order of visitation.
void SetDialogHistory(string sHistory);

/// @brief Clear the currently running dialog's history.
void ClearDialogHistory();

/// @brief Return the current dialog page.
string GetDialogPage();

/// @brief Return the current dialog page number.
/// @returns 1, if the current page is a parent page; the page number if the 
///     current page is a child page; 0, in case of error or page number cannot
///     be determined.
int GetDialogPageNumber();

/// @brief Return the page name of the current dialog page's parent.
/// @note If the current dialog page is not a child page, returns "".
string GetDialogPageParent();

/// @brief Set the current dialog page.
/// @param sPage Page to set as the current dialog page.
/// @param nPage Page number to set as the current dialog page, if sPage has
///     continuation/child pages.
void SetDialogPage(string sPage, int nPage = 1);

/// @brief Return the index of the last-selected dialog node.
/// @note Returns DLG_NODE_NONE if no node has been selected yet.
int GetDialogNode();

/// @brief Sets the index of the last-selected dialog node.
/// @param nNode Index of dialog node to set as last-selected.
/// @warning Using this function without understanding its repurcussions can
///     cause unexpected behavior.
void SetDialogNode(int nNode);

/// @brief Get the current dialog event.
/// @returns DLG_EVENT_* constant:
///     DLG_EVENT_INIT: dialog setup and initialization
///     DLG_EVENT_PAGE: page choice and action
///     DLG_EVENT_NODE: node selected action
///     DLG_EVENT_END: dialog ended normally
///     DLG_EVENT_ABORT: dialog ended abnormally
int GetDialogEvent();

/// @brief Alias for GetDialogText() for automated nodes.
/// @param nNode Index of dialog node to get text from.
/// @param sPage Page to search for nNode on.
/// @note If sPage = "", nNode's label for all pages will be returned.
string GetDialogLabel(int nNode, string sPage = "");

/// @brief Alias for SetDialogText() for automated nodes.
/// @param nNode Index of dialog node to set text on.
/// @param sLabel Text to set on dialog node.
/// @param sPage Page to set dialog text on.
/// @note If sPage = "", nNode's label for all pages will be set to sLabel.
void SetDialogLabel(int nNode, string sLabel, string sPage = "");

/// @brief Enable a dialog node.
/// @param nNode Index of dialog node to enable.
/// @param sPage Page to enable dialog node on.
/// @note If sPage = "", nNode will be enabled on all pages.
void EnableDialogNode(int nNode, string sPage = "");

/// @brief Disable a dialog node.
/// @param nNode Index of dialog node to disable.
/// @param sPage Page to disable dialog node on.
/// @note If sPage = "", nNode will be enabled on all pages.
void DisableDialogNode(int nNode, string sPage = "");

/// @brief Returns whether a dialog node is enabled.
/// @param nNode Index of dialog node to check.
/// @param sPage Page to check for enabled dialog node.
/// @note If sPage = "", will return whether nNode is enable for the dialog
///     in general.
int DialogNodeEnabled(int nNode, string sPage = "");

/// @brief Enable the automated end dialog node.
/// @param sLabel Text to set on the end dialog node.
/// @param sPage Page to set the enable the end dialog node on.
/// @note If sPage = "", end dialog node will be labeled and enabled on all
///     dialog pages.
/// @note This function is equivalent to calling:
///     EnableDialogNode(DLG_NODE_END, sPage);
///     SetDialogLabel(DLG_NODE_END, sLabel, sPage);
void EnableDialogEnd(string sLabel = DLG_LABEL_END, string sPage = "");

/// @brief Enable the automated back dialog node.
/// @param sLabel Text to set on the back dialog node.
/// @param sPage Page to set the enable the back dialog node on.
/// @note If sPage = "", back dialog node will be labeled and enabled on all
///     dialog pages.
/// @note This function is equivalent to calling:
///     EnableDialogNode(DLG_NODE_BACK, sPage);
///     SetDialogLabel(DLG_NODE_BACK, sLabel, sPage);
void EnableDialogBack(string sLabel = DLG_LABEL_BACK, string sPage = "");

/// @brief Returns the number of nodes before the first node displayed on the
///     dialog response list.
int GetDialogOffset();

/// @brief Set the index of the first dialog node to be shown on the dialog
///     response list.
/// @param nOffset Index of dialog node.
/// @note If nOffset > 0, the automated previous node will be displayed.
void SetDialogOffset(int nOffset);

/// @brief Returns the filter that controls the display of a node.
/// @param nPos Index of dialog node to check filter for.
int GetDialogFilter(int nPos = 0);

/// @brief Return the color constant used to color an automated dialog node.
/// @param nNode Index of automated dialog node.
/// @param sPage Page containing nNode.
/// @warning The nwn color code is returned, not a hex color.
string GetDialogColor(int nNode, string sPage = "");

/// @brief Set the hex color used to color an automated dialog node.
/// @param nNode Index of automated dialog node to color.
/// @param nColor Hex color used to color dialog nodes.
/// @param sPage Page containing nNode.
/// @note If sPage = "", nNode on every dialog page will be colored.
void SetDialogColor(int nNode, int nColor, string sPage = "");

// ----- Dialog Tokens ---------------------------------------------------------

/// @brief Returns the form of a token used with AddDialogToken(). If all
///     lowercase, the token can resolve to uppercase or lowercase, depending
///     on the value of sToken. Otherwise, the value will not have its case changed.
/// @param sToken String token to normalize.
/// @returns sToken with appropriate capitalization applied.
string NormalizeDialogToken(string sToken);

/// @brief Used in token evaluation scripts to set the value the token should resolve
///     to. If the value can be either lowercase or uppercase, always set the
///     uppercase version.
/// @param sValue Value to set dialog token to.
void SetDialogTokenValue(string sValue);

/// @brief Adds a token, which will be evaluated at displaytime by the library script
///     sEvalScript. If sToken is all lowercase, the token can be used in either
///     upper- or lowercase forms. Otherwise, the token is case-sensitive and must
///     match sToken. sValues is a CSV list of possible values that can be handed to
///     sEvalScript.
/// @param sToken Token to add to dialog token list.
/// @param sEvalScript Script or function that will be run to determine value of sToken.
/// @param sValues Comma-separated list of possible values that will be passed to
void AddDialogToken(string sToken, string sEvalScript = "", string sValues = "");

/// @brief Add all default dialog tokens.  This is called by the system during the
///     dialog init stage and need not be used by the builder.
void AddDialogTokens();

/// @brief Add a cached dialog token with a known value.
/// @param sToken Name of dialog token.
/// @param sValue Cached value of dialog token.
/// @note If a dialog token's value will generally not change, this function can
///     be used to hasten token resolution.
void AddCachedDialogToken(string sToken, string sValue);

/// @brief Returns a cached token value.
/// @param sToken Name of dialog token.
string GetCachedDialogToken(string sToken);

/// @brief Caches the value of a token so that the eval script does not have to run
///     every time the token is encountered. This cache lasts for the lifetime of the
///     dialog.
/// @param sToken Name of dialog token.
/// @param sValue Cached value of dialog token. 
void CacheDialogToken(string sToken, string sValue);

/// @brief Clears the cache for sToken, ensuring that the next time the token is
///     encountered, its eval script will run again.
/// @param sToken Name of dialog token.
void UnCacheDialogToken(string sToken);

/// @brief Runs the appropriate evaluation script for sToken using oPC as OBJECT_SELF.
///     Returns the token value. This is called by the system and need not be used by
///     the builder.
/// @param sToken Name of dialog token.
/// @param oPC Player object running current dialog.
string EvalDialogToken(string sToken, object oPC);

/// @brief Evaluates all tokens in sString and interpolates them. This is called by the
///     system and need not be used by the builder.
/// @param sString String containing tokens to be evaluated.
string EvalDialogTokens(string sString);

// ----- System Functions ------------------------------------------------------

/// @brief Returns the object holding cached dialog data.
/// @param sDialog Name of dialog.
object GetDialogCache(string sDialog);

/// @brief Registers a library script as handling particular events for a dialog.
/// @param sDialog Name of dialog to register events to.
/// @param sScript Name of dialog script to register.
/// @param nEvents Bitmasked list of DLG_EVENT_* constants to register.
/// @param fPriority Determines order in which scripts will be called.
/// @note fPriority is useful if there are multiple scripts that have been
//      registered for this event to this dialog. This is useful if you want to have
//      outside scripts add or handle new nodes and pages.
void RegisterDialogScript(string sDialog, string sScript = "", int nEvents = DLG_EVENT_ALL, float fPriority = DLG_PRIORITY_DEFAULT);

/// @brief Sorts all scripts registered to the current dialog by priority.
/// @param nEvent DLG_EVENT_* constant.
void SortDialogScripts(int nEvent);

/// @brief Calls all scripts registered to nEvent for the current dialog in order of
///     priority.
/// @param nEvent DLG_EVENT_* constant.
/// @note The called scripts can use LibraryReturn(DLG_SCRIPT_ABORT) to stop remaining
///     scripts from firing.
void SendDialogEvent(int nEvent);

/// @brief Creates a cache for the current dialog and send the DLG_EVENT_INIT event if
///     it was not already created, instantiates the cache for the current PC, and
///     sets the dialog state to DLG_STATE_RUNNING.
void InitializeDialog();

/// @brief Runs the DLG_EVENT_PAGE event for the current page and sets the page text.
/// @returns Whether a valid page was returned and the dialog should continue.
int LoadDialogPage();

/// @brief Evaluates which nodes should be shown to the PC and sets the appropriate
///     text.
void LoadDialogNodes();

/// @brief Sends the DLG_EVENT_NODE event for the node represented by a PC response.
/// @param nClicked Dialog node clicked by PC.
void DoDialogNode(int nClicked);

/// @brief Cleans up leftover dialog data when a conversation ends.
void DialogCleanup();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Utility Functions -----------------------------------------------------

// Private function used below
string NodeToString(string sPage, int nNode = DLG_NODE_NONE)
{
    if (nNode == DLG_NODE_NONE)
        return sPage;

    return sPage + DLG_NODE + IntToString(nNode);
}

string DialogEventToString(int nEvent)
{
    switch (nEvent)
    {
        case DLG_EVENT_INIT:  return DIALOG_EVENT_ON_INIT;
        case DLG_EVENT_PAGE:  return DIALOG_EVENT_ON_PAGE;
        case DLG_EVENT_NODE:  return DIALOG_EVENT_ON_NODE;
        case DLG_EVENT_END:   return DIALOG_EVENT_ON_END;
        case DLG_EVENT_ABORT: return DIALOG_EVENT_ON_ABORT;
     }

     return "";
}

void StartDialog(object oPC, object oTarget = OBJECT_SELF, string sDialog = "", int bPrivate = FALSE, int bNoHello = FALSE, int bNoZoom = FALSE)
{
    if (sDialog != "")
        SetLocalString(oPC, DLG_DIALOG, sDialog);

    // Since dialog zoom is not exposed to scripting, we use two dialogs: one
    // that zooms and one that doesn't.
    string sResRef = (bNoZoom ? DLG_RESREF_NOZOOM : DLG_RESREF_ZOOM);

    // If the object is not a creature or placeable, we will have the PC talk
    // with himself.
    int nType = GetObjectType(oTarget);
    if (nType != OBJECT_TYPE_PLACEABLE && nType != OBJECT_TYPE_CREATURE)
    {
        // Set the NPC speaker on the PC so we can get the object the PC is
        // supposed to be speaking with.
        SetLocalObject(oPC, DLG_SPEAKER, oTarget);
        oTarget = oPC;
    }

    AssignCommand(oPC, ActionStartConversation(oTarget, sResRef, bPrivate, !bNoHello));
}

// ----- Dialog Setup ----------------------------------------------------------

int HasDialogPage(string sPage)
{
    if (sPage == "")
        return FALSE;

    return GetLocalInt(DIALOG, sPage + DLG_HAS);
}

string AddDialogPage(string sPage, string sText = "", string sData = "")
{
    if (HasDialogPage(sPage))
    {
        int nCount = GetLocalInt(DIALOG, sPage + DLG_CONTINUE);
        SetLocalInt(DIALOG, sPage + DLG_CONTINUE, ++nCount);

        string sParent = sPage;

        // Page -> Page#2 -> Page#3...
        if (nCount > 1)
            sParent += "#" + IntToString(nCount);

        sPage += "#" + IntToString(nCount + 1);
        EnableDialogNode(DLG_NODE_CONTINUE, sParent);
        SetDialogTarget(sPage, sParent, DLG_NODE_CONTINUE);
    }

    Debug("Adding dialog page " + sPage);
    SetLocalString(DIALOG, sPage + DLG_TEXT,  sText);
    SetLocalString(DIALOG, sPage + DLG_DATA,  sData);
    SetLocalString(DIALOG, sPage + DLG_NODES, sPage);
    SetLocalInt   (DIALOG, sPage + DLG_HAS,   TRUE);
    return sPage;
}

void ContinueDialogPage(string sPage, string sTarget)
{
    EnableDialogNode(DLG_NODE_CONTINUE, sPage);
    SetDialogTarget(sTarget, sPage, DLG_NODE_CONTINUE);
}

int AddDialogNode(string sPage, string sTarget, string sText, string sData = "")
{
    if (sPage == "")
        return DLG_NODE_NONE;

    int    nNode = GetLocalInt(DIALOG, sPage + DLG_NODES);
    string sNode = NodeToString(sPage, nNode);

    Debug("Adding dialog node " + sNode);
    SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
    SetLocalString(DIALOG, sNode + DLG_TARGET, sTarget);
    SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
    SetLocalInt   (DIALOG, sPage + DLG_NODES,  nNode + 1);
    return nNode;
}

int CountDialogNodes(string sPage)
{
    return GetLocalInt(DIALOG, sPage + DLG_NODES);
}

int CopyDialogNode(string sSource, int nSource, string sTarget, int nTarget = DLG_NODE_NONE)
{
    int nSourceCount = CountDialogNodes(sSource);
    int nTargetCount = CountDialogNodes(sTarget);

    if (nSource >= nSourceCount || nTarget >= nTargetCount)
        return DLG_NODE_NONE;

    if (nTarget == DLG_NODE_NONE)
    {
        nTarget = nTargetCount;
        SetLocalInt(DIALOG, sSource + DLG_NODES, ++nTargetCount);
    }

    string sText, sData, sDest;
    sSource = NodeToString(sSource, nSource);
    sTarget = NodeToString(sTarget, nTarget);
    sText = GetLocalString(DIALOG, sSource + DLG_TEXT);
    sData = GetLocalString(DIALOG, sSource + DLG_DATA);
    sDest = GetLocalString(DIALOG, sSource + DLG_TARGET);
    SetLocalString(DIALOG, sTarget + DLG_TEXT,   sText);
    SetLocalString(DIALOG, sTarget + DLG_DATA,   sData);
    SetLocalString(DIALOG, sTarget + DLG_TARGET, sDest);
    return nTarget;
}

int CopyDialogNodes(string sSource, string sTarget)
{
    int i;
    int nSource = CountDialogNodes(sSource);
    int nTarget = CountDialogNodes(sTarget);
    string sNode, sText, sData, sDest;

    for (i = 0; i < nSource; i++)
    {
        sNode = NodeToString(sSource, i);
        sText = GetLocalString(DIALOG, sNode + DLG_TEXT);
        sData = GetLocalString(DIALOG, sNode + DLG_DATA);
        sDest = GetLocalString(DIALOG, sNode + DLG_TARGET);

        sNode = NodeToString(sTarget, nTarget + i);
        SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
        SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
        SetLocalString(DIALOG, sNode + DLG_TARGET, sDest);
    }

    nTarget += i;
    SetLocalInt(DIALOG, sTarget + DLG_NODES, nTarget);
    return nTarget;
}

int DeleteDialogNode(string sPage, int nNode)
{
    int nNodes = CountDialogNodes(sPage);
    if (nNode < 0)
        return nNodes;

    string sNode, sText, sData, sDest;
    for (nNode; nNode < nNodes; nNode++)
    {
        sNode = NodeToString(sPage, nNode + 1);
        sText = GetLocalString(DIALOG, sNode + DLG_TEXT);
        sData = GetLocalString(DIALOG, sNode + DLG_DATA);
        sDest = GetLocalString(DIALOG, sNode + DLG_TARGET);

        sNode = NodeToString(sPage, nNode);
        SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
        SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
        SetLocalString(DIALOG, sNode + DLG_TARGET, sDest);
    }

    SetLocalInt(DIALOG, sPage + DLG_NODES, --nNodes);
    return nNodes;
}

void DeleteDialogNodes(string sPage)
{
    string sNode;
    int i, nNodes = CountDialogNodes(sPage);
    for (i = 0; i < nNodes; i++)
    {
        sNode = NodeToString(sPage, i);
        DeleteLocalString(DIALOG, sNode + DLG_TEXT);
        DeleteLocalString(DIALOG, sNode + DLG_TARGET);
        DeleteLocalString(DIALOG, sNode + DLG_DATA);
    }

    DeleteLocalInt(DIALOG, sPage + DLG_NODES);
}

// Credits: this function was ripped straight from the HG dialog system.
// Nodes are chunked in blocks of 30. Then we set bit flags to note whether a
// node is to be filtered out. So the following would yield 0x17:
//     FilterDialogNodes(0, 2);
//     FilterDialogNodes(4);
void FilterDialogNodes(int nStart, int nEnd = -1)
{
    if (nStart < 0)
        return;

    if (nEnd < 0)
        nEnd = nStart;

    int nBlockStart = nStart / 30;
    int nBlockEnd   = nEnd / 30;

    int i, j, nBitStart, nBitEnd, nFilter;

    for (i = nBlockStart; i <= nBlockEnd; i++)
    {
        nFilter = GetLocalInt(DIALOG, DLG_FILTER + IntToString(i));

        if (i == nBlockStart)
            nBitStart = nStart % 30;
        else
            nBitStart = 0;

        if (i == nBlockEnd)
            nBitEnd = nEnd % 30;
        else
            nBitEnd = 29;

        for (j = nBitStart; j <= nBitEnd; j++)
            nFilter |= 1 << j;

        SetLocalInt(DIALOG, DLG_FILTER + IntToString(i), nFilter);
    }

    int nMax = GetLocalInt(DIALOG, DLG_FILTER_MAX);
    if (nMax <= nBlockEnd)
        SetLocalInt(DIALOG, DLG_FILTER_MAX, nBlockEnd + 1);
}

// ----- Accessor Functions ----------------------------------------------------

string GetDialog()
{
    return GetLocalString(DIALOG, DLG_DIALOG);
}

string GetDialogNodes(string sPage)
{
    return GetLocalString(DIALOG, sPage + DLG_NODES);
}

void SetDialogNodes(string sPage, string sSource = "")
{
    if (sSource == "")
        sSource = sPage;

    SetLocalString(DIALOG, sPage + DLG_NODES, sSource);
}

string GetDialogText(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT);
}

void SetDialogText(string sText, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT, sText);
}

string GetDialogData(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_DATA);
}

void SetDialogData(string sData, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_DATA, sData);
}

string GetDialogTarget(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TARGET);
}

void SetDialogTarget(string sTarget, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TARGET, sTarget);
}

int GetDialogState()
{
    return GetLocalInt(DIALOG, DLG_STATE);
}

void SetDialogState(int nState)
{
    SetLocalInt(DIALOG, DLG_STATE, nState);
}

string GetDialogHistory()
{
    return GetLocalString(DIALOG, DLG_HISTORY);
}

void SetDialogHistory(string sHistory)
{
    SetLocalString(DIALOG, DLG_HISTORY, sHistory);
}

void ClearDialogHistory()
{
    DeleteLocalString(DIALOG, DLG_HISTORY);
}

string GetDialogPage()
{
    return GetLocalString(DIALOG, DLG_CURRENT_PAGE);
}

int GetDialogPageNumber()
{
    string sPageNumber = JsonGetString(JsonArrayGet(RegExpMatch(".*#(\\d*)", GetDialogPage()), 1));
    return sPageNumber == "" ? 1 : StringToInt(sPageNumber);
}

string GetDialogPageParent()
{
    string sPage = GetDialogPage();
    string sName = JsonGetString(JsonArrayGet(RegExpMatch("^(.*)#\\d*", sPage), 1));
    return sName == "" ? sPage : sName;
}

void SetDialogPage(string sPage, int nPage = 1)
{
    string sHistory = GetLocalString(DIALOG, DLG_HISTORY);
    string sCurrent = GetLocalString(DIALOG, DLG_CURRENT_PAGE);

    if (sHistory == "" || sHistory == sCurrent)
        SetLocalString(DIALOG, DLG_HISTORY, sCurrent);
    else if (GetListItem(sHistory, 0) != sCurrent)
        SetLocalString(DIALOG, DLG_HISTORY, MergeLists(sCurrent, sHistory));

    if (nPage > 1)
        sPage += "#" + IntToString(nPage);

    SetLocalString(DIALOG, DLG_CURRENT_PAGE, sPage);
    SetLocalInt(DIALOG, DLG_CURRENT_PAGE, TRUE);
}

int GetDialogNode()
{
    return GetLocalInt(DIALOG, DLG_CURRENT_NODE);
}

void SetDialogNode(int nNode)
{
    SetLocalInt(DIALOG, DLG_CURRENT_NODE, nNode);
}

int GetDialogEvent()
{
    return GetLocalInt(DIALOG, DLG_EVENT);
}

string GetDialogLabel(int nNode, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return "";

    if (!GetLocalInt(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT))
        sPage = "";

    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT);
}

void SetDialogLabel(int nNode, string sLabel, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return;

    string sNode = NodeToString(sPage, nNode);
    SetLocalString(DIALOG, sNode + DLG_TEXT, sLabel);
    SetLocalInt   (DIALOG, sNode + DLG_TEXT, TRUE);
}

void EnableDialogNode(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    SetLocalInt(DIALOG, sNode + DLG_ENABLED, TRUE);
    SetLocalInt(DIALOG, sNode + DLG_HAS,     TRUE);
}

void DisableDialogNode(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    SetLocalInt(DIALOG, sNode + DLG_ENABLED, FALSE);
    SetLocalInt(DIALOG, sNode + DLG_HAS,     TRUE);
}

int DialogNodeEnabled(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    if (!GetLocalInt(DIALOG, sNode + DLG_HAS))
        sNode = NodeToString("", nNode);

    return GetLocalInt(DIALOG, sNode + DLG_ENABLED);
}

void EnableDialogEnd(string sLabel = DLG_LABEL_END, string sPage = "")
{
    EnableDialogNode(DLG_NODE_END, sPage);
    SetDialogLabel(DLG_NODE_END, sLabel, sPage);
}

void EnableDialogBack(string sLabel = DLG_LABEL_BACK, string sPage = "")
{
    EnableDialogNode(DLG_NODE_BACK, sPage);
    SetDialogLabel(DLG_NODE_BACK, sLabel, sPage);
}

int GetDialogOffset()
{
    return GetLocalInt(DIALOG, DLG_OFFSET);
}

void SetDialogOffset(int nOffset)
{
    SetLocalInt(DIALOG, DLG_OFFSET, nOffset);
}

int GetDialogFilter(int nPos = 0)
{
    return GetLocalInt(DIALOG, DLG_FILTER + IntToString(nPos % 30));
}

string GetDialogColor(int nNode, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return "";

    if (!GetLocalInt(DIALOG, NodeToString(sPage, nNode) + DLG_COLOR))
        sPage = "";

    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_COLOR);
}

void SetDialogColor(int nNode, int nColor, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return;

    string sNode = NodeToString(sPage, nNode);
    string sColor = HexToColor(nColor);
    SetLocalString(DIALOG, sNode + DLG_COLOR, sColor);
    SetLocalInt   (DIALOG, sNode + DLG_COLOR, TRUE);
}

// ----- Dialog Tokens ---------------------------------------------------------

string NormalizeDialogToken(string sToken)
{
    if (GetLocalInt(DIALOG, DLG_TOKEN + "*" + sToken))
        return sToken;

    if (GetLocalString(DIALOG, DLG_TOKEN_SCRIPT) != "")
        return sToken;

    string sLower = GetStringLowerCase(sToken);
    if (sToken == sLower || !GetLocalInt(DIALOG, DLG_TOKEN + "*" + sLower))
        return "";

    return sLower;
}

void SetDialogTokenValue(string sValue)
{
    SetLocalString(GetPCSpeaker(), DLG_TOKEN, sValue);
}

void SetDialogTokenScript(string sScript)
{
    SetLocalString(DIALOG, DLG_TOKEN_SCRIPT, sScript);
}

void AddDialogToken(string sToken, string sEvalScript, string sValues = "")
{
    SetLocalInt   (DIALOG, DLG_TOKEN + "*" + sToken, TRUE);
    SetLocalString(DIALOG, DLG_TOKEN + "*" + sToken, sEvalScript);
    SetLocalString(DIALOG, DLG_TOKEN_VALUES + "*" + sToken, sValues);
}

void AddDialogTokens()
{
    if (!GetIsLibraryLoaded("dlg_l_tokens"))
        LoadLibrary("dlg_l_tokens");

    string sPrefix = "DialogToken_";
    AddDialogToken("alignment",       sPrefix + "Alignment");
    AddDialogToken("bitch/bastard",   sPrefix + "Gender", "Bastard, Bitch");
    AddDialogToken("boy/girl",        sPrefix + "Gender", "Boy, Girl");
    AddDialogToken("brother/sister",  sPrefix + "Gender", "Brother, Sister");
    AddDialogToken("class",           sPrefix + "Class");
    AddDialogToken("classes",         sPrefix + "Class");
    AddDialogToken("day/night",       sPrefix + "DayNight");
    AddDialogToken("Deity",           sPrefix + "Deity");
    AddDialogToken("FirstName",       sPrefix + "Name");
    AddDialogToken("FullName",        sPrefix + "Name");
    AddDialogToken("gameday",         sPrefix + "GameDate");
    AddDialogToken("gamedate",        sPrefix + "GameDate");
    AddDialogToken("gamehour",        sPrefix + "GameTime");
    AddDialogToken("gameminute",      sPrefix + "GameTime");
    AddDialogToken("gamemonth",       sPrefix + "GameDate");
    AddDialogToken("gamesecond",      sPrefix + "GameTime");
    AddDialogToken("gametime12",      sPrefix + "GameTime");
    AddDialogToken("gametime24",      sPrefix + "GameTime");
    AddDialogToken("gameyear",        sPrefix + "GameDate");
    AddDialogToken("good/evil",       sPrefix + "Alignment");
    AddDialogToken("he/she",          sPrefix + "Gender", "He, She");
    AddDialogToken("him/her",         sPrefix + "Gender", "Him, Her");
    AddDialogToken("his/her",         sPrefix + "Gender", "His, Her");
    AddDialogToken("his/hers",        sPrefix + "Gender", "His, Hers");
    AddDialogToken("lad/lass",        sPrefix + "Gender", "Lad, Lass");
    AddDialogToken("LastName",        sPrefix + "Name");
    AddDialogToken("lawful/chaotic",  sPrefix + "Alignment");
    AddDialogToken("law/chaos",       sPrefix + "Alignment");
    AddDialogToken("level",           sPrefix + "Level");
    AddDialogToken("lord/lady",       sPrefix + "Gender", "Lord, Lady");
    AddDialogToken("male/female",     sPrefix + "Gender", "Male, Female");
    AddDialogToken("man/woman",       sPrefix + "Gender", "Man, Woman");
    AddDialogToken("master/mistress", sPrefix + "Gender", "Master, Mistress");
    AddDialogToken("mister/missus",   sPrefix + "Gender", "Mister, Missus");
    AddDialogToken("PlayerName",      sPrefix + "PlayerName");
    AddDialogToken("quarterday",      sPrefix + "QuarterDay");
    AddDialogToken("race",            sPrefix + "Race");
    AddDialogToken("races",           sPrefix + "Race");
    AddDialogToken("racial",          sPrefix + "Race");
    AddDialogToken("sir/madam",       sPrefix + "Gender", "Sir, Madam");
    AddDialogToken("subrace",         sPrefix + "SubRace");
    AddDialogToken("StartAction",     sPrefix + "Token", HexToColor(DLG_COLOR_ACTION));
    AddDialogToken("StartCheck",      sPrefix + "Token", HexToColor(DLG_COLOR_CHECK));
    AddDialogToken("StartHighlight",  sPrefix + "Token", HexToColor(DLG_COLOR_HIGHLIGHT));
    AddDialogToken("/Start",          sPrefix + "Token", "</c>");
}

void AddCachedDialogToken(string sToken, string sValue)
{
    AddDialogToken(sToken);
    CacheDialogToken(sToken, sValue);
}

string GetCachedDialogToken(string sToken)
{
    if (GetLocalInt(DIALOG, DLG_TOKEN_CACHE + "*" + sToken))
        return GetLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken);

    return "";
}

void CacheDialogToken(string sToken, string sValue)
{
    Debug("Caching value for token <" + sToken + ">: " + sValue);
    SetLocalInt   (DIALOG, DLG_TOKEN_CACHE + "*" + sToken, TRUE);
    SetLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken, sValue);
}

void UnCacheDialogToken(string sToken)
{
    Debug("Clearing cache for token <" + sToken + ">");
    DeleteLocalInt   (DIALOG, DLG_TOKEN_CACHE + "*" + sToken);
    DeleteLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken);
}

string EvalDialogToken(string sToken, object oPC)
{
    string sNormal = NormalizeDialogToken(sToken);

    // Ensure this is a valid token
    if (sNormal == "")
        return "<" + sToken + ">";

    // Check the cached token value. This saves us having to run a library
    // script to get a known result.
    string sCached = GetCachedDialogToken(sToken);
    if (sCached != "")
    {
        Debug("Using cached value for token <" + sToken + ">: " + sCached);
        return sCached;
    }

    string sScript = GetLocalString(DIALOG, DLG_TOKEN + "*" + sNormal);
    if (sScript == "")
        sScript = GetLocalString(DIALOG, DLG_TOKEN_SCRIPT);
    
    string sValues = GetLocalString(DIALOG, DLG_TOKEN_VALUES + "*" + sNormal);

    SetLocalString(oPC, DLG_TOKEN, sNormal);
    SetLocalString(oPC, DLG_TOKEN_VALUES, sValues);
    RunLibraryScript(sScript, oPC);

    string sEval = GetLocalString(oPC, DLG_TOKEN);

    // Token eval scripts should always yield the uppercase version of the
    // token. If the desired value is lowercase, we change it here.
    if (sToken == GetStringLowerCase(sToken))
        sEval = GetStringLowerCase(sEval);

    // If we are supposed to cache the results, do so. We have to check the PC
    // since the token script will not have access to the DIALOG object.
    if (GetLocalInt(oPC, DLG_TOKEN_CACHE))
    {
        CacheDialogToken(sToken, sEval);
        DeleteLocalInt(oPC, DLG_TOKEN_CACHE);
    }

    return sEval;
}

string EvalDialogTokens(string sString)
{
    int i;
    object oPC = GetPCSpeaker();
    json jEvals = JSON_ARRAY, jCheck = JSON_ARRAY;

    while (TRUE)
    {
        json jTokens = RegExpIterate("<(?!c...>|/c>)(.*?)>(?!>)", sString);
        if (jTokens == JSON_ARRAY)
            break;

        jTokens = JsonArrayTransform(jTokens, JSON_ARRAY_UNIQUE);

        if (jTokens == jCheck) break;
        jCheck = jTokens;

        int n; for (n; n < JsonGetLength(jTokens); n++)
        {
            string sToken = JsonGetString(JsonArrayGet(JsonArrayGet(jTokens, n), 1));

            if (GetStringLeft(sToken, 1) == "<" && GetStringRight(sToken, 1) == ">")
            {
                sString = SubstituteSubStrings(sString, "<" + sToken + ">", "$" + IntToString(++i));
                JsonArrayInsertInplace(jEvals, JsonString(sToken));
            }
            else 
            {
                string sEval = EvalDialogToken(sToken, oPC);
                if ("<" + sToken + ">" != sEval)
                    sString = SubstituteSubStrings(sString, "<" + sToken + ">", sEval);
            }
        }
    }

    return SubstituteString(sString, jEvals, "$");
}

// ----- System Functions ------------------------------------------------------

object GetDialogCache(string sDialog)
{
    object oCache = GetDataItem(DIALOGS, DLG_PREFIX + sDialog);
    if (!GetIsObjectValid(oCache))
        oCache = CreateDataItem(DIALOGS, DLG_PREFIX + sDialog);

    return oCache;
}

void RegisterDialogScript(string sDialog, string sScript = "", int nEvents = DLG_EVENT_ALL, float fPriority = DLG_PRIORITY_DEFAULT)
{
    if (fPriority < DLG_PRIORITY_LAST || fPriority > DLG_PRIORITY_FIRST)
        return;

    if (sScript == "")
        sScript = sDialog;

    string sEvent;
    object oCache = GetDialogCache(sDialog);
    int nEvent = DLG_EVENT_INIT;

    for (nEvent; nEvent < DLG_EVENT_ALL; nEvent <<= 1)
    {
        if (nEvents & nEvent)
        {
            sEvent = DialogEventToString(nEvent);
            Debug("Adding " + sScript + " to " + sDialog + "'s " + sEvent +
                  " event with a priority of " + FloatToString(fPriority, 2, 2));
            AddListString(oCache, sScript,   sEvent);
            AddListFloat (oCache, fPriority, sEvent);

            // Mark the event as unsorted
            SetLocalInt(oCache, sEvent, FALSE);
        }
    }
}

void SortDialogScripts(int nEvent)
{
    string sEvent = DialogEventToString(nEvent);
    json jPriority = GetFloatList(DIALOG, sEvent);
    if (jPriority == JsonArray())
        return;

    Debug("Sorting " + IntToString(JsonGetLength(jPriority)) + " scripts for " + sEvent);

    string sQuery = "SELECT json_group_array(id - 1) " +
                    "FROM (SELECT id, atom " +
                        "FROM json_each(json('" + JsonDump(jPriority) + "')) " +
                        "ORDER BY value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    SetIntList(DIALOG, SqlGetJson(sql, 0), sEvent);
    SetLocalInt(DIALOG, sEvent, TRUE);
}

void SendDialogEvent(int nEvent)
{
    string sScript, sEvent = DialogEventToString(nEvent);

    if (!GetLocalInt(DIALOG, sEvent))
        SortDialogScripts(nEvent);

    int i, nIndex, nCount = CountIntList(DIALOG, sEvent);

    for (i = 0; i < nCount; i++)
    {
        nIndex  = GetListInt   (DIALOG, i,      sEvent);
        sScript = GetListString(DIALOG, nIndex, sEvent);

        SetLocalInt(DIALOG, DLG_EVENT, nEvent);
        Debug("Dialog event " + sEvent + " is running " + sScript);
        if (RunLibraryScript(sScript) & DLG_SCRIPT_ABORT)
        {
            Debug("Dialog event queue was cancelled by " + sScript);
            return;
        }
    }

    if (!nCount)
    {
        sScript = GetDialog();
        SetLocalInt(DIALOG, DLG_EVENT, nEvent);
        Debug("Dialog event " + sEvent + " is running " + sScript);
        RunLibraryScript(sScript);
    }
}

void InitializeDialog()
{
    object oPC = GetPCSpeaker();
    string sDialog = GetLocalString(oPC, DLG_DIALOG);

    if (sDialog == "")
    {
        sDialog = GetLocalString(OBJECT_SELF, DLG_DIALOG);
        if (sDialog == "")
            sDialog = GetTag(OBJECT_SELF);
    }

    DIALOG = GetDialogCache(sDialog);
    if (!GetLocalInt(DIALOG, DLG_INITIALIZED))
    {
        Debug("Initializing dialog " + sDialog);
        SetLocalString(DIALOG, DLG_DIALOG, sDialog);
        SetDialogLabel(DLG_NODE_CONTINUE, DLG_LABEL_CONTINUE);
        SetDialogLabel(DLG_NODE_PREV,     DLG_LABEL_PREV);
        SetDialogLabel(DLG_NODE_NEXT,     DLG_LABEL_NEXT);
        SetDialogLabel(DLG_NODE_BACK,     DLG_LABEL_BACK);
        SetDialogLabel(DLG_NODE_END,      DLG_LABEL_END);
        SetDialogColor(DLG_NODE_CONTINUE, DLG_COLOR_CONTINUE);
        SetDialogColor(DLG_NODE_PREV,     DLG_COLOR_PREV);
        SetDialogColor(DLG_NODE_NEXT,     DLG_COLOR_NEXT);
        SetDialogColor(DLG_NODE_BACK,     DLG_COLOR_BACK);
        SetDialogColor(DLG_NODE_END,      DLG_COLOR_END);
        AddDialogTokens();
        SetLocalObject(oPC, DLG_SYSTEM, DIALOG);
        SendDialogEvent(DLG_EVENT_INIT);
        SetLocalInt(DIALOG, DLG_INITIALIZED, TRUE);
    }
    else
        Debug("Dialog " + sDialog + " has already been initialized");

    if (GetIsObjectValid(oPC))
    {
        Debug("Instantiating dialog " + sDialog + " for " + GetName(oPC));
        DIALOG = CopyItem(DIALOG, DIALOGS, TRUE);
        SetLocalObject(oPC, DLG_SYSTEM, DIALOG);
        SetDialogState(DLG_STATE_RUNNING);
        SetDialogNode(DLG_NODE_NONE);

        if (!GetIsObjectValid(DLG_SELF))
            SetLocalObject(oPC, DLG_SPEAKER, OBJECT_SELF);
    }
}

int LoadDialogPage()
{
    // Do not reset if we got here from an automatic node
    if (GetDialogNode() > DLG_NODE_NONE)
        SetDialogOffset(0);

    int i, nFilters = GetLocalInt(DIALOG, DLG_FILTER_MAX);
    for (i = 0; i < nFilters; i++)
        DeleteLocalInt(DIALOG, DLG_FILTER + IntToString(i));

    DeleteLocalInt(DIALOG, DLG_FILTER_MAX);

    Debug("Initializing dialog page: " + GetDialogPage());
    SendDialogEvent(DLG_EVENT_PAGE);

    string sMessage;
    string sPage = GetDialogPage();
    if (!HasDialogPage(sPage))
        Warning(sMessage = "No dialog page found. Aborting...");
    else if (GetDialogState() == DLG_STATE_ENDED)
        Debug(sMessage = "Dialog ended by the event script. Aborting...");

    if (sMessage != "")
        return FALSE;

    string sText = GetDialogText(sPage);
    SetCustomToken(DLG_CUSTOM_TOKEN, EvalDialogTokens(sText));
    return TRUE;
}

// Private function for LoadDialogNodes(). Maps a response node to a target node
// and sets its text. When the response node is clicked, we will send the node
// event for the target node.
void MapDialogNode(int nNode, int nTarget, string sText, string sPage = "")
{
    string sNode = IntToString(nNode);
    int nMax = DLG_MAX_RESPONSES + 5;
    if (nNode < 0 || nNode > nMax)
    {
        Error("Attempted to set dialog response node " + sNode +
              " but max is " + IntToString(nMax));
        return;
    }

    sText = EvalDialogTokens(sText);

    if (nTarget < DLG_NODE_NONE)
    {
        string sColor = GetDialogColor(nTarget, sPage);
        sText = ColorString(sText, sColor);
    }

    Debug("Setting response node " + sNode + " -> " + IntToString(nTarget));
    SetLocalInt(DIALOG, DLG_NODES + sNode, nTarget);
    SetLocalString(DIALOG, DLG_NODES + sNode, sText);
}

void LoadDialogNodes()
{
    string sText, sTarget;
    string sPage = GetDialogPage();
    string sNodes = GetDialogNodes(sPage);
    int nNodes;

    // Check if we need to show a continue node. This always goes at the top.
    if (DialogNodeEnabled(DLG_NODE_CONTINUE, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_CONTINUE, sPage);
        MapDialogNode(nNodes++, DLG_NODE_CONTINUE, sText, sPage);
    }

    // The max number of responses does not include automatic nodes.
    int nMax = DLG_MAX_RESPONSES + nNodes;
    int i, nMod, nPos, bFilter;
    int nFilter = GetDialogFilter();
    int nCount = CountDialogNodes(sNodes);
    int nOffset = GetDialogOffset();

    // Check which nodes to show and set their tokens
    for (i = 0; i < nCount; i++)
    {
        nMod    = nPos % 30;
        sText   = GetDialogText(sNodes, i);
        sTarget = GetDialogTarget(sNodes, i);
        bFilter  = !(nFilter & (1 << nMod));

        Debug("Checking dialog node " + IntToString(i) +
              "\n  Target: " + sTarget +
              "\n  Text: " + sText +
              "\n  Display: " + (bFilter ? "yes" : "no"));

        if (bFilter && i >= nOffset)
        {
            // We check this here so we know if we need a "next" node.
            if (nNodes >= nMax)
                break;

            MapDialogNode(nNodes++, i, sText);
        }

        // Load the next filter chunk
        if (nMod == 29)
            nFilter = GetDialogFilter((i + 1) / 30);
        else
            nPos++;
    }

    // Check if we need automatic nodes
    if (i < nCount)
    {
        sText = GetDialogLabel(DLG_NODE_NEXT, sPage);
        MapDialogNode(nNodes++, DLG_NODE_NEXT, sText, sPage);
    }

    if (nOffset)
    {
        sText = GetDialogLabel(DLG_NODE_PREV, sPage);
        MapDialogNode(nNodes++, DLG_NODE_PREV, sText, sPage);
    }

    if (DialogNodeEnabled(DLG_NODE_BACK, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_BACK, sPage);
        MapDialogNode(nNodes++, DLG_NODE_BACK, sText, sPage);
    }

    if (DialogNodeEnabled(DLG_NODE_END, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_END, sPage);
        MapDialogNode(nNodes++, DLG_NODE_END, sText, sPage);
    }

    SetLocalInt(DIALOG, DLG_NODES, nNodes);
    SetLocalInt(DIALOG, DLG_NODE, 0);
}

void DoDialogNode(int nClicked)
{
    int nNode = GetLocalInt(DIALOG, DLG_NODES + IntToString(nClicked));
    string sPage = GetDialogPage();
    string sNodes = GetDialogNodes(sPage);
    string sTarget = GetDialogTarget(sNodes, nNode);

    if (nNode == DLG_NODE_END)
    {
        SetDialogState(DLG_STATE_ENDED);
        return;
    }

    if (nNode == DLG_NODE_NEXT)
    {
        int nOffset = GetDialogOffset();
        SetDialogOffset(nOffset + DLG_MAX_RESPONSES);
        sTarget = sPage;
    }
    else if (nNode == DLG_NODE_PREV)
    {
        int nOffset = GetDialogOffset() - DLG_MAX_RESPONSES;
        SetDialogOffset((nOffset < 0 ? 0 : nOffset));
        sTarget = sPage;
    }
    else if (nNode == DLG_NODE_BACK && sTarget == "")
    {
        string sHistory = GetDialogHistory();
        string sLast = GetListItem(sHistory, 0);
        if (sLast != "")
        {
            sTarget = sLast;
            SetDialogHistory(DeleteListItem(sHistory, 0));
        }
    }

    SetLocalInt(DIALOG, DLG_CURRENT_PAGE, FALSE);
    SetDialogNode(nNode);
    SendDialogEvent(DLG_EVENT_NODE);

    // Check if the page change was already handled by the user.
    if (!GetLocalInt(DIALOG, DLG_CURRENT_PAGE))
        SetDialogPage(sTarget);
}

void DialogCleanup()
{
    object oPC = GetPCSpeaker();
    DeleteLocalString(oPC, DLG_DIALOG);
    DeleteLocalObject(oPC, DLG_SPEAKER);
    DestroyObject(DIALOG);
}
