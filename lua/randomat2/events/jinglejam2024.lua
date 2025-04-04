local player = player
local table = table

local EVENT = {}

EVENT.Title = "Jingle Jam 2024"
EVENT.Description = "You've joined a jam band! Each player was assigned a random instrument\nShoot to play, aim up and down to change notes"
EVENT.id = "jinglejam2024"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

function EVENT:Begin()
    local currentInstrument = 1
    local instruments = Randomat.JingleJam2024.GetInstruments()
    local maxInstruments = table.Count(instruments)
    -- Shuffle the instrument list so we get a different group of instruments every time
    table.Shuffle(instruments)
    for _, ply in player.Iterator() do
        local instrument = instruments[currentInstrument]
        ply:SetNWString("RdmtJingleJam2024Instrument", instrument)

        -- Tell the player their instrument
        timer.Simple(0.1, function()
            Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You have the " .. instrument)
        end)

        currentInstrument = currentInstrument + 1
        -- Loop through the instruments repeatedly
        if currentInstrument > maxInstruments then
            currentInstrument = 1
        end
    end

    self:AddHook("EntityEmitSound", function(data)
        if Randomat.JingleJam2024.ShouldIgnoreSound(data.SoundName:lower()) then return end
        if not IsPlayer(data.Entity) then return end

        local aim = data.Entity:EyeAngles()
        aim:Normalize()

        -- Negate the pitch because in GMod looking down is positive and looking up is negative
        local pitch = -aim.pitch
        -- Normalize the pitch to within 0-180 for easier indexing
        pitch = pitch + 90

        local chosen_sound = Randomat.JingleJam2024.GetWeaponSound(data.Entity, pitch)
        data.SoundName = chosen_sound
        return true
    end)
end

Randomat:register(EVENT)