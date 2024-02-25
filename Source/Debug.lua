function Todoloo.Debug.IsActive()
    return Todoloo.Config.Get(Todoloo.Config.Options.DEBUG)
end

function Todoloo.Debug.Message(message, ...)
    if Todoloo.Debug.IsActive() then
        print(GREEN_FONT_COLOR:WrapTextInColorCode("[TODOLOO DEBUG] ") .. message , ...)
    end
end