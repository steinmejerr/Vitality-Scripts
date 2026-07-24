# Prompt Prison Escape - Documentation

## Overview

This script provides an **immersive toilet-based cell escape minigame** for FiveM prison servers. Players must unscrew 4 screws from a toilet tank cover to reveal an escape route. The script features:

- Custom animations (enter, work, exit sequences)
- Interactive screw removal minigame with cursor-based mechanics
- Persistent progress (screws remain unscrewed if player leaves)
- Support for multiple interaction systems (ox_target, qb-target, textUI)
- Support for inventory systems (ox_inventory, qb-inventory)

---

## Table of Contents

1. [Dependencies](#dependencies)
2. [How the Script Works](#how-the-script-works)
3. [Configuration Files](#configuration-files)
4. [Integration with Prison/Jail Systems](#integration-with-prisonjail-systems)
5. [Exports and Events Reference](#exports-and-events-reference)
6. [Customization Guide](#customization-guide)
7. [Common Integration Examples](#common-integration-examples)

---

## Dependencies

| Dependency | Required | Purpose |
|------------|----------|---------|
| `ox_lib` | ✅ Yes | Core utilities, zones, callbacks, UI, keybinds |
| `ox_target` | ⚪ Optional | Target interaction system |
| `qb-target` | ⚪ Optional | QB-Core target interaction |
| `ox_inventory` | ⚪ Optional | Item requirement checking |
| `qb-inventory` | ⚪ Optional | QB-Core inventory checking |

---

## How the Script Works

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRISON ESCAPE FLOW                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────────┐     ┌───────────────────────────────┐
│ Player enters│────▶│ Interaction      │────▶│ Server validates:             │
│ prison zone  │     │ enabled on       │     │ - isPlayerInPrison(source)    │
│              │     │ toilet models    │     │ - Distance check              │
└──────────────┘     └──────────────────┘     └───────────────┬───────────────┘
                                                              │
                      ┌───────────────────────────────────────┘
                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ TOILET OBJECT CREATION                                                       │
│ • Server creates networked toilet object with state `isPrisonToilet`         │
│ • Original toilet is hidden (visibility + collision disabled)                │
│ • Player assigned as "owner" of this toilet instance                         │
└─────────────────────────────────────┬────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ ENTER ANIMATION                                                              │
│ • Player sits on toilet (animation: promt@jail_3 → jail_enter_ped)           │
│ • Screwdriver attached to hand                                               │
│ • Player attached to toilet entity                                           │
└─────────────────────────────────────┬────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ SCREW SELECTION UI                                                           │
│ • NUI shows 4 screws (top-left, bottom-left, top-right, bottom-right)        │
│ • Already unscrewed screws are grayed out                                    │
│ • Navigate with scroll wheel or arrow keys                                   │
│ • Confirm with E/Enter, Cancel with X/Backspace                              │
└─────────────────────────────────────┬────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ SCREW MINIGAME                                                               │
│ • Camera zooms to selected screw                                             │
│ • Player must hover cursor over screw (yellow outline)                       │
│ • Hold left mouse button to unscrew (green outline, animation plays)         │
│ • Release to pause progress                                                  │
│ • Press R to switch camera view (overview)                                   │
│ • Press X to cancel and exit                                                 │
└─────────────────────────────────────┬────────────────────────────────────────┘
                                      │
                     ┌────────────────┴────────────────┐
                     ▼                                 ▼
          ┌─────────────────┐               ┌─────────────────────┐
          │ Screw completed │               │ Player cancels (X)  │
          │ - Save to server│               │ - Progress saved    │
          │ - Repeat for    │               │ - 10min cleanup     │
          │   remaining 4   │               │   timer starts      │
          └────────┬────────┘               └─────────────────────┘
                   │
                   ▼ (when all 4 complete)
┌──────────────────────────────────────────────────────────────────────────────┐
│ ESCAPE SEQUENCE                                                              │
│ • Prompt: Press E to escape, X to cancel                                     │
│ • Exit animations play (opening hatch, crawling out, closing hatch)          │
│ • Toilet object deleted, original restored                                   │
│ • Server callback: prompt_prison_escape:completeEscape                       │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Key Components

| File | Purpose |
|------|---------|
| `client/main.lua` | Prison zone setup, starts interaction |
| `client/editable/interaction.lua` | Handles target/textUI interaction setup |
| `client/minigame/screw_game.lua` | Core minigame logic |
| `client/minigame/camera_manager.lua` | Camera transitions |
| `client/minigame/animation_controller.lua` | Animation playback |
| `server/server.lua` | Toilet management, progress persistence |
| `config/config_c.lua` | Client configuration |
| `config/config_s.lua` | Server configuration |

---

## Configuration Files

### Client Config (`config/config_c.lua`)

```lua
return {
    -- Interaction system: 'auto' | 'ox_target' | 'qb-target' | 'textUI' | 'custom'
    interaction = 'auto',
    
    -- Item required to start (empty string = no requirement)
    -- Works with ox_inventory or qb-inventory
    requiredItem = '',
    
    -- UI location for screw selection
    -- 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right' | 'middle-left' | 'middle-right' | 'center'
    uiLocation = 'middle-left',
    
    -- TextUI functions (customize for your framework)
    textUI = {
        hide = function()
            lib.hideTextUI()
        end,
        show = function(text)
            lib.showTextUI(text)
        end,
    },
    
    -- Toilet model settings
    toilet = {
        screwOffsets = { ... },           -- Screw positions (don't modify)
        screwModel = joaat('prompt_prison_screw'),
        screwDriverModel = joaat('v_ind_cs_screwdrivr3'),
        useNetworkedObjects = false       -- Set true if NOT using entity lockdown
    }
}
```

### Server Config (`config/config_s.lua`)

```lua
return {
    debug = true,  -- Enable debug logging
    
    -- ⚠️ CRITICAL INTEGRATION POINT ⚠️
    -- This function determines if a player can use the escape mechanic
    -- Return TRUE to allow, FALSE to deny
    isPlayerInPrion = function(source)
        return true  -- Default: always allow (replace with your jail system check)
    end
}
```

---

## Integration with Prison/Jail Systems

### 🔑 The Main Integration Point

The **most important** file for integration is `config/config_s.lua`. The `isPlayerInPrison` function is called server-side whenever a player attempts to start the escape minigame.

### Integration Examples

#### Generic Framework (ESX/QBCore/Custom)

```lua
-- config/config_s.lua

return {
    debug = false,
    
    isPlayerInPrion = function(source)
        -- Example: Check if player has "prisoner" job
        local Player = YourFramework.GetPlayer(source)
        if not Player then return false end
        
        local job = Player.job.name
        return job == 'prisoner' or job == 'inmate'
    end
}
```

#### qb-prison Integration

```lua
-- config/config_s.lua

return {
    debug = false,
    
    isPlayerInPrion = function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        -- Check if player is in prison (has jail time remaining)
        local jailTime = Player.PlayerData.metadata['injail']
        return jailTime and jailTime > 0
    end
}
```

#### esx_jail / esx_prison Integration

```lua
-- config/config_s.lua

return {
    debug = false,
    
    isPlayerInPrion = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        -- Check jail metadata or job
        local jailTime = xPlayer.get('jailTime') or 0
        return jailTime > 0
    end
}
```

#### ND_Jail Integration

```lua
-- config/config_s.lua

return {
    debug = false,
    
    isPlayerInPrion = function(source)
        return exports['ND_Jail']:isPlayerJailed(source)
    end
}
```

#### Custom Database Check

```lua
-- config/config_s.lua

return {
    debug = false,
    
    isPlayerInPrion = function(source)
        local identifier = GetPlayerIdentifier(source, 0)
        local result = MySQL.Sync.fetchScalar(
            'SELECT jail_time FROM players WHERE identifier = ?',
            {identifier}
        )
        return result and result > 0
    end
}
```

---

## Exports and Events Reference

### Server Callbacks (lib.callback)

These are the internal callbacks used by the script. You can monitor or hook into these for extended functionality:

| Callback | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `prompt_prison_escape:createToiletObject` | `coords (vector4)` | `netID` or `nil` | Creates/claims toilet object |
| `prompt_prison_escape:unscrewProgress` | `screwIndex (1-4)` | `boolean` | Saves screw removal progress |
| `prompt_prison_escape:getUnscrewedState` | none | `table` | Returns array of unscrewed screw indices |
| `prompt_prison_escape:completeEscape` | none | `boolean` | Called when player successfully escapes |
| `prompt_prison_escape:stopSitting` | none | `boolean` | Called when player cancels/exits |

### Client Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `prompt_prison_escape:toggleToiletVisibility` | `toggle, coords, id` | Shows/hides original toilet models |

### Hooking Into Escape Completion

If you want to trigger actions when a player escapes (e.g., reduce jail time, alert guards, add wanted level), you can modify the server callback:

```lua
-- In your own server script, override or hook the callback

-- Option 1: Add a handler that fires after escape
AddEventHandler('prompt_prison_escape:playerEscaped', function(source)
    -- Your custom logic here
    print('Player ' .. source .. ' escaped from prison!')
    
    -- Example: Add wanted level
    TriggerClientEvent('yourPoliceScript:setWanted', source, 3)
    
    -- Example: Remove from jail in your system
    exports['your_jail_system']:releasePlayer(source)
end)

-- Then in config_s.lua, add to completeEscape callback (or wrap it):
-- TriggerEvent('prompt_prison_escape:playerEscaped', source)
```

---

## Customization Guide

### Adding Custom Interaction System

In `client/editable/interaction.lua`, there's a `custom` interaction type you can implement:

```lua
-- client/editable/interaction.lua

-- Find the 'custom' sections and add your logic:

elseif interaction == 'custom' then
    -- SETUP: Called when player enters prison zone
    -- onUse(entity) should be called when player interacts with toilet
    
    -- Example: Custom proximity prompt
    exports['your_interact_system']:AddInteraction({
        model = toiletHash,
        label = locale('interaction_label'),
        action = function(entity)
            onUse(entity)
        end
    })
end

-- And in cleanup:
elseif interaction == 'custom' then
    -- CLEANUP: Called when player leaves prison zone
    exports['your_interact_system']:RemoveInteraction(toiletHash)
end
```


### Requiring an Item

Set the `requiredItem` in client config to require players have a specific item:

```lua
-- config/config_c.lua

requiredItem = 'screwdriver',  -- Player must have this item
```

This works automatically with `ox_target` and `qb-target` (checks inventory before showing option).

### Custom TextUI Framework

Replace the textUI functions in `config/config_c.lua`:

```lua
-- config/config_c.lua

textUI = {
    hide = function()
        -- Your framework's hide function
        exports['your_ui']:HideTextUI()
    end,
    show = function(text)
        -- Your framework's show function
        exports['your_ui']:ShowTextUI(text)
    end,
},
```

---

## Common Integration Examples

### Full Integration: qb-prison + qb-target + qb-inventory

```lua
-- config/config_s.lua
return {
    debug = false,
    isPlayerInPrion = function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.PlayerData.metadata['injail'] > 0
    end
}

-- config/config_c.lua  
return {
    interaction = 'qb-target',
    requiredItem = 'lockpick', -- Optional: require lockpick
    -- ... rest of config
}
```

### Full Integration: ESX + ox_target + ox_inventory

```lua
-- config/config_s.lua
return {
    debug = false,
    isPlayerInPrion = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.get('inJail') == true
    end
}

-- config/config_c.lua
return {
    interaction = 'ox_target',
    requiredItem = 'screwdriver',
    -- ... rest of config
}
```

### Triggering Events After Escape

Add to the end of `prompt_prison_escape:completeEscape` callback in `server/server.lua`:

```lua
-- After the existing code in completeEscape callback, before the return:

-- Notify your jail system
TriggerEvent('yourJailSystem:playerEscaped', source)

-- Or directly modify jail time
local Player = YourFramework.GetPlayer(source)
if Player then
    Player.Functions.SetMetaData('injail', 0)
end

-- Alert police
TriggerEvent('yourDispatch:prisonEscape', source, toilet.coords)
```

---

## What This Script Does NOT Handle

This script is **cell escape only**. For a complete prison escape experience, you'll need to add:

| Feature | Suggested Implementation |
|---------|-------------------------|
| 🚨 Guard alerts | Trigger dispatch/police notification on `completeEscape` |
| 🗺️ Escape routes | Add waypoints/tunnels after escaping the cell |
| ⏱️ Jail time reduction | Modify your jail system's time in `completeEscape` |
| 🔒 Lockdown mode | Check a global state in `isPlayerInPrison` to prevent escapes |
| 👮 Guard NPCs | Separate guard AI script with patrol routes |
| 📍 Recapture zones | Add zones outside prison that return escaped players |
| 🎒 Contraband items | Item spawning/finding system for the screwdriver |

---

## Troubleshooting

### "Failed to create toilet object"
- Check that `isPlayerInPrison` returns `true` for the player
- Verify player is within 200m of the prison center
- Check server console for error messages

### Interaction not showing
- Verify you're using the correct toilet models (`prompt_prison_toilet_withscrew`, `prompt_prison_toilet`)
- Check that your interaction system is properly detected (auto mode) or configured
- Ensure player is inside the prison zone polygon

### Progress not saving
- Verify ox_lib callbacks are working
- Check server console for callback errors
- Ensure resource has proper permissions

---

## File Structure Reference

```
prompt_prison_escape/
├── client/
│   ├── main.lua                 # Zone setup, game initialization
│   ├── events.lua               # Toilet visibility syncing
│   ├── utils.lua                # Cursor detection utilities
│   ├── editable/
│   │   └── interaction.lua      # Interaction system (EDITABLE)
│   └── minigame/
│       ├── screw_game.lua       # Core minigame logic
│       ├── camera_manager.lua   # Camera control
│       └── animation_controller.lua  # Animation handling
├── config/
│   ├── config_c.lua             # Client config (EDITABLE)
│   └── config_s.lua             # Server config (EDITABLE - MAIN INTEGRATION POINT)
├── server/
│   └── server.lua               # Toilet management, callbacks
├── locales/
│   ├── en.json                  # English translations
│   ├── de.json                  # German
│   ├── es.json                  # Spanish
│   ├── fr.json                  # French
│   └── pl.json                  # Polish
├── stream/
│   └── *.ycd                    # Custom animations
├── web/
│   └── ...                      # NUI for screw selection UI
└── fxmanifest.lua               # Resource manifest
```

---

## Summary

To integrate this script with your server:

1. **Required**: Modify `config/config_s.lua` → `isPlayerInPrison(source)` to check your jail system
2. **Optional**: Set `config/config_c.lua` → `interaction` to your preferred system
3. **Optional**: Set `config/config_c.lua` → `requiredItem` if you want item requirements
4. **Optional**: Hook into `prompt_prison_escape:completeEscape` for escape consequences
5. **Optional**: Modify the zone polygon in `client/main.lua` for custom prison locations

The script handles **cell escape only** - players unscrew a toilet and crawl out. Everything after (guard alerts, recapture, jail time, etc.) should be handled by your existing prison system or additional scripts.


## tk_jail Integration (added)

This version includes direct server-side support for `tk_jail`.

- `exports.tk_jail:getSentence(source)` verifies that the player has an active sentence before the escape interaction can start.
- `exports.tk_jail:unjail(tostring(source), false)` releases the player after a successful escape without teleporting them away from the escape location.
- Settings are available in `config/config_s.lua` under `tkJail`.

Set `releaseOnEscape = false` if the escape should only trigger the `prompt_prison_escape:playerEscaped` event without automatically releasing the player from `tk_jail`.
