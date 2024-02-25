
-- *****************************************************************************************************
-- ***** TASK TRACKER MIXIN
-- *****************************************************************************************************

TodolooTaskTrackerMixin = {}

function TodolooTaskTrackerMixin:OnLoad()
	Todoloo.Debug.Message("TodolooTaskTrackerMixin:OnLoad")

	self:RegisterForDrag("LeftButton")

	self.Text:SetText("Tasks")

	self.MinimizeButton:SetScript("OnClick", function()
		--TODO: Minimize tracker
		Todoloo.Debug.Message("Minimize button OnClick")
	end)

    -- Override default scripts from template
    -- self.Block.HeaderButton:SetScript("OnEnter", function()
    --     self:OnBlockEnter()
    -- end)

    -- self.Block.HeaderButton:SetScript("OnLeave", function()
    --     self:OnBlockLeave()
    -- end)

    -- self.Block.HeaderButton:SetScript("OnClick", function()
    --     self:OnBlockClick()
    -- end)

    -- Create frame pool for tasks
	self.groupPool = CreateFramePool("Frame", self, "TodolooTaskTrackerBlockTemplate")

    -- Add current tasks to the group
    self:UpdateGroups()
end

function TodolooTaskTrackerMixin:OnShow()
	Todoloo.Debug.Message("TodolooTaskTrackerMixin:OnShow")
end

function TodolooTaskTrackerMixin:UpdateGroups()
	self.groupPool:ReleaseAll()

	local yOffset = 10

	for index, group in ipairs(Todoloo.TaskManager.GetAll()) do
		local groupFrame = self.groupPool:Acquire()
		groupFrame:Init(group, index)
		groupFrame:Show()
		groupFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 10, -yOffset)
		yOffset = yOffset + groupFrame:GetHeight()
	end
end

function TodolooTaskTrackerMixin:OnBlockEnter()
    Todoloo.Debug.Message("TodolooTaskTrackerMixin:OnBlockEnter")
    self.isHighlighted = true
    local headerColorStyle = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
    self.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
    self.HeaderText.colorStyle = headerColorStyle;
end

function TodolooTaskTrackerMixin:OnBlockLeave()
    Todoloo.Debug.Message("TodolooTaskTrackerMixin:OnBlockLeave")
    self.isHighlighted = nil
    local headerColorStyle = OBJECTIVE_TRACKER_COLOR["Header"];
    self.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
    self.HeaderText.colorStyle = headerColorStyle;
end

function TodolooTaskTrackerMixin:OnBlockClick()
    Todoloo.Debug.Message("TodolooTaskTrackerMixin:OnBlockClick")
end

function TodolooTaskTrackerMixin:OnDragStart()

end

function TodolooTaskTrackerMixin:OnDragStop()

end


-- *****************************************************************************************************
-- ***** TASK TRACKER BLOCK MIXIN
-- *****************************************************************************************************

TodolooTaskTrackerBlockMixin = {}

function TodolooTaskTrackerBlockMixin:Init(group, index)
	self.group = group
	self.index = index
	
	self.lines = {}

	self.HeaderText:SetText(group.name)

	-- Override default events on HeaderButton
	self.HeaderButton:SetScript("OnEnter", function() self:OnHeaderButtonEnter() end)
	self.HeaderButton:SetScript("OnLeave", function() self:OnHeaderButtonLeave() end)
	self.HeaderButton:SetScript("OnClick", function() self:OnHeaderButtonClick() end)

	self.taskPool = CreateFramePool("Frame", self, "TodolooTaskTrackerLineTemplate")

	self.completeFunc = function()
		self.group = Todoloo.TaskManager.GetGroup(self.index)
		self:UpdateTasks()
	end

	self.initialized = true

	self:UpdateTasks()
end

function TodolooTaskTrackerBlockMixin:OnShow()
	if not self.initialized then
		return
	end

	self:UpdateTasks()
end

function TodolooTaskTrackerBlockMixin:UpdateTasks()
	self.taskPool:ReleaseAll()

    local yOffset = 3

    for index, task in ipairs(self.group.tasks) do
		if task.completed then return end

        local frame = self.taskPool:Acquire()
		self.lines[index] = frame
		frame:Init(self.index, task, index, self.completeFunc)
        frame:Show()
        frame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -yOffset)		

        yOffset = yOffset + frame:GetHeight()
    end
end

function TodolooTaskTrackerBlockMixin:OnHeaderButtonEnter()
	local headerColorStyle = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
	self.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
	self.HeaderText.colorStyle = headerColorStyle;

	for _, line in pairs(self.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if ( colorStyle ) then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["NormalHighlight"].r, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].g, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].b);
			end
		end
	end
end

function TodolooTaskTrackerBlockMixin:OnHeaderButtonLeave()
	local headerColorStyle = OBJECTIVE_TRACKER_COLOR["Header"];
	self.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
	self.HeaderText.colorStyle = headerColorStyle;

	for _, line in pairs(self.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if colorStyle then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["Normal"].r, OBJECTIVE_TRACKER_COLOR["Normal"].g, OBJECTIVE_TRACKER_COLOR["Normal"].b);
			end
		end
	end
end

function TodolooTaskTrackerBlockMixin:OnHeaderButtonClick()

end

-- *****************************************************************************************************
-- ***** TASK TRACKER LINE MIXIN
-- *****************************************************************************************************

TodolooTaskTrackerLineMixin = {}

function TodolooTaskTrackerLineMixin:Init(groupIndex, task, index, completeFunc)
	self.groupIndex = groupIndex
	self.task = task
	self.index = index
	self.completeFunc = completeFunc
	self.completed = task.completed

	self.Text:SetText(task.name)

	if self.completed then
		self.Dash:Hide()
		self.Check:Show()
	end

	local colorStyle = OBJECTIVE_TRACKER_COLOR["Normal"]
	self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
	self.Text.colorStyle = colorStyle

	self.initialized = true
end

function TodolooTaskTrackerLineMixin:OnLineButtonEnter()
	local colorStyle = self.Text.colorStyle.reverse
	if colorStyle then
		self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		self.Text.colorStyle = colorStyle
		if self.Dash then
			self.Dash:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end
end

function TodolooTaskTrackerLineMixin:OnLineButtonLeave()
	local colorStyle = self.Text.colorStyle.reverse
	if colorStyle then
		self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		self.Text.colorStyle = colorStyle
		if self.Dash then
			self.Dash:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		end
	end
end

function TodolooTaskTrackerLineMixin:OnLineButtonClick()
	if self.completed then
		return
	end

	Todoloo.TaskManager.SetTaskCompletion(self.groupIndex, self.index, true)

	self.Dash:Hide()

	self.Check:Show()
	self.Sheen.Anim:Play()
	self.Glow.Anim:Play()
	self.CheckFlash.Anim:Play()
end

function TodolooTaskTrackerLineMixin:GlowAnimFinished()
	if Todoloo.Config.Get(Todoloo.Config.Options.SHOW_COMPLETED_TASKS) then
		self.FadeOutAnim:Play()
	end
end

function TodolooTaskTrackerLineMixin:FadeOutAnimFinished()
	--TODO: Somehow make the task dissapear from the task tracker
	self.completeFunc()
end