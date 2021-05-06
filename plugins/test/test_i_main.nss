// -----------------------------------------------------------------------------
//    File: test_i_main.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Core functions
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "test_i_config"
#include "test_i_const"
#include "test_i_text"

#include "util_i_data"
#include "util_i_debug"
#include "util_i_libraries"
#include "core_i_framework"

#include "nwnx_creature"

const int TYPE_INTEGER = 1;
const int TYPE_FLOAT = 2;
const int TYPE_STRING = 3;
const int TYPE_OBJECT = 4;
const int TYPE_VECTOR = 5;
const int TYPE_LOCATION = 6;

void ReloadLibraries(string sLibraries)
{
    if (CountList(sLibraries) > 1)
        LoadLibraries(sLibraries, TRUE);
    else
        LoadLibrary(sLibraries, TRUE);
}

string GetVariable(object oPC, object oTarget, string sOverride = "")
{
    int nInternal = (sOverride == "" ? FALSE : TRUE);
    int i, n, nFound, nCount = (!nInternal ? CountChatArguments(oPC) : 1);
    string s, sVarName, sType, sResult, sTitle = (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget));
    string sKeys, sValues;
    float f;
    location l;
    vector v;
    object o;    

    for (n = 0; n < nCount; n++)
    {
        sVarName = (!nInternal ? GetChatArgument(oPC, n) : sOverride);

        i = GetLocalInt(oTarget, sVarName);
        if (i)
        {
            if (HasChatOption(oPC, "bool,b,boolean"))
                sResult = i ? "TRUE" : "FALSE";
            else
                sResult = IntToString(i);

            sKeys = AddListItem(sKeys, "Integer");
            sValues = AddListItem(sValues, sResult);
        }

        s = GetLocalString(oTarget, sVarName);
        if (s != "")
        {
            sResult = s;
            sKeys = AddListItem(sKeys, "String");
            sValues = AddListItem(sValues, sResult);
        }

        f = GetLocalFloat(oTarget, sVarName);
        if (f != 0.0)
        {
            sResult = FloatToString(f, 0);
            sKeys = AddListItem(sKeys, "Float");
            sValues = AddListItem(sValues, sResult);
        }

        o = GetLocalObject(oTarget, sVarName);
        if (GetIsObjectValid(o))
        {
            sResult = "{tag} " + GetTag(o) + " {Name} " + GetName(o);
            sKeys = AddListItem(sKeys, "Object");
            sValues = AddListItem(sValues, sResult);
        }

        l = GetLocalLocation(oTarget, sVarName);
        if (GetAreaFromLocation(l) != OBJECT_INVALID)
        {
            sType = "Location";
            vector v = GetPositionFromLocation(l);
            sResult = "{area} " + GetTag(GetAreaFromLocation(l)) + " " +
                      "{position} [" + FloatToString(v.x, 0, 2) + "  " +
                                        FloatToString(v.y, 0, 2) + "  " +
                                        FloatToString(v.z, 0, 2) + "] " +
                      "{facing} " + FloatToString(GetFacingFromLocation(l), 0, 2);

            sKeys = AddListItem(sKeys, "Location");
            sValues = AddListItem(sKeys, sResult);
        }
/*
        v = GetLocalVector(oTarget, sVarName);
        if (v != Vector())
        {
            sResult = "[" + FloatToString(v.x, 0, 2) + "  " +
                            FloatToString(v.y, 0, 2) + "  " +
                            FloatToString(v.z, 0, 2) + "]";
            sKeys = AddListItem(sKeys, "Vector");
            sValues = AddListItem(sValues, sResult);
        }
*/

        if (nCount = CountList(sKeys))
        {
            if (nInternal && nCount > 0)
                return sKeys;

            for (n = 0; n < nCount; n++)
                SendChatResult(GetListItem(sKeys, n) + " " + sVarName + " on " + sTitle + " -> " + GetListItem(sValues, n), oPC);
        }
        else if (!nInternal)
            SendChatResult("Variable " + sVarName + " not found on " + sTitle + " (or is default value)", oPC, FLAG_ERROR);

        sKeys = "";
        sValues = "";
    }

    return "";
}

void DeleteVariable(object oPC, object oTarget)
{
    int n, nType, nTypes, nSpecify, nCount = CountChatArguments(oPC);
    int bAll;
    string sConfirm, sType, sTypes, sVarName, sTitle = (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget));

    for (n = 0; n < nCount; n++)
    {
        sVarName = GetChatArgument(oPC, n);
        sTypes = GetVariable(oPC, oTarget, sVarName);

        if (!CountList(sTypes))
        {
            SendChatResult("Variable " + sVarName + " not found on " + sTitle + " (or is default value)", oPC, FLAG_ERROR);
            SendChatResult(DeleteVariableHelp(), oPC, FLAG_HELP);
            continue;
        }

        nTypes = CountList(sTypes);
        bAll = HasChatOption(oPC, "all");
        
        for (nType = 0; nType < nTypes; nType++)
        {
            sType = GetListItem(sTypes, nType);
            if (sType == "Integer")
            {               
                if (nTypes == 1)
                    DeleteLocalInt(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "i,int,integer")))
                {
                    DeleteLocalInt(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "String")
            {               
                if (nTypes == 1)
                    DeleteLocalString(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "s,str,string")))
                {
                    DeleteLocalString(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Float")
            {               
                if (nTypes == 1)
                    DeleteLocalFloat(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "f,float")))
                {
                    DeleteLocalFloat(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Object")
            {               
                if (nTypes == 1)
                    DeleteLocalObject(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "o,obj,object")))
                {
                    DeleteLocalObject(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Location")
            {               
                if (nTypes == 1)
                    DeleteLocalLocation(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "l,loc,location")))
                {
                    DeleteLocalLocation(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
/*
            else if (sType == "Vector")
            {               
                if (nTypes == 1)
                    DeleteLocalVector(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "v,vec,vector")))
                {
                    DeleteLocalVector(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
*/
        }

        if (nTypes > 1 && CountList(sConfirm) && !nSpecify)
        {
            SendChatResult("Found multiple types for variable " + sVarName + "; type to delete must be specified" +
                           "\n  Variable types found -> " + sTypes +
                           "\n  Variable types not specified for deletion -> " + sConfirm, oPC, FLAG_ERROR);
            SendChatResult(DeleteVariableHelp(), oPC, FLAG_HELP);
        }

        for (nType = 0; nType < nTypes; nType++)
        {
            sType = GetListItem(sTypes, nType);
            if (!HasListItem(sConfirm, sType))
                SendChatResult(sType + " variable " + sVarName + " deleted from " + sTitle, oPC);
        }

        nSpecify = FALSE;
    }
}

void SetVariable(object oPC, object oTarget)
{
    string sType, sVarName, sValue, sResult;
    string sTitle = (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget));

    if (CountChatArguments(oPC) > 1)
        SendChatResult("More than one variable name passed; only the first will be used" +
                       "\n  Arguments received -> " + GetChatArguments(oPC), oPC, FLAG_ERROR);

    sVarName = GetChatArgument(oPC);

    if (HasChatKey(oPC, "i,int,integer"))
    {
        sValue = GetChatKeyValue(oPC, "i,int,integer");
        if (TestStringAgainstPattern("*n", sValue))
        {
            sType = "Integer";
            SetLocalInt(oTarget, sVarName, StringToInt(sValue));
        }
    }
    else if (HasChatKey(oPC, "s,str,string"))
    {
        sValue = GetChatKeyValue(oPC, "s,str,string");
        sType = "String";
        SetLocalString(oTarget, sVarName, sValue);
    }
    else if (HasChatKey(oPC, "f,float"))
    {
        sValue = GetChatKeyValue(oPC, "f,float");
        if (TestStringAgainstPattern("*n.*n|*n", sValue))
        {
            sType = "Float";
            SetLocalFloat(oTarget, sVarName, StringToFloat(sValue));
        }
    }
    else if (HasChatKey(oPC, "o,obj,object"))
    {
        sValue = GetChatKeyValue(oPC, "o,obj,object");
        if (GetIsObjectValid(GetObjectByTag(sValue)))
        {
            sType = "Object";
            sResult = "{tag} " + sValue;
            SetLocalObject(oTarget, sVarName, GetObjectByTag(sValue));
        }
    }
    else if (HasChatKey(oPC, "l,loc,location"))
    {
        sValue = GetChatKeyValue(oPC, "l,loc,location");
        string sValues = Tokenize(sValue, ";", "", TRUE);

        if (CountList(sValues) != 5)
        {
            SendChatResult("Incorrect number of arguments passed in the --[l|loc|location] value" +
                           "\n  Values received -> " + sValue, oPC, FLAG_ERROR);
            SendChatResult(SetVariableHelp(), oPC, FLAG_HELP);
            return;
        }

        object oArea = GetObjectByTag(GetListItem(sValues, 0));
        float fX = StringToFloat(GetListItem(sValues, 1));
        float fY = StringToFloat(GetListItem(sValues, 2));
        float fZ = StringToFloat(GetListItem(sValues, 3));
        float fFacing = StringToFloat(GetListItem(sValues, 4));

        if (GetIsObjectValid(oArea))
        {
            sType = "Location";
            sResult = "{area tag} " + GetListItem(sValues, 0) + 
                      "{position} [" + GetListItem(sValues, 1) +
                        "," + GetListItem(sValues, 2) +
                        "," + GetListItem(sValues, 3) + "] " +
                      "{facing} " + GetListItem(sValues, 4);
            SetLocalLocation(oTarget, sVarName, Location(oArea, Vector(fX, fY, fZ), fFacing));
        }
        else
            SendChatResult("Could not find a valid object for passed object tag" +
                           "\n  Tag received -> " + GetListItem(sValues, 0), oPC, FLAG_ERROR);
    }
/*    
    else if (HasChatKey(oPC, "v,vec,vector"))
    {
        sValue = GetChatKeyValue(oPC, "v,vec,vector");
        string sValues = Tokenize(sValue, ";", "", TRUE);

        if (CountList(sValues) != 3)
        {
            SendChatResult("Incorrect number of arguments passed in the --[v|vec|vector] value" +
                           "\n  Values received -> " + sValue +
                           "\n\n" +
                           SetVariableHelp(), oPC, FLAG_ERROR);
            return;
        }

        float fX = StringToFloat(GetListItem(sValues, 0));
        float fY = StringToFloat(GetListItem(sValues, 1));
        float fZ = StringToFloat(GetListItem(sValues, 2));

        sType = "Vector";
        sResult = "[" + GetListItem(sValues, 0) +
                    "," + GetListItem(sValues, 1) +
                    "," + GetListItem(sValues, 2) + "]";
        SetLocalVector(oTarget, sVarName, Vector(fX, fY, fZ));
    }
*/
    else
        SendChatResult("Variable type could not be determined from options" +
                       "\n  Key-Value Pairs received -> " + GetChatPairs(oPC), oPC, FLAG_ERROR);

    if (sType != "")      
        SendChatResult(sType + " variable " + sVarName + " with value " + (sResult == "" ? sValue : sResult) + " set on " + (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget)), oPC);
}

void test_polymorph()
{
  object oPC = OBJECT_SELF;
  string sCurrentEvent = NWNX_Events_GetCurrentEvent();
  if (sCurrentEvent == "NWNX_ON_POLYMORPH_BEFORE") {
    //Saving of spell-casting memorised/remaining slots for restoration on unpolymorph.
    int ClassPos, InitDone;
    for(ClassPos = 1; ClassPos <= 3; ClassPos++) {
      int Class = GetClassByPosition(ClassPos, oPC);
      if(Get2DAString("classes", "SpellCaster", Class) != "1")
        continue;//not a spellcasting class, skip it

      if (!InitDone) { //prep - only once
        SqlStep(SqlPrepareQueryObject(oPC, "CREATE TABLE IF NOT EXISTS PolySpellRestore (ClassID INTEGER, Can INTEGER, One INTEGER, Two INTEGER, Three INTEGER, Four INTEGER, Five INTEGER, Six INTEGER, Seven INTEGER, Eight INTEGER, Nine INTEGER)"));
        SqlStep(SqlPrepareQueryObject(oPC, "BEGIN TRANSACTION"));
        InitDone = TRUE;
      }

      if(!StringToInt(Get2DAString("classes", "MemorizesSpells", Class))) { //Sorc-like casters
        sqlquery SorcLikeSQL = SqlPrepareQueryObject(oPC, "INSERT INTO PolySpellRestore(ClassID, Can, One, Two, Three, Four, Five, Six, Seven, Eight, Nine) VALUES (@Class, @Ca, @On, @Tw, @Th, @Fo, @Fi, @Si, @Se, @Ei, @Ni)");
        SqlBindInt(SorcLikeSQL, "@Class", Class);
        SqlBindInt(SorcLikeSQL, "@Ca", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 0));
        SqlBindInt(SorcLikeSQL, "@On", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 1));
        SqlBindInt(SorcLikeSQL, "@Tw", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 2));
        SqlBindInt(SorcLikeSQL, "@Th", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 3));
        SqlBindInt(SorcLikeSQL, "@Fo", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 4));
        SqlBindInt(SorcLikeSQL, "@Fi", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 5));
        SqlBindInt(SorcLikeSQL, "@Si", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 6));
        SqlBindInt(SorcLikeSQL, "@Se", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 7));
        SqlBindInt(SorcLikeSQL, "@Ei", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 8));
        SqlBindInt(SorcLikeSQL, "@Ni", NWNX_Creature_GetRemainingSpellSlots(oPC, Class, 9));
        SqlStep(SorcLikeSQL);
      }
      else { //all Wizard-like-cases here - Because Wizards are too smart for their own good we're going to bit-mask it. Note undefined behaviour if anyone ever memorises more than 32 spells of one spell level (HA!)
        sqlquery WizLikeSQL = SqlPrepareQueryObject(oPC, "INSERT INTO PolySpellRestore(ClassID, Can, One, Two, Three, Four, Five, Six, Seven, Eight, Nine) VALUES (@Class, @Ca, @On, @Tw, @Th, @Fo, @Fi, @Si, @Se, @Ei, @Ni)");
        SqlBindInt(WizLikeSQL, "@Class", Class);
        int spellLevel;
        for(spellLevel = 0; spellLevel <= 9; spellLevel++) {
          int memIndexCount = NWNX_Creature_GetMemorisedSpellCountByLevel(oPC, Class, spellLevel);
          if(memIndexCount == 0) continue; //skip this line if there's no memorised spells.
          string VarName;
          switch(spellLevel) { //get the right var for the sql binding.
            case 0: VarName = "@Ca"; break;
            case 1: VarName = "@On"; break;
            case 2: VarName = "@Tw"; break;
            case 3: VarName = "@Th"; break;
            case 4: VarName = "@Fo"; break;
            case 5: VarName = "@Fi"; break;
            case 6: VarName = "@Si"; break;
            case 7: VarName = "@Se"; break;
            case 8: VarName = "@Ei"; break;
            case 9: VarName = "@Ni"; break;
          }

          int Index, BitmaskReady;
          for(Index = 0; Index < memIndexCount; Index++) {
            struct NWNX_Creature_MemorisedSpell spellStruct = NWNX_Creature_GetMemorisedSpell(oPC, Class, spellLevel, Index);
            if(spellStruct.ready == 1) BitmaskReady |= (1 << Index); //Add the '1' bit-shifted by the Index to the bitmask.
          }
          //now we've got the bitmask so let's bind it!
          SqlBindInt(WizLikeSQL, VarName, BitmaskReady);
        }
        SqlStep(WizLikeSQL); //Having now done all spell-levels: Do!
      }
    }
    if(InitDone) {
      SqlStep(SqlPrepareQueryObject(oPC, "COMMIT TRANSACTION")); //if we found any spellcasting, and therefore began the transaction: Commit it.
      SetLocalInt(oPC, "POLYMORPH_SPELL_TABLE", TRUE);
    }
  }
  else if (sCurrentEvent == "NWNX_ON_UNPOLYMORPH_AFTER") {
    // Restoration of spells memorised/remaining as saved in Polymorph_Before.
    if(!GetLocalInt(oPC, "POLYMORPH_SPELL_TABLE")) return;
    int ClassPos;
    for(ClassPos = 1; ClassPos <= 3; ClassPos++)
    {
      int Class = GetClassByPosition(ClassPos, oPC);
      if(Get2DAString("classes", "SpellCaster", Class) != "1")
        continue;//not a spellcasting class, skip it

      //Get the spell-array for this class...
      sqlquery ReadySpellSQL = SqlPrepareQueryObject(oPC, "SELECT Can, One, Two, Three, Four, Five, Six, Seven, Eight, Nine FROM PolySpellRestore WHERE ClassID = @Class");
      SqlBindInt(ReadySpellSQL, "@Class", Class);
      SqlStep(ReadySpellSQL);

      if(!StringToInt(Get2DAString("classes", "MemorizesSpells", Class))) //Sorc-like casters
      {
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 0, SqlGetInt(ReadySpellSQL, 0));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 1, SqlGetInt(ReadySpellSQL, 1));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 2, SqlGetInt(ReadySpellSQL, 2));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 3, SqlGetInt(ReadySpellSQL, 3));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 4, SqlGetInt(ReadySpellSQL, 4));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 5, SqlGetInt(ReadySpellSQL, 5));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 6, SqlGetInt(ReadySpellSQL, 6));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 7, SqlGetInt(ReadySpellSQL, 7));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 8, SqlGetInt(ReadySpellSQL, 8));
        NWNX_Creature_SetRemainingSpellSlots(oPC, Class, 9, SqlGetInt(ReadySpellSQL, 9));
      }
      else //all Wizard-like-cases here - Unfolding the bitmask (Cause Wizards are still too smart)
      {
        int spellLevel;
        for(spellLevel = 0; spellLevel <= 9; spellLevel++)
        {
          int memIndexCount = NWNX_Creature_GetMemorisedSpellCountByLevel(oPC, Class, spellLevel);
          if(memIndexCount == 0) continue; //skip this line if there's no memorised spells.
          int BitmaskReady = SqlGetInt(ReadySpellSQL, spellLevel);
          int Index;
          for(Index = 0; Index < memIndexCount; Index++)
          {
            struct NWNX_Creature_MemorisedSpell spellStruct = NWNX_Creature_GetMemorisedSpell(oPC, Class, spellLevel, Index); //Get the current one...
            if(spellStruct.id == -1) 
            {
                continue;
            }
            if(BitmaskReady & (1 << Index)) {
              spellStruct.ready = 1; // If bitmask test is passed, it's good! if not, chuck it.
            }
            else {
              spellStruct.ready = 0;
            }
            DelayCommand(0.7, NWNX_Creature_SetMemorisedSpell(oPC, Class, spellLevel, Index, spellStruct)); // and now set it with the corrected ready state.

          }
        }
      }

    }
    SqlStep(SqlPrepareQueryObject(oPC, "DROP TABLE IF EXISTS PolySpellRestore")); //wipe that table OUT
    DeleteLocalInt(oPC, "POLYMORPH_SPELL_TABLE");


  }

}

void test_spells()
{
    

    object oPC = GetPCChatSpeaker();
    Notice(HexColorString("Reviewing Known Spells for " + HexColorString(GetName(oPC), COLOR_CYAN), COLOR_RED_LIGHT));
    int ClassPos;
    
    for(ClassPos = 1; ClassPos <= 3; ClassPos++) 
    {
        int Class = GetClassByPosition(ClassPos, oPC);
        if (Get2DAString("classes", "SpellCaster", Class) != "1")
            continue;//not a spellcasting class, skip it

        int spellLevel;
        for (spellLevel = 0; spellLevel <= 9; spellLevel++)
        {
            int Index, memIndexCount = NWNX_Creature_GetMemorisedSpellCountByLevel(oPC, Class, spellLevel);
            Notice(HexColorString("Spell level " + IntToString(spellLevel) + " has " + IntToString(memIndexCount) + " spells", COLOR_ORANGE_LIGHT));
            for(Index = 0; Index < memIndexCount; Index++)
            {
                struct NWNX_Creature_MemorisedSpell spellStruct = NWNX_Creature_GetMemorisedSpell(oPC, Class, spellLevel, Index);
                Notice("  Spell at Index " + HexColorString(IntToString(Index), COLOR_CYAN));
                Notice("    ID -> " + IntToString(spellStruct.id));
                Notice("    Ready? -> " + (spellStruct.ready ? "TRUE":"FALSE"));
            }            
        }
    }
}