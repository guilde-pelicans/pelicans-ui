-- Saved variables
PelicanUI_Settings = PelicanUI_Settings or {
    EmotesEnabled = true,
    PelimemeEnabled = true,
    TooltipsEnabled = true,
    AwardsEnabled = true,
    ReadyCheckEnabled = true,
    PauseEnabled = true,
    PelimemeMinDelay = 60,
    DisableSounds = false,
    SoundsChannel = 'Master'
}

local mainFrame = CreateFrame("Frame")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then

        local welcomeMsg = "Module Pélicans chargés : "

        if PelicanUI_Settings.EmotesEnabled then
            PelicanUI_Emotes:Initialize()
            welcomeMsg = welcomeMsg .. " Emotes"
        end

        if PelicanUI_Settings.PelimemeEnabled then
            PelicanUI_Pelimeme:Initialize()
            welcomeMsg = welcomeMsg .. " Pélimeme"
        end

        if PelicanUI_Settings.ReadyCheckEnabled then
            PelicanUI_ReadyCheck:Initialize()
            welcomeMsg = welcomeMsg .. " ReadyCheck"
        end

        if PelicanUI_Settings.PauseEnabled then
            PelicanUI_Pause:Initialize()
            welcomeMsg = welcomeMsg .. " Pause"
        end

        if PelicanUI_Settings.AwardsEnabled then
            PelicanUI_Awards:Initialize()
            welcomeMsg = welcomeMsg .. " Awards"
        end

        print(welcomeMsg)
    end
end)