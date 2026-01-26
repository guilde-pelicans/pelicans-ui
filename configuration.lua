-- Create a configuration panel for PelicanUI
local optionsFrame = CreateFrame("Frame", "PelicanUIOptionsFrame")
optionsFrame.name = "PelicanUI"

-- Scrollable container
local scrollFrame = CreateFrame("ScrollFrame", "PelicanUIOptionsScrollFrame", optionsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8) -- espace pour la barre de défilement

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1) -- taille minimale, s'étendra via ses enfants
scrollFrame:SetScrollChild(content)

-- Synchroniser la largeur du contenu avec la fenêtre visible du ScrollFrame
local function SyncContentWidth()
    local w = scrollFrame:GetWidth()
    if w and w > 0 then
        content:SetWidth(w) -- largeur = viewport du scroll (barre déjà déduite par -28)
    end
end
scrollFrame:SetScript("OnSizeChanged", SyncContentWidth)
optionsFrame:HookScript("OnShow", SyncContentWidth)
SyncContentWidth()

-- Panel title
local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Pelican UI - Configuration")

local configurationDesc = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
configurationDesc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
configurationDesc:SetText("Beaucoup de réglages pour un add-on qui ne sert à rien.")

-- Display the Murloc image in scrollable zone
local murlocImage = content:CreateTexture(nil, "ARTWORK")
murlocImage:SetTexture("Interface\\AddOns\\PelicansUI\\Medias\\configuration-logo.png")
murlocImage:SetSize(230, 230)
murlocImage:SetPoint("TOPRIGHT", -16, -16)
murlocImage:SetAlpha(0.5)

-- Small helper to create a horizontal separator line
local function CreateSeparator(parent, anchorTo, offsetY)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(1, 1, 1, 0.15)
    sep:SetSize(300, 2)
    sep:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, offsetY or -12)
    return sep
end

-- Create icon with menu image for help
local function CreateInfoIconWithImage(parent, anchorTo, offsetX, offsetY)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", anchorTo, "RIGHT", offsetX or 6, offsetY or 0)

    local tex = icon:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(true)
    tex:SetTexture("Interface\\FriendsFrame\\InformationIcon")

    local IMAGE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\docs\\menu.png"

    icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|T" .. IMAGE_PATH .. ":92:193|t")
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return icon
end

-- Checkbox to disable all addon sounds (global)
local disableSoundCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
disableSoundCheckbox:SetPoint("TOPLEFT", configurationDesc, "BOTTOMLEFT", 0, -12)
disableSoundCheckbox.text = disableSoundCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
disableSoundCheckbox.text:SetPoint("LEFT", disableSoundCheckbox, "RIGHT", 4, 0)
disableSoundCheckbox.text:SetText("Désactiver les sons (je n'aime pas le fun)")
disableSoundCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.DisableSounds = self:GetChecked()
end)

-- Sound Channel
local soundChannelLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
soundChannelLabel:SetPoint("TOPLEFT", disableSoundCheckbox, "BOTTOMLEFT", 0, -10)
soundChannelLabel:SetText("Canal sonore utilisé")

local soundChannelHint = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
soundChannelHint:SetPoint("TOPLEFT", soundChannelLabel, "BOTTOMLEFT", 0, -6)
soundChannelHint:SetWidth(520)
soundChannelHint:SetJustifyH("LEFT")
soundChannelHint:SetText("Le réglage de volume du canal sélectionné s’appliquera à tous les sons de l’add-on.")

local soundsChannelDropdown = CreateFrame("Frame", "PelicanUISoundsChannelDropdown", content, "UIDropDownMenuTemplate")
soundsChannelDropdown:SetPoint("TOPLEFT", soundChannelHint, "BOTTOMLEFT", 0, -8)

local channelOptions = {
    { label = "Principal", value = "Master" },
    { label = "Musique", value = "Music" },
    { label = "Effets", value = "SFX" },
    { label = "Ambiance", value = "Ambience" },
    { label = "Discussion", value = "Dialog" },
}

local function GetChannelLabelByValue(v)
    for _, o in ipairs(channelOptions) do
        if o.value == v then
            return o.label
        end
    end
    return channelOptions[1].label
end

UIDropDownMenu_SetWidth(soundsChannelDropdown, 180)
UIDropDownMenu_Initialize(soundsChannelDropdown, function(self, level)
    local current = PelicanUI_Settings.SoundsChannel or "Master"
    for _, opt in ipairs(channelOptions) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = opt.label
        info.func = function()
            PelicanUI_Settings.SoundsChannel = opt.value
            UIDropDownMenu_SetText(soundsChannelDropdown, opt.label)
        end
        info.checked = (current == opt.value)
        UIDropDownMenu_AddButton(info, level)
    end
end)
UIDropDownMenu_SetText(soundsChannelDropdown, GetChannelLabelByValue(PelicanUI_Settings.SoundsChannel or "Master"))

local sep1 = CreateSeparator(content, soundsChannelDropdown, -12)

-- MODULE EMOTE
local emoteHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
emoteHeader:SetPoint("TOPLEFT", sep1, "BOTTOMLEFT", 0, -12)
emoteHeader:SetText("Module Emote")

local emoteDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
emoteDesc:SetPoint("TOPLEFT", emoteHeader, "BOTTOMLEFT", 0, -6)
emoteDesc:SetJustifyH("LEFT")
emoteDesc:SetWidth(520)
emoteDesc:SetText("Ce module permet l’affichage des emotes personnalisées de la guilde.\n|cffffff00/peli|r |cffffff00/pelimotes|r ou |cffffff00/emotes|r pour voir les emotes disponibles .\n")

-- Checkbox to enable/disable the Emotes module
local emotesCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
emotesCheckbox:SetPoint("TOPLEFT", emoteDesc, "BOTTOMLEFT", 0, -12)
emotesCheckbox.text = emotesCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
emotesCheckbox.text:SetPoint("LEFT", emotesCheckbox, "RIGHT", 4, 0)
emotesCheckbox.text:SetText("Activer")
emotesCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.EmotesEnabled = self:GetChecked()
end)

local sep2 = CreateSeparator(content, emotesCheckbox, -12)

-- READY-CHECK
local rcHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
rcHeader:SetPoint("TOPLEFT", sep2, "BOTTOMLEFT", 0, -12)
rcHeader:SetText("Ready-check")

local rcDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
rcDesc:SetPoint("TOPLEFT", rcHeader, "BOTTOMLEFT", 0, -6)
rcDesc:SetJustifyH("LEFT")
rcDesc:SetWidth(520)
rcDesc:SetText("Ce module ajoute quelques visuels et sons au ready-check natif du jeu.")

local readyCheckCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
readyCheckCheckbox:SetPoint("TOPLEFT", rcDesc, "BOTTOMLEFT", 0, -8)
readyCheckCheckbox.text = readyCheckCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
readyCheckCheckbox.text:SetPoint("LEFT", readyCheckCheckbox, "RIGHT", 4, 0)
readyCheckCheckbox.text:SetText("Activer")
readyCheckCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.ReadyCheckEnabled = self:GetChecked()
end)

local sep3 = CreateSeparator(content, readyCheckCheckbox, -12)

-- PeliMeme
local pmHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
pmHeader:SetPoint("TOPLEFT", sep3, "BOTTOMLEFT", 0, -12)
pmHeader:SetText("PeliMeme")

local pmDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
pmDesc:SetPoint("TOPLEFT", pmHeader, "BOTTOMLEFT", 0, -6)
pmDesc:SetJustifyH("LEFT")
pmDesc:SetWidth(520)
pmDesc:SetText("Ce module permet d’envoyer et de recevoir des mèmes animés à une personne ou à votre groupe ")

local pmContext = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
pmContext:SetPoint("TOPLEFT", pmDesc, "BOTTOMLEFT", 0, -2)
pmContext:SetText("via un menu contextuel (click droit sur le joueur)")
CreateInfoIconWithImage(content, pmContext, 6, 0)

local warningText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warningText:SetPoint("TOPLEFT", pmContext, "BOTTOMLEFT", 0, -6)
warningText:SetJustifyH("LEFT")
warningText:SetWidth(520)
warningText:SetText("Vous ne recevrez |cffffff00JAMAIS|r d’animation si vous êtes en combat.")

local pelimemeCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
pelimemeCheckbox:SetPoint("TOPLEFT", warningText, "BOTTOMLEFT", 0, -10)
pelimemeCheckbox.text = pelimemeCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
pelimemeCheckbox.text:SetPoint("LEFT", pelimemeCheckbox, "RIGHT", 4, 0)
pelimemeCheckbox.text:SetText("Activer")
pelimemeCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.PelimemeEnabled = self:GetChecked()
end)

-- Optional small description
local delayDescription = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
delayDescription:SetPoint("TOPLEFT", pelimemeCheckbox, "BOTTOMLEFT", 0, -10)
delayDescription:SetText("Réglez l’intervalle entre deux réceptions pour éviter tout spam. (car on est un peu con quand même)")

-- Slider for PelimemeMinDelay
local minDelaySlider = CreateFrame("Slider", "PelicanUIPelimemeMinDelaySlider", content, "OptionsSliderTemplate")
minDelaySlider:SetPoint("TOPLEFT", delayDescription, "BOTTOMLEFT", 0, -16)
minDelaySlider:SetMinMaxValues(1, 600)
minDelaySlider:SetValueStep(1)
minDelaySlider:SetValue(PelicanUI_Settings.PelimemeMinDelay or 10)
minDelaySlider:SetWidth(200)

_G[minDelaySlider:GetName() .. "Low"]:SetText("1 seconde")
_G[minDelaySlider:GetName() .. "High"]:SetText("10 minutes")
_G[minDelaySlider:GetName() .. "Text"]:SetText("")

minDelaySlider.text = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
minDelaySlider.text:SetPoint("LEFT", minDelaySlider, "RIGHT", 8, 0)
minDelaySlider.text:SetText((PelicanUI_Settings.PelimemeMinDelay or 10) .. " secondes")

minDelaySlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    PelicanUI_Settings.PelimemeMinDelay = value
    self.text:SetText(value .. " secondes")
end)

local sep4 = CreateSeparator(content, minDelaySlider, -20)

-- Pélican Awards
local awardsHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
awardsHeader:SetPoint("TOPLEFT", sep4, "BOTTOMLEFT", 0, -14)
awardsHeader:SetText("Pélican Awards")

local awardsDesc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
awardsDesc:SetPoint("TOPLEFT", awardsHeader, "BOTTOMLEFT", 0, -6)
awardsDesc:SetJustifyH("LEFT")
awardsDesc:SetWidth(520)
awardsDesc:SetText("Ce module permet de décerner une « distinction » à un membre de votre groupe ou raid")

local awardsDesc2 = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
awardsDesc2:SetPoint("TOPLEFT", awardsDesc, "BOTTOMLEFT", 0, -6)
awardsDesc2:SetJustifyH("LEFT")
awardsDesc2:SetText("(si vous en êtes le chef uniquement)")
CreateInfoIconWithImage(content, awardsDesc2, 6, 0)

local awardsNote = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
awardsNote:SetPoint("TOPLEFT", awardsDesc2, "BOTTOMLEFT", 0, -6)
awardsNote:SetWidth(520)
awardsNote:SetJustifyH("LEFT")
awardsNote:SetText("|cffffff00Il n’est possible d’afficher une distinction qu’une fois par minute.|r")

local awardsCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
awardsCheckbox:SetPoint("TOPLEFT", awardsNote, "BOTTOMLEFT", 0, -10)
awardsCheckbox.text = awardsCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
awardsCheckbox.text:SetPoint("LEFT", awardsCheckbox, "RIGHT", 4, 0)
awardsCheckbox.text:SetText("Activer")
awardsCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.AwardsEnabled = self:GetChecked()
end)

-- Warning at the bottom
local warningText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warningText:SetPoint("TOPLEFT", awardsCheckbox, "BOTTOMLEFT", 0, -16)
warningText:SetJustifyH("LEFT")
warningText:SetWidth(520)
warningText:SetText("|cffff0000Attention|r : après l’activation ou la désactivation d’un module, il peut être nécessaire de faire un |cffffff00/reload|r")

-- Update checkboxes and the slider when the panel is displayed
optionsFrame:SetScript("OnShow", function()
    -- Keep current saved values
    disableSoundCheckbox:SetChecked(PelicanUI_Settings.DisableSounds)
    UIDropDownMenu_SetText(soundsChannelDropdown, GetChannelLabelByValue(PelicanUI_Settings.SoundsChannel or "Master"))
    emotesCheckbox:SetChecked(PelicanUI_Settings.EmotesEnabled)
    readyCheckCheckbox:SetChecked(PelicanUI_Settings.ReadyCheckEnabled)
    pelimemeCheckbox:SetChecked(PelicanUI_Settings.PelimemeEnabled)
    awardsCheckbox:SetChecked(PelicanUI_Settings.AwardsEnabled)

    minDelaySlider:SetValue(PelicanUI_Settings.PelimemeMinDelay or 10)
end)

local addonCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "PelicanUI")
addonCategory.ID = "PelicanUI"
Settings.RegisterAddOnCategory(addonCategory)

PelicanUI_SettingsCategory = addonCategory

-- /pelican shortcut to open configuration panel
SLASH_PELICAN1 = "/pelican"
SlashCmdList["PELICAN"] = function(msg)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addonCategory)
    else
        print("Impossible d'ouvrir la configuration : API Settings indisponible.")
    end
end