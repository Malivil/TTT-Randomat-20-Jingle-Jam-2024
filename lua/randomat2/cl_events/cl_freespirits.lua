local EVENT = {}

EVENT.id = "freespirits"

local roleFaked = false
function EVENT:Begin()
    -- Make sure the Ghost Whisperer is registered so the functionality works
    roleFaked = true
    RegisterRoleHooks(ROLE_GHOSTWHISPERER)
end

function EVENT:End()
    -- Only unregister the role hooks if this event was actually started
    -- We don't want to unregister hooks for a player who is actually this role
    if roleFaked then
        UnregisterRoleHooks(ROLE_GHOSTWHISPERER)
        roleFaked = false
    end
end

Randomat:register(EVENT)