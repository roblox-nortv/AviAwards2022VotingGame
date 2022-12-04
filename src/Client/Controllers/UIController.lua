local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local IsLocalPlayerAdmin = LocalPlayer:GetRankInGroup(5287078) >= 252

local CurrentCamera = workspace.CurrentCamera
local CameraCFrame = workspace:WaitForChild("Camera_POV").CFrame

local VotingOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("VotingOptions"))
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("MainGui")
local PageInfo, Arrows, Pages =
	MainGui:WaitForChild("PageInfo"), MainGui:WaitForChild("Arrows"), MainGui:WaitForChild("Pages")
local PageItemTemplate, PageTemplate = MainGui:WaitForChild("PageItemTemplate"), MainGui:WaitForChild("PageTemplate")
local AdminPage = Pages:WaitForChild("Admin Page")

local SLIGHTER_MARGIN_UDIM2 = UDim2.new(0, 6, 0, 6)
local SLIGHT_MARGIN_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local LONG_MARGIN_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

local Knit = require(ReplicatedStorage.Packages.Knit)
local UIController = Knit.CreateController({
	Name = "UIController",
	Client = {},
	_Debounce = false,
})

function UIController:KnitInit()
	PageInfo.Spinner.Visible = false
	PageInfo.Spinner.Rotation = 0
	TweenService:Create(
		PageInfo.Spinner,
		TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
		{ Rotation = 359 }
	):Play()
end

function UIController:ShowNotification(text: string, duration: number)
	local Notification = MainGui:WaitForChild("Notification"):Clone()
	Notification.Parent = MainGui
	Notification.Text = text
	Notification.Visible = true
	print(Notification)
	task.wait(duration)
	Notification:Destroy()
end

function UIController:KnitStart()
	local CutsceneUIController = Knit.GetController("CutsceneUIController")
	local VotingService = Knit.GetService("VotingService")
	CutsceneUIController:SetCutsceneState(true)

	Pages.UIPageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		PageInfo.CategoryName.Text = string.upper(Pages.UIPageLayout.CurrentPage.Name)
	end)

	Arrows.Left.MouseButton1Click:Connect(function()
		if self._Debounce then
			return
		end
		Pages.UIPageLayout:Previous()
	end)

	Arrows.Right.MouseButton1Click:Connect(function()
		if self._Debounce then
			return
		end
		Pages.UIPageLayout:Next()
	end)

	for category, allOptions in pairs(VotingOptions) do
		local page = PageTemplate:Clone()
		page.Name = category
		page.Parent = Pages
		for _, option in pairs(allOptions) do
			local pageItem = PageItemTemplate:Clone()
			pageItem.Name = option.title
			pageItem.CompanyName.Text = string.upper(option.title)
			pageItem.Owner.Text = string.upper(("Owner: %s"):format(option.owner))
			pageItem.CompanyPreview.Image = option.preview

			local previewButton = pageItem.CompanyPreview
			local originalSize, originalImageColor = previewButton.Size, previewButton.ImageColor3
			previewButton.MouseEnter:Connect(function()
				TweenService:Create(previewButton, SLIGHT_MARGIN_TWEENINFO, {
					Size = originalSize + SLIGHTER_MARGIN_UDIM2,
					ImageColor3 = Color3.fromRGB(180, 180, 180),
				}):Play()
			end)

			previewButton.MouseLeave:Connect(function()
				TweenService:Create(previewButton, SLIGHT_MARGIN_TWEENINFO, {
					Size = originalSize,
					ImageColor3 = originalImageColor,
				}):Play()
			end)

			previewButton.MouseButton1Down:Connect(function()
				if self._Debounce then
					return
				end
				self._Debounce = true
				TweenService:Create(previewButton, SLIGHT_MARGIN_TWEENINFO, {
					Size = originalSize - UDim2.new(0, 15, 0, 15),
					ImageColor3 = Color3.fromRGB(129, 129, 129),
				}):Play()

				PageInfo.Spinner.Visible = true
				--//Vote
				local voteSuccess, info = VotingService:Vote(category, option.id)
				print(voteSuccess, info)
				if not voteSuccess then
					task.spawn(function()
						self:ShowNotification(info, 1.5)
					end)
				end
				--//Get result
				PageInfo.Spinner.Visible = false
				self._Debounce = false
			end)

			previewButton.MouseButton1Up:Connect(function()
				TweenService:Create(previewButton, SLIGHT_MARGIN_TWEENINFO, {
					Size = originalSize,
					ImageColor3 = originalImageColor,
				}):Play()
			end)

			previewButton.Voted.Visible = true
			previewButton.Voted.GroupTransparency = 1

			VotingService.CurrentVoted:Observe(function(newVotedData)
				local votedIdInMyCategory = nil
				for i, voted in pairs(newVotedData[category]) do
					if voted and allOptions[i].id == option.id then
						votedIdInMyCategory = option.id
						break
					end
				end

				TweenService:Create(previewButton.Voted, LONG_MARGIN_TWEENINFO, {
					GroupTransparency = (not not votedIdInMyCategory) and 0 or 1,
				}):Play()
			end)

			pageItem.Parent = page
			pageItem.Visible = true
		end

		page.Visible = true
	end

	AdminPage.Parent = IsLocalPlayerAdmin and Pages or nil
	AdminPage.ExportData.TextButton.MouseButton1Click:Connect(function()
		if self._Debounce then
			return
		end
		self._Debounce = true
		PageInfo.Spinner.Visible = true

		AdminPage.ExportData.TextButton.Text = "Exporting..."
		AdminPage.ExportData.Output.Text = VotingService:ExportData()
		AdminPage.ExportData.TextButton.Text = "Export Data (Click me)"

		self._Debounce = false
		PageInfo.Spinner.Visible = false
	end)

	local _ = LocalPlayer:GetAttribute("Authorized") or LocalPlayer:GetAttributeChangedSignal("Authorized"):Wait()
	CutsceneUIController:SetCutsceneState(false)

	CurrentCamera:GetPropertyChangedSignal("CameraType", "CameraSubject"):Connect(function()
		if CurrentCamera.CameraType == Enum.CameraType.Scriptable then
			CurrentCamera.CameraType = Enum.CameraType.Scriptable
			CurrentCamera.FieldOfView = 30
		end
	end)
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.FieldOfView = 30

	RunService:BindToRenderStep("UpdateUIBackgroundCamera", Enum.RenderPriority.Camera.Value - 1, function()
		local mouseOffsetFromScreenCenter = Vector2.new(
			UserInputService:GetMouseLocation().X - (CurrentCamera.ViewportSize.X / 2),
			UserInputService:GetMouseLocation().Y - (CurrentCamera.ViewportSize.Y / 2)
		)
		local newCFrame = CameraCFrame
			* CFrame.Angles(
				math.rad(-mouseOffsetFromScreenCenter.Y * 0.002),
				math.rad(-mouseOffsetFromScreenCenter.X * 0.002),
				0
			)
			* CFrame.new(math.noise(tick() * 0.5) * 10, math.noise(tick() * 0.3) * 15, 0)
		CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(newCFrame, 0.15)
	end)

	RunService:BindToRenderStep("UpdateAnimation", Enum.RenderPriority.Camera.Value - 1, function()
		for _, preview in pairs(CollectionService:GetTagged("ImagePlaceholderLoop")) do
			local uiGradient = preview:FindFirstChildOfClass("UIGradient")
			if uiGradient then
				if preview.IsLoaded then
					uiGradient.Rotation = 0
					uiGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
					continue
				end
			end
		end
	end)

	for _, preview in pairs(CollectionService:GetTagged("ImagePlaceholderLoop")) do
		local uiGradient = preview:FindFirstChildOfClass("UIGradient")
		if uiGradient then
			local offsetXTemp = uiGradient:findFirstChild("OffsetXTemp") or Instance.new("NumberValue")
			offsetXTemp.Name = "OffsetXTemp"
			offsetXTemp.Value = -2
			offsetXTemp.Parent = uiGradient

			TweenService:Create(
				offsetXTemp,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 1),
				{
					Value = 2
				}
			):Play()
			offsetXTemp.Changed:Connect(function()
				uiGradient.Offset = Vector2.new(offsetXTemp.Value, 0)
			end)
		end
	end

	CollectionService:GetInstanceAddedSignal("ImagePlaceholderLoop"):Connect(function(preview)
		local uiGradient = preview:FindFirstChildOfClass("UIGradient")
		if uiGradient then
			local offsetXTemp = uiGradient:findFirstChild("OffsetXTemp") or Instance.new("NumberValue")
			offsetXTemp.Name = "OffsetXTemp"
			offsetXTemp.Value = -2
			offsetXTemp.Parent = uiGradient

			TweenService:Create(
				offsetXTemp,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 1),
				{
					Value = 2
				}
			):Play()
			offsetXTemp.Changed:Connect(function()
				uiGradient.Offset = Vector2.new(offsetXTemp.Value, 0)
			end)
		end
	end)
end

return UIController
