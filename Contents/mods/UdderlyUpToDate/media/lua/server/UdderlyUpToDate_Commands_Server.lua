local modName = "UdderlyUpToDate"
print("["..modName.."] Initializing UdderlyCommands Server..")
UdderlyUpToDate = UdderlyUpToDate or {}
UdderlyUpToDate.CommandHandlers = {}

local function isAdminPlayer(player)
	if not player then return false end
	local level = string.lower(tostring(player:getAccessLevel() or ""))
	return level == "admin"
end

Events.OnClientCommand.Add(function(moduleName, command, player, args)
	if moduleName == modName then
		local commandHandler = UdderlyUpToDate.CommandHandlers[command]
		if commandHandler then
			if not isAdminPlayer(player) then
				print("["..modName.."] Denied command \""..tostring(command).."\" from non-admin \""..player:getUsername().."\".")
				return
			end
			print("["..modName.."] Running command \""..command.."\" for player \""..player:getUsername().."\".")
			commandHandler(player, args)
		else
			print("["..modName.."] Unknown command \""..command.."\" from player \""..player:getUsername().."\"!")
		end
	end
end)

print("["..modName.."] Initializing UdderlyCommands Command Handlers..")
UdderlyUpToDate.CommandHandlers["checkworkshop"] = function(player, args)
	UdderlyUpToDate.pollWorkshop()
end

UdderlyUpToDate.CommandHandlers["restart"] = function(player, args)
	local restartSeconds = (SandboxVars.UdderlyUpToDate.RestartDelayMinutes or 5) * 60
	UdderlyUpToDate.scheduleServerRestart(getTimestamp() + restartSeconds)
end

UdderlyUpToDate.CommandHandlers["restartnow"] = function(player, args)
	UdderlyUpToDate.scheduleServerRestart(1) -- Scheduled for the first tick so it happens immediately.
end

UdderlyUpToDate.CommandHandlers["schedulerestart"] = function(player, args)
	local minutes = tonumber(args and args[1])
	if not minutes or minutes < 0 then
		print("["..modName.."] schedulerestart requires a non-negative minutes argument.")
		return
	end
	UdderlyUpToDate.scheduleServerRestart(getTimestamp() + (minutes * 60))
end
