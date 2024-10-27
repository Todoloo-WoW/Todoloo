function Todoloo.Messenger.IsActive()
    return Todoloo.Config.Get(Todoloo.Config.Options.MESSENGER);
end

function Todoloo.Messenger.Message(message, ...)
    if Todoloo.Messenger.IsActive() then
        print(LIGHTBLUE_FONT_COLOR:WrapTextInColorCode("Todoloo: ") .. message, ...);
    end
end

function Todoloo.Messenger.SlashMessage(message, ...)
    print(LIGHTBLUE_FONT_COLOR:WrapTextInColorCode("Todoloo: ") .. message, ...);
end