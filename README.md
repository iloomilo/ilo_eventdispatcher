# ilo_eventdispatcher

A lightweight Lua-based **event dispatcher** designed for modular event handling in FiveM. This module allows you to create custom events, register listeners, and control event propagation.

---

## Features

* **Create events** with custom key-value storage
* **Register listeners** for named events
* **Dispatch events** to all registered listeners
* **Stop propagation** to prevent further listeners from firing
* Simple, lightweight, and extensible

---

## API Reference

### `CreateEvent()` → `EventObject`

Creates a new event object.

**Example:**

```lua
local event = exports['ilo_eventdispatcher']:CreateEvent()
event:set("foo", "bar")
```

---

### `RegisterListener(eventName: string, callback: fun(event: EventObject))`

Registers a listener for the given event name. Multiple listeners can be registered for the same event.

**Example:**

```lua
exports['ilo_eventdispatcher']:RegisterListener("my:event", function(event)
    print("foo is:", event:get("foo"))
end)
```

---

### `DispatchEvent(eventName: string, event: EventObject)`

Dispatches an event to all listeners registered under `eventName`. Listeners are executed in the order they were registered. Propagation can be stopped using `event:stopPropagation()`.

**Example:**

```lua
local event = exports['ilo_eventdispatcher']:CreateEvent()
event:set("foo", "bar")

exports['ilo_eventdispatcher']:DispatchEvent("my:event", event)
```

---

### EventObject Methods

* **`set(key: string, value: any)`** → `nil`
  Store a value inside the event.

* **`get(key: string)`** → `any`
  Retrieve a stored value.

* **`getAll()`** → `table<string, any>`
  Retrieve all stored values.

* **`stopPropagation()`** → `nil`
  Prevents further listeners from being executed.

* **`isPropagationStopped()`** → `boolean`
  Check if propagation has been stopped.

---

**📌 Example Usage:**

Let’s say we want to modify the player’s paycheck based on different conditions across multiple resources.
We dispatch an event that can be listened to anywhere, allowing other resources to adjust the values before the final paycheck is applied
```lua
    --- Send paycheck to a player
    --- @param player Player Player object
    --- @param payment number Payment amount
    sendPaycheck = function(player, payment)
        local event = exports['ilo_eventdispatcher']:CreateEvent()
        event:set('player', player)
        event:set('payment', payment)

        -- Dispatch paycheck event
        exports['ilo_eventdispatcher']:DispatchEvent('qbx_core:sendPaycheck', event)

        -- Get potentially modified payment value
        payment = event:get('payment')

        if payment <= 0 then return end

        player.Functions.AddMoney('bank', payment)
        Notify(player.PlayerData.source, locale('info.received_paycheck', payment))
    end
```
Now, you can listen for this event in any resource and modify the paycheck amount dynamically:
```lua
--- Example: Add extra payment if player is on shop duty
--- @param event EventObject
exports['ilo_eventdispatcher']:RegisterListener('qbx_core:sendPaycheck', function(event)
    local currentPayment = event:get('payment')
    --- @type Player
    local player = event:get('player')

    if player.PlayerData.source ~= nil then
        local src = player.PlayerData.source

        if IsShopDuty(src) then
            currentPayment = currentPayment + config.payCheck

            -- Update event payment value
            event:set('payment', currentPayment)
        end
    end
end)
```

---

## Installation

1. Add the file to your resource.
2. Ensure it is properly loaded.
3. Use the exported functions in your scripts.

---

## License

This project is released under the **MIT License**. You are free to use, modify, and distribute it.
