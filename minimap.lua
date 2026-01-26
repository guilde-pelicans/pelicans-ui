local ADDON_NAME = "PelicanUI"
local ICON_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\icon.tga"

-- Do not initialize SavedVariables at the top to avoid early references
-- before the saved variables are loaded. They will be prepared in ADDON_LOADED.
-- PelicanUI_Settings (SavedVariables) is declared in the .toc

local function OpenSettings()
    if SettingsPanel and PelicanUI_SettingsCategory then
        SettingsPanel:OpenToCategory(PelicanUI_SettingsCategory)
        -- Force selection of the category after opening
        if SettingsPanel.SelectCategory then
            C_Timer.After(0.1, function()
                SettingsPanel:SelectCategory(PelicanUI_SettingsCategory)
            end)
        end
    else
        print("PelicanUI: unable to open settings.")
    end
end

local function UpdateTooltip(tt, inCompartment)
    if not tt or not tt.AddLine then return end
    tt:AddLine("PelicanUI")
    tt:AddLine("|cffffff00Left-click|r: Ouvrir la configuration")
    tt:AddLine("|cffffff00Drag|r: Déplacer le bouton de minimap")
    if inCompartment then
        tt:AddLine("|cffffff00Right-click|r: Replacer le bouton sur la minimap")
    else
        tt:AddLine("|cffffff00Right-click|r: Envoyer le bouton dans le menu AddOns de la minimap")
    end
end

local function ToggleCompartment(LDBIcon, dataObject)
    -- Toggle between the minimap button and the native AddOns compartment (Dragonflight+)
    if not LDBIcon or not dataObject then return end
    local db = PelicanUI_Settings and PelicanUI_Settings.minimap
    local name = ADDON_NAME

    local inCompartment = LDBIcon.IsButtonInCompartment and LDBIcon:IsButtonInCompartment(name)
    local compartmentAvailable = LDBIcon.IsButtonCompartmentAvailable and LDBIcon:IsButtonCompartmentAvailable()

    -- If the compartment is not available (older clients), keep the minimap button
    if not compartmentAvailable then
        print("PelicanUI: le menu AddOns de la minimap n'est pas disponible sur cette version du jeu.")
        return
    end

    if inCompartment then
        -- Remove from compartment and show the minimap icon again
        if LDBIcon.RemoveButtonFromCompartment then
            LDBIcon:RemoveButtonFromCompartment(name)
        end
        if db then
            db.showInCompartment = nil
            db.hide = nil
        end
        if LDBIcon.Show then
            LDBIcon:Show(name)
        end
        if LDBIcon.Refresh then
            LDBIcon:Refresh(name, db)
        end
        print("PelicanUI: bouton replacé sur la minimap.")
    else
        -- Add to compartment and hide the minimap icon
        if LDBIcon.AddButtonToCompartment then
            -- Optional custom icon as second parameter (we keep the addon's icon by default)
            LDBIcon:AddButtonToCompartment(name)
        end
        if db then
            db.showInCompartment = true
            db.hide = true
        end
        if LDBIcon.Hide then
            LDBIcon:Hide(name)
        end
        if LDBIcon.Refresh then
            LDBIcon:Refresh(name, db)
        end
        print("PelicanUI: bouton déplacé dans le menu AddOns de la minimap.")
    end
end

local function InitMinimapButton()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not LDB or not LDBIcon then
        return
    end

    -- Ensure SavedVariables exist now that everything has loaded
    PelicanUI_Settings = PelicanUI_Settings or {}
    PelicanUI_Settings.minimap = PelicanUI_Settings.minimap or {}
    local db = PelicanUI_Settings.minimap

    -- Create or reuse the DataObject
    local dataObject = LDB:GetDataObjectByName(ADDON_NAME)
    if not dataObject then
        dataObject = LDB:NewDataObject(ADDON_NAME, {
            type = "launcher",
            icon = ICON_PATH,
            label = ADDON_NAME,
            OnClick = function(_, button)
                if button == "LeftButton" then
                    OpenSettings()
                elseif button == "RightButton" then
                    ToggleCompartment(LDBIcon, dataObject)
                end
            end,
            OnTooltipShow = function(tt)
                local inCompartment = LDBIcon and LDBIcon.IsButtonInCompartment and LDBIcon:IsButtonInCompartment(ADDON_NAME)
                UpdateTooltip(tt, inCompartment)
            end,
        })
    else
        -- If the DataObject already exists, ensure its handlers include right-click behavior
        local origOnClick = dataObject.OnClick
        dataObject.OnClick = function(frame, button)
            if button == "LeftButton" then
                if origOnClick then origOnClick(frame, button) else OpenSettings() end
            elseif button == "RightButton" then
                ToggleCompartment(LIBDBICON10 and LibStub("LibDBIcon-1.0", true) or LDBIcon, dataObject)
            end
        end
        dataObject.OnTooltipShow = function(tt)
            local inCompartment = LDBIcon and LDBIcon.IsButtonInCompartment and LDBIcon:IsButtonInCompartment(ADDON_NAME)
            UpdateTooltip(tt, inCompartment)
        end
        dataObject.icon = ICON_PATH
        dataObject.label = ADDON_NAME
    end

    -- Register and show the minimap icon as needed
    if not LDBIcon:IsRegistered(ADDON_NAME) then
        LDBIcon:Register(ADDON_NAME, dataObject, db)
    end

    -- Apply persisted state:
    -- - If showInCompartment == true, add to compartment and hide the minimap icon
    -- - Otherwise, show the minimap icon with the saved position (handled by the lib)
    if db.showInCompartment and LDBIcon.IsButtonCompartmentAvailable and LDBIcon:IsButtonCompartmentAvailable() then
        if LDBIcon.AddButtonToCompartment then
            LDBIcon:AddButtonToCompartment(ADDON_NAME)
        end
        if LDBIcon.Hide then
            LDBIcon:Hide(ADDON_NAME)
        end
    else
        if LDBIcon.Show then
            LDBIcon:Show(ADDON_NAME)
        end
    end

    -- Refresh to ensure position (minimapPos) and state are applied
    if LDBIcon.Refresh then
        LDBIcon:Refresh(ADDON_NAME, db)
    end
end

-- Ordered loading to guarantee:
-- - SavedVariables are ready
-- - UI is ready for placement and minimap shape detection
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        -- Prepare SavedVariables as soon as the addon is loaded
        PelicanUI_Settings = PelicanUI_Settings or {}
        PelicanUI_Settings.minimap = PelicanUI_Settings.minimap or {}
    elseif event == "PLAYER_LOGIN" then
        -- Initialize the button when the UI is ready
        InitMinimapButton()
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")
    end
end)