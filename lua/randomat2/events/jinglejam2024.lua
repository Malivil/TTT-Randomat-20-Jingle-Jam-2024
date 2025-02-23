local math = math
local string = string
local util = util

local StringFind = string.find
local StringReplace = string.Replace
local MathCeil = math.ceil

local EVENT = {}

EVENT.Title = "Jingle Jam 2024"
EVENT.Description = "You've joined a jam band! Each player was assigned a random instrument"
EVENT.id = "jinglejam2024"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

-- Instruments toward the start of this list will be used more often than the ones at the end
local sounds = {
    Guitar = {
        "GuitarC.mp3", "GuitarD.mp3", "GuitarE.mp3", "GuitarF.mp3", "GuitarG.mp3", "GuitarA.mp3",
        "GuitarHeavyELow.mp3", "GuitarHeavyA.mp3", "GuitarHeavyG.mp3", "GuitarHeavyEHigh.mp3", "GuitarHeavyPluck.mp3", "GuitarHeavyPluck2.mp3"
    },
    ["Bass Guitar"] = {
        "BassC.mp3", "BassD.mp3", "BassE.mp3", "BassF.mp3", "BassG.mp3", "BassA.mp3",
        "ElectricBassC.mp3", "ElectricBassD.mp3", "ElectricBassE.mp3", "ElectricBassF.mp3", "ElectricBassG.mp3", "ElectricBassB.mp3"
    },
    Drums = {
        "Kick.mp3", "Kick2.mp3", "ConcertTom.mp3", "FloorTom.mp3", "Tom.mp3", "Snare.mp3",
        "Snare2.mp3", "HiHat.mp3", "CymbalCrash.mp3", "CymbalShort.mp3", "CymbalMedium.mp3", "CymbalLong.mp3"
    },
    ["Acoustic Guitar"] = {
        "AcousticC.mp3", "AcousticD.mp3", "AcousticE.mp3", "AcousticF.mp3", "AcousticG.mp3", "AcousticA.mp3",
        "NylonBMinor.mp3", "NylonDflatMinor.mp3", "NylonEMajor.mp3", "NylonFsharpMaj9.mp3", "NylonFsharpMinor.mp3", "NylonAflatMajor.mp3"
    },
    Piano = {
        "PianoA.mp3", "PianoGSharp.mp3", "PianoBFlat.mp3", "PianoB.mp3", "PianoC.mp3", "PianoCSharp.mp3",
        "PianoD.mp3", "PianoEFlat.mp3", "PianoE.mp3", "PianoF.mp3", "PianoFSharp.mp3", "PianoG.mp3"
    }
}
local soundsFolder = {}
local ignorePaths = {
    ".*weapons/.*explode.*%..*", ".*weapons/.*beep.*%..*",
    ".*weapons/.*out%..*", ".*weapons/.*in%..*",
    ".*weapons/.*reload.*%..*", ".*weapons/.*deploy.*%..*",
    ".*weapons/.*insertshell.*%..*", ".*weapons/.*selectorswitch.*%..*",
    ".*weapons/.*fetchmag.*%..*", ".*weapons/.*magslap.*%..*",
    ".*weapons/.*beltjingle.*%..*", ".*weapons/.*beltalign.*%..*",
    ".*weapons/.*lidopen.*%..*", ".*weapons/.*lidclose.*%..*",
    ".*weapons/.*coverup.*%..*", ".*weapons/.*coverdown.*%..*",
    ".*weapons/.*rattle.*%..*", ".*weapons/.*slidepull.*%..*",
    ".*weapons/.*slideback.*%..*", ".*weapons/.*sliderelease.*%..*",
    ".*weapons/.*bolt.*%..*", ".*weapons/.*shotgun_shell.*%..*",
    ".*weapons/.*empty.*%..*", ".*weapons/.*zoom.*%..*"
}

local function GetWeaponSound(ply, pitch)
    local instrument = ply:GetNWString("RdmtJingleJam2024Instrument", "")
    if #instrument == 0 then return end

    local index = MathCeil(pitch / 15)
    return soundsFolder[instrument] ..  "/" .. sounds[instrument][index]
end

local function ShouldIgnoreSound(soundName)
    -- If this isn't a weapon sound, ignore it
    if not StringFind(soundName, "weapon") then return true end

    -- If any of these patterns match the sound name, ignore it
    for _, pattern in ipairs(ignorePaths) do
        if string.find(soundName, pattern) then return true end
    end

    return false
end

function EVENT:Initialize()
    local instruments = table.GetKeys(sounds)
    for _, i in pairs(instruments) do
        soundsFolder[i] = StringReplace(i, " ", "")
    end

    for _, i in pairs(instruments) do
        local instrumentFolder = soundsFolder[i]
        for _, s in ipairs(sounds[i]) do
            util.PrecacheSound(instrumentFolder .. "/" .. s)
        end
    end
end

function EVENT:Begin()
    local currentInstrument = 1
    local instruments = table.GetKeys(sounds)
    local maxInstruments = table.Count(instruments)
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
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
        if ShouldIgnoreSound(data.SoundName:lower()) then return end
        if not IsPlayer(data.Entity) then return end

        local aim = data.Entity:EyeAngles()
        aim:Normalize()

        -- Negate the pitch because in GMod looking down is positive and looking up is negative
        local pitch = -aim.pitch
        -- Normalize the pitch to within 0-180 for easier indexing
        pitch = pitch + 90

        local chosen_sound = GetWeaponSound(data.Entity, pitch)
        data.SoundName = chosen_sound
        return true
    end)
end

Randomat:register(EVENT)