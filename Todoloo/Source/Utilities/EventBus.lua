-- *****************************************************************************************************
-- ***** EVENT BUS
-- *****
-- ***** This file is highly inspired by plusmouse and Auctionator. A bug thanks goes out to you
-- ***** for providing the idea of a custom event bus.
-- *****************************************************************************************************

TodolooEventBusMixin = {}

function TodolooEventBusMixin:Init()
    self.registeredListeners = {}
    self.sources = {}
    self.queue = {}
end

---Register event source
---@param source any Source of events
---@param name string Source name
function TodolooEventBusMixin:RegisterSource(source, name)
    self.sources[source] = name

    return self
end

---Unregister event source
---@param source any Source of events
function TodolooEventBusMixin:UnregisterSource(source)
    self.sources[source] = nil

    return self
end

---Is the given source of events currently registered?
---@param source any Source of events
---@return boolean # True if registered, false otherwise
function TodolooEventBusMixin:IsSourceRegistered(source)
    return self.sources[source] ~= nil
end

---Register multiple events to the given listener
---@param listener any Listener to register
---@param eventNames string[] List of events to register the listener to
function TodolooEventBusMixin:RegisterEvents(listener, eventNames)
    if listener.ReceiveEvent == nil then
        error("Attempted to register and invalid listener. 'ReceiveEvent' method must be defined.")
        return self
    end

    for _, eventName in ipairs(eventNames) do
        if self.registeredListeners[eventName] == nil then
            self.registeredListeners[eventName] = {}
        end

        table.insert(self.registeredListeners[eventName], listener)
    end

    return self
end

---Register a single event to the given listener
---@param listener any Listener to register
---@param eventName string Event name to register the listener to
function TodolooEventBusMixin:RegisterEvent(listener, eventName)
    if listener.ReceiveEvent == nil then
        error("Attempted to register and invalid listener. 'ReceiveEvent' method must be defined.")
        return self
    end

    if self.registeredListeners[eventName] == nil then
        self.registeredListeners[eventName] = {}
    end

    table.insert(self.registeredListeners[eventName], listener)

    return self
end

---Unregister multiple events from the given listener
---@param listener any Listener to unregister
---@param eventNames string[] List of events to unregister the listener from
function TodolooEventBusMixin:UnregisterEvents(listener, eventNames)
    for _, eventName in ipairs(eventNames) do
        local index = tIndexOf(self.registeredListeners[eventName], listener)
        if index ~= nil then
            table.remove(self.registeredListeners[eventName], index)
        end
    end

    return self
end

---Unregister a single event from the given listener
---@param listener any Listener to unregister
---@param eventName string Event to unregsiter the listener from
function TodolooEventBusMixin:UnregisterEvent(listener, eventName)
    for _, eventName in ipairs(eventNames) do
        local index = tIndexOf(self.registeredListeners[eventName], listener)
        if index ~= nil then
            table.remove(self.registeredListeners[eventName], index)
        end
    end

    return self
end

---Fire event from the given source
---@param source any Event source registered
---@param eventName string Name of the event to fire
---@param ... any Event data
function TodolooEventBusMixin:FireEvent(source, eventName, ...)
    if self.source[source] == nil then
        error("Trying to trigger event (" .. eventName .. ") from an unregistered source. All events sources must be registered.")
    end

    if self.registeredListeners[eventName] == nil then
        -- no active listener
        return self
    end

    for _, listener in ipairs(self.registeredListeners[eventName]) do
        listener:ReceiveEvent(eventName, ...)
    end

    return self
end

Todoloo.EventBus = CreateAndInitFromMixin(TodolooEventBusMixin)