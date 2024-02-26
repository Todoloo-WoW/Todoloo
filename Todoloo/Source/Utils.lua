function Todoloo.Utils.SplitStringArray(array, delimiter)
    delimiter = delimiter or ","
    return {strsplit(delimiter, array)}
end

---Get the player name including realm (will return in form "Detílium-ShatteredHand")
---@return string characterFullName In format "Player-Realm"
function Todoloo.Utils.GetCharacterFullName()
    local characterName, realmName = UnitFullName("player")
    return characterName .. "-" .. realmName
end