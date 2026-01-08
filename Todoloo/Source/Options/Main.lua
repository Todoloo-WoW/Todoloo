function Todoloo.Config.Show()
    if Settings and SettingsPanel then
        Settings.OpenToCategory(Todoloo.Config.Category:GetID());
    elseif InterfaceOptionsFrame ~= nil then
        InterfaceOptionsFrame:Show();
        InterfaceOptionsFrame_OpenToCategory("Todoloo");
    end
end