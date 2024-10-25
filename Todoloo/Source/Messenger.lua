---@class Todoloo
local Todoloo = select(2, ...);

function Todoloo.Messenger.IsActive()
    return Todoloo.Config.Get(Todoloo.Config.Options.MESSENGER);
end

function Todoloo.Messenger.Message(message, ...)
    if Todoloo.Messenger.IsActive() then
        print(GREEN_FONT_COLOR:WrapTextInColorCode("[Todoloo] ") .. message, ...);
    end
end