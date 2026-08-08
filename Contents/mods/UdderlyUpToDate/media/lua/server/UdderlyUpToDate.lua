local getTimestamp = getTimestamp
local querySteamWorkshopItemDetails = querySteamWorkshopItemDetails
local getSteamWorkshopItemIDs = getSteamWorkshopItemIDs
local getOnlinePlayers = getOnlinePlayers
local getCore = getCore

if not getCore():isDedicated() then
	print("[UdderlyUpToDate] Refusing to load (this is not a dedicated server)")
	return
end

UdderlyUpToDate = UdderlyUpToDate or {}

local serverStarted = getTimestamp()
local pendingReboot = false
local rebootingNow = false
local restartingAt

local function isServerEmpty()
	return getOnlinePlayers():size() == 0
end

function UdderlyUpToDate.rebootServer()
	if rebootingNow then return end
	rebootingNow = true

	Events.OnSave.Add(function()
		local delayTimestamp = getTimestamp() + (SandboxVars.UdderlyUpToDate.QuitDelaySeconds or 15)
		local lastSecondLogged = (SandboxVars.UdderlyUpToDate.QuitDelaySeconds or 15) + 1 -- start above the limit so we log all.
		Events.OnTickEvenPaused.Add(function()
			local secondsLeft = delayTimestamp - getTimestamp()
			if secondsLeft <= 0 then
				print("[UdderlyUpToDate] Quitting...")
				getCore():quit()
			else
				if lastSecondLogged > secondsLeft then
					print("[UdderlyUpToDate] Quitting in "..secondsLeft.." seconds!")
					lastSecondLogged = secondsLeft -- avoid logging the same timestamp again.
				end
			end
		end)
	end)

	print("[UdderlyUpToDate] Saving...")
	saveGame()
end

ModData.remove("UdderlyUpToDate")

Events.OnInitGlobalModData.Add(function()
	if restartingAt then
		ModData.add("UdderlyUpToDate", { restartingAt = restartingAt })
		ModData.transmit("UdderlyUpToDate")
	else
		ModData.remove("UdderlyUpToDate")
	end
end)

function UdderlyUpToDate.scheduleServerRestart(timestamp)
	pendingReboot = true
	restartingAt = timestamp
	ModData.add("UdderlyUpToDate", { restartingAt = timestamp })
	ModData.transmit("UdderlyUpToDate")
	UdderlyUpToDate.startRestartCountdown(timestamp)
end

local function rebootWhenEmpty()
	if pendingReboot and isServerEmpty() then
		UdderlyUpToDate.rebootServer()
		Events.OnTickEvenPaused.Remove(rebootWhenEmpty)
	end
end

local function workshopOutdated()
	if pendingReboot then return end
	pendingReboot = true

	if isServerEmpty() then
		print("[UdderlyUpToDate] Restarting the server (server empty and outdated workshop items were detected)..")
		UdderlyUpToDate.rebootServer()
		return
	end

	if (SandboxVars.UdderlyUpToDate.RestartDelayMinutes or 5) > 0 then
		local restartSeconds = (SandboxVars.UdderlyUpToDate.RestartDelayMinutes or 5) * 60
		print("[UdderlyUpToDate] Detected outdated workshop item - restarting server in " .. UdderlyUpToDate.minutes(restartSeconds).. "!")
		UdderlyUpToDate.scheduleServerRestart(getTimestamp() + restartSeconds)
	else
		print("[UdderlyUpToDate] Restarting the server when it becomes empty... (outdated workshop items were detected)")
		Events.OnTickEvenPaused.Add(rebootWhenEmpty)
	end
end

function UdderlyUpToDate.pollWorkshop()
	local fakeTable = {}

	if pendingReboot then return end

	print("[UdderlyUpToDate] Checking for outdated workshop items...")

	querySteamWorkshopItemDetails(getSteamWorkshopItemIDs(), function(_, status, info)
		if status ~= "Completed" then return end
		for i = 0, info:size() - 1 do
			local details = info:get(i)
			local updated = details:getTimeUpdated()
			if updated >= serverStarted then
				local modLine = "Mod \""..details:getTitle().."\" ("..details:getID()..") has an update!"
				print("[UdderlyUpToDate] "..modLine)
				workshopOutdated()
			end
		end
	end, fakeTable)
end

-- Only do this if we're in the mode where we only reboot with no users online.
-- Will require a restart of server to initialize this mode.
if (SandboxVars.UdderlyUpToDate.RestartDelayMinutes or 5) == 0 then
	Events.OnDisconnect.Add(function() UdderlyUpToDate.pollWorkshop() end)
end

local nextPoll
Events.OnTickEvenPaused.Add(function()
	if not rebootingNow and restartingAt then
		if isServerEmpty() then
			print("[UdderlyUpToDate] Restarting the server now! (Outdated workshop items were detected and server is empty)")
			UdderlyUpToDate.rebootServer()
		elseif restartingAt - getTimestamp() <= 0 then
			print("[UdderlyUpToDate] Restarting the server now! (Outdated workshop items were detected)")
			UdderlyUpToDate.rebootServer()
		end
		return
	end

	if pendingReboot then return end

	-- Don't bother checking for outdated Workshop items if there's no restart delay and the server has players on it
	if (SandboxVars.UdderlyUpToDate.RestartDelayMinutes or 5) == 0 and not isServerEmpty() then
		return
	end

	local timestamp = getTimestamp()
	if not nextPoll or timestamp >= nextPoll then
		nextPoll = timestamp + ((SandboxVars.UdderlyUpToDate.WorkshopPollingIntervalMinutes or 15) * 60)
		return UdderlyUpToDate.pollWorkshop()
	end
end)
