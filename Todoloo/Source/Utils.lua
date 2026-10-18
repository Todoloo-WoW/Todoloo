---Split string into string array
---@param array string String contianing multiple values split by the provided delimiter
---@param delimiter string? Delimiter (if not provided, defaults to ",")
---@return string[] # Array of string split by the provided delimiter
function Todoloo.Utils.SplitStringArray(array, delimiter)
    delimiter = delimiter or ",";
    return {strsplit(delimiter, array)};
end

---Check if the given string value exists in the given string array table
---@param array table Table in question
---@param value string Value in question
---@return boolean # True if exists, false otherwise
function Todoloo.Utils.StringArrayContains(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true;
        end
    end

    return false;
end

---Get the index of the given value in the string array
---@param array string[] The string array in question
---@param value string The value in question
---@return integer|nil # Index of the given value if found, else nil
function Todoloo.Utils.StringArrayIndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i;
        end
    end

    return nil;
end

function Todoloo.Utils.GetTaskDisplayText(task)
    if task.target > 1 then
        return string.format("%d/%d %s", task.progress, task.target, task.name)
    end

    return task.name
end

---Get the player name including realm (will return in form "Detílium-ShatteredHand")
---@return string characterFullName In format "Player-Realm"
function Todoloo.Utils.GetCharacterFullName()
    local characterName = UnitName("player");
    local realmName = GetNormalizedRealmName();
    return characterName .. "-" .. realmName;
end

---Split slash command
---@param input string Command
---@return string[] # Seperated command arguments
function Todoloo.Utils.SplitCommand(input)
    local result = {};

    for match in string.gmatch(input:lower(), "%S+") do
        table.insert(result, match);
    end

    return result;
end

function Todoloo.Utils.Slice(array, start, count)
    local result = {}

    for index = start, math.min(#array, start + count - 1) do
      table.insert(result, array[index])
    end

    return result
end

function Todoloo.Utils.ShowTaskTooltip(owner, task)
    Todoloo.Utils.HideTaskTooltip(owner)

    local description = task and task.description
    if not description or not description:find("%S") then
        return
    end

    if not owner.todolooTaskTooltipHooked then
        owner:HookScript("OnHide", Todoloo.Utils.HideTaskTooltip)
        owner.todolooTaskTooltipHooked = true
    end

    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip_SetTitle(GameTooltip, task.name, NORMAL_FONT_COLOR, true)
    GameTooltip:AddLine(description, 1, 1, 1, true)
    GameTooltip:Show()
end

function Todoloo.Utils.HideTaskTooltip(owner)
    if GameTooltip:GetOwner() == owner then
        GameTooltip:Hide()
    end
end