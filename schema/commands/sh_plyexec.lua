AddCSLuaFile()

ix.command.Add("PlyExec", {
	alias = "exec",
	description = "Force a player to execute a command",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, command)
		command = string.Replace(command, "'", "\"")
		target:ConCommand(command)

		return true
	end
})

ix.command.Add("PlyExecAll", {
	alias = "execall",
	description = "Force all players to execute a command",
	adminOnly = true,
	arguments = {
		ix.type.string
	},
	OnRun = function(self, client, command)
		for k, target in pairs(player.GetAll()) do
			target:ConCommand(command)
		end
		return true
	end
})