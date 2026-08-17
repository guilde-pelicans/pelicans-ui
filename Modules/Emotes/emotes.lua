-- PelicanUI Emotes Module
local Emotes = {}
PelicanUI_Emotes = Emotes

local IMAGE_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\emotes\\"

-- Table of emotes
local emotes = {
    ["<3"] = { behaviour = "replace", image = "heart.tga" },
    [":D"] = { behaviour = "replace", image = "big-smile.tga" },
    [":nephlol:"] = { behaviour = "replace", image = "big-smile.tga" },
    [":)"] = { behaviour = "replace", image = "smile.tga" },
    [":("] = { behaviour = "replace", image = "frown.tga" },
    [":o"] = { behaviour = "replace", image = "open-mouth.tga" },
    [";)"] = { behaviour = "replace", image = "wink.tga" },
    [":'("] = { behaviour = "replace", image = "cry.tga" },
    ["meh"] = { behaviour = "replace", image = "gamine.tga", wholeWord = true },
    [":Gamine2:"] = { behaviour = "replace", image = "gamine.tga", wholeWord = true },
    [":Gamine:"] = { behaviour = "replace", image = "gamine.tga", wholeWord = true },
    ["murloc"] = { behaviour = "after", image = "murloc.tga", wholeWord = true },
    ["zzz"] = { behaviour = "replace", image = "zzz.tga", wholeWord = true },
    ["caca"] = { behaviour = "replace", image = "poop.tga" },
    ["merde"] = { behaviour = "after", image = "poop.tga" },
    ["+1"] = { behaviour = "replace", image = "nek-pouce.tga", wholeWord = true },
    ["ok"] = { behaviour = "replace", image = "nek-pouce.tga", wholeWord = true },
    [":Nekpouce:"] = { behaviour = "replace", image = "nek-pouce.tga", wholeWord = true },
    ["saucisse"] = { behaviour = "after", image = "sausage.tga", wholeWord = true },
    ["so6"] = { behaviour = "replace", image = "sausage.tga", wholeWord = true },
    [":Peliso6:"] = { behaviour = "replace", image = "sausage.tga", wholeWord = true },
    ["fu*k"] = { behaviour = "replace", image = "gogo.tga", wholeWord = true },
    [":gogofu:"] = { behaviour = "replace", image = "gogo.tga", wholeWord = true },
}

-- Helper function to escape special characters in Lua patterns
local function escapePattern(str)
    return str:gsub("([^%w])", "%%%1")
end

-- Function to get the emote tag
local function getEmoteTag(emote)
    return "|T" .. IMAGE_BASE_PATH .. emote.image .. ":16|t"
end

-- Applique le comportement (replace/before/after) d'un emote à un texte matché
local function applyBehaviour(emote, emoteTag, match)
    if emote.behaviour == "replace" then
        return emoteTag
    elseif emote.behaviour == "before" then
        return emoteTag .. " " .. match
    elseif emote.behaviour == "after" then
        return match .. " " .. emoteTag
    else
        return match
    end
end

-- Function to replace text with emotes
local function replaceEmotesInText(text)
    for code, emote in pairs(emotes) do
        local emoteTag = getEmoteTag(emote)
        local escaped = escapePattern(code)

        if emote.wholeWord then
            text = text:gsub("()" .. escaped .. "()", function(startPos, endPos)
                local before = text:sub(startPos - 1, startPos - 1)
                local after = text:sub(endPos, endPos)
                if before:match("%w") or after:match("%w") then
                    return code
                end
                return applyBehaviour(emote, emoteTag, code)
            end)
        else
            text = text:gsub("(" .. escaped .. ")", function(match)
                return applyBehaviour(emote, emoteTag, match)
            end)
        end
    end
    return text
end

-- helper to show emotes help in chat
local function printEmotesHelp()
    local buckets = {
        replace = {},
        before = {},
        after = {},
        other = {},
    }

    -- Regroup by behaviour
    for code, e in pairs(emotes) do
        local key = e.behaviour
        if key ~= "replace" and key ~= "before" and key ~= "after" then
            key = "other"
        end
        table.insert(buckets[key], { code = code, emote = e })
    end

    local function sortByCode(a, b)
        return tostring(a.code) < tostring(b.code)
    end
    for _, list in pairs(buckets) do
        table.sort(list, sortByCode)
    end

    -- Display "emote + code" entry
    local function renderEntry(item)
        return getEmoteTag(item.emote) .. " |cffffffff" .. item.code .. "|r"
    end

    -- Header
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00PelicanUI - Emotes disponibles !|r")

    local sections = {
        { key = "replace", label = "|cffaaaaaa[Remplacement]|r" },
        { key = "before", label = "|cffaaaaaa[Icône avant]|r" },
        { key = "after", label = "|cffaaaaaa[Icône après]|r" },
    }

    -- One line by behaviour
    for _, s in ipairs(sections) do
        local list = buckets[s.key]
        if list and #list > 0 then
            local parts = {}
            for _, item in ipairs(list) do
                table.insert(parts, renderEntry(item))
            end
            DEFAULT_CHAT_FRAME:AddMessage(s.label .. "  " .. table.concat(parts, "   "))
        end
    end
end

-- Filter applying emote replacement in messages
local function emoteMessageFilter(_, _, msg, sender, ...)
    local updatedMsg = replaceEmotesInText(msg)
    if updatedMsg ~= msg then
        return false, updatedMsg, sender, ...
    end
    return false
end

-- Initialization of the Emotes module
function Emotes:Initialize()
    local eventsToFilter = {
        "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_SAY",
        "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    }
    for _, event in ipairs(eventsToFilter) do
        ChatFrame_AddMessageEventFilter(event, emoteMessageFilter)
    end

    -- Help commands
    SLASH_PELI1 = "/peli"
    SLASH_PELI2 = "/pelimotes"
    SLASH_PELI3 = "/emotes"
    SlashCmdList["PELI"] = function()
        printEmotesHelp()
    end
end