local LastChange = {}
local DEBUG = false

-- Az-Framework exports handle
local fw = exports['Az-Framework']

local function dbg(...)
    if not DEBUG then return end
    local parts = {}
    for i = 1, select('#', ...) do
        parts[#parts+1] = tostring(select(i, ...))
    end
    print("[az-jobcenter]", table.concat(parts, " "))
end

--- Resolve which value to use in the WHERE clause for user_characters.charid
--- By default this tries Az-Framework's GetPlayerCharacter export, which in your logs
--- returns the current charid as a string (e.g. 17526937318528).
local function getDBKeyForPlayer(src)
    if Config.UseAzFrameworkCharacter then
        local ok, charId = pcall(function()
            return exports["Az-Framework"]:GetPlayerCharacter(src)
        end)
        if ok and charId then
            dbg("Resolved charid from Az-Framework for src", src, "=", charId)
            return tostring(charId)
        else
            dbg("Az-Framework:GetPlayerCharacter failed for src", src, "ok=", ok)
        end
    end

    -- Fallback: use first identifier if you ever swap Config.DB.identifierColumn
    local identifiers = GetPlayerIdentifiers(src)
    if not identifiers or #identifiers == 0 then
        dbg("No identifiers for src", src)
        return nil
    end

    dbg("Falling back to first identifier for src", src, identifiers[1])
    return identifiers[1]
end

local function getJobById(jobId)
    if not jobId then return nil end
    for _, job in ipairs(Config.Jobs) do
        if job.id == jobId then
            return job
        end
    end
    return nil
end

local function buildOpenPayload(src, currentJobId)
    local playerName = GetPlayerName(src) or 'Citizen'
    local job = getJobById(currentJobId)
    local jobLabel = job and job.label or 'Unemployed'
    local jobId = job and job.id or 'unemployed'

    return {
        player = {
            name = playerName,
            jobId = jobId,
            jobLabel = jobLabel
        },
        jobs = Config.Jobs
    }
end

-- Open Job Center (called from client when /jobcenter is used)
RegisterNetEvent('az_jobcenter:open', function()
    local src = source
    local key = getDBKeyForPlayer(src)

    if not key then
        dbg("No DB key for src", src, "opening with default payload")
        TriggerClientEvent('az_jobcenter:show', src, buildOpenPayload(src, nil))
        return
    end

    local q = ('SELECT `%s` FROM `%s` WHERE `%s` = ? LIMIT 1'):format(
        Config.DB.jobColumn,
        Config.DB.table,
        Config.DB.identifierColumn
    )

    dbg("Querying current job for key", key, "SQL:", q)

    MySQL.single(q, { key }, function(row)
        local jobId
        if row and row[Config.DB.jobColumn] then
            jobId = tostring(row[Config.DB.jobColumn])
        end

        dbg("Current job for key", key, "=", jobId or "nil")
        TriggerClientEvent('az_jobcenter:show', src, buildOpenPayload(src, jobId))
    end)
end)

-- Apply for a job
RegisterNetEvent('az_jobcenter:applyJob', function(jobId)
    local src = source

    if type(jobId) ~= 'string' then return end
    jobId = jobId:match('^%s*(.-)%s*$') -- trim spaces

    local chosenJob = getJobById(jobId)
    if not chosenJob then
        TriggerClientEvent('az_jobcenter:notify', src, 'That job does not exist.', 'error')
        return
    end

    local key = getDBKeyForPlayer(src)
    if not key then
        TriggerClientEvent('az_jobcenter:notify', src, 'Could not resolve your character. Contact staff.', 'error')
        return
    end

    -- Cooldown check
    if Config.JobChangeCooldown and Config.JobChangeCooldown > 0 then
        local now = os.time()
        local last = LastChange[key] or 0
        local diff = now - last

        if diff < Config.JobChangeCooldown then
            local remaining = Config.JobChangeCooldown - diff
            local minutes = math.ceil(remaining / 60)
            TriggerClientEvent('az_jobcenter:notify', src,
                ('You can change jobs again in %d minute(s).'):format(minutes),
                'error'
            )
            return
        end
    end

    local q = ('UPDATE `%s` SET `%s` = ? WHERE `%s` = ?'):format(
        Config.DB.table,
        Config.DB.jobColumn,
        Config.DB.identifierColumn
    )

    dbg("Updating job for key", key, "to", jobId, "SQL:", q)

    MySQL.update(q, { jobId, key }, function(affected)
        if not affected or affected < 1 then
            TriggerClientEvent('az_jobcenter:notify', src, 'Database error. Job not updated.', 'error')
            dbg("Update affected rows =", affected or "nil")
            return
        end

        LastChange[key] = os.time()

        local msg = ('You are now hired as %s.'):format(chosenJob.label)
        TriggerClientEvent('az_jobcenter:notify', src, msg, 'success')
        TriggerClientEvent('az_jobcenter:updateCurrentJob', src, jobId, chosenJob.label)

        -- Optional: update your own framework job record here
        -- exports['Az-Framework']:SetPlayerJob(src, jobId)

        -- 🔄 After doing custom DB work, ping Az-Framework to refresh HUD / money UI
        local ok, err = pcall(function()
            dbg("Calling fw:sendMoneyToClient for src", src)
            fw:sendMoneyToClient(src)
        end)

        if not ok then
            dbg("Error calling fw:sendMoneyToClient:", err)
        end
    end)
end)
