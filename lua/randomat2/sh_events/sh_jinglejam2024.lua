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
    -- Mapping of instrument name to sound file names in increasing order
    -- Instruments toward the start of this list will be used more often than the ones at the end
    Sounds = {
        guitar = {
            "guitarc.mp3", "guitard.mp3", "guitare.mp3", "guitarf.mp3", "guitarg.mp3", "guitara.mp3",
            "guitarheavyelow.mp3", "guitarheavya.mp3", "guitarheavyg.m3", "guitarheavyehigh.mp3", "guitarheavypluck.mp3", "guitarheavypluck2.mp3"
        },
        ["bass guitar"] = {
            "bassc.mp3", "bassd.mp3", "basse.mp3", "bassf.mp3", "bassg.mp3", "bassa.mp3",
            "electricbassc.mp3", "electricbassd.mp3", "electricbasse.mp3", "electricbassf.mp3", "electricbassg.mp3", "electricbassb.mp3"
        },
        drums = {
            "kick.mp3", "kick2.mp3", "concerttom.mp3", "floortom.mp3", "tom.mp3", "snare.mp3",
            "snare2.mp3", "hihat.mp3", "cymbalcrash.mp3", "cymbalshort.mp3", "cymbalmedium.mp3", "cymballong.mp3"
        },
        ["acoustic guitar"] = {
            "acousticc.mp3", "acousticd.mp3", "acoustice.mp3", "acousticf.mp3", "acousticg.mp3", "acoustica.mp3",
            "nylonbminor.mp3", "nylondflatminor.mp3", "nylonemajor.mp3", "nylonfsharpmaj9.mp3", "nylonfsharpminor.mp3", "nylonaflatmajor.mp3"
        },
        piano = {
            "pianoa.mp3", "pianogsharp.mp3", "pianobflat.mp3", "pianob.mp3", "pianoc.mp3", "pianocsharp.mp3",
            "pianod.mp3", "pianoeflat.mp3", "pianoe.mp3", "pianof.mp3", "pianofsharp.mp3", "pianog.mp3"
        }
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

    GetWeaponSound = function(ply, pitch)
        local instrument = ply:GetNWString("RdmtJingleJam2024Instrument", "")
        if #instrument == 0 then return end

        -- Translate the pitch into a number [1-12]
        local index = MathMax(1, MathMin(MathCeil(pitch / 15), 12))
        return "jinglejam2024/" .. Randomat.JingleJam2024.SoundsFolder[instrument] ..  "/" .. Randomat.JingleJam2024.Sounds[instrument][index]
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
    local instruments = table.GetKeys(Randomat.JingleJam2024.Sounds)
    for _, i in ipairs(instruments) do
        Randomat.JingleJam2024.SoundsFolder[i] = StringReplace(i, " ", "")
    end

    if SERVER then
        for _, i in pairs(instruments) do
            local instrumentFolder = Randomat.JingleJam2024.SoundsFolder[i]
            for _, s in ipairs(Randomat.JingleJam2024.Sounds[i]) do
                util.PrecacheSound(instrumentFolder .. "/" .. s)
            end
        end
    end
end
Initialize()