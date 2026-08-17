local Pause = {}
PelicanUI_Pause = Pause

-- Sprite frames (01.png, 02.png, ... in the folder)
local IMAGE_DIR_PAUSE = "Interface\\AddOns\\PelicansUI\\Medias\\pause"
local PAUSE_FRAME_COUNT = 10
local PAUSE_FPS = 6

-- Animation timings (seconds)
local PAUSE_SLIDE_DURATION = 1
local PAUSE_DISPLAY_DURATION = 10
local PAUSE_FADE_DURATION = 0.4

-- Only trigger for pulls longer than this, with an anti-spam cooldown
local PULL_THRESHOLD_SECONDS = 60
local PULL_TRIGGER_COOLDOWN = 20

-- reused frame / texture
local f, tex

local function ensureFrame()
    if f and tex then
        return f, tex
    end
    f = CreateFrame("Frame", "PelicanUIPauseFrame", UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:Hide()
    tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(f)
    return f, tex
end

-- Same display pattern as the ready-check module: reused frame, slide down from
-- the top of the screen, looping sprite while shown, then fade out.
local function pauseStartAnimation()
    local frame, texture = ensureFrame()

    if frame._ag then
        frame._ag:Stop()
    end

    if frame._frameTicker then
        frame._frameTicker:Cancel()
        frame._frameTicker = nil
    end

    -- Set first frame immediately
    texture:SetTexture(IMAGE_DIR_PAUSE .. "\\01.png")

    local w, h = texture:GetSize()
    if not w or not h or w == 0 or h == 0 then
        w, h = 350, 350
    end

    frame:SetSize(w, h)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, h + 50) -- off-screen before the slide
    frame:SetAlpha(1)

    local ag = frame:CreateAnimationGroup()
    frame._ag = ag

    local slideDown = ag:CreateAnimation("Translation")
    slideDown:SetOffset(0, -h - 200)
    slideDown:SetDuration(PAUSE_SLIDE_DURATION)
    slideDown:SetSmoothing("IN_OUT")
    slideDown:SetOrder(1)

    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(PAUSE_DISPLAY_DURATION)
    hold:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(PAUSE_FADE_DURATION)
    fadeOut:SetOrder(3)

    ag:SetScript("OnFinished", function()
        if frame._frameTicker then
            frame._frameTicker:Cancel()
            frame._frameTicker = nil
        end
        frame:Hide()
        frame._ag = nil
        f, tex = nil, nil
    end)

    frame:Show()
    frame._frameTicker = PelicanUI_Animations.playFrames(texture, IMAGE_DIR_PAUSE, PAUSE_FRAME_COUNT, PAUSE_FPS, true)
    ag:Play()
end

-- Triggers the animation when "seconds" exceeds the configured threshold, with anti-spam.
local lastTriggerTime = 0

local function handlePullSeconds(seconds)
    if not seconds or seconds <= PULL_THRESHOLD_SECONDS then
        return
    end

    local now = GetTime()
    if now - lastTriggerTime < PULL_TRIGGER_COOLDOWN then
        return
    end
    lastTriggerTime = now

    pauseStartAnimation()
end

-- START_PARTY_COUNTDOWN args aren't in a fixed order across clients; just grab the number.
local function extractFirstNumber(...)
    for i = 1, select("#", ...) do
        local n = tonumber((select(i, ...)))
        if n then
            return n
        end
    end
    return nil
end

function Pause:Initialize()
    -- Registered first: even if the rest of init fails (e.g. a native event missing on
    -- this game version), /pelipause stays usable.
    SLASH_PELIPAUSE1 = "/pelipause"
    SlashCmdList["PELIPAUSE"] = function()
        pauseStartAnimation()
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- START_PLAYER_COUNTDOWN is the native /pull broadcast (Blizzard's own countdown
    -- system, works with no addon on either end). Best-effort: some game versions may
    -- not expose it. Payload: initiatorGUID, seconds, seconds, isActive, initiatorName.
    pcall(frame.RegisterEvent, frame, "START_PLAYER_COUNTDOWN")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            PelicanUI_Animations.preloadFrames(IMAGE_DIR_PAUSE, PAUSE_FRAME_COUNT)
        elseif event == "START_PLAYER_COUNTDOWN" then
            handlePullSeconds(extractFirstNumber(...))
        end
    end)
end
