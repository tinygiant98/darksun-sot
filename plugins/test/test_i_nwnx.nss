// -----------------------------------------------------------------------------
//    File: test_i_nwnx.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  NWNX Test Functionality
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

string test_nwnx_ColorInvalid(string s)
{
    return HexColorString(s, COLOR_RED_LIGHT);
}

string test_nwnx_ColorPC(string s)
{
    return HexColorString(s, COLOR_ORANGE);
}

string test_nwnx_ColorData(string s)
{
    return HexColorString(s, COLOR_BLUE_LIGHT);
}

string test_nwnx_ColorSection(string s)
{
    return HexColorString(s, COLOR_CYAN);
}

void test_nwnx_DisplayEventData(string sEvent, string sDatas, string sTypes)
{
    int n;
    int nDatas = CountList(sDatas);
    int nTypes = CountList(sTypes);
    string sResult, sDelimiter = HexColorString(" | ", COLOR_GRAY_LIGHT);

    // Display OBJECT_SELF data
    if (GetIsPC(OBJECT_SELF))
        sResult = test_nwnx_ColorPC(GetName(OBJECT_SELF) + " (PC)");
    else
        sResult = test_nwnx_ColorData(GetName(OBJECT_SELF) + sDelimiter + GetTag(OBJECT_SELF));

    Notice(test_nwnx_ColorSection("Event Data for " + sEvent) +
        "\n  OBJECT_SELF  " + sResult);

    // Display retrieved event data
    while (n < nDatas)
    {
        string sData = GetListItem(sDatas, n);
        string sEventData = NWNX_Events_GetEventData(sData);

        string sType = GetListItem(sTypes, n++);
        if (sType == "object")
        {
            object o = StringToObject(sEventData);
            string sResult;
            if (GetIsObjectValid(o))
            {
                if (GetIsPC(o))
                    sResult = test_nwnx_ColorPC(GetName(o) + " (PC)");
                else
                    sResult = test_nwnx_ColorData(GetName(o) + sDelimiter + 
                        GetTag(o) + sDelimiter + sEventData);
            }
            else
                sResult = test_nwnx_ColorInvalid("OBJECT_INVALID");

            sResult = "  " + IntToString(n) + "  " + sType + sDelimiter + sResult;
        }
        else if (sType == "int")
        {
            sResult = "  " + IntToString(n) + "  " + sType + sDelimiter + sEventData;
        }
        else if (sType == "float")
        {
            sResult = "  " + IntToString(n) + "  " + sType + sDelimiter + sEventData;
        }
        else if (sType == "string")
        {
            sResult = "  " + IntToString(n) + "  " + sType + sDelimiter + sEventData;
        }

        Notice(sResult);
    }
}

void test_nwnx_GetEventData(string sEvent)
{
    if (FindSubString(sEvent, "ADD_ASSOCIATE") || FindSubString(sEvent, "REMOVE_ASSOCIATE")
    {
        sDatas = "ASSOCIATE_OBJECT_ID";
        sTypes = "object";
    }
    else if (FindSubString(sEvent, ))
}