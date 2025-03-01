local isSearching = false
local menuHeader = "shopui_title_sm_hangar"

if Config.CustomMenuEnabled then
    local txd = CreateRuntimeTxd('Custom_Menu_Head')
    CreateRuntimeTextureFromImage(txd, 'Custom_Menu_Head', 'header.png')
    menuHeader = "Custom_Menu_Head"
end

local mainMenu = UIMenu.New(Config.MenuTitle or "", "", 20, 20, false, menuHeader, menuHeader)

local sharemenu, shareddancemenu, favmenu, infomenu

local EmoteTable = {}
local FavEmoteTable = {}
local DanceTable = {}
local AnimalTable = {}
local PropETable = {}
local WalkTable = {}
local FaceTable = {}
local ShareTable = {}
local FavoriteEmote = ""

if Config.FavKeybindEnabled then
    RegisterCommand('emotefav', function() FavKeybind() end, false)
    RegisterKeyMapping("emotefav", Translate("register_fav_anim"), "keyboard", Config.FavKeybind)
    local doingFavoriteEmote = false
    function FavKeybind()
        if doingFavoriteEmote == false then
            doingFavoriteEmote = true
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                if FavoriteEmote ~= "" and (not CanUseFavKeyBind or CanUseFavKeyBind()) then
                    EmoteCommandStart(nil, { FavoriteEmote, 0 })
                    Wait(500)
                end
            end
        else
            EmoteCancel()
            doingFavoriteEmote = false
        end
    end
end

function AddEmoteMenu(menu)
    local submenu = UIMenu.New(Translate('emotes'), "", true, true)
    local submenuButton = UIMenuItem.New(Translate('emotes'), "")
    submenuButton.Activated = function(ParentMenu, SelectedItem)
        menu:SwitchTo(submenu, 1, true)
    end
    menu:AddItem(submenuButton)
    if Config.Search then
        submenu:AddItem(UIMenuItem.New(Translate('searchemotes'), ""))
        table.insert(EmoteTable, Translate('searchemotes'))
    end

    local dancemenu = UIMenu.New(Translate('danceemotes'), "", true, true)
    local dancemenuButton = UIMenuItem.New(Translate('danceemotes'), "")
    dancemenuButton.Activated = function(ParentMenu, SelectedItem)
        submenu:SwitchTo(dancemenu, 1, true)
    end
    submenu:AddItem(dancemenuButton)
    local animalmenu
    if Config.AnimalEmotesEnabled then
        animalmenu = UIMenu.New(Translate('animalemotes'), "", true, true)
        local animalmenuButton = UIMenuItem.New(Translate('animalemotes'), "")
        animalmenuButton.Activated = function(ParentMenu, SelectedItem)
            submenu:SwitchTo(animalmenu, 1, true)
        end
        submenu:AddItem(animalmenuButton)
        table.insert(EmoteTable, Translate('animalemotes'))
    end
    local propmenu = UIMenu.New(Translate('propemotes'), "", true, true)
    local propmenuButton = UIMenuItem.New(Translate('propemotes'), "")
    propmenuButton.Activated = function(ParentMenu, SelectedItem)
        submenu:SwitchTo(propmenu, 1, true)
    end
    submenu:AddItem(propmenuButton)
    table.insert(EmoteTable, Translate('danceemotes'))
    table.insert(EmoteTable, Translate('danceemotes'))
    if Config.SharedEmotesEnabled then
        sharemenu = UIMenu.New(Translate('shareemotes'), Translate('shareemotesinfo'))
        local sharemenuButton = UIMenuItem.New(Translate('shareemotes'), "")
        sharemenuButton.Activated = function(ParentMenu, SelectedItem)
            submenu:SwitchTo(sharemenu, 1, true)
        end
        submenu:AddItem(sharemenuButton)
        shareddancemenu = UIMenu.New(Translate('sharedanceemotes'), "")
        local shareddancemenuButton = UIMenuItem.New(Translate('sharedanceemotes'), "")
        shareddancemenuButton.Activated = function(ParentMenu, SelectedItem)
            sharemenu:SwitchTo(shareddancemenu, 1, true)
        end
        sharemenu:AddItem(shareddancemenuButton)
        table.insert(ShareTable, 'none')
        table.insert(EmoteTable, Translate('shareemotes'))
    end
    -- -- Temp var to be able to sort every emotes in the fav list
    local favEmotes = {}
    if not Config.SqlKeybinding then
        favmenu = UIMenu.New(Translate('favoriteemotes'), Translate('favoriteinfo'))
        local favmenuButton = UIMenuItem.New(Translate('favoriteemotes'), "")
        favmenuButton.Activated = function(ParentMenu, SelectedItem)
            submenu:SwitchTo(favmenu, 1, true)
        end
        submenu:AddItem(favmenuButton)
        favmenu:AddItem(UIMenuItem.New(Translate('prop2info'), ""))
        favmenu:AddItem(UIMenuItem.New(Translate('rfavorite'), Translate('rfavorite')))
        -- Add two elements as offset
        table.insert(FavEmoteTable, Translate('rfavorite'))
        table.insert(FavEmoteTable, Translate('rfavorite'))
        table.insert(EmoteTable, Translate('favoriteemotes'))
    else
        table.insert(EmoteTable, "keybinds")
        submenu:AddItem(UIMenuItem.New(Translate('keybinds'),
            Translate('keybindsinfo') .. " /emotebind [~y~num4-9~w~] [~g~emotename~w~]"))
    end
    for a, b in PairsByKeys(RP.Emotes) do
        local x, y, z = table.unpack(b)
        submenu:AddItem(UIMenuItem.New(z, "/e (" .. a .. ")"))
        table.insert(EmoteTable, a)
        if not Config.SqlKeybinding then
            favEmotes[a] = z
        end
    end
    for a, b in PairsByKeys(RP.Dances) do
        local x, y, z = table.unpack(b)
        dancemenu:AddItem(UIMenuItem.New(z, "/e (" .. a .. ")"))
        if Config.SharedEmotesEnabled then
            shareddancemenu:AddItem(UIMenuItem.New(z, "/nearby (" .. a .. ")"))
        end
        table.insert(DanceTable, a)
        if not Config.SqlKeybinding then
            favEmotes[a] = z
        end
    end
    if Config.AnimalEmotesEnabled then
        for a, b in PairsByKeys(RP.AnimalEmotes) do
            local x, y, z = table.unpack(b)
            animalmenu:AddItem(UIMenuItem.New(z, "/e (" .. a .. ")"))
            table.insert(AnimalTable, a)
            if not Config.SqlKeybinding then
                favEmotes[a] = z
            end
        end
    end
    if Config.SharedEmotesEnabled then
        for a, b in PairsByKeys(RP.Shared) do
            local x, y, z, otheremotename = table.unpack(b)
            local shareitem = UIMenuItem.New(z,
                "/nearby (~g~" ..
                a ..
                "~w~)" ..
                (otheremotename and " " .. Translate('makenearby') .. " (~y~" .. otheremotename .. "~w~)" or ""))
            sharemenu:AddItem(shareitem)
            table.insert(ShareTable, a)
        end
    end
    for a, b in PairsByKeys(RP.PropEmotes) do
        local x, y, z = table.unpack(b)
        local propitem = b.AnimationOptions.PropTextureVariations and
            UIMenuListItem.New(z, b.AnimationOptions.PropTextureVariations, 1, "/e (" .. a .. ")") or
            UIMenuItem.New(z, "/e (" .. a .. ")")
        propmenu:AddItem(propitem)
        table.insert(PropETable, a)
        if not Config.SqlKeybinding then
            favEmotes[a] = z
        end
    end
    if not Config.SqlKeybinding then
        -- Add the emotes to the fav menu
        for emoteName, emoteLabel in PairsByKeys(favEmotes) do
            favmenu:AddItem(UIMenuItem.New(emoteLabel, Translate('set') .. emoteLabel .. Translate('setboundemote')))
            table.insert(FavEmoteTable, emoteName)
        end
        favmenu.OnItemSelect = function(sender, item, index)
            if FavEmoteTable[index] == Translate('rfavorite') then
                FavoriteEmote = ""
                SimpleNotify(Translate('rfavorite'))
                return
            end
            if Config.FavKeybindEnabled then
                FavoriteEmote = FavEmoteTable[index]
                SimpleNotify("~o~" .. FirstToUpper(FavoriteEmote) .. Translate('newsetemote'))
            end
        end
    end
    favEmotes = nil
    -- Ped Emote on Change Index
    dancemenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(DanceTable[newindex], "dances")
    end
    propmenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(PropETable[newindex], "props")
    end
    submenu.OnIndexChange = function(menu, newindex)
        if newindex > 6 then
            ClearPedTaskPreview()
            EmoteMenuStartClone(EmoteTable[newindex], "emotes")
        end
    end
    dancemenu.OnMenuOpen = function(menu)
        ShowPedMenu()
    end
    propmenu.OnMenuOpen = function(menu)
        ShowPedMenu()
    end
    dancemenu.OnMenuClose = function(menu)
        ClearPedTaskPreview()
    end
    -- --------
    dancemenu.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(DanceTable[index], "dances")
    end
    if Config.AnimalEmotesEnabled then
        animalmenu.OnItemSelect = function(sender, item, index)
            EmoteMenuStart(AnimalTable[index], "animals")
        end
    end
    if Config.SharedEmotesEnabled then
        sharemenu.OnItemSelect = function(sender, item, index)
            if ShareTable[index] ~= 'none' then
                local target, distance = GetClosestPlayer()
                if (distance ~= -1 and distance < 3) then
                    TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), ShareTable[index])
                    SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                else
                    SimpleNotify(Translate('nobodyclose'))
                end
            end
        end
        shareddancemenu.OnItemSelect = function(sender, item, index)
            local target, distance = GetClosestPlayer()
            if (distance ~= -1 and distance < 3) then
                TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), DanceTable[index], 'Dances')
                SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
            else
                SimpleNotify(Translate('nobodyclose'))
            end
        end
    end
    propmenu.OnItemSelect = function(menu, item, index)
        EmoteMenuStart(PropETable[index], "props")
    end
    propmenu.OnListSelect = function(menu, item, newindex)
        local realIndex = nil
        for i = 1, #menu.Items do
            if menu.Items[i] == item then
                realIndex = i
                break
            end
        end
        EmoteMenuStart(PropETable[realIndex], "props", newindex-1)
    end
    submenu.OnItemSelect = function(sender, item, index)
        if Config.Search and EmoteTable[index] == Translate('searchemotes') then
            EmoteMenuSearch(submenu)
        elseif EmoteTable[index] ~= Translate('favoriteemotes') then
            EmoteMenuStart(EmoteTable[index], "emotes")
        end
    end
    submenu.OnMenuClose = function(menu)
        if not isSearching then
            ClosePedMenu()
        end
    end
end

if Config.Search then
    local ignoredCategories = {
        ["Walks"] = true,
        ["Expressions"] = true,
        ["Shared"] = not Config.SharedEmotesEnabled
    }

    function EmoteMenuSearch(lastMenu)
        ClosePedMenu()
        local favEnabled = not Config.SqlKeybinding and Config.FavKeybindEnabled
        AddTextEntry("PM_NAME_CHALL", Translate('searchinputtitle'))
        DisplayOnscreenKeyboard(1, "PM_NAME_CHALL", "", "", "", "", "", 30)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(100)
        end
        local input = GetOnscreenKeyboardResult()
        if input ~= nil then
            local results = {}
            for k, v in pairs(RP) do
                if not ignoredCategories[k] then
                    for a, b in pairs(v) do
                        if string.find(string.lower(a), string.lower(input)) or (b[3] ~= nil and string.find(string.lower(b[3]), string.lower(input))) then
                            table.insert(results, {table = k, name = a, data = b})
                        end
                    end
                end
            end

            if #results > 0 then
                isSearching = true

                local searchMenu = UIMenu.New(string.format('%s '..Translate('searchmenudesc')..' ~r~%s~w~', #results, input), "")
                local sharedDanceMenu
                if favEnabled then
                    searchMenu:AddItem(UIMenuItem.New(Translate('rfavorite'), Translate('rfavorite')))
                end

                if Config.SharedEmotesEnabled then
                    sharedDanceMenu = UIMenu.New(Translate('sharedanceemotes'), "", true, true)
                end

                table.sort(results, function(a, b) return a.name < b.name end)
                for k, v in pairs(results) do
                    local desc = ""
                    if v.table == "Shared" then
                        local otheremotename = v.data[4]
                        if otheremotename == nil then
                           desc = "/nearby (~g~" .. v.name .. "~w~)"
                        else
                           desc = "/nearby (~g~" .. v.name .. "~w~) " .. Translate('makenearby') .. " (~y~" .. otheremotename .. "~w~)"
                        end
                    else
                        desc = "/e (" .. v.name .. ")" .. (favEnabled and "\n" .. Translate('searchshifttofav') or "")
                    end

                    if v.data.AnimationOptions and v.data.AnimationOptions.PropTextureVariations then
                        searchMenu:AddItem(UIMenuListItem.New(v.data[3], v.data.AnimationOptions.PropTextureVariations, 1, desc))
                    else
                        searchMenu:AddItem(UIMenuItem.New(v.data[3], desc))
                    end

                    if v.table == "Dances" and Config.SharedEmotesEnabled then
                        sharedDanceMenu:AddItem(UIMenuItem.New(v.data[3], ""))
                    end
                end

                if favEnabled then
                    table.insert(results, 1, Translate('rfavorite'))
                end


                searchMenu.OnMenuChanged = function(menu, newmenu, forward)
                    isSearching = false
                    ShowPedMenu()
                end

                searchMenu.OnIndexChange = function(menu, newindex)
                    local data = results[newindex]

                    ClearPedTaskPreview()
                    if data.table == "Emotes" or data.table == "Dances" then
                        EmoteMenuStartClone(data.name, string.lower(data.table))
                    elseif data.table == "PropEmotes" then
                        EmoteMenuStartClone(data.name, "props")
                    elseif data.table == "AnimalEmotes" then
                        EmoteMenuStartClone(data.name, "animals")
                    end
                end


                searchMenu.OnItemSelect = function(sender, item, index)
                    local data = results[index]

                    if data == Translate('sharedanceemotes') then return end
                    if data == Translate('rfavorite') then
                        FavoriteEmote = ""
                        SimpleNotify(Translate('rfavorite'))
                        return
                    end

                    if favEnabled and IsControlPressed(0, 21) then
                        if data.table ~= "Shared" then
                            FavoriteEmote = data.name
                            SimpleNotify("~o~" .. FirstToUpper(data.name) .. Translate('newsetemote'))
                        else
                            SimpleNotify(Translate('searchcantsetfav'))
                        end
                    elseif data.table == "Emotes" or data.table == "Dances" then
                        EmoteMenuStart(data.name, string.lower(data.table))
                    elseif data.table == "PropEmotes" then
                        EmoteMenuStart(data.name, "props")
                    elseif data.table == "AnimalEmotes" then
                        EmoteMenuStart(data.name, "animals")
                    elseif data.table == "Shared" then
                        local target, distance = GetClosestPlayer()
                        if (distance ~= -1 and distance < 3) then
                            TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), data.name)
                            SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                        else
                            SimpleNotify(Translate('nobodyclose'))
                        end
                    end
                end

                searchMenu.OnListSelect = function(menu, item, newindex)
                    for i = 1, #menu.Items do
                        if menu.Items[i] == item then
                            realIndex = i
                            break
                        end
                    end
                    EmoteMenuStart(results[realIndex].name, "props", newindex-1)
                end

                if Config.SharedEmotesEnabled then
                    if #sharedDanceMenu.Items > 0 then
                        table.insert(results, (favEnabled and 2 or 1), Translate('sharedanceemotes'))
                        sharedDanceMenu.OnItemSelect = function(sender, item, index)
                            if not LocalPlayer.state.canEmote then return end

                            local data = results[index]
                            local target, distance = GetClosestPlayer()
                            if (distance ~= -1 and distance < 3) then
                                TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), data.name, 'Dances')
                                SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                            else
                                SimpleNotify(Translate('nobodyclose'))
                            end
                        end
                    else
                        sharedDanceMenu:Clear()
                        --searchMenu:RemoveItemAt((favEnabled and 2 or 1))
                    end
                end

                searchMenu.OnMenuClose = function()
                    MenuHandler:CloseAndClearHistory()
                    results = {}
                    ClosePedMenu()
                end

                MenuHandler:CloseAndClearHistory()
                searchMenu:Visible(true)
                ShowPedMenu()
            else
                SimpleNotify(string.format(Translate('searchnoresult')..' ~r~%s~w~', input))
            end
        end
    end
end


function AddCancelEmote(menu)
    local newitem = UIMenuItem.New(Translate('cancelemote'), Translate('cancelemoteinfo'))
    menu:AddItem(newitem)
    newitem.Activated = function()
        EmoteCancel()
        DestroyAllProps()
    end
end

ShowPedPreview = function(menu)
    menu.OnItemSelect = function(sender, item, index)
        if (index == 1) then
            isSearching = false
            ShowPedMenu()
        elseif index == 4 then
            ShowPedMenu(true)
        end
    end
end

function AddWalkMenu(menu)
    local submenu = UIMenu.New(Translate('walkingstyles'), "")
    local submenuButton = UIMenuItem.New(Translate('walkingstyles'), "")

    menu:AddItem(submenuButton)
    submenuButton.Activated = function()
        menu:SwitchTo(submenu, 1, true)
    end

    local walkreset = UIMenuItem.New(Translate('normalreset'), Translate('resetdef'))
    submenu:AddItem(walkreset)
    table.insert(WalkTable, Translate('resetdef'))
    local sortedWalks = {}
    for a, b in PairsByKeys(RP.Walks) do
        local x, label = table.unpack(b)
        if x == "move_m@injured" then
            table.insert(sortedWalks, 1, { label = label or a, anim = x })
        else
            table.insert(sortedWalks, { label = label or a, anim = x })
        end
    end
    for _, walk in ipairs(sortedWalks) do
        submenu:AddItem(UIMenuItem.New(walk.label, "/walk (" .. string.lower(walk.label) .. ")"))
        table.insert(WalkTable, walk.anim)
    end
    submenu.OnItemSelect = function(sender, item, index)
        if item == walkreset then
            ResetWalk()
            DeleteResourceKvp("walkstyle")
        else
            WalkMenuStart(WalkTable[index])
        end
    end
end

function AddFaceMenu(menu)
    local submenu = UIMenu.New(Translate('moods'), "I love sausages")
    local submenuButton = UIMenuItem.New(Translate('moods'), "")
    menu:AddItem(submenuButton)

    submenuButton.Activated = function()
        menu:SwitchTo(submenu, 1, true)
    end
    local facereset = UIMenuItem.New(Translate('normalreset'), Translate('resetdef'))
    submenu:AddItem(facereset)
    table.insert(FaceTable, "")
    for name, data in PairsByKeys(RP.Expressions) do
        local faceitem = UIMenuItem.New(data[2] or name, "")
        submenu:AddItem(faceitem)
        table.insert(FaceTable, name)
    end
    submenu.OnMenuClose = function(menu)
        ClosePedMenu()
    end
    submenu.OnIndexChange = function(menu, newindex)
        EmoteMenuStartClone(FaceTable[newindex], "expression")
    end
    submenu.OnItemSelect = function(sender, item, index)
        if item ~= facereset then
            EmoteMenuStart(FaceTable[index], "expression")
        else
            DeleteResourceKvp("expression")
            ClearFacialIdleAnimOverride(PlayerPedId())
        end
    end
end

function AddInfoMenu(menu)
    infomenu = UIMenu.New(Translate('infoupdate'), "~y~The RPEmotes Team & Collaborators", true, true)
    infomenu:MenuAlignment(MenuAlignment.LEFT)
    local infomenuButton = UIMenuItem.New(Translate('infoupdate'), "")
    menu:AddItem(infomenuButton)
    infomenuButton.Activated = function()
        menu:SwitchTo(infomenu, 1, true)
    end
    for _, v in ipairs(Config.Credits) do
        local item = UIMenuItem.New(v.title, v.subtitle or "")
        infomenu:AddItem(item)
    end
end

function OpenEmoteMenu()
    if IsEntityDead(PlayerPedId()) then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "RPEmotes", Translate('dead') }
        })
        return
    end

    if (IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId())) and not Config.AllowInWater then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "RPEmotes", Translate('swimming') }
        })
        return
    end

    if MenuHandler:IsAnyMenuOpen() then
        MenuHandler:CloseAndClearHistory()
    else
        mainMenu:Visible(true)
    end
end

LoadAddonEmotes()
AddEmoteMenu(mainMenu)
AddCancelEmote(mainMenu)
if Config.PreviewPed then
    ShowPedPreview(mainMenu)
end
if Config.WalkingStylesEnabled then
    AddWalkMenu(mainMenu)
end
if Config.ExpressionsEnabled then
    AddFaceMenu(mainMenu)
end
AddInfoMenu(mainMenu)

RegisterNetEvent("rp:Update", function(state)
    UpdateAvailable = state
    AddInfoMenu(mainMenu)
end)

RegisterNetEvent("rp:RecieveMenu", function()
    OpenEmoteMenu()
end)


-- While ped is dead, don't show menus
CreateThread(function()
    while true do
        Wait(500)
        if IsEntityDead(PlayerPedId()) then
            MenuHandler:CloseAllMenus()
        end
        if (IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId())) and not Config.AllowInWater then
            -- cancel emote, destroy props and close menu
            if IsInAnimation then
                EmoteCancel()
            end
            MenuHandler:CloseAllMenus()
        end
    end
end)
