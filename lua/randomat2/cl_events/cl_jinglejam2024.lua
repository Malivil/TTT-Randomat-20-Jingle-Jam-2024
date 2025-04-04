local EVENT = {}

EVENT.id = "jinglejam2024"

function EVENT:Begin()
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