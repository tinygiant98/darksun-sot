/// -----------------------------------------------------------------------------
/// @file   dlg_dialogend.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (event script)
/// -----------------------------------------------------------------------------
/// This script handles normal ends for dialogs. It should be placed in the
/// "Normal" script slot in the Current File tab of the dynamic dialog template
/// conversation.
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"

void main()
{
    SendDialogEvent(DLG_EVENT_END);
    DialogCleanup();
}
