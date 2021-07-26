-- boiler code to override reaper search paths
local parent_dir = ({reaper.get_action_context()})[2]:match('^(.+[\\//])scripts')
package.path = parent_dir .. "?.lua"

require "lib.menu"

local menu_table = {
    {name = "#Freeze selected tracks"},
    {name = "To mono", cmd = 40901},
    {name = "To stereo", cmd = 41223},
    {name = "To multichannel", cmd = 40877},
    {name = "Unfreeze", cmd = 41644},
    {name = "Show details...", cmd = 41654},
    {name = ""},
    {name = "#Move to subproject"},
    {name = "Selected items", cmd = 41996},
    {name = "Selected tracks", cmd = 41997},
    {name = "#Subproject..."},
    {name = "Select all subproject items", cmd = "_BR_SEL_ALL_ITEMS_PIP"},
    {name = ">Options"},
    {name = "Defer rendering of subprojects (render on tab switch rather than save)", cmd = 41998, check_state = true},
    {name = "Synchronize any parent projects when playing back subproject", cmd = 41994, check_state = true},
    {name = "Prompt before automatic render of subprojects", cmd = 42334, check_state = true},
    {name = "<Leave subprojects open in tab after automatic open and render", cmd = 42012, check_state = true},
    {name = ""},
    {name = "#Render tracks to stem tracks (SWS)"},
    {name = "To mono, obeying time selection", cmd = "_SWS_AWRENDERMONOSMART"},
    {name = "To stereo, obeying time selection", cmd = "_SWS_AWRENDERSTEREOSMART"},
    {name = ">More..."},
        {name = "#Render selected tracks to stems (Post-fader)"},
        {name = "To mono", cmd = 40537},
        {name = "To stereo", cmd = 40405},
        {name = "To multichannel", cmd = 40892},
        {name = "#Limit to selected area"},
        {name = "To mono (limit to selected area)", cmd = 41718},
        {name = "To stereo (limit to selected area)", cmd = 41716},
        {name = "To multichannel (limit to selected area)", cmd = 41717},
        {name = "#Use 2nd pass render"},
        {name = "To mono (2nd pass render)", cmd = 42415},
        {name = "To stereo (2nd pass render)", cmd = 42413},
        {name = "<To multichannel (2nd pass render)", cmd = 42414},
    {name = ""},
    {name = "#Render selected items (KAWA)"},
    {name = "To stereo, obeying time selection", cmd = "_kawa_MAIN2_Render_SelectedItems_ToNewTrack"},
}

QuickMenu(SECTION_ID.MAIN, menu_table)
