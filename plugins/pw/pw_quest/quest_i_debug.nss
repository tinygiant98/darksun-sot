#include "util_i_debug"
#include "util_i_csvlists"
#include "util_i_math"
#include "quest_i_const"

string GetPrefix()
{
    return HexColorString("(quest) ", COLOR_GOLD);
}

void QuestDebug(string sMessage)
{
    Debug(GetPrefix() + sMessage);
}

void QuestNotice(string sMessage)
{
    Notice(GetPrefix() + sMessage);
}

void QuestWarning(string sMessage)
{
    Warning(GetPrefix() + sMessage);
}

void QuestError(string sMessage)
{
    Error(GetPrefix() + sMessage);
}

void QuestCriticalError(string sMessage)
{
    CriticalError(GetPrefix() + sMessage);
}

string _GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, 0, nIndex);
}

string _GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

string AwardTypeToString(int nAwardType)
{
    switch (nAwardType)
    {
        case AWARD_ALL: return "ALL";
        case AWARD_GOLD: return "GOLD";
        case AWARD_XP: return "XP";
        case AWARD_ITEM: return "ITEMS";
        case AWARD_ALIGNMENT: return "ALIGNMENT";
        case AWARD_QUEST: return "QUEST";
        case AWARD_MESSAGE: return "MESSAGE";
    }

    return "[NOT FOUND]";
}

string AlignmentAxisToString(int nAxis)
{
    switch (nAxis)
    {
        case ALIGNMENT_ALL: return "ALL";
        case ALIGNMENT_CHAOTIC: return "CHAOTIC";
        case ALIGNMENT_EVIL: return "EVIL";
        case ALIGNMENT_GOOD: return "GOOD";
        case ALIGNMENT_LAWFUL: return "LAWFUL";        
        case ALIGNMENT_NEUTRAL: return "NEUTRAL";
    }

    return "[NOT FOUND]";
}

string ClassToString(int nClass)
{
    switch (nClass)
    {
        case CLASS_TYPE_ABERRATION: return "ABERRATION";
        case CLASS_TYPE_ANIMAL: return "ANIMAL";
        case CLASS_TYPE_ARCANE_ARCHER: return "ARCANE ARCHER";
        case CLASS_TYPE_ASSASSIN: return "ASSASSIN";
        case CLASS_TYPE_BARBARIAN: return "BARBARIAN";
        case CLASS_TYPE_BARD: return "BARD";
        case CLASS_TYPE_BEAST: return "BEAST";
        case CLASS_TYPE_CLERIC: return "CLERIC"; 
        case CLASS_TYPE_COMMONER: return "COMMONER";
        case CLASS_TYPE_CONSTRUCT: return "CONSTRUCT";
        //case CLASS_TYPE_DIVINECHAMPION:
        case CLASS_TYPE_DIVINE_CHAMPION: return "DIVINE CHAMPION";
        case CLASS_TYPE_DRAGON: return "DRAGON";
        //case CLASS_TYPE_DRAGONDISCIPLE:
        case CLASS_TYPE_DRAGON_DISCIPLE: return "DRAGON DISCIPLE";
        case CLASS_TYPE_DRUID: return "DRUID"; 
        //case CLASS_TYPE_DWARVENDEFENDER:
        case CLASS_TYPE_DWARVEN_DEFENDER: return "DWARVEN DEFENDER";
        case CLASS_TYPE_ELEMENTAL: return "ELEMENTAL";
        case CLASS_TYPE_EYE_OF_GRUUMSH: return "GRUUMSH";
        case CLASS_TYPE_FEY: return "FEY";
        case CLASS_TYPE_FIGHTER: return "FIGHTER"; 
        case CLASS_TYPE_GIANT: return "GIANT";
        case CLASS_TYPE_HARPER: return "HARPER";
        case CLASS_TYPE_HUMANOID: return "HUMANOID";
        case CLASS_TYPE_INVALID: return "INVALID";
        case CLASS_TYPE_MAGICAL_BEAST: return "MAGICAL BEAST";
        case CLASS_TYPE_MONK: return "MONK"; 
        case CLASS_TYPE_MONSTROUS: return "MONSTROUS";
        case CLASS_TYPE_OOZE: return "OOZE";
        case CLASS_TYPE_OUTSIDER: return "OUTSIDER";
        case CLASS_TYPE_PALADIN: return "PALADIN";
        //case CLASS_TYPE_PALEMASTER: return "PALE MASTER";
        case CLASS_TYPE_PALE_MASTER	: return "PALE MASTER";
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: return "PURPLE DRAGON KNIGHT";
        case CLASS_TYPE_RANGER: return "RANGER";
        case CLASS_TYPE_ROGUE: return "ROGUE"; 
        case CLASS_TYPE_SHADOWDANCER: return "SHADOW DANCER";
        case CLASS_TYPE_SHAPECHANGER: return "SHAPE CHANGER";
        case CLASS_TYPE_SHOU_DISCIPLE: return "SHOU DISCIPLE"; 
        case CLASS_TYPE_SHIFTER: return "SHIFTER";
        case CLASS_TYPE_SORCERER: return "SORCERER";
        case CLASS_TYPE_UNDEAD: return "UNDEAD"; 
        case CLASS_TYPE_VERMIN: return "VERMIN";
        case CLASS_TYPE_WEAPON_MASTER: return "WEAPON MASTER";
        case CLASS_TYPE_WIZARD: return "WIZARD"; 
    }

    // if we're here must be a custom class
    string sField = "Name";
    string sRef = Get2DAString("classes", sField, nClass);

    if (sRef != "")
        return GetStringByStrRef(StringToInt(sRef));
    else
        return "[NOT FOUND]";
}

string StepToString(int nStep)
{
    return HexColorString("Step " + IntToString(nStep), COLOR_PINK);
}

string RaceToString(int nRace)
{
    switch (nRace)
    {
        case RACIAL_TYPE_ABERRATION: return "ABERRATION";
        case RACIAL_TYPE_ALL: return "ALL|INVALID";
        case RACIAL_TYPE_ANIMAL: return "ANIMAL";
        case RACIAL_TYPE_BEAST: return "BEAST";
        case RACIAL_TYPE_CONSTRUCT: return "CONSTRUCT";
        case RACIAL_TYPE_DRAGON: return "DRAGON";
        case RACIAL_TYPE_DWARF: return "DWARF";
        case RACIAL_TYPE_ELEMENTAL: return "ELEMENTAL";
        case RACIAL_TYPE_ELF: return "ELF";
        case RACIAL_TYPE_FEY: return "FEY";
        case RACIAL_TYPE_GIANT: return "GIANT";
        case RACIAL_TYPE_GNOME: return "GNOME";
        case RACIAL_TYPE_HALFELF: return "HALF ELF";
        case RACIAL_TYPE_HALFLING: return "HALFLING";
        case RACIAL_TYPE_HALFORC: return "HALF ORC";
        case RACIAL_TYPE_HUMAN: return "HUMAN";
        case RACIAL_TYPE_HUMANOID_GOBLINOID: return "HUMANOID GOBLINOID";
        case RACIAL_TYPE_HUMANOID_MONSTROUS: return "HUMANOID MONSTROUS";
        case RACIAL_TYPE_HUMANOID_ORC: return "HUMANOID ORC";
        case RACIAL_TYPE_HUMANOID_REPTILIAN: return "HUMANOID REPTILIAN";
        //case RACIAL_TYPE_INVALID: return "INVALID";
        case RACIAL_TYPE_MAGICAL_BEAST: return "MAGICAL BEAST";
        case RACIAL_TYPE_OOZE: return "OOZE";
        case RACIAL_TYPE_OUTSIDER: return "OUTSIDER";
        case RACIAL_TYPE_SHAPECHANGER: return "SHAPE CHANGER";
        case RACIAL_TYPE_UNDEAD: return "UNDEAD";
        case RACIAL_TYPE_VERMIN: return "VERMIN";
    }

    return "[NOT FOUND]";
}

string JournalHandlerToString(int nJournalHandler)
{
    switch (nJournalHandler)
    {
        case QUEST_JOURNAL_NONE: return "NONE";
        case QUEST_JOURNAL_NWN: return "NWN";
        case QUEST_JOURNAL_NWNX: return "NWNX";
    }

    return "[NOT FOUND]";
}

string ColorValue(string sValue, int nZeroIsEmpty = FALSE, int bStripe = FALSE)
{
    if (sValue == "" || (nZeroIsEmpty && sValue == "0") || sValue == "-1")
        return HexColorString("[EMPTY]", COLOR_GRAY);
    else if (sValue == "[NOT FOUND]")
        return HexColorString(sValue, COLOR_RED_LIGHT);
    else
        return HexColorString(sValue, bStripe ? COLOR_BLUE : COLOR_BLUE_LIGHT);
}

string ScriptTypeToString(int nScriptType)
{
    switch (nScriptType)
    {
        case QUEST_SCRIPT_TYPE_ON_ACCEPT: return "ON_ACCEPT";
        case QUEST_SCRIPT_TYPE_ON_ADVANCE: return "ON_ADVANCE";
        case QUEST_SCRIPT_TYPE_ON_COMPLETE: return "ON_COMPLETE";
        case QUEST_SCRIPT_TYPE_ON_FAIL: return "ON_FAIL";
    }
    
    return "[NOT FOUND]";
}

string ObjectiveTypeToString(int nObjectiveType)
{
    switch (nObjectiveType)
    {
        case QUEST_OBJECTIVE_GATHER: return "GATHER";
        case QUEST_OBJECTIVE_KILL: return "KILL";
        case QUEST_OBJECTIVE_DELIVER: return "DELIVER";
        case QUEST_OBJECTIVE_SPEAK: return "SPEAK";
        case QUEST_OBJECTIVE_DISCOVER: return "DISCOVER";
    }

    return "[NOT FOUND]";
}

string StepTypeToString(int nStepType)
{
    switch (nStepType)
    {
        case QUEST_STEP_TYPE_PROGRESS: return "PROGRESS";
        case QUEST_STEP_TYPE_SUCCESS: return "SUCCESS";
        case QUEST_STEP_TYPE_FAIL: return "FAIL";
    }

    return "[NOT FOUND]";
}

string AbilityToString(int nAbility)
{
    switch (nAbility)
    {
        case ABILITY_CHARISMA: return "CHARISMA";
        case ABILITY_CONSTITUTION: return "CONSTITUTION";
        case ABILITY_DEXTERITY: return "DEXTERITY";
        case ABILITY_INTELLIGENCE: return "INTELLIGENCE";
        case ABILITY_STRENGTH: return "STRENGTH";
        case ABILITY_WISDOM: return "WISDOM";
    }

    return "[NOT FOUND]";
}

string ValueTypeToString(int nValueType, int nCategoryType = QUEST_CATEGORY_PREREQUISITE)
{
    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        switch (nValueType)
        {
            case QUEST_VALUE_NONE: return "NONE";
            case QUEST_VALUE_ALIGNMENT: return "ALIGNMENT";
            case QUEST_VALUE_CLASS: return "CLASS";
            case QUEST_VALUE_GOLD: return "GOLD";
            case QUEST_VALUE_ITEM: return "ITEM";
            case QUEST_VALUE_LEVEL_MAX: return "LEVEL_MAX";
            case QUEST_VALUE_LEVEL_MIN: return "LEVEL_MIN";
            case QUEST_VALUE_QUEST: return "QUEST";
            case QUEST_VALUE_RACE: return "RACE";
            case QUEST_VALUE_XP: return "XP";
            case QUEST_VALUE_REPUTATION: return "REPUTATION";
            case QUEST_VALUE_MESSAGE: return "MESSAGE";
            case QUEST_VALUE_QUEST_STEP: return "QUEST_STEP";
            case QUEST_VALUE_SKILL: return "SKILL";
            case QUEST_VALUE_ABILITY: return "ABILITY";
            case QUEST_VALUE_VARIABLE: return "VARIABLE";
        }
    }
    else
        return ObjectiveTypeToString(nValueType);

    return "[NOT FOUND]";
}

string PCToString(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return HexColorString("[NOT FOUND]", COLOR_RED_LIGHT);

    return HexColorString(GetName(oPC), COLOR_VIOLET);
}

string CategoryTypeToString(int nCategoryType)
{
    switch (nCategoryType)
    {
        case QUEST_CATEGORY_PREREQUISITE: return "PREREQUISITE";
        case QUEST_CATEGORY_OBJECTIVE: return "OBJECTIVE";
        case QUEST_CATEGORY_PREWARD: return "PREWARD";
        case QUEST_CATEGORY_REWARD: return "REWARD";
    }

    return "[NOT FOUND]";
}

string ResolutionToString(int bQualifies)
{
    string sResult = "Assignable";
    if (bQualifies)
        return HexColorString(sResult, COLOR_GREEN_LIGHT);
    else
        return HexColorString("NOT " + sResult, COLOR_RED_LIGHT);
}

string SkillToString(int nSkill)
{
    switch (nSkill)
    {
        case SKILL_ALL_SKILLS: return "ALL";
        case SKILL_ANIMAL_EMPATHY: return "ANIMAL EMPATHY";
        case SKILL_APPRAISE: return "APPRAISE";
        case SKILL_BLUFF: return "BLUFF";
        case SKILL_CONCENTRATION: return "CONCENTRATION";
        case SKILL_CRAFT_ARMOR: return "CRAFT ARMOR";
        case SKILL_CRAFT_TRAP: return "CRAFT TRAP";
        case SKILL_CRAFT_WEAPON: return "CRAFT WEAPON";
        case SKILL_DISABLE_TRAP: return "DISABLE TRAP";
        case SKILL_DISCIPLINE: return "DISCIPLINE";
        case SKILL_HEAL: return "HEAL";
        case SKILL_HIDE: return "HIDE";
        case SKILL_INTIMIDATE: return "INTIMIDATE";
        case SKILL_LISTEN: return "LISTEN";
        case SKILL_LORE: return "LORE";
        case SKILL_MOVE_SILENTLY: return "MOVE SILENTLY";
        case SKILL_OPEN_LOCK: return "OPEN LOCK";
        case SKILL_PARRY: return "PARRY";
        case SKILL_PERFORM: return "PERFORM";
        case SKILL_PERSUADE: return "PERSUADE";
        case SKILL_PICK_POCKET: return "PICK POCKET";
        case SKILL_RIDE: return "RIDE";
        case SKILL_SEARCH: return "SEARCH";
        case SKILL_SET_TRAP: return "SET TRAP";
        case SKILL_SPELLCRAFT: return "SPELLCRAFT";
        case SKILL_SPOT: return "SPOT";
        case SKILL_TAUNT: return "TAUNT";
        case SKILL_TUMBLE: return "TUMBLE";
        case SKILL_USE_MAGIC_DEVICE: return "USE MAGIC DEVICE";
    }

    return "[NOT FOUND]";
}

string VersionActionToString(int nQuestVersionAction)
{
    switch (nQuestVersionAction)
    {
        case QUEST_VERSION_ACTION_NONE: return "NONE";
        case QUEST_VERSION_ACTION_RESET: return "RESET";
        case QUEST_VERSION_ACTION_DELETE: return "DELETE";
    }

    return "[NOT FOUND]";
}

string TimeVectorToString(string sTimeVector)
{
    string sUnit, sResult, sElement, sUnits = "Year, Month, Day, Hour, Minute, Second";

    int n, nCount = CountList(sTimeVector);
    for (n = 0; n < nCount; n++)
    {
        sElement = GetListItem(sTimeVector, n);
        sUnit = GetListItem(sUnits, n);

        if (sElement != "0")
            sResult += (sResult == "" ? "" : ", ") + sElement + " " + sUnit + (sElement == "1" ? "" : "s");
    }

    return sResult;
}

string GetIndent(int bReset = FALSE);

string ResetIndent()
{
    DeleteLocalInt(GetModule(), QUEST_INDENT);
    return GetIndent();
}

string GetIndent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    string sIndent;
    int nIndent = GetLocalInt(GetModule(), QUEST_INDENT);
    if (nIndent == 0)
        return "";

    while (nIndent-- > 0)
        sIndent += "  ";

    return sIndent;
}

string Indent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    int nIndent = GetLocalInt(GetModule(), QUEST_INDENT);
    SetLocalInt(GetModule(), QUEST_INDENT, ++nIndent);

    return GetIndent();
}

string Outdent()
{
    int nIndent = GetLocalInt(GetModule(), QUEST_INDENT);
    SetLocalInt(GetModule(), QUEST_INDENT, max(0, --nIndent));

    return GetIndent();
}

string ColorTitle(string s)
{
    return HexColorString(s, COLOR_CYAN);
}

string ColorSuccess(string s)
{
    return HexColorString(s, COLOR_GREEN_LIGHT);
}

string ColorFail(string s)
{
    return HexColorString(s, COLOR_RED_LIGHT);
}

void PrintProperties(int nQuestID, int nCategoryType, int nStep = 0)
{
/*
    Prerequisite -> TYPE | sKey | nValue
    Objective -> TYPE | sTargetTag | nQuantity [| sData]
    Reward -> REWARD | sType | nValue
    Preward -> PREWARD | sType | nValue
*/
    string sType, sQuery, sKey, sValue, sPrereqOperators, sValueType, sData;
    string sQuestTag = GetQuestTag(nQuestID);
    int nValueType, bParty, bRecordsFound;
    sqlquery sql1;

    if (nCategoryType == QUEST_CATEGORY_PREREQUISITE)
    {
        sType = "prerequisites";
        sQuery = "SELECT * FROM quest_prerequisites " +
                 "WHERE quests_id = @nQuestID;";
        sql1 = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlBindInt(sql1, "@nQuestID", nQuestID);

        sPrereqOperators = "CLASS,GOLD,ITEM,QUEST,XP,SKILL,ABILITY,REPUTATION";
    }
    else if (nCategoryType == QUEST_CATEGORY_OBJECTIVE)
        sType = "objectives";
    else if (nCategoryType == QUEST_CATEGORY_PREWARD)
        sType = "prewards";
    else if (nCategoryType == QUEST_CATEGORY_REWARD)
        sType = "rewards";    

    if (sQuery == "")
    {
        sQuery = "SELECT quest_step_properties.* FROM quest_steps INNER JOIN quest_step_properties " +
                    "ON quest_steps.id = quest_step_properties.quest_steps_id " +
                 "WHERE quest_steps.quests_id = @nQuestID " +
                 "AND quest_steps.nStep = @nStep " +
                 "AND quest_step_properties.nCategoryType = @nCategoryType;";
        sql1 = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlBindInt(sql1, "@nQuestID", nQuestID);
        SqlBindInt(sql1, "@nStep", nStep);
        SqlBindInt(sql1, "@nCategoryType", nCategoryType);
    }

    string s = GetIndent();
    Debug(ColorTitle(s + "Dumping " + sType + " for " + QuestToString(nQuestID) + 
        (nStep > 0 ? " " + StepToString(nStep) : "")));
    s = Indent();

    while (SqlStep(sql1))
    {
        if (nCategoryType == QUEST_CATEGORY_PREREQUISITE)
        {
            nValueType = SqlGetInt(sql1, 2);
            sKey = SqlGetString(sql1, 3);
            sValue = SqlGetString(sql1, 4);

            sValueType = ValueTypeToString(nValueType);
            if (HasListItem(sPrereqOperators, sValueType))
                sValue = _GetKey(sValue) + " " + _GetValue(sValue);
        }
        else
        {
            nValueType = SqlGetInt(sql1, 3);
            sKey = SqlGetString(sql1, 4);
            sValue = SqlGetString(sql1, 5);
            sData = SqlGetString(sql1, 6);
            bParty = SqlGetInt(sql1, 7);

            sValueType = ValueTypeToString(nValueType);
        }

        string sCategory = ColorSuccess(CategoryTypeToString(nCategoryType));
        string sPipe = HexColorString(" | ", COLOR_GRAY);
        int nValue = StringToInt(sValue);

        if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
        {
            switch (nValueType)
            {
                case QUEST_VALUE_ALIGNMENT:
                    sKey = AlignmentAxisToString(StringToInt(sKey));
                    if (nCategoryType == QUEST_CATEGORY_PREREQUISITE)
                    {
                        if (nValue == 1) sValue = "NEUTRAL";
                        else sValue = "";
                    }
                    break;
                case QUEST_VALUE_CLASS:
                    sKey = ClassToString(StringToInt(sKey));

                    if (nValue == -1)
                        sValue = "Any";
                    else if (nValue == 0)
                        sValue = "Excluded";
                    else
                        sValue += " level" + (nValue == 1 ? "" : "s");

                    break;
                case QUEST_VALUE_RACE:
                    sKey = RaceToString(StringToInt(sKey));

                    if (nValue == 1)
                        sValue = "Allowed";
                    else
                        sValue = "Excluded";

                    break;
                case QUEST_VALUE_GOLD:
                    sKey = " ";
                    sValue += "gp";
                    break;
                case QUEST_VALUE_LEVEL_MAX:
                    sKey = " ";
                    sValue = "<= " + sValue;
                    break;
                case QUEST_VALUE_LEVEL_MIN:
                    sKey = " ";
                    sValue = ">= " + sValue;
                    break;
                case QUEST_VALUE_ITEM:
                    break;
                case QUEST_VALUE_XP:
                    sKey = " ";
                    sValue += "xp";
                    break;
                case QUEST_VALUE_MESSAGE:
                    sKey = " ";
                    break;
            }
        }

        if (sKey != " ")
            sKey = ColorValue(sKey);

        sValue = ColorValue(sValue);

        Debug(s + sCategory + sPipe +
                sValueType + sPipe +
                (sKey == " " ? "" : sKey + sPipe) +
                sValue +
                (sData == "" ? "" : sPipe + ColorValue(sData)) +
                (bParty ? sPipe + "Party Allotment" : ""));

        bRecordsFound = TRUE;
    }

    if (!bRecordsFound)
        Debug(ColorFail(s + "No " + sType + " found for " + QuestToString(nQuestID) + 
            (nStep > 0 ? " " + StepToString(nStep) : "")));

    Outdent();
}

void DumpQuestData(string sQuestTag)
{
    string sQuery = "SELECT * " +
                    "FROM quest_quests " +
                    "WHERE sTag = @sQuestTag;";
    sqlquery sqlDump = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sqlDump, "@sQuestTag", sQuestTag);
    if (SqlStep(sqlDump))
    {
        int n;
        int nQuestID = SqlGetInt(sqlDump, n++);
        int nActive = SqlGetInt(sqlDump, ++n);
        string sTitle = SqlGetString(sqlDump, ++n);
        int nRepetitions = SqlGetInt(sqlDump, ++n);
        string sScriptOnAccept = SqlGetString(sqlDump, ++n);
        string sScriptOnAdvance = SqlGetString(sqlDump, ++n);
        string sScriptOnComplete = SqlGetString(sqlDump, ++n);
        string sScriptOnFail = SqlGetString(sqlDump, ++n);
        string sTimeLimit = SqlGetString(sqlDump, ++n);
        string sCooldown = SqlGetString(sqlDump, ++n);
        int nJournalHandler = SqlGetInt(sqlDump, ++n);
        int nRemoveJournalOnComplete = SqlGetInt(sqlDump, ++n);
        int nAllowPrecollectedItems = SqlGetInt(sqlDump, ++n);
        int nRemoveQuestOnComplete = SqlGetInt(sqlDump, ++n);
        int nVersion = SqlGetInt(sqlDump, ++n);
        int nVersionAction = SqlGetInt(sqlDump, ++n);        
    
        string s = Indent(TRUE);
        Debug(ColorTitle(s + "Dumping quest data for " + QuestToString(nQuestID)));
        s = Indent();

        Debug( s + "Active " + ColorValue(nActive ? "TRUE" : "FALSE") +
        "\n" + s + "Title  " + ColorValue(sTitle) +
        "\n" + s + "Repetitions  " + ColorValue(IntToString(nRepetitions)) +
        "\n" + s + "OnAccept Script  " + ColorValue(sScriptOnAccept) +
        "\n" + s + "OnAdvance Script  " + ColorValue(sScriptOnAdvance) +
        "\n" + s + "OnComplete Script  " + ColorValue(sScriptOnComplete) +
        "\n" + s + "OnFail Script  " + ColorValue(sScriptOnFail) +
        "\n" + s + "Time Limit  " + ColorValue(TimeVectorToString(sTimeLimit)) +
        "\n" + s + "Cooldown  " + ColorValue(TimeVectorToString(sCooldown)) +
        "\n" + s + "Journal Handler  " + ColorValue(JournalHandlerToString(nJournalHandler)) +
        "\n" + s + "Remove Journal Entries on Quest Completion  " + ColorValue(nRemoveJournalOnComplete ? "TRUE" : "FALSE") +
        "\n" + s + "Allow Precollected Items  " + ColorValue(nAllowPrecollectedItems ? "TRUE" : "FALSE") +
        "\n" + s + "Remove PC Quest On Quest Completion  " + ColorValue(nRemoveQuestOnComplete ? "TRUE" : "FALSE") +
        "\n" + s + "Version  " + ColorValue(IntToString(nVersion)) +
        "\n" + s + "Version Action  " + ColorValue(VersionActionToString(nVersionAction)));

        PrintProperties(nQuestID, QUEST_CATEGORY_PREREQUISITE);

        // Step Data!
        sQuery = "SELECT * " +
                 "FROM quest_steps " +
                 "WHERE quests_id = @id;";
        sqlDump = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlBindInt(sqlDump, "@id", nQuestID);

        while (SqlStep(sqlDump))
        {
            n = 0;
            int nStepID = SqlGetInt(sqlDump, n);
            int nQuestID = SqlGetInt(sqlDump, ++n);
            int nStep = SqlGetInt(sqlDump, ++n);
            string sJournalEntry = SqlGetString(sqlDump, ++n);
            string sTimeLimit = SqlGetString(sqlDump, ++n);
            int nPartyCompletion = SqlGetInt(sqlDump, ++n);
            int nProximity = SqlGetInt(sqlDump, ++n);
            int nStepType = SqlGetInt(sqlDump, ++n);
            int nObjectiveMinimumCount = SqlGetInt(sqlDump, ++n);
            int nRandomObjectiveCount = SqlGetInt(sqlDump, ++n);

            s = GetIndent();
            Debug(ColorTitle(s + "Dumping quest step data for " + QuestToString(nQuestID) + " " + StepToString(nStep)));
            s = Indent();

            Debug( s + "Step Number " + ColorValue(IntToString(nStep)) +
            "\n" + s + "Journal Entry  " + ColorValue(sJournalEntry) +
            "\n" + s + "Time Limit  " + ColorValue(TimeVectorToString(sTimeLimit)) +
            "\n" + s + "Party Completion Allowed  " + ColorValue(nPartyCompletion ? "TRUE" : "FALSE") +
            "\n" + s + "Proximity Required  " + ColorValue(nProximity ? "TRUE" : "FALSE") +
            "\n" + s + "Type  " + ColorValue(StepTypeToString(nStepType)) +
            "\n" + s + "Minimum Objective Count  " + ColorValue(IntToString(nObjectiveMinimumCount), TRUE) +
            "\n" + s + "Random Objective Count  " + ColorValue(IntToString(nRandomObjectiveCount), TRUE));

            PrintProperties(nQuestID, QUEST_CATEGORY_PREWARD, nStep);
            PrintProperties(nQuestID, QUEST_CATEGORY_REWARD, nStep);
        }
    }
}

void DumpPCQuestData(object oPC, string sQuestTag)
{
    string sQuery = "SELECT * " +
                    "FROM quest_pc_data " +
                    "WHERE quest_tag = @sQuestTag;";
    sqlquery sqlDump = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sqlDump, "@sQuestTag", sQuestTag);

    if (SqlStep(sqlDump))
    {
        int n = 0;
        string sQuestTag = SqlGetString(sql, n);
        int nStep = SqlGetInt(sql, ++n);
        int nAttempts = SqlGetInt(sql, ++n);
        int nCompletions = SqlGetInt(sql, ++n);
        int nFailures = SqlGetInt(sql, ++n);
        int nQuestStart = SqlGetInt(sql, ++n);
        int nStepStart = SqlGetInt(sql, ++n);
        int nQuestComplete = SqlGetInt(sql, ++n);
        int nLastCompleteType = SqlGetInt(sql, ++n);
        int nVersion = SqlGetInt(sql, ++n);
                
        string s = Indent(TRUE);
        int nQuestID = GetQuestID(sQuestTag);
        Debug(ColorTitle(s + "Dumping PC quest data for " + QuestToString(nQuestID)) +
            " on " + PCToString(oPC));
        s = Indent();

        Debug( s + "Current Step  " + ColorValue(IntToString(nStep)) +
        "\n" + s + "Attempts  " + ColorValue(IntToString(nAttempts)) +
        "\n" + s + "Successes  " + ColorValue(IntToString(nCompletions)) +
        "\n" + s + "Failures  " + ColorValue(IntToString(nFailures)) +
        "\n" + s + "Quest Start Time  " + (nQuestStart == 0 ?
            ColorValue(IntToString(nQuestStart), TRUE) :
            ColorValue(FormatUnixTimestamp(nQuestStart, QUEST_TIME_FORMAT))) +
        "\n" + s + "Step STart Time  " + (nStepStart == 0 ?
            ColorValue(IntToString(nStepStart), TRUE) :
            ColorValue(FormatUnixTimestamp(nStepStart, QUEST_TIME_FORMAT))) +
        "\n" + s + "Last Completion Time  " + (nQuestComplete == 0 ?
            ColorValue(IntToString(nQuestComplete), TRUE) :
            ColorValue(FormatUnixTimestamp(nQuestComplete, QUEST_TIME_FORMAT))) +
        "\n" + s + "Last Completion Type  " + ColorValue(StepTypeToString(nLastCompleteType)) +
        "\n" + s + "Quest Version  " + ColorValue(IntToString(nVersion)));

        // Dump step data
        if (nStep == 0)
            Debug(ColorFail("Inactive quest; no step data to report for " + QuestToString(nQuestID)));
        else
        {
            sQuery = "SELECT * " +
                     "FROM quest_pc_step " +
                     "WHERE quest_tag = @sQuestTag;";
            sqlquery sqlStepDump = SqlPrepareQueryObject(oPC, sQuery);
            SqlBindString(sqlStepDump, "@sQuestTag", sQuestTag);

            while (SqlStep(sqlStepDump))
            {
                n = 0;
                string sQuestTag = SqlGetString(sqlStepDump, n);
                int nObjectiveType = SqlGetInt(sqlStepDump, ++n);
                string sTag = SqlGetString(sqlStepDump, ++n);
                string sData = SqlGetString(sqlStepDump, ++n);
                int nRequired = SqlGetInt(sqlStepDump, ++n);
                int nAcquired = SqlGetInt(sqlStepDump, ++n);

                s = GetIndent();
                Debug(ColorTitle(s + "Dumping quest step data for " + 
                    QuestToString(nQuestID) + " " + StepToString(nStep) +
                    " on " + PCToString(oPC)));
                s = Indent();

                Debug( s + "Objective Type  " + ColorValue(ObjectiveTypeToString(nObjectiveType)) +
                "\n" + s + "Tag  " + ColorValue(sTag) +
                "\n" + s + "Data  " + ColorValue(sData) +
                "\n" + s + "Quantity Required  " + ColorValue(IntToString(nRequired)) +
                "\n" + s + "Quantity Acquired  " + ColorValue(IntToString(nAcquired)));
            }
        }
    }
}