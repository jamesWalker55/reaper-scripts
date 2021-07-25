-- boiler code to override reaper search paths
local _root_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts') .. "?.lua"
local _parent_path = ({reaper.get_action_context()})[2]:match('^(.+[\\//])') .. "?.lua"
package.path = _parent_path .. ";" .. _root_path

require "lib.dev"

--[[==============================================================================================
    Global variables
================================================================================================]]

-- imgui
r = reaper
Ctx = r.ImGui_CreateContext('Simple Track Inspector', 300, 500)
Viewport = r.ImGui_GetMainViewport(Ctx)
FLT_MIN, FLT_MAX = r.ImGui_NumericLimits_Float()

-- reaper
actions = {
    show_fx_chain = 40291,
    show_track_routing = 40293,
    show_envelopes = 40292,
    solo_defeat = 41199,
    solo_toggle = 40281,
    unsolo_all = 40340,
    mute_toggle = 40280,
    mute_all = 40341,
    unmute_all = 40339,
}

-- custom
MainHeight = 200
const = {}

const.vol = {
    db_slider_max = 12,  -- highest value in slider
    db_min = -144,  -- the lowest volume that isn't mute
    reaper_inf = 1e-50,  -- value that represents -inf in reaper
    slider_curve = 30,  -- visualize the curve with x^(1/curve)
}

const.pan = {
    order = {
        "default",
        "mono_pan",
        "stereo_pan",
        "dual_pan",
        "deprecated",
    },
    id = {
        default = -1,
        mono_pan = 3,
        stereo_pan = 5,
        dual_pan = 6,
        deprecated = 0,
    },
    names = {
        default = "Project def.",
        mono_pan = "Stereo balance",
        stereo_pan = "Stereo pan",
        dual_pan = "Dual pan",
        deprecated = "3.x (deprecated)",
    },
}

const.solo = {
    off = 0,
    in_place = 2,
    ignore_routing = 1,
    unused_safe = 5,
    safe_in_place = 6,
}

const.pan.menu = ""
for _, key in ipairs(const.pan.order) do
    const.pan.menu = const.pan.menu .. const.pan.names[key] .. "\31"
end

mem = {}

mem.disp = {
    lines_data = reaper.new_array(10),
}
mem.disp.lines_data.clear()

mem.title = {
    editing_title = false
}

--[[==============================================================================================
    Helper functions
================================================================================================]]

--[[ volumes

there are 3 formats of volmues in this file
reaper: weird float value using the constant ( 20√ 10 )
     20⋅log(reaper)
dB = ──────────────
        log(10)

float: linear value in range 0..1, from ImGui slider
min and max controls the range of `float`, doesn't affect reaper
     curve_______
dB =    ╲╱ float ⋅(max - min) + min

dB: volume in actual dB

therefore, assuming min=-1000 and max=12:
               curve_______
           253⋅   ╲╱ float
           ──────────────── - 50
                  5
reaper = 10

                                                                           curve
        ⎛5⋅log(100000000000000000000000000000000000000000000000000⋅reaper)⎞
float = ⎜─────────────────────────────────────────────────────────────────⎟
        ⎝                           253⋅log(10)                           ⎠
                             curve
        ⎛5⋅log(reaper)   250⎞
float = ⎜───────────── + ───⎟
        ⎝ 253⋅log(10)    253⎠
 ]]

function DBToReaperVol(db)
    return math.exp(db * math.log(10) / 20)
end

function ReaperToDBVol(reaper)
    return math.log(reaper, 10) * 20
end

function ReaperToFloatVol(reaper)
    if reaper == 0 then return 0 end
    return (5*math.log(reaper, 10) / 253 + 250/253) ^ const.vol.slider_curve
end

function FloatToReaperVol(float)
    return 10 ^ (253 * (float^(1/const.vol.slider_curve))/5 - 50)
end

function DBVolToText(db, precision)
    if db < const.vol.db_min then
        return "-Inf dB"
    else
        return ('%.' .. precision .. 'f dB')
    end
end

-- append a value to mem.disp.lines_data and remove first value
function AppendLineData(value)
    local new_table = mem.disp.lines_data.table(2)
    table.insert(new_table, value)
    mem.disp.lines_data = r.new_array(new_table)
end

function Text(msg)
    r.ImGui_Text(Ctx, msg)
end

function PanToText(pan_val)
    -- this takes a value from -100..100
    if pan_val == 0 then
        return 'C'
    elseif pan_val > 0 then
        return '%.1f R'
    else
        return '%.1f L'
    end
end

function QuickSlider(id_name, var)
    local _, val = reaper.ImGui_DragDouble(Ctx, id_name, var)
    return val
end

function HeldCtrl(mods)
    return (mods & r.ImGui_KeyModFlags_Ctrl()) ~= 0
end

function HeldShift(mods)
    return (mods & r.ImGui_KeyModFlags_Shift()) ~= 0
end

function HeldAlt(mods)
    return (mods & r.ImGui_KeyModFlags_Alt()) ~= 0
end

--[[==============================================================================================
    WIDGETS
================================================================================================]]

function Widget_History(reaper_array, width, height)
    r.ImGui_PlotLines(Ctx, '##History', reaper_array, 0, nil, 0, 1, width, height)
end

function Widget_VolumeSlider(track, reaper_vol, width, height)
    local _
    local float_vol = ReaperToFloatVol(reaper_vol)
    _, float_vol = r.ImGui_VSliderDouble(Ctx, '##VolumeSlider', width, height, float_vol, 0, 1, " ")
    if r.ImGui_IsItemActive(Ctx) or r.ImGui_IsItemHovered(Ctx) then
        local db_vol = ReaperToDBVol(reaper_vol)
        r.ImGui_SetTooltip(Ctx, DBVolToText(db_vol, 2):format(db_vol))
    end
    if r.ImGui_IsItemActive(Ctx) then
        r.SetMediaTrackInfo_Value(track, "D_VOL", FloatToReaperVol(float_vol))
    end
    if r.ImGui_IsItemClicked(Ctx, r.ImGui_PopupFlags_MouseButtonRight()) then
        Text("Right clicked slider!")
        reaper.Main_OnCommand(actions.show_track_routing, 0)
    end
    -- -- hack for detecting double click on slider
    -- if r.ImGui_IsMouseDoubleClicked(Ctx, 0) and r.ImGui_IsItemHovered(Ctx) then
    --     r.SetMediaTrackInfo_Value(track, "D_VOL", DBToReaperVol(0))
    -- end
end

function Widget_VolumeInfo(track, reaper_vol, width)
    local _
    r.ImGui_PushItemWidth(Ctx, width)
    local db_vol = ReaperToDBVol(reaper_vol)
    _, db_vol = r.ImGui_DragDouble(Ctx, '##VolumeDrag', db_vol, 0.1, const.vol.db_min, const.vol.db_slider_max, DBVolToText(db_vol, 3))
    if r.ImGui_IsItemActive(Ctx) then
        reaper.SetMediaTrackInfo_Value(track, "D_VOL", DBToReaperVol(db_vol))
    end
    r.ImGui_PopItemWidth(Ctx)
end

function AddPanPopup(track)
    local width = 120
    local _
    if r.ImGui_BeginPopupContextItem(Ctx) then -- use last item id as popup id
        r.ImGui_PushItemWidth(Ctx, width)
        r.ImGui_Text(Ctx, "Pan law:")
        local pan_law_reaper = r.GetMediaTrackInfo_Value(track, "D_PANLAW")
        local pan_law_enabled = pan_law_reaper ~= -1
        -- begin checkbox
        _, pan_law_enabled = reaper.ImGui_Checkbox(Ctx, "Enabled##PanPopupLawEnabled", pan_law_enabled)
        if r.ImGui_IsItemEdited(Ctx) then
            if pan_law_enabled then
                pan_law_reaper = 1
            else
                pan_law_reaper = -1
            end
            r.SetMediaTrackInfo_Value(track, "D_PANLAW", pan_law_reaper)
        end
        -- end checkbox
        -- begin double input
        if pan_law_enabled then
            local pan_law_db = ReaperToDBVol(pan_law_reaper)
            _, pan_law_db = r.ImGui_InputDouble(Ctx, '##PanPopupLawValue', pan_law_db, 0.5, 1, '%.1f dB')
            pan_law_reaper = DBToReaperVol(pan_law_db)
            if r.ImGui_IsItemEdited(Ctx) then
                r.SetMediaTrackInfo_Value(track, "D_PANLAW", pan_law_reaper)
            end
        end
        -- end double input

        r.ImGui_Text(Ctx, "Pan mode:")
        -- begin combo section
        local pan_mode_id = r.GetMediaTrackInfo_Value(track, "I_PANMODE")
        local pan_key = nil
        local menu_idx = nil
        for i, key in pairs(const.pan.order) do
            local id = const.pan.id[key]
            if id == pan_mode_id then
                pan_key = key
                menu_idx = i - 1
            end
        end
        assert(pan_key and menu_idx, "Invalid pan id retrieved from r.GetMediaTrackInfo_Value(track, 'I_PANMODE')")

        _, menu_idx = reaper.ImGui_Combo(Ctx, "##PanPopupMode", menu_idx, const.pan.menu)

        if r.ImGui_IsItemEdited(Ctx) then
            reaper.SetMediaTrackInfo_Value(track, "I_PANMODE", const.pan.id[const.pan.order[menu_idx + 1]])
        end
        -- end combo section
        r.ImGui_PopItemWidth(Ctx)
        
        r.ImGui_EndPopup(Ctx)
    end
end

function Widget_PanInfo(track, width, item_gap)
    local _
    local is_dual_pan = r.GetMediaTrackInfo_Value(track, "I_PANMODE") == const.pan.id.dual_pan
    -- reaper returns a float in -1..1
    r.ImGui_BeginGroup(Ctx)
    -- if dual pan mode, then
    if is_dual_pan then
        if not width then width = ({r.ImGui_GetContentRegionAvail(Ctx)})[1] end
        for _, direction in ipairs({"L", "R"}) do
            local info_key = "D_DUALPAN" .. direction
            local pan = r.GetMediaTrackInfo_Value(track, info_key) * 100

            _, pan = r.ImGui_DragDouble(Ctx, '##PanInfoPan'..direction, pan, 1, -100, 100, direction .. " -> " .. PanToText(pan))

            if r.ImGui_IsItemEdited(Ctx) then reaper.SetMediaTrackInfo_Value(track, info_key, pan / 100) end
            AddPanPopup(track)
        end
    else
        -- convert pan from -1..1 to -100..100
        local pan = r.GetMediaTrackInfo_Value(track, "D_PAN") * 100
        local label = "Pan = " .. PanToText(pan)

        if width then r.ImGui_PushItemWidth(Ctx, width) end

        _, pan = r.ImGui_DragDouble(Ctx, '##PanInfoPan', pan, 1, -100, 100, label)
        if r.ImGui_IsItemEdited(Ctx) then reaper.SetMediaTrackInfo_Value(track, "D_PAN", pan / 100) end
        AddPanPopup(track)

        -- convert width from -1..1 to -100..100
        local pan_width = r.GetMediaTrackInfo_Value(track, "D_WIDTH") * 100

        _, pan_width = r.ImGui_DragDouble(Ctx, '##PanInfoWidth', pan_width, 1, -100, 100, "Width = %.1f")

        if r.ImGui_IsItemEdited(Ctx) then reaper.SetMediaTrackInfo_Value(track, "D_WIDTH", pan_width / 100.0) end
        if width then r.ImGui_PopItemWidth(Ctx) end
        AddPanPopup(track)
    end
    r.ImGui_EndGroup(Ctx)
end

function Widget_TrackName(track)
    local _
    local rv, title = r.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    local flags = r.ImGui_InputTextFlags_None()
    if rv == false then
        title = "MASTER"
        flags = r.ImGui_InputTextFlags_ReadOnly()
    end
    local track_num = r.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    Text(("Track %d:"):format(track_num))
    _, title = r.ImGui_InputText(Ctx, '##TrackNameInput', title, flags)
    if r.ImGui_IsItemEdited(Ctx) then
        r.GetSetMediaTrackInfo_String(track, "P_NAME", title, true)
    end
end

function Widget_SimpleButton(text, hue, width, height, saturation)
    if not saturation then saturation = 1 end
    local buttonColor  = reaper.ImGui_ColorConvertHSVtoRGB(hue, 0.6 * saturation, 0.6, 1.0)
    local hoveredColor = reaper.ImGui_ColorConvertHSVtoRGB(hue, 0.7 * saturation, 0.7, 1.0)
    local activeColor  = reaper.ImGui_ColorConvertHSVtoRGB(hue, 0.8 * saturation, 0.8, 1.0)
    r.ImGui_PushStyleColor(Ctx, r.ImGui_Col_Button(),        buttonColor)
    r.ImGui_PushStyleColor(Ctx, r.ImGui_Col_ButtonHovered(), hoveredColor)
    r.ImGui_PushStyleColor(Ctx, r.ImGui_Col_ButtonActive(),  activeColor)
    r.ImGui_Button(Ctx, text, width, height)
    r.ImGui_PopStyleColor(Ctx, 3)
end

function Widget_FXToggle(track, width)
    local fx_enabled = r.GetMediaTrackInfo_Value(track, "I_FXEN") ~= 0
    if fx_enabled then
        Widget_SimpleButton("FX###FXToggle", 2/7, width)
    else
        Widget_SimpleButton("FX###FXToggle", 0, width)
    end
    if r.ImGui_IsItemActivated(Ctx) then
        r.SetMediaTrackInfo_Value(track, "I_FXEN", fx_enabled and 0 or 1)
    end
    if r.ImGui_IsItemHovered(Ctx) and r.ImGui_IsMouseClicked(Ctx, r.ImGui_MouseButton_Right()) then
        r.Main_OnCommand(actions.show_fx_chain, 0)
    end
    if r.ImGui_IsItemHovered(Ctx) then
        r.ImGui_SetTooltip(Ctx, "FX Chain")
    end
end

function Widget_MuteButton(track, size)
    local track_muted = r.GetMediaTrackInfo_Value(track, "B_MUTE") ~= 0
    if track_muted then
        Widget_SimpleButton("M##Mute", 0, size, size)
    else
        Widget_SimpleButton("M##Mute", 0, size, size, 0)
    end
    local mods = r.ImGui_GetKeyMods(Ctx)
    if r.ImGui_IsItemActivated(Ctx) then
        if HeldCtrl(mods) and HeldAlt(mods) then
            r.Main_OnCommand(actions.unmute_all, 0)
            r.Main_OnCommand(actions.mute_toggle, 0)
        elseif HeldCtrl(mods) then
            r.Main_OnCommand(actions.unmute_all, 0)
        else
            -- r.SetMediaTrackInfo_Value(track, "B_MUTE", track_muted and 0 or 1)
            r.Main_OnCommand(actions.mute_toggle, 0)
        end
    end
    if r.ImGui_IsItemHovered(Ctx) then
        r.ImGui_SetTooltip(Ctx, "Mute")
    end
end

function Widget_SoloButton(track, size)
    local solo_state = r.GetMediaTrackInfo_Value(track, "I_SOLO")
    local text, hue, sat
    if solo_state == const.solo.ignore_routing then
        text = "SR"
    elseif solo_state == const.solo.safe_in_place or solo_state == const.solo.unused_safe then
        text = "SD"
    else
        text = "S"
    end
    if solo_state == const.solo.ignore_routing or solo_state == const.solo.in_place then
        hue = 1/7
        sat = 1.2
    else
        hue = 0
        sat = 0
    end
    Widget_SimpleButton(text .. "###Solo", hue, size, size, sat)
    if r.ImGui_IsItemActivated(Ctx) then
        local mods = r.ImGui_GetKeyMods(Ctx)
        if HeldCtrl(mods) and HeldShift(mods) then
            r.Main_OnCommand(actions.solo_defeat, 0)
        elseif HeldCtrl(mods) then
            r.Main_OnCommand(actions.unsolo_all, 0)
        elseif HeldAlt(mods) then
            if solo_state == const.solo.off or solo_state == const.solo.safe_in_place or solo_state == const.solo.unused_safe then
                r.SetMediaTrackInfo_Value(track, "I_SOLO", const.solo.ignore_routing)
            else
                r.SetMediaTrackInfo_Value(track, "I_SOLO", const.solo.off)
            end
        else
            r.Main_OnCommand(actions.solo_toggle, 0)
        end
    end
    if r.ImGui_IsItemHovered(Ctx) then
        if solo_state == const.solo.ignore_routing then
            r.ImGui_SetTooltip(Ctx, "Ignore routing")
        elseif solo_state == const.solo.safe_in_place then
            r.ImGui_SetTooltip(Ctx, "Solo defeated")
        else
            r.ImGui_SetTooltip(Ctx, "Solo")
        end
    end
end

function Widget_PhaseButton(track, width)
    -- Text(r.GetMediaTrackInfo_Value(track, "B_PHASE"))
    local phase_inverted = r.GetMediaTrackInfo_Value(track, "B_PHASE") ~= 0
    if phase_inverted then
        Widget_SimpleButton("P##Phase", 5/7, width)
    else
        Widget_SimpleButton("P##Phase", 5/7, width, nil, 0)
    end
    if r.ImGui_IsItemActivated(Ctx) then
        r.SetMediaTrackInfo_Value(track, "B_PHASE", phase_inverted and 0 or 1)
    end
    if r.ImGui_IsItemActive(Ctx) or r.ImGui_IsItemHovered(Ctx) then
        r.ImGui_SetTooltip(Ctx, "Invert phase")
    end
end

function Widget_EnvelopeButton(track, width)
    Widget_SimpleButton("Env###Envelopes", 0, width, nil, 0)
    if r.ImGui_IsItemActivated(Ctx) then
        r.Main_OnCommand(actions.show_envelopes, 0)
    end
    if r.ImGui_IsItemHovered(Ctx) then
        r.ImGui_SetTooltip(Ctx, "Envelopes")
    end
end

--[[==============================================================================================
    the actual UI
================================================================================================]]

function MainLoop()
    if r.ImGui_IsCloseRequested(Ctx) then
        r.ImGui_DestroyContext(Ctx)
        return
    end

    local track = r.GetSelectedTrack2(0, 0, true)

    -- populate the window with widgets and shit
    FrameMain(track)

    -- loop!
    r.defer(MainLoop)
end

function FrameMain(track)
    if not track then
        r.ImGui_Begin(Ctx, 'wnd', nil, r.ImGui_WindowFlags_NoDecoration())
        r.ImGui_End(Ctx)
        return
    end

    local _
    -- the viewport is the base container itself
    -- for the next imgui window created, resize the window to the container
    r.ImGui_SetNextWindowPos(Ctx, r.ImGui_Viewport_GetPos(Viewport))
    r.ImGui_SetNextWindowSize(Ctx, r.ImGui_Viewport_GetSize(Viewport))

    -- create a window context, and give it a NoDecoration() flag
    r.ImGui_Begin(Ctx, 'wnd', nil, r.ImGui_WindowFlags_NoDecoration())

    -- make all items be (full-width - minimum amount)
    r.ImGui_PushItemWidth(Ctx, -FLT_MIN);

    --[[ 
        set up values for widgets
    ]]

    -- setup reaper_vol
    local reaper_vol

    if track then
        reaper_vol = r.GetMediaTrackInfo_Value(track, "D_VOL")
        -- min reaper volume is -144, anything lower is treated as -inf
        if reaper_vol < DBToReaperVol(const.vol.db_min) then reaper_vol = const.vol.reaper_inf end
    else
        reaper_vol = const.vol.reaper_inf
    end

    -- get peak volume for history display
    local peak_reaper = r.Track_GetPeakInfo(track, 0)
    local peak_float = ReaperToFloatVol(peak_reaper)
    AppendLineData(peak_float)

    local item_spacing_x, item_spacing_y = r.ImGui_GetStyleVar(Ctx, r.ImGui_StyleVar_ItemSpacing())

    --[[ 
        widgets
    ]]

    Widget_TrackName(track)

    if not width then width = 38 end
    _, width = r.ImGui_DragDouble(Ctx, '##width', width, 0.1, 38, 100)
    if not height then height = 200 end
    _, height = r.ImGui_DragDouble(Ctx, '##height', height, 0.1, 50, 300)

    Text([[peak_reaper]])
    Text(peak_reaper)

    Text([[peak_float]])
    Text(peak_float)

    Text("item_spacing_x")
    Text(inspect({item_spacing_x, item_spacing_y}))

    Text([[ashdajbvshdkj]])

    Widget_PanInfo(track, nil, item_spacing_x)

    r.ImGui_BeginGroup(Ctx)

    Widget_History(mem.disp.lines_data, width, height)
    r.ImGui_SameLine(Ctx)
    Widget_VolumeSlider(track, reaper_vol, width, height)

    Widget_VolumeInfo(track, reaper_vol, width * 2 + item_spacing_x)
    r.ImGui_EndGroup(Ctx)

    r.ImGui_SameLine(Ctx)
    r.ImGui_BeginGroup(Ctx)
    Widget_MuteButton(track, 24)
    Widget_SoloButton(track, 24)
    Widget_FXToggle(track, 24)
    Widget_EnvelopeButton(track, 24)
    Widget_PhaseButton(track, 24)
    r.ImGui_EndGroup(Ctx)
    

    -- end the window context
    r.ImGui_End(Ctx)
end

MainLoop()
