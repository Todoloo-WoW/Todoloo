function Todoloo.Config.Show()
    if Settings and SettingsPanel then
        Settings.OpenToCategory("Todoloo")
    elseif InterfaceOptionsFrame ~= nil then
        InterfaceOptionsFrame:Show()
        InterfaceOptionsFrame_OpenToCategory("Todoloo")
    end
end