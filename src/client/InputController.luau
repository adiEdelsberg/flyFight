-- InputController
-- Handles keyboard, mobile, and controller input (client-side)
-- Normalizes all inputs into standard actions

local InputController = {}

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local BoardingController = nil

-- Input state
InputController.inputState = {
	moveX = 0, -- -1 to 1 (left/right)
	moveZ = 0, -- -1 to 1 (forward/backward)
	pitch = 0, -- -1 to 1 (up/down)
	boost = false,
	fire = false,
}

-- Input callbacks (for other systems to subscribe)
local inputCallbacks = {}

-- Register a callback for input updates
function InputController:OnInput(callback)
	table.insert(inputCallbacks, callback)
end

-- Fire all callbacks with current input state
local function fireCallbacks()
	for _, callback in ipairs(inputCallbacks) do
		callback(InputController.inputState)
	end
end

local function isBoarded()
	if not BoardingController then
		BoardingController = require(script.Parent:WaitForChild("BoardingController"))
	end

	return BoardingController:IsBoarded()
end

local function getInputResult()
	return isBoarded() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
end

-- Setup keyboard controls
local function setupKeyboardInput()
	-- Movement
	ContextActionService:BindAction("Move_Forward", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.moveZ = -1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.moveZ = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.W, Enum.KeyCode.Up)
	
	ContextActionService:BindAction("Move_Backward", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.moveZ = 1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.moveZ = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.S, Enum.KeyCode.Down)
	
	ContextActionService:BindAction("Move_Left", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.moveX = -1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.moveX = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.A, Enum.KeyCode.Left)
	
	ContextActionService:BindAction("Move_Right", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.moveX = 1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.moveX = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.D, Enum.KeyCode.Right)
	
	-- Pitch (up/down)
	ContextActionService:BindAction("Pitch_Up", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.pitch = 1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.pitch = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.Space)
	
	ContextActionService:BindAction("Pitch_Down", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.pitch = -1
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.pitch = 0
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.LeftControl)
	
	-- Boost
	ContextActionService:BindAction("Boost", function(actionName, inputState, inputObject)
		if not isBoarded() then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.boost = true
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.boost = false
		end
		fireCallbacks()
		return getInputResult()
	end, false, Enum.KeyCode.LeftShift)
	
	-- Fire (Mouse click)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			InputController.inputState.fire = true
			fireCallbacks()
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			InputController.inputState.fire = false
			fireCallbacks()
		end
	end)
end

-- Setup controller input
local function setupControllerInput()
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			-- Left stick for movement
			if input.KeyCode == Enum.KeyCode.Gamepad1LeftThumbstick then
				local position = input.Position
				InputController.inputState.moveX = position.X
				InputController.inputState.moveZ = -position.Y
				fireCallbacks()
			end
			
			-- Right stick for pitch
			if input.KeyCode == Enum.KeyCode.Gamepad1RightThumbstick then
				local position = input.Position
				InputController.inputState.pitch = -position.Y
				fireCallbacks()
			end
		end
	end)
	
	-- Boost with R1
	ContextActionService:BindAction("Gamepad_Boost", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.boost = true
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.boost = false
		end
		fireCallbacks()
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonR1)
	
	-- Fire with R2
	ContextActionService:BindAction("Gamepad_Fire", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			InputController.inputState.fire = true
		elseif inputState == Enum.UserInputState.End then
			InputController.inputState.fire = false
		end
		fireCallbacks()
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonR2)
end

-- Setup mobile touch input
local function setupMobileInput()
	-- TODO: Implement touch input for mobile
	-- This will use touch positions to control movement and pitch
end

-- Initialize input system
function InputController:Start()
	setupKeyboardInput()
	setupControllerInput()
	-- setupMobileInput() -- TODO when needed
end

return InputController
