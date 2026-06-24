-- Server Entry Point
-- Initialize all server services and game logic

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

if ServerScriptService:GetAttribute("FlyFightServerStarted") then
	warn("[Server] Duplicate server entry point ignored")
	return
end
ServerScriptService:SetAttribute("FlyFightServerStarted", true)

-- Wait for shared modules to load
ReplicatedStorage:WaitForChild("Shared")

-- FlyingShipService is a sibling in ServerScriptService.Server folder
local FlyingShipServiceModule = script:FindFirstChild("FlyingShipService")

if not FlyingShipServiceModule then
	error("FlyingShipService module not found")
end

local FlyingShipService = require(FlyingShipServiceModule)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	-- Wait for character to load, then spawn ship
	player.CharacterAdded:Connect(function(character)
		wait(0.5) -- Small delay for workspace setup
		FlyingShipService:SpawnShip(player, "FrogShip")
	end)
	
	-- Trigger first character load
	if not player.Character then
		player:LoadCharacter()
	end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	-- Cleanup handled by FlyingShipService
end)
