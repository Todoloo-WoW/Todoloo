local currentLocale = {};

---Fill missing translations in the given locale, if any.
local function FillMissingTranslations(incomplete, locale)
    if locale == "enUS" then
        return;
    end

    local default = TODOLOO_LOCALES["enUS"]();
    for key, val in pairs(default) do
        if incomplete[key] == nil then
            incomplete[key] = val;
        end
    end
end

local function ConvertLineBreaks(localeTable)
    for key, val in pairs(localeTable) do
        localeTable[key] = string.gsub(localeTable[key], "\\n", "\n");
    end
end

if TODOLOO_LOCALES[GetLocale()] ~= nil then
    currentLocale = TODOLOO_LOCALES[GetLocale()]();
else
    currentLocale = TODOLOO_LOCALES["enUS"]();
end

ConvertLineBreaks(currentLocale);

--Export translations to global scope for access through frames.
for key, value in pairs(currentLocale) do
    _G["TODOLOO_L_"..key] = value;
end