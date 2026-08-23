local EVENT = {}

EVENT.id = "freespirits"

function EVENT:Begin()
    -- Make sure the Ghost Whisperer is registered so the functionality works
    RegisterRoleHooks(ROLE_GHOSTWHISPERER)
end

Randomat:register(EVENT)