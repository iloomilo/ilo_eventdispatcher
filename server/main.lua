---@class EventObject
---@field set fun(self: EventObject, key: string, value: any)
---@field get fun(self: EventObject, key: string): any
---@field getAll fun(self: EventObject): table<string, any>
---@field stopPropagation fun(self: EventObject)
---@field isPropagationStopped fun(self: EventObject): boolean

local listeners = {} ---@type table<string, fun(event: EventObject)[]>

function CreateEvent()
    local store = {} ---@type table<string, any>
    local stopped = false

    ---@type EventObject
    local event = {
        set = function(self, key, value)
            store[key] = value
        end,

        get = function(self, key)
            return store[key]
        end,

        getAll = function(self)
            return store
        end,

        stopPropagation = function(self)
            stopped = true
        end,

        isPropagationStopped = function(self)
            return stopped
        end
    }

    return event
end
exports('CreateEvent', CreateEvent)

---@param eventName string
---@param callback fun(event: EventObject)
function RegisterListener(eventName, callback)
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    table.insert(listeners[eventName], callback)
end
exports('RegisterListener', RegisterListener)

---@param eventName string
---@param event EventObject
function DispatchEvent(eventName, event)
    local eventListeners = listeners[eventName]
    if not eventListeners then return end
    for _, callback in ipairs(eventListeners) do
        callback(event)
        if event:isPropagationStopped() then
            break
        end
    end
end
exports('DispatchEvent', DispatchEvent)