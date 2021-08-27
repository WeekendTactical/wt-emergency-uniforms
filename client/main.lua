local display = false
local formattedUniforms = {}
local isLoggedIn = true
PlayerJob = {}

for name, outfit in pairs(Config.LSPD) do
    if not formattedUniforms[name] then
        formattedUniforms[name] = {
            imageUrl = outfit.imageUrl,
            gender = outfit.gender,
            name = name,
        }
    end
end



local function setOutfit(outfit)
    local ped = PlayerPedId()

    RequestModel(outfit.ped)

    while not HasModelLoaded(outfit.ped) do
        Wait(0)
    end

    if GetEntityModel(ped) ~= GetHashKey(outfit.ped) then
        SetPlayerModel(PlayerId(), outfit.ped)
    end

    ped = PlayerPedId()

    for _, comp in ipairs(outfit.components) do
       SetPedComponentVariation(ped, comp[1], comp[2] - 1, comp[3] - 1, 0)
    end

    for _, comp in ipairs(outfit.props) do
        if comp[2] == 0 then
            ClearPedProp(ped, comp[1])
        else
            SetPedPropIndex(ped, comp[1], comp[2] - 1, comp[3] - 1, true)
        end
    end
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function SaveSkin()
	local model = GetEntityModel(PlayerPedId())
    clothing = json.encode(skinData)
	TriggerServerEvent("qb-clothing:saveSkin", model, clothing)
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = QBCore.Functions.GetPlayerData().job.onduty
    isHandcuffed = false

end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isLoggedIn then
            if PlayerJob.name == "police" then
                local pos = GetEntityCoords(PlayerPedId())  

                for k, v in pairs(Config.Locations["LSPD Lockers"]) do
                    if #(pos - vector3(v.x, v.y, v.z)) < 7.5 then
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, "~g~E~w~ - Police Uniforms ~g~G~w~ - Edit Outfits ~g~H~w~ - View Outfits")
                            if IsControlJustReleased(0, 38) then -- E
                                if display ~= 0 then
                                    TriggerEvent('nui:on', true)
                                else
                                    TriggerEvent('nui:off', true)
                                end
                            end

                            if IsControlJustPressed(0, 47) then -- G
                                TriggerEvent('qb-clothing:client:openMenu')
                            end
                            if IsControlJustPressed(0, 101) then -- H
                                TriggerEvent('qb-clothing:client:openOutfitMenu')
                            end
                        end  
                     end
                end
            else
                Citizen.Wait(2000)
            end
        end
    end
end)

RegisterNetEvent("nui:on")
AddEventHandler("nui:on", function()
    SetNuiFocus(true,true)
    display = true
    local gender = QBCore.Functions.GetPlayerData().charinfo.gender

    SendNUIMessage({
        status = "openLocker",
        uniforms = formattedUniforms,
        gender = gender
    })

end)

RegisterNetEvent("nui:off")
AddEventHandler("nui:off", function()
    SetNuiFocus(false, false)
    display = false
    SendNUIMessage({
        status = "closeLocker",
    })
end)

RegisterNUICallback("NUIFocusOff", function(data, cb)
    SetNuiFocus(false, false)
    display = false
end)

RegisterNUICallback("putOnOutfit", function(data, cb)
    setOutfit(Config.LSPD[data.name])
    SetNuiFocus(false, false)
    display = false
    QBCore.Functions.Notify("You have put on the uniform: ".. data.name, "success")
    SaveSkin()
    SendNUIMessage({
        status = "closeLocker",
    })
end)



