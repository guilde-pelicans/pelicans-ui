local ReadyCheck = {}
PelicanUI_ReadyCheck = ReadyCheck

local IMAGE_DIR_RC = "Interface\\AddOns\\PelicansUI\\Medias\\ready\\check"
local CHECK_FRAME_COUNT = 2

local IMAGE_DIR_GO   = "Interface\\AddOns\\PelicansUI\\Medias\\ready\\go"
local READY_GO_FRAME_COUNT = 5

local IMAGE_DIR_FAIL   = "Interface\\AddOns\\PelicansUI\\Medias\\ready\\fail"
local READY_FAIL_FRAME_COUNT = 17

local SOUND_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\sounds\\"

local function playSound(filePath)
    if not filePath or filePath == "" then
        return
    end
    if not PelicanUI_Settings.DisableSounds then
        PlaySoundFile(SOUND_BASE_PATH .. filePath, PelicanUI_Settings.SoundsChannel)
    end
end

-- reused frame / texture
local f, tex

local function ensureFrame()
    if f and tex then
        return f, tex
    end
    f = CreateFrame("Frame", "PelicanUIReadyCheckFrame", UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:Hide()
    tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(f)
    return f, tex
end

-- Final position after slide down
local FINAL_TOP_OFFSET = -150

local function rcStartAnimation()
    local frame, texture = ensureFrame()

    if frame._ag then
        frame._ag:Stop()
    end

    if frame._frameTicker then
        frame._frameTicker:Cancel()
        frame._frameTicker = nil
    end

    -- Set first frame immediately
    texture:SetTexture(IMAGE_DIR_RC .. "\\01.png")

    local w, h = texture:GetSize()
    if not w or not h or w == 0 or h == 0 then
        w, h = 350, 350
    end

    frame:SetSize(w, h)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, h + 50) -- hors écran avant slide
    frame:SetAlpha(1)

    local ag = frame:CreateAnimationGroup()
    frame._ag = ag

    local slideDown = ag:CreateAnimation("Translation")
    slideDown:SetOffset(0, -h - 200)
    slideDown:SetDuration(1.5)
    slideDown:SetSmoothing("IN_OUT")
    slideDown:SetOrder(1)

    local pause = ag:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(5)
    pause:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetStartDelay(0.3)
    fadeOut:SetOrder(3)

    frame:Show()
    frame._frameTicker = PelicanUI_Animations.playFrames(texture, IMAGE_DIR_RC, CHECK_FRAME_COUNT, 2, true)
    ag:Play()
end

local function rcGoAnimation()
    local frame, texture = ensureFrame()

    -- Stop running animation and put it directly to its final position
    if frame._ag then
        frame._ag:Stop()
    end

    if frame._frameTicker then
        frame._frameTicker:Cancel()
        frame._frameTicker = nil
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, FINAL_TOP_OFFSET)

    -- Start sprite animation (sets first frame immediately so GetSize() works below)
    frame._frameTicker = PelicanUI_Animations.playFrames(texture, IMAGE_DIR_GO, READY_GO_FRAME_COUNT, 6, true)

    frame:SetSize(400, 400)

    playSound("combattre.ogg")

    -- Fade in, tenue, fade out
    frame:SetAlpha(0)
    frame:Show()

    if frame._goAg then
        frame._goAg:Stop()
    end
    local ag = frame:CreateAnimationGroup()
    frame._goAg = ag

    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.15)
    fadeIn:SetOrder(1)

    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(2.0)
    hold:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.4)
    fadeOut:SetOrder(3)

    ag:SetScript("OnFinished", function()
        if frame._frameTicker then
            frame._frameTicker:Cancel()
            frame._frameTicker = nil
        end
        frame:Hide()
        frame._goAg = nil
        frame._ag = nil
        f, tex = nil, nil
    end)

    ag:Play()
end

local function rcFailAnimation()
    local frame, texture = ensureFrame()

    -- Stop running animation and put it directly to its final position
    if frame._ag then
        frame._ag:Stop()
    end

    if frame._frameTicker then
        frame._frameTicker:Cancel()
        frame._frameTicker = nil
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, FINAL_TOP_OFFSET)

    -- Start sprite animation (sets first frame immediately so GetSize() works below)
    frame._frameTicker = PelicanUI_Animations.playFrames(texture, IMAGE_DIR_FAIL, READY_FAIL_FRAME_COUNT, 12, false)

    frame:SetSize(400, 400)

    playSound("sad-noise.ogg")

    -- Fade in, tenue, fade out
    frame:SetAlpha(0)
    frame:Show()

    if frame._goAg then
        frame._goAg:Stop()
    end
    local ag = frame:CreateAnimationGroup()
    frame._goAg = ag

    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.15)
    fadeIn:SetOrder(1)

    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(2.0)
    hold:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.4)
    fadeOut:SetOrder(3)

    ag:SetScript("OnFinished", function()
        if frame._frameTicker then
            frame._frameTicker:Cancel()
            frame._frameTicker = nil
        end
        frame:Hide()
        frame._goAg = nil
        frame._ag = nil
        f, tex = nil, nil
    end)

    ag:Play()
end

local function ForEachGroupUnit(callback)
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                callback(unit)
            end
        end
    else
        callback("player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                callback(unit)
            end
        end
    end
end

local function AreAllReady()
    local everyoneAnswered, allReady = true, true
    ForEachGroupUnit(function(unit)
        -- "ready" | "notready" | "afk" | nil
        local status = GetReadyCheckStatus(unit)
        if status == nil then
            everyoneAnswered, allReady = false, false
        elseif status ~= "ready" then
            allReady = false
        end
    end)
    return everyoneAnswered, allReady
end

-- Save last know state while ready check
local lastEveryoneAnswered, lastAllReady = false, false

function ReadyCheck:Initialize()

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            -- preload ready check on loading
            PelicanUI_Animations.preloadFrames(IMAGE_DIR_RC, CHECK_FRAME_COUNT)

        elseif event == "READY_CHECK" then
            -- preload GO and Fail animatoins while ready check
            PelicanUI_Animations.preloadFrames(IMAGE_DIR_GO, READY_GO_FRAME_COUNT)
            PelicanUI_Animations.preloadFrames(IMAGE_DIR_FAIL, READY_FAIL_FRAME_COUNT)

            lastEveryoneAnswered, lastAllReady = false, false
            rcStartAnimation()

        elseif event == "READY_CHECK_CONFIRM" then
            local everyoneAnswered, allReady = AreAllReady()

            -- this event is trigger multiple time by player, so we save the last know player status
            lastEveryoneAnswered, lastAllReady = everyoneAnswered, allReady
            if everyoneAnswered and allReady then
                rcGoAnimation()
            end

        elseif event == "READY_CHECK_FINISHED" then
            if lastEveryoneAnswered and not lastAllReady then
                rcFailAnimation()
            end

            if f and f:IsShown() and not (f._goAg and f._goAg:IsPlaying()) then
                f:Hide()
            end

            lastEveryoneAnswered, lastAllReady = false, false
        end
    end)
end