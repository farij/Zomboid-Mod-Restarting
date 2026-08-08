local modName = "UdderlyUpToDate"
print("["..modName.."] Initializing UdderlyCommands Client..")
UdderlyUpToDate = UdderlyUpToDate or {}
UdderlyUpToDate.Commands = UdderlyUpToDate.Commands or {}

function UdderlyUpToDate.FakeMessage(msg, isAlert)
	local chatMsg =
	{
		getTextWithPrefix = function(self)
			return msg
		end,

		getText = function(self)
			return msg
		end,

		setText = function(self, newMsg)
			msg = newMsg
		end,

		isOverHeadSpeech = function() return not isAlert end,
		isServerAlert = function() return isAlert end,
		isShowAuthor = function() return false end,
		isServerAuthor = function() return true end,
		getAuthor = function() return false end,
		getRadioChannel = function() return -1 end
	}
	chatMsg.__index = chatMsg
	if not isAlert then
		msg = "[Server] "..msg
	end
	ISChat.addLineInChat(setmetatable({ msg = msg.."\t" }, chatMsg), 0)
end

function UdderlyUpToDate.Split(s, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(s, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function UdderlyUpToDate.IsAdmin()
	return isAdmin() or string.lower(tostring(getAccessLevel() or "")) == "admin"
end

local original = ISChat["onCommandEntered"]
ISChat["onCommandEntered"] = function(self)
	local commandText = ISChat.instance.textEntry:getText()
	ISChat.instance:logChatCommand(commandText)
	if commandText and commandText ~= "" then
		local strings = UdderlyUpToDate.Split(commandText)
		local enteredCommand = nil
		local args = {}
		if #strings == 1 then
			enteredCommand = string.sub(strings[1], 2, #strings[1])
		else
			for i,arg in ipairs(strings) do
				if i == 1 then
					enteredCommand = string.sub(arg, 2, #arg)
				else
					table.insert(args, arg)
				end
			end
		end
		local command = UdderlyUpToDate.Commands[enteredCommand]
		if command ~= nil and command ~= false then -- If it has a function defined for client-side execution, run that.
			local result = command(args)
			if result and result ~= "" then
				UdderlyUpToDate.FakeMessage(result, false)
			end
			return
		elseif command == false then -- No client-side code but is present..
			sendClientCommand(modName, enteredCommand, args) -- Send it to the server.
			return
		end -- Unknown command for this mod, let it fall through.
	end
	-- If we get here, we didn't find a command to run from our module.
	original(self) -- So fall back to the vanilla (or whatever overrode it before us) handler.
end

print("["..modName.."] Initializing UdderlyCommands Commands..")
UdderlyUpToDate.Commands["checkworkshop"] = function(args)
	if not UdderlyUpToDate.IsAdmin() then
		return "You do not have access to this command."
	else
		sendClientCommand(modName, "checkworkshop", args)
	end
end
UdderlyUpToDate.Commands["restart"] = function(args)
	if not UdderlyUpToDate.IsAdmin() then
		return "You do not have access to this command."
	else
		sendClientCommand(modName, "restart", args)
	end
end
UdderlyUpToDate.Commands["restartnow"] = function(args)
	if not UdderlyUpToDate.IsAdmin() then
		return "You do not have access to this command."
	else
		sendClientCommand(modName, "restartnow", args)
	end
end
UdderlyUpToDate.Commands["schedulerestart"] = function(args)
	if not UdderlyUpToDate.IsAdmin() then
		return "You do not have access to this command."
	else
		sendClientCommand(modName, "schedulerestart", args)
	end
end
