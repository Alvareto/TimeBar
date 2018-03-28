
function GetModLocation()
    -- /Code/TimeScript.lua = 20
    return debug.getinfo(2, "S").source:sub(2, -20)
end

-- prop = Time, Date, Duration
-- func = string rollover text
function AddDateTimeSection(parent, prop, icon, func)
    local local_section = XWindow:new({
        Id = "id"..prop.."Bar", 
        LayoutMethod = "HList", 
        VAlign = "center", 
        HandleMouse = true, 
        RolloverTemplate = "Rollover", 
        Padding = box(0, 0, 5, 0), 
    }, parent)

    XImage:new({
        Id = "idCurrent"..prop.."Icon", 
        Image = icon, 
        ImageScale = point(500, 500), 
    }, local_section)
    local current = XText:new({
        Id = "idCurrent"..prop.."Display", 
        MinWidth = 25, 
        TextColor = RGB(255, 255, 255), 
        RolloverTextColor = RGB(255, 255, 255), 
    }, local_section)

    local_section:SetRolloverTitle(T{T{5778311, prop}, UICity})
    local_section:SetRolloverText(T{
        T{
            "Current " .. prop .. " is <em><time></em>", 
            time = func--
        }, 
        UICity
    })

    return current
end


function AddCurrentTime()
    local interface = GetXDialog("InGameInterface")
    if interface['idTopRightTimeBar'] then
        -- The current time is already there, so this must have been called more than once
        return
    end

    --local this_mod_dir = GetModLocation()

    local bar = XWindow:new({
        Id = "idTopRightTimeBar", 
        HAlign = "right", 
        VAlign = "top", 
        LayoutMethod = "HList", 
        Margins = box(0, -1, 0, 0), 
        Padding = box(8, 0, 8, 0), 
        Background = RGBA(0, 20, 40, 200), 
        BorderWidth = 1, 
    }, interface)

    --[[if interface['idTimeBar'] then
        -- The current time is already there, so this must have been called more than once
        return

        "correct" way to check for a global that might be undefined, without recording an error in the game log, is 
            rawget(_G, "g_MyGlobal")
        GameTime() = time elapsed since sol 0 - a day is 720000,so divide the value by it and you should have number of sols
    end--]]
    local this_mod_dir = GetModLocation()

    local current_time = AddDateTimeSection(bar, "Time", this_mod_dir .. "UI/Icons/res_time.tga", function() return tostring(os.date("%H:%M")) end)
    local current_date = AddDateTimeSection(bar, "Date", this_mod_dir .. "UI/Icons/res_date.tga", function() return tostring(os.date("%x")) end)
    --local current_duration = AddDateTimeSection(bar, "Duration", "UI/Icons/res_experimental_research.tga", function() return MsToClock(os.clock()) end)

    return current_time
end

--[[local function MsToClock(miliseconds)
    local seconds = tonumber(miliseconds / 1000)

    if seconds <= 0 then
        return "00:00:00"; 
    else
        hours = string.format("%02.f", math.floor(seconds / 3600)); 
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60))); 
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60)); 
        return hours..":"..mins..":"..secs
    end
end--]]

function UpdateCurrentTime()
    local interface = GetXDialog("InGameInterface") -- ['idTopRightTimeBar']['idTimeBar']['idCurrentTimeDisplay']
    --local bar = interface['idTopRightTimeBar']
    --local section = bar['idTimeBar']
    --local current_time = section['idCurrentTimeDisplay']
    local current_time = interface['idCurrentTimeDisplay']
    local current_date = interface['idCurrentDateDisplay']
    --local current_duration = interface['idCurrentDurationDisplay']

    -- This shouldn't ever happen, but it can't hurt to check
    if not current_time then
        current_time = AddCurrentTime()
        current_date = interface['idCurrentDateDisplay']
        --current_duration = interface['idCurrentDurationDisplay']
    end

    current_time:SetText(tostring(os.date("%H:%M")))
    current_date:SetText(tostring(os.date("%x")))
    --current_duration:SetText(tostring(MsToClock(os.clock())))


    XUpdateRolloverWindow(interface['idTimeBar'])
    XUpdateRolloverWindow(interface['idDateBar'])
    --XUpdateRolloverWindow(interface['idDurationBar'])
end



function OnMsg.NewMinute()
    UpdateCurrentTime()
end

function OnMsg.UIReady()
    CreateGameTimeThread(function()
        while true do
            WaitMsg("OnRender")
            AddCurrentTime()
            UpdateCurrentTime()
            break
        end
    end)
end

function OnMsg.LoadGame()
    CreateGameTimeThread(function()
        while true do
            WaitMsg("OnRender")
            if GetXDialog("InGameInterface") then
                Msg("UIReady")
                break
            end
        end
    end)
end
function OnMsg.NewMapLoaded()
    Msg("UIReady")
end
