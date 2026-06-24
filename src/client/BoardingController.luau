-- BoardingController
-- Handles boarding the ship (client-side)

local BoardingController = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

local currentShip = nil
local isBoarded = false
local prompt = nil
local promptShip = nil

local function isPromptPart(part)
	return part:IsA("BasePart") and part.CanQuery and part.Transparency < 1
end

local function getPromptPart(ship)
	if isPromptPart(ship) then
		return ship
	end

	if ship:IsA("Model") and ship.PrimaryPart and isPromptPart(ship.PrimaryPart) then
		return ship.PrimaryPart
	end

	for _, descendant in ipairs(ship:GetDescendants()) do
		if isPromptPart(descendant) then
			return descendant
		end
	end

	return nil
end

-- Attach a ProximityPrompt to the ship's PrimaryPart
local function createPrompt(ship)
	if prompt and promptShip == ship then
		return
	end

	local primaryPart = nil
	for _ = 1, 20 do
		primaryPart = getPromptPart(ship)
		if primaryPart then
			break
		end
		task.wait(0.1)
	end

	if not primaryPart then
		warn("[BoardingController] Ship has no BasePart for prompt")
		return
	end

	if prompt then
		prompt:Destroy()
	end

	local p = Instance.new("ProximityPrompt")
	p.ObjectText = "Ship"
	p.ActionText = "Board"
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.MaxActivationDistance = 20
	p.HoldDuration = 0
	p.Parent = primaryPart

	p.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer == player then
			BoardingController:Board()
		end
	end)

	prompt = p
	promptShip = ship
end

-- Board the ship
function BoardingController:Board()
	if not currentShip or isBoarded then return end

	local character = player.Character
	if not character then
		warn("[BoardingController] No character when boarding")
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	isBoarded = true
	print("[BoardingController] Boarded ship")

	-- Remove the prompt
	if prompt then
		prompt:Destroy()
		prompt = nil
	end

	-- Freeze character in place
	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
	if hrp then
		hrp.Anchored = true
	end

	-- Hide character visually
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

-- Set the ship to board
function BoardingController:SetShip(ship)
	currentShip = ship
	createPrompt(ship)
end

function BoardingController:IsBoarded()
	return isBoarded
end

function BoardingController:Start()
	-- nothing to init
end

return BoardingController
