local ipairs = ipairs
local math = math
local string = string
local table = table

local MathCeil = math.ceil
local MathMax = math.max
local MathMin = math.min
local StringFind = string.find
local StringReplace = string.Replace

Randomat.JingleJam2024 = {
    -- Mapping of untuned instrument name to sound file names
    UntunedSounds = {
        drums = {
            "kick.mp3", "kick2.mp3", "concerttom.mp3", "floortom.mp3", "tom.mp3", "snare.mp3",
            "snare2.mp3", "hihat.mp3", "cymbalcrash.mp3", "cymbalshort.mp3", "cymbalmedium.mp3", "cymballong.mp3"
        }
    },

    -- Tuned instrument sound file names
    TunedSounds = {
        "C3.wav", "C#3.wav", "D3.wav", "D#3.wav", "E3.wav", "F3.wav", "F#3.wav", "G3.wav", "G#3.wav", "A3.wav", "A#3.wav", "B3.wav",
        "C4.wav", "C#4.wav", "D4.wav", "D#4.wav", "E4.wav", "F4.wav", "F#4.wav", "G4.wav", "G#4.wav", "A4.wav", "A#4.wav", "B4.wav",
        "C5.wav"
    },

    -- List of tuned instrument names that will use the C3 - C5 file name scheme
    TunedInstruments = {
        "acoustic guitar",
        "bass guitar",
        "electric guitar",
        "flute",
        "organ",
        "piano",
        "trumpet",
        "violin",
        "xylophone"
    },

    -- Mapping of instrument name to sound folder
    SoundsFolder = {},

    -- Wildcard-enabled mappings of weapon sounds to ignore
    IgnorePaths = {
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
    },

    GetInstruments = function()
        local instruments = table.GetKeys(Randomat.JingleJam2024.UntunedSounds)
        table.Add(instruments, Randomat.JingleJam2024.TunedInstruments)
        return instruments
    end,

    GetWeaponSound = function(ply, pitch)
        local instrument = ply:GetNWString("RdmtJingleJam2024Instrument", "")
        if #instrument == 0 then return end

        if table.HasValue(Randomat.JingleJam2024.TunedInstruments, instrument) then
            -- Tuned instruments should have 25 notes from C3 to C5 so translate the pitch into an index from 1 to 25
            local index = MathMax(1, MathMin(MathCeil(pitch / 7.2), 25))
            return "jinglejam2024/" .. Randomat.JingleJam2024.SoundsFolder[instrument] ..  "/" .. Randomat.JingleJam2024.SoundsFolder[instrument] .. Randomat.JingleJam2024.TunedSounds[index]
        else
            -- Translate the pitch into an index no greater than the number of sounds for this instrument
            local maxSounds = table.Count(Randomat.JingleJam2024.UntunedSounds[instrument])
            local index = MathMax(1, MathMin(MathCeil(pitch / (180 / maxSounds)), maxSounds))
            return "jinglejam2024/" .. Randomat.JingleJam2024.SoundsFolder[instrument] ..  "/" .. Randomat.JingleJam2024.UntunedSounds[instrument][index]
        end
    end,

    ShouldIgnoreSound = function(soundName)
        -- If this isn't a weapon sound, ignore it
        if not StringFind(soundName, "weapon") then return true end

        -- If any of these patterns match the sound name, ignore it
        for _, pattern in ipairs(Randomat.JingleJam2024.IgnorePaths) do
            if StringFind(soundName, pattern) then return true end
        end

        return false
    end
}

-- Build out the mapping of instrument name to sound folder
local function Initialize()
    local instruments = Randomat.JingleJam2024.GetInstruments()
    for _, i in ipairs(instruments) do
        Randomat.JingleJam2024.SoundsFolder[i] = StringReplace(i, " ", "")
    end

    if SERVER then
        for _, i in pairs(instruments) do
            local instrumentFolder = Randomat.JingleJam2024.SoundsFolder[i]
            if table.HasValue(Randomat.JingleJam2024.TunedInstruments, i) then
                for _, s in ipairs(Randomat.JingleJam2024.TunedSounds) do
                    util.PrecacheSound(instrumentFolder .. "/" .. instrumentFolder .. s)
                end
            else
                for _, s in ipairs(Randomat.JingleJam2024.UntunedSounds[i]) do
                    util.PrecacheSound(instrumentFolder .. "/" .. s)
                end
            end

        end
    end
end
Initialize()