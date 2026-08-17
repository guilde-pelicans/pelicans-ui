-- PelicanUI Pelimeme Module
local Pelimeme = {}
PelicanUI_Pelimeme = Pelimeme

-- Define base directories for memes and sounds
local IMAGE_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\memes\\"
local SOUND_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\sounds\\"

local pelimemes = {
    ["jae"] = { desc = "Jae Hippie", image = "jae.png", animation = "simpleDisplay" },
    ["molky"] = { desc = "Molky espiègle", image = "molky.png", animation = "rightSlide", sound = "tu-veut-voir-ma.ogg" },
    ["nephlol"] = { desc = "Neph LOL", image = "nephlol.png", animation = "bounce", sound = "haha.ogg" },
    ["gogo"] = { desc = "Gogo", image = "gogo.png", animation = "simpleDisplay" },
    ["gogorain"] = { desc = "Pluie de Gogo", image = "gogo.png", animation = "rain" },
    ["sausage"] = { desc = "Saucisse", image = "sausage.png", animation = "shake" },
    ["sausagerain"] = { desc = "Pluie de saucisses", image = "sausage.png", animation = "rain" },
    ["murlove"] = { desc = "Murlove", image = "love.png", animation = "simpleDisplay" },
}

local lastReceivedPelimemeTimestamp = nil
local isMuted = false

-- Function to play a sound
local function playSound(filePath)
    if not filePath or filePath == "" then
        return
    end

    if not PelicanUI_Settings.DisablePelimemeSound then
        PlaySoundFile(SOUND_BASE_PATH .. filePath, PelicanUI_Settings.SoundsChannel)
    end
end

-- Function to display a Pelimeme
local function displayPelimeme(pelimemeID)
    local pelimeme = pelimemes[pelimemeID]
    if not pelimeme then
        print("Pelimeme non défini: " .. pelimemeID)
        return
    end

    local animationFunc = PelicanUI_Animations[pelimeme.animation]
    if not animationFunc or type(animationFunc) ~= "function" then
        print("Animation non définie ou invalide : " .. pelimeme.animation)
        return
    end

    animationFunc(IMAGE_BASE_PATH .. pelimeme.image)
    playSound(pelimeme.sound)
end

-- Handle Pelimeme reception (Anti-Spam and Mute Verification)
local function handlePelimemeReception(sender, pelimemeID)

    local desc = pelimemes[pelimemeID] and pelimemes[pelimemeID].desc or "Inconnu"

    -- Check if player is in fight
    if UnitAffectingCombat("player") then
        print(desc .. " de " .. sender .. " bloqué car vous êtes en combat.")
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "Le destinataire est en train de COMBATTRE", "WHISPER", sender)
        return false
    end

    if isMuted then
        print(desc .. " de " .. sender .. " bloqué car vous êtes en mode avion.")
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "le destinataire est en mode avion", "WHISPER", sender)
        return false
    end

    -- Check anti-spam
    local currentTime = GetServerTime()
    local minDelay = PelicanUI_Settings.PelimemeMinDelay or 10

    if lastReceivedPelimemeTimestamp and (currentTime - lastReceivedPelimemeTimestamp < minDelay) then
        local remainingTime = minDelay - (currentTime - lastReceivedPelimemeTimestamp)
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "Essayez à nouveau dans " .. tostring(remainingTime) .. " secondes.", "WHISPER", sender)
        return false
    end

    lastReceivedPelimemeTimestamp = currentTime

    displayPelimeme(pelimemeID)
    print(desc .. " reçu de " .. sender)

    return true
end

-- Send Pelimeme with a command
SLASH_PELIMEME1 = "/pelimeme"
SlashCmdList["PELIMEME"] = function(msg)
    -- Help command
    if msg == nil or msg == "" then
        print("Utilisation : /pelimeme [nom_pelimeme] [nom_du_joueur] ou /pelimeme mute")
        print("Types de PéliMeme disponibles :")
        for id, info in pairs(pelimemes) do
            print(" - " .. id .. " : " .. (info.desc or ""))
        end
        return
    end

    -- Mute command
    local first = msg:match("^(%S+)$")
    if first == "mute" then
        isMuted = not isMuted
        print(isMuted and "PéliMeme désactivé jusqu'à la déconnexion ou un /reload." or "Pélimeme activés.")
        return
    end

    local pelimemeID, playerName = msg:match("^(%S+)%s+(%S+)$")
    if not pelimemeID or not playerName then
        print("Utilisation : /pelimeme [nom_pelimeme] [nom_du_joueur] ou /pelimeme mute")
        print("Types de PéliMeme disponibles :")
        for id, info in pairs(pelimemes) do
            print(" - " .. id .. " : " .. (info.desc or ""))
        end
        return
    end

    if not pelimemes[pelimemeID] then
        print("Type de PéliMeme invalide : " .. pelimemeID)
        print("Types disponibles :")
        for id in pairs(pelimemes) do
            print(" - " .. id)
        end
        return
    end

    C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "WHISPER", playerName)
    print((pelimemes[pelimemeID].desc or pelimemeID) .. " envoyé à " .. playerName)
end

-- Create context menu for players
local function UpdateContextMenu(_, parent, data)

    local targetPlayer = data.name

    local personalSubmenu
    if targetPlayer then
        personalSubmenu = parent:CreateButton("Envoyer un PéliMeme à " .. targetPlayer)
        personalSubmenu:CreateTitle("Envoyer à " .. targetPlayer)
    end

    local raidSubmenu
    if IsInRaid() then
        raidSubmenu = parent:CreateButton("Envoyer un PéliMeme au raid")
        raidSubmenu:CreateTitle("Envoyer au raid")
    end

    local groupSubmenu
    if IsInGroup() then
        groupSubmenu = parent:CreateButton("Envoyer un PéliMeme au groupe")
        groupSubmenu:CreateTitle("Envoyer au groupe")
    end

    for pelimemeID, pelimemeInfo in pairs(pelimemes) do
        if personalSubmenu then
            personalSubmenu:CreateButton(pelimemeInfo.desc, function()
                print(pelimemeInfo.desc .. " envoyé à " .. targetPlayer)
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "WHISPER", targetPlayer)
            end, false)
        end

        if raidSubmenu then
            raidSubmenu:CreateButton(pelimemeInfo.desc, function()
                print(pelimemeInfo.desc .. " envoyé au raid")
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "RAID")
            end, false)
        end

        if groupSubmenu then
            groupSubmenu:CreateButton(pelimemeInfo.desc, function()
                print(pelimemeInfo.desc .. " envoyé au groupe")
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "PARTY")
            end, false)
        end
    end

end

-- Register Pelimeme event for reception
function Pelimeme:Initialize()
    local pelimemeFrame = CreateFrame("Frame")
    pelimemeFrame:RegisterEvent("CHAT_MSG_ADDON")
    pelimemeFrame:SetScript("OnEvent", function(_, _, prefix, message, _, sender)
        if prefix == "PELIMEME" then
            handlePelimemeReception(sender, message)
        elseif prefix == "PELIMEME_BLOCKED" then
            print("Votre Pélimeme a été bloqué. " .. message)
        end
    end)
    C_ChatInfo.RegisterAddonMessagePrefix("PELIMEME")
    C_ChatInfo.RegisterAddonMessagePrefix("PELIMEME_BLOCKED")

    PelicanUI_Menu.RegisterBuilder(UpdateContextMenu, 10)
end
