local EVENT = {}

EVENT.Title = "Free Spirits"
EVENT.Description = "Dead players become empowered spirits capable of talking with the living and using abilities"
EVENT.id = "freespirits"
EVENT.Categories = {"deathtrigger", "spectator", "largeimpact", "eventtrigger"}

local function GhostPlayer(ply)
    ply:QueueMessage(MSG_PRINTBOTH, "'"  ..  Randomat:GetEventTitle(EVENT) .. "' has granted you the ability to talk in chat and use abilities!")
    ply:QueueMessage(MSG_PRINTBOTH, "Select your abilit" .. (cvars.Number("ttt_ghostwhisperer_max_abilities", -1) == 1 and "y" or "ies") .. " in the shop")
    ply:SetProperty("TTTIsGhosting", true, ply)
end

function EVENT:Begin()
    -- If only ghost whisperers can normally read ghost chat, start "deadchat" so everyone can read it instead (if it exists)
    if cvars.Bool("ttt_ghostwhisperer_limited_chat", false) and Randomat.Events["deadchat"] then
        Randomat:SilentTriggerEvent("deadchat", self.owner)
    end

    -- Non-spectator dead players become ghosts immediately
    for _, p in self:GetDeadPlayers(false, false) do
        GhostPlayer(p)
    end

    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        GhostPlayer(ply)
    end)
end

function EVENT:End()
    Randomat:EndActiveEvent("deadchat", true)
    for _, p in player.Iterator() do
        p:ClearProperty("TTTIsGhosting")
    end
end

function EVENT:Condition()
    if cvars.Number("ttt_ghostwhisperer_max_abilities", -1) <= 0 then return false end

    for _, p in player.Iterator() do
        if p:GetRole() == ROLE_GHOSTWHISPERER then return false end
        if p:GetRole() == ROLE_SOULBOUND then return false end
        if p:GetRole() == ROLE_SOULMAGE then return false end
    end

    return true
end

Randomat:register(EVENT)