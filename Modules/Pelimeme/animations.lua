-- Declare a global namespace for animations
PelicanUI_Animations = {}

-- Animation function: simpleDisplay
function PelicanUI_Animations.simpleDisplay(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(250, 250)
    frame:SetPoint("CENTER", UIParent, "TOP", 0, -300)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    frame:SetAlpha(0)

    -- Fade-in and fade-out animation
    local animationGroup = frame:CreateAnimationGroup()

    local fadeAlphaIn = animationGroup:CreateAnimation("Alpha")
    fadeAlphaIn:SetFromAlpha(0)
    fadeAlphaIn:SetToAlpha(1)
    fadeAlphaIn:SetDuration(2)
    fadeAlphaIn:SetOrder(1)

    local delay = animationGroup:CreateAnimation("Alpha")
    delay:SetFromAlpha(1)
    delay:SetToAlpha(1)
    delay:SetDuration(3)
    delay:SetOrder(2)

    local fadeAlphaOut = animationGroup:CreateAnimation("Alpha")
    fadeAlphaOut:SetFromAlpha(1)
    fadeAlphaOut:SetToAlpha(0)
    fadeAlphaOut:SetDuration(1)
    fadeAlphaOut:SetOrder(3)

    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
    end)

    frame:Show()
    animationGroup:Play()
end

-- Animation function: bounce
function PelicanUI_Animations.bounce(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(200, 200)
    frame:SetPoint("CENTER", UIParent, "CENTER", 250, 250)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local bounce = frame:CreateAnimationGroup()
    local translateUp = bounce:CreateAnimation("Translation")
    translateUp:SetOffset(0, 100)
    translateUp:SetDuration(0.6)
    translateUp:SetSmoothing("OUT")
    translateUp:SetOrder(1)

    local translateDown = bounce:CreateAnimation("Translation")
    translateDown:SetOffset(0, -100)
    translateDown:SetDuration(0.6)
    translateDown:SetSmoothing("IN")
    translateDown:SetOrder(2)

    bounce:SetScript("OnFinished", function()
        frame:Hide()
    end)

    frame:Show()
    bounce:Play()
end

-- Animation function: rain
function PelicanUI_Animations.rain(imagePath)
    local duration = 2.5
    local numImages = 40
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local imageSize = 128

    for i = 1, numImages do
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(imageSize, imageSize) -- Using the doubled size
        frame:SetPoint("TOPLEFT", math.random(0, screenWidth), math.random(0, screenHeight))

        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(frame)
        texture:SetTexture(imagePath)
        texture:SetAlpha(1)
        texture:SetRotation(math.rad(math.random(-25, 25)))

        local animationGroup = frame:CreateAnimationGroup()

        local moveDown = animationGroup:CreateAnimation("Translation")
        moveDown:SetOffset(0, -screenHeight - 200)
        moveDown:SetDuration(duration)
        moveDown:SetSmoothing("OUT")
        moveDown:SetOrder(1)

        -- Handle random spinning
        local spin = animationGroup:CreateAnimation("Rotation")
        spin:SetDegrees((math.random(0, 1) == 1 and 1 or -1) * math.random(180, 540))
        spin:SetDuration(duration)
        spin:SetSmoothing("IN_OUT")
        spin:SetOrigin("CENTER", 0, 0)
        spin:SetOrder(1)

        animationGroup:SetScript("OnFinished", function()
            frame:Hide()
            frame = nil
        end)

        C_Timer.After(math.random() * 0.8, function()
            frame:Show()
            animationGroup:Play()
        end)
    end
end

-- Animation function: leftSlide
function PelicanUI_Animations.leftSlide(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(300, 300)

    -- Initial position completely off-screen to the left
    frame:SetPoint("LEFT", UIParent, "LEFT", -300, 0)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local animationGroup = frame:CreateAnimationGroup()

    -- Animation: The image slides into the screen
    local slideIn = animationGroup:CreateAnimation("Translation")
    slideIn:SetOffset(300, 0)
    slideIn:SetDuration(1.5)
    slideIn:SetSmoothing("IN_OUT")
    slideIn:SetOrder(1)

    -- Remains visible for 2 seconds
    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(2)
    pause:SetOrder(2)

    -- Moves out, completely off-screen
    local slideOut = animationGroup:CreateAnimation("Translation")
    slideOut:SetOffset(-300, 0)
    slideOut:SetDuration(1)
    slideOut:SetSmoothing("IN_OUT")
    slideOut:SetOrder(3)

    -- Once the animation is finished, hide the frame
    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
        frame = nil
    end)

    frame:Show()
    animationGroup:Play()
end

-- Animation function: rightSlide
function PelicanUI_Animations.rightSlide(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(300, 300)

    -- Initial position completely off-screen to the right
    frame:SetPoint("RIGHT", UIParent, "RIGHT", 300, 0)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local animationGroup = frame:CreateAnimationGroup()

    -- Animation: The image slides into the screen
    local slideIn = animationGroup:CreateAnimation("Translation")
    slideIn:SetOffset(-300, 0) -- Slides in by the full width of the image
    slideIn:SetDuration(1.5)
    slideIn:SetSmoothing("IN_OUT")
    slideIn:SetOrder(1)

    -- Remains visible for 2 seconds
    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(2)
    pause:SetOrder(2)

    -- Moves out, completely off-screen
    local slideOut = animationGroup:CreateAnimation("Translation")
    slideOut:SetOffset(300, 0)
    slideOut:SetDuration(1)
    slideOut:SetSmoothing("IN_OUT")
    slideOut:SetOrder(3)

    -- Once the animation is finished, hide the frame
    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
        frame = nil
    end)

    frame:Show()
    animationGroup:Play()
end

-- Animation function: shake (leftSlide + shake/rotation before sliding out)
function PelicanUI_Animations.shake(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(300, 300)

    -- Initial position completely off-screen to the left
    frame:SetPoint("LEFT", UIParent, "LEFT", -300, 0)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local ag = frame:CreateAnimationGroup()

    -- 1) Slide in (same as leftSlide)
    local slideIn = ag:CreateAnimation("Translation")
    slideIn:SetOffset(450, 0)
    slideIn:SetDuration(1.5)
    slideIn:SetSmoothing("IN_OUT")
    slideIn:SetOrder(1)

    -- 2) Shake (quick rotations around center)
    -- Keep total rotation sum to 0 so we end at the original angle
    local r1 = ag:CreateAnimation("Rotation")
    r1:SetDegrees(6)
    r1:SetDuration(0.08)
    r1:SetOrder(2)
    r1:SetSmoothing("IN_OUT")
    r1:SetOrigin("CENTER", 0, 0)

    local r2 = ag:CreateAnimation("Rotation")
    r2:SetDegrees(-12)
    r2:SetDuration(0.10)
    r2:SetOrder(3)
    r2:SetSmoothing("IN_OUT")
    r2:SetOrigin("CENTER", 0, 0)

    local r3 = ag:CreateAnimation("Rotation")
    r3:SetDegrees(10)
    r3:SetDuration(0.10)
    r3:SetOrder(4)
    r3:SetSmoothing("IN_OUT")
    r3:SetOrigin("CENTER", 0, 0)

    local r4 = ag:CreateAnimation("Rotation")
    r4:SetDegrees(-8)
    r4:SetDuration(0.10)
    r4:SetOrder(5)
    r4:SetSmoothing("IN_OUT")
    r4:SetOrigin("CENTER", 0, 0)

    local r5 = ag:CreateAnimation("Rotation")
    r5:SetDegrees(4) -- back to the initial angle (sum = 0)
    r5:SetDuration(0.08)
    r5:SetOrder(6)
    r5:SetSmoothing("IN_OUT")
    r5:SetOrigin("CENTER", 0, 0)

    -- Small hold after the shake
    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(0.5)
    hold:SetOrder(7)

    -- 3) Slide out (same as leftSlide)
    local slideOut = ag:CreateAnimation("Translation")
    slideOut:SetOffset(-450, 0)
    slideOut:SetDuration(1.0)
    slideOut:SetSmoothing("IN_OUT")
    slideOut:SetOrder(8)

    ag:SetScript("OnFinished", function()
        frame:Hide()
        frame = nil
    end)

    frame:Show()
    ag:Play()
end

-- Helper: animate a sprite sheet stored as frame-01.png, frame-02.png, ... in a directory.
-- texture    : WoW Texture object to update
-- dirPath    : full addon path to the directory (e.g. "Interface\\AddOns\\PelicansUI\\Medias\\ready\\go")
-- frameCount : total number of frames in the directory
-- fps        : frames per second
-- loop       : if true, cycles indefinitely; if false, plays once then calls onFinish
-- onFinish   : optional callback fired when a non-looping animation ends
-- Returns a ticker handle; call handle:Cancel() to stop early.
function PelicanUI_Animations.playFrames(texture, dirPath, frameCount, fps, loop, onFinish)
    local currentFrame = 1
    local ticker

    local function setFrame()
        texture:SetTexture(dirPath .. "\\" .. string.format("%02d", currentFrame) .. ".png")
    end

    setFrame() -- first frame shown immediately, no delay
    currentFrame = 2

    ticker = C_Timer.NewTicker(1 / fps, function()
        if not loop and currentFrame > frameCount then
            ticker:Cancel()
            if onFinish then onFinish() end
            return
        end
        setFrame()
        if loop then
            currentFrame = currentFrame % frameCount + 1
        else
            currentFrame = currentFrame + 1
        end
    end)

    return ticker
end

-- Preload: force GPU upload of all frames in a sprite sheet by rendering them once
-- on a 1×1 off-screen frame at addon load time, eliminating first-play flickering.
-- dirPath    : same as playFrames
-- frameCount : same as playFrames
function PelicanUI_Animations.preloadFrames(dirPath, frameCount)
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(1, 1)
    f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -10) -- below visible screen
    for i = 1, frameCount do
        local t = f:CreateTexture(nil, "BACKGROUND")
        t:SetAllPoints(f)
        t:SetTexture(dirPath .. "\\" .. string.format("%02d", i) .. ".png")
    end
    f:Show()
    -- Hide after a few seconds; textures remain cached in GPU memory
    C_Timer.After(5, function() f:Hide() end)
end