local isOpen = false

-- Name of the resource that has the HUD refresh export
local HUD_RES = 'Az-Framework'

-- Make sure Config exists client-side
Config = Config or {}

-- ===== HUD REFRESH EXPORT WRAPPER =====
local function safeRefreshHUD()
    local ok, err = pcall(function()
        exports[HUD_RES]:refreshHUD()
        -- exports[HUD_RES]:updateHUD()
    end)

    if not ok then
        print(("[az-jobcenter] Failed to call %s HUD export: %s"):format(HUD_RES, tostring(err)))
    else
        print(("[az-jobcenter] HUD refresh requested via %s:refreshHUD()"):format(HUD_RES))
    end
end

-- ===== JOB CENTER UI OPEN =====
local function openJobCenter(payload)
    isOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        player = payload.player,
        jobs = payload.jobs
    })
end

-- Command to open job center (fallback / debug)
RegisterCommand('jobcenter', function()
    if isOpen then return end
    TriggerServerEvent('az_jobcenter:open')
end, false)

RegisterNetEvent('az_jobcenter:show', function(payload)
    openJobCenter(payload)
end)

RegisterNetEvent('az_jobcenter:updateCurrentJob', function(jobId, jobLabel)
    SendNUIMessage({
        action = 'updateJob',
        jobId = jobId,
        jobLabel = jobLabel
    })

    if jobLabel and jobLabel ~= "" then
        TriggerEvent('hud:setDepartment', jobLabel)
    else
        TriggerEvent('hud:setDepartment', jobId or "Unemployed")
    end

    safeRefreshHUD()
end)

RegisterNetEvent('az_jobcenter:notify', function(message, ntype)
    ntype = ntype or 'info'
    print(('[JobCenter][%s] %s'):format(ntype:upper(), message))

    SendNUIMessage({
        action = 'notify',
        message = message,
        ntype = ntype
    })
end)

RegisterNUICallback('applyJob', function(data, cb)
    if data and data.jobId then
        TriggerServerEvent('az_jobcenter:applyJob', data.jobId)
    end
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb({})
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and isOpen then
        SetNuiFocus(false, false)
    end

    if lib and lib.isTextUIOpen and lib.isTextUIOpen() then
        lib.hideTextUI()
    end
end)

-- =========================================================
-- =               JOB CENTER NPC / BLIPS / TEXT UI       =
-- =========================================================

local spawnedNPCs = {}
local textUIActiveFor = nil

local function loadModel(model)
    if type(model) == "string" then
        model = joaat(model)
    end

    if not IsModelValid(model) then
        print(("[az-jobcenter] Invalid ped model: %s"):format(tostring(model)))
        return nil
    end

    RequestModel(model)
    local time = GetGameTimer()
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() - time > 5000 then
            print(("[az-jobcenter] Timed out loading model %s"):format(tostring(model)))
            return nil
        end
    end

    return model
end

local function createJobCenterBlip(npcConfig, coords)
    if not Config.EnableJobCenterBlips then return end

    local sprite = npcConfig.blipSprite or (Config.JobCenterBlip and Config.JobCenterBlip.sprite) or 407 -- briefcase-ish
    local colour = npcConfig.blipColour or (Config.JobCenterBlip and Config.JobCenterBlip.color) or 3   -- light blue
    local scale  = npcConfig.blipScale  or (Config.JobCenterBlip and Config.JobCenterBlip.scale) or 0.9

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(npcConfig.blipLabel or npcConfig.label or "Job Center")
    EndTextCommandSetBlipName(blip)

    return blip
end

local function spawnJobCenterNPCs()
    if not Config.EnableJobCenterNPCs then
        print("[az-jobcenter] Job Center NPCs disabled in config.")
        return
    end

    if not Config.JobCenterNPCs or #Config.JobCenterNPCs == 0 then
        print("[az-jobcenter] No Job Center NPCs configured.")
        return
    end

    print(("[az-jobcenter] Spawning %d Job Center NPCs..."):format(#Config.JobCenterNPCs))

    for i, data in ipairs(Config.JobCenterNPCs) do
        if data.enabled ~= false and data.coords then
            local model = loadModel(data.model or "cs_bankman")
            if model then
                local coords = data.coords
                local heading = data.heading or 0.0

                local ped = CreatePed(
                    4,                    -- CIVMALE
                    model,
                    coords.x, coords.y, coords.z - 1.0,
                    heading,
                    false, true
                )

                if ped and ped > 0 then
                    SetEntityAsMissionEntity(ped, true, false)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedFleeAttributes(ped, 0, false)
                    SetPedCombatAttributes(ped, 46, true)
                    SetEntityInvincible(ped, true)
                    FreezeEntityPosition(ped, true)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

                    local npcData = {
                        ped = ped,
                        coords = vector3(coords.x, coords.y, coords.z),
                        label = data.label or "Job Center",
                        interactDistance = data.interactDistance or 2.0,
                        icon = data.icon or "briefcase"
                    }

                    npcData.blip = createJobCenterBlip(data, coords)

                    spawnedNPCs[#spawnedNPCs + 1] = npcData

                    print(("[az-jobcenter] Spawned Job Center NPC #%d at %.2f %.2f %.2f"):format(
                        i, coords.x, coords.y, coords.z
                    ))
                else
                    print(("[az-jobcenter] Failed to create NPC #%d"):format(i))
                end

                SetModelAsNoLongerNeeded(model)
            end
        end
    end

    print(("[az-jobcenter] Total NPCs spawned: %d"):format(#spawnedNPCs))
end

local function handleNPCInteractionLoop()
    CreateThread(function()
        while true do
            local sleep = 750

            if #spawnedNPCs > 0 then
                local playerPed = PlayerPedId()
                local pCoords = GetEntityCoords(playerPed)

                local closestData, closestDist

                for _, npc in ipairs(spawnedNPCs) do
                    local dist = #(pCoords - npc.coords)
                    if not closestDist or dist < closestDist then
                        closestDist = dist
                        closestData = npc
                    end
                end

                if closestData and closestDist and closestDist < (closestData.interactDistance or 2.0) then
                    sleep = 0

                    -- Only try to use TextUI if ox_lib is ready
                    if lib and lib.showTextUI and lib.hideTextUI then
                        if textUIActiveFor ~= closestData then
                            textUIActiveFor = closestData

                            lib.showTextUI(("[E] - %s"):format(closestData.label or "Open Job Center"), {
                                position = "left-center",
                                icon = closestData.icon or "briefcase",
                                iconColor = "#00b4ff",
                                style = {
                                    borderRadius = 6,
                                    backgroundColor = "#111827",
                                    borderColor = "#00b4ff",
                                    borderWidth = 1,
                                    color = "white",
                                    padding = "6px 10px",
                                    fontSize = "14px"
                                }
                            })
                        end
                    else
                        -- Fallback debug: simple 3D marker if lib isn't ready
                        DrawMarker(2, closestData.coords.x, closestData.coords.y, closestData.coords.z + 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            0.2, 0.2, 0.2,
                            0, 150, 255, 180, false, true, 2, nil, nil, false)
                    end

                    -- Press E to open Job Center
                    if IsControlJustReleased(0, 38) then -- E
                        if not isOpen then
                            TriggerServerEvent('az_jobcenter:open')
                        end
                    end
                else
                    if textUIActiveFor and lib and lib.hideTextUI then
                        lib.hideTextUI()
                        textUIActiveFor = nil
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

CreateThread(function()
    spawnJobCenterNPCs()
    handleNPCInteractionLoop()
end)
