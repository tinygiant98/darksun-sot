string AlignmentToString(int nAlignment)
{
    switch (nAlignment)
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

    return "[NOT FOUND]";
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

string ColorValue(string sValue)
{
    if (sValue == "" )
        return HexColorString("[EMPTY]", COLOR_GRAY);
    else if (sValue == "[NOT FOUND]")
        return HexColorString(sValue, COLOR_RED_LIGHT);
    else
        return HexColorString(sValue, COLOR_BLUE_LIGHT);
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
            case QUEST_VALUE_FACTION: return "FACTION";
            case QUEST_VALUE_MESSAGE: return "MESSAGE";
            case QUEST_VALUE_QUEST_STEP: return "QUEST_STEP";
        }
    }
    else
        return ObjectiveTypeToString(nValueType);

    return "[NOT FOUND]";
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

string StepOrderToString(int nStepOrder)
{
    switch (nStepOrder)
    {
        case QUEST_STEP_ORDER_SEQUENTIAL: return "SEQUENTIAL";
        case QUEST_STEP_ORDER_RANDOM: return "RANDOM";
    }

    return "[NOT FOUND]";
}

string QuestToString(int nQuestID)
{
    string sTag = GetQuestTag(nQuestID);

    if (sTag == "")
        return "[NOT FOUND]";

    return HexColorString(sTag + " (ID " + IntToString(nQuestID) + ")", COLOR_ORANGE_LIGHT);
}

string TranslateCategoryValue(int nCategoryType, int nValueType, string sKey, int nValue)
{
    string sIndent = "            ";
    string sDelimiter = HexColorString(" | ", COLOR_GRAY);
    string sValue;

    string sCategory = HexColorString(CategoryTypeToString(nCategoryType), COLOR_GREEN_LIGHT);
    string sValueType = ColorValue(ValueTypeToString(nValueType, nCategoryType));

    if (nCategoryType != QUEST_CATEGORY_OBJECTIVE)
    {
        switch (nValueType)
        {
            case QUEST_VALUE_ALIGNMENT:
                sKey = AlignmentToString(StringToInt(sKey));
                if (nValue == 0)
                    sValue = "Any";
                break;
            case QUEST_VALUE_CLASS:
                sKey = ClassToString(StringToInt(sKey));
                if (nValue == -1)
                    sValue = "Any";
                else if (nValue == 0)
                    sValue = "Excluded";
                else
                    sValue = ">= " + IntToString(nValue) + " level" + (nValue == 1 ? "" : "s");
                break;
            case QUEST_VALUE_RACE:
                sKey = RaceToString(StringToInt(sKey));
                if (nValue == 1)
                    sValue = "Included";
                else
                    sValue = "Excluded";
                break;
            case QUEST_VALUE_GOLD:
                sKey = " ";
                sValue = IntToString(nValue) + "gp";
                break;
            case QUEST_VALUE_LEVEL_MAX:
                sKey = " ";
                sValue = "<= " + IntToString(nValue);
                break;
            case QUEST_VALUE_LEVEL_MIN:
                sKey = " ";
                sValue = ">= " + IntToString(nValue);
                break;
            case QUEST_VALUE_ITEM:
                sValue = ">= " + IntToString(nValue);
                break;
            case QUEST_VALUE_XP:
                sKey = " ";
                sValue = IntToString(nValue) + "xp";
                break;
        }
    }
    else
    {

    }

    if (sKey != " ")
        sKey = ColorValue(sKey);

    if (sValue == "")
        sValue = IntToString(nValue);

    sValue = ColorValue(sValue);

    return
        sIndent + sCategory + sDelimiter + sValueType + sDelimiter +
        (sKey != " " ? sKey + sDelimiter : "") +
        sValue;
}

string TranslateValue(int nValueType, string sKey, string sValue)
{
    string sValueType;
    string sKeyTitle;
    string sValueTitle;
    
    string sIndent = "   ";
    string sDelimiter = HexColorString(" | ", COLOR_GRAY);

    sValueType = HexColorString(ValueTypeToString(nValueType), COLOR_GREEN_LIGHT);
    switch (nValueType)
    {
        case QUEST_VALUE_ALIGNMENT:
            sKey = AlignmentToString(StringToInt(sKey));
            if (sValue == "0")
                sValue = "Any";
            break;
        case QUEST_VALUE_CLASS:
            sKey = ClassToString(StringToInt(sKey));
            if (sValue == "-1")
                sValue = "Any";
            else if (sValue == "0")
                sValue = "Excluded";
            else
                sValue = ">= " + sValue + " level" + (sValue == "1" ? "" : "s");
            break;
        case QUEST_VALUE_RACE:
            sKey = RaceToString(StringToInt(sKey));
            if (sValue == "1")
                sValue = "Included";
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
            sValue = ">= " + sValue;
            break;
        case QUEST_VALUE_XP:
            sKey = " ";
            sValue += "xp";
            break;
    }

    if (sKey != " ")
        sKey = ColorValue(sKey);

    sValue = ColorValue(sValue);

    return
        sIndent + sValueType + sDelimiter +
        (sKey != " " ? sKey + sDelimiter : "") +
        sValue;
}
