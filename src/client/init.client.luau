-- Client Entry Point
-- Initialize input system and ship controller

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules
ReplicatedStorage:WaitForChild("Shared")

-- Load controllers
local InputController = require(script:WaitForChild("InputController"))
local ShipController = require(script:WaitForChild("ShipController"))
local CameraController = require(script:WaitForChild("CameraController"))
local BoardingController = require(script:WaitForChild("BoardingController"))

-- Start input system
InputController:Start()

-- Start ship controller (which finds the ship)
ShipController:Start()

-- Start camera controller
CameraController:Start()

-- Start boarding controller
BoardingController:Start()

-- Link ship controller to other controllers after a moment
local ship = nil
for _ = 1, 50 do
	ship = ShipController:GetShip()
	if ship then
		break
	end
	task.wait(0.1)
end

if not ship then
	warn("[Client] Could not link controllers because no ship was found")
	return
end

CameraController:SetShip(ship)
CameraController:SetTargetProvider(function()
	return ShipController:GetCameraTarget()
end)
BoardingController:SetShip(ship)
