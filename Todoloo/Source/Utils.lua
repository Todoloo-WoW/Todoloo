local _, Todoloo = ...

---Split string into string array
---@param array string String contianing multiple values split by the provided delimiter
---@param delimiter string? Delimiter (if not provided, defaults to ",")
---@return string[] # Array of string split by the provided delimiter
function Todoloo.Utils.SplitStringArray(array, delimiter)
    delimiter = delimiter or ","
    return {strsplit(delimiter, array)}
end

---Check if the given string value exists in the given string array table
---@param array table Table in question
---@param value string Value in question
---@return boolean # True if exists, false otherwise
function Todoloo.Utils.StringArrayContains(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end

    return false
end

---Get the index of the given value in the string array
---@param array string[] The string array in question
---@param value string The value in question
---@return integer|nil # Index of the given value if found, else nil
function Todoloo.Utils.StringArrayIndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end

    return nil
end

---Get the player name including realm (will return in form "Detílium-ShatteredHand")
---@return string characterFullName In format "Player-Realm"
function Todoloo.Utils.GetCharacterFullName()
    local characterName, realmName = UnitFullName("player")
    return characterName .. "-" .. realmName
end