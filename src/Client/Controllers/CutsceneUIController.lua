local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local MainGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CutsceneAnimationWrapper")
local CutsceneAnimation = MainGui:WaitForChild("Root")

local Knit = require(ReplicatedStorage.Packages.Knit)
local UIController = Knit.CreateController({
	Name = "UIController",
	_CurrentCutscene = false,
})

local LONG_TWEENINFO = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local function SetBackgroundMusicVolume(newVolume: number)
	return
end

local function PlayGenericSFX()
	local sfx = Instance.new("Sound")
	sfx.SoundId = "rbxassetid://11536328340"
	sfx.Volume = 0.5
	sfx.Parent = MainGui
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
end

local function TweenWrapperText(TextLabelWrapper: any, reverse: boolean?)
	local targetChild = TextLabelWrapper:FindFirstChild("TextLabel")
	if targetChild:GetAttribute("OriginalChildPos") then
		targetChild.Position = reverse and UDim2.new(0, 0, 0, 0) or targetChild:GetAttribute("OriginalChildPos")
	end
	targetChild:SetAttribute("OriginalChildPos", targetChild:GetAttribute("OriginalChildPos") or targetChild.Position)
	TweenService:Create(
		targetChild,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = reverse and targetChild:GetAttribute("OriginalChildPos") or UDim2.new(0, 0, 0, 0) }
	):Play()
end

function UIController:KnitInit()
	task.spawn(function()
		self:SetCutsceneState(true)
		self._KnitInitCutsceneFinished = true
	end)

	CutsceneAnimation.Spinner.Rotation = 0
	TweenService:Create(
		CutsceneAnimation.Spinner,
		TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{ Rotation = 359 }
	):Play()
end

function UIController:KnitStart()
	task.spawn(function()
		repeat
			task.wait()
		until self._KnitInitCutsceneFinished
		self:SetCutsceneState(false)
	end)
end

function UIController:SetCutsceneState(cutsceneState: boolean)
	if self._CurrentCutscene == cutsceneState then
		return
	end
	self._CurrentCutscene = cutsceneState
	CutsceneAnimation.Visible = true
	CutsceneAnimation.Spinner.Visible = cutsceneState
	CutsceneAnimation.Motto.TextTransparency = cutsceneState and 1 or 0

	TweenService:Create(CutsceneAnimation, LONG_TWEENINFO, { ImageTransparency = cutsceneState and 0 or 1 }):Play()

	PlayGenericSFX()
	SetBackgroundMusicVolume(0)
	local logoTween = TweenService:Create(
		CutsceneAnimation.Logo,
		cutsceneState and LONG_TWEENINFO or TweenInfo.new(1),
		{ Size = cutsceneState and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 0) }
	)

	local function logoTweenCompleted()
		TweenWrapperText(CutsceneAnimation.SubtextWrapper, not cutsceneState)
		TweenWrapperText(CutsceneAnimation.TitleWrapper, not cutsceneState)
		TweenService:Create(CutsceneAnimation.Motto, LONG_TWEENINFO, { TextTransparency = cutsceneState and 0 or 1 })
			:Play()
	end

	logoTween:Play()
	if cutsceneState then
		logoTween.Completed:Connect(logoTweenCompleted)
	else
		logoTweenCompleted()
	end
	task.wait(3.5)
end

return UIController
