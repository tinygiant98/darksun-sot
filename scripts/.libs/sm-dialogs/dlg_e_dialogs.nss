
/// -----------------------------------------------------------------------------
/// @file   dlg_e_dialogs.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (event script)
/// -----------------------------------------------------------------------------
/// This script handles node-based events for dialogs.  This script should be
/// assigned to all of the script locations below.  In addition, set up script
/// parameters as follows:
///                                 Script Param:   Param Value:
///     "Text Appears When" Tab:
///         NPC Nodes               *Action         *Page     
///         PC Nodes                *Action         *Check 
///     "Actions Taken" Tab:        *Action         *Node
///                                 *Node           <node number>
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"

int StartingConditional()
{
    string sAction = GetScriptParam(DLG_ACTION);
    if (sAction == DLG_ACTION_CHECK)
    {
        int nNodes = GetLocalInt(DIALOG, DLG_NODES);
        int nNode  = GetLocalInt(DIALOG, DLG_NODE);
        string sText = GetLocalString(DIALOG, DLG_NODES + IntToString(nNode));

        SetLocalInt(DIALOG, DLG_NODE, nNode + 1);
        SetCustomToken(DLG_CUSTOM_TOKEN + nNode + 1, sText);
        return (nNode < nNodes);
    }   
    else if (sAction == DLG_ACTION_NODE)
    {
        int nNode = StringToInt(GetScriptParam(DLG_NODE));
        DoDialogNode(nNode);
    }
    else if (sAction == DLG_ACTION_PAGE)
    {
        int nState = GetDialogState();
        if (nState == DLG_STATE_ENDED)
            return FALSE;

        if (nState == DLG_STATE_INIT)
            InitializeDialog();

        if (!LoadDialogPage())
            return FALSE;

        LoadDialogNodes();
        return TRUE;
    }
    
    return FALSE;
}
