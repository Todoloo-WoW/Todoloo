-- *****************************************************************************************************
-- ***** GROUP LIST
-- *****************************************************************************************************

TodolooTaskListMixin = {}

local function SetupScrollBox(self)
    local indent = 10;
	local padLeft = 0;
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing);

    view:SetElementFactory(function(factory, node)
        local elementData = node:GetData()
        if elementData.groupInfo then
            -- if the element is a group
            local function Initializer(groupButton, node)
                groupButton:Initialize(node)

                groupButton:SetScript("OnClick", function(button, buttonName)
                    if buttonName == "LeftButton" and IsShiftKeyDown() then
                        node:ToggleCollapsed()
                        button:SetCollapseState(node:IsCollapsed())
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK);
                    elseif buttonName == "RightButton" then
                        ToggleDropDownMenu(1, elementData.groupInfo, self.GroupContextMenu, "cursor")
                    end
                end)

                groupButton:SetScript("OnDoubleClick", function(button, buttonName)
                    if buttonName == "LeftButton" then
                        --enter edit mode, enabling the player to edit the group name
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                        button:SetEditMode(true)
                    end
                end)
            end
            factory("TodolooTaskListGroupTemplate", Initializer);
        elseif elementData.taskInfo then
            -- if the element is a task
            local function Initializer(taskButton, node)
                taskButton:Initialize(node)

                taskButton:SetScript("OnClick", function(button, buttonName, down)
                    if buttonName == "RightButton" then
                        ToggleDropDownMenu(1, elementData.taskInfo, self.TaskContextMenu, "cursor")
                    elseif buttonName == "LeftButton" and IsShiftKeyDown() then
                        taskButton:ToggleCompletion()
                    end
                end)

                taskButton:SetScript("OnDoubleClick", function(button, buttonName)
                    if buttonName == "LeftButton" then
                        --enter edit mode, enabling the player to edit the task name
                        PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                        button:SetEditMode(true)
                    end
                end)
            end
            factory("TodolooTaskListTaskTemplate", Initializer);
        elseif elementData.isDivider then
			factory("TodolooTaskListDividerTemplate");
        else
			factory("Frame");
        end
    end)

    view:SetElementExtentCalculator(function(dataIndex, node)
        local elementData = node:GetData()
        local baseElementHeight = 20
        local groupPadding = 5

        if elementData.taskInfo then
            return baseElementHeight
        end

        if elementData.groupInfo then
            return baseElementHeight + groupPadding
        end

        if elementData.dividerHeight then
            return elementData.dividerHeight
        end

        if elementData.topPadding  then
            return 1
        end

        if elementData.bottomPadding then
            return 10
        end
    end)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    local function OnSelectionChanged(o, elementData, selected)
        local button = self.ScrollBox:FindFrame(elementData)

        if selected then
            local data = elementData:GetData()
            if data.groupInfo then
                button:SetEditMode(true)
            elseif data.taskInfo then
                button:SetEditMode(true)
            end
        end
    end

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox)
    self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self)
end

local function SetupDragBehavior(self)
    self.dragBehavior = Todoloo.ScrollUtil.InitDefaultTaskListDragBehavior(self.ScrollBox)
    self.dragBehavior:SetReorderable(true)
end

function TodolooTaskListMixin:OnLoad()
    -- setup scroll box
    SetupScrollBox(self)

    -- setup drag behaviour
    SetupDragBehavior(self)

    -- setup context menus
    UIDropDownMenu_SetInitializeFunction(self.GroupContextMenu, GenerateClosure(self.InitializeGroupContextMenu, self))
    UIDropDownMenu_SetDisplayMode(self.GroupContextMenu, "MENU")

    UIDropDownMenu_SetInitializeFunction(self.TaskContextMenu, GenerateClosure(self.InitializeTaskContextMenu, self))
    UIDropDownMenu_SetDisplayMode(self.TaskContextMenu, "MENU")
end

function TodolooTaskListMixin:InitializeGroupContextMenu(dropDown, level)
    local groupInfo = UIDROPDOWNMENU_MENU_VALUE
    local info = UIDropDownMenu_CreateInfo()

    info.isTitle = true
    info.notCheckable = true
    info.text = "Group actions"
    UIDropDownMenu_AddButton(info, level)
    
    info.isTitle = false
    info.disabled = false
    
    info.notCheckable = true
    info.text = "Add new task"
    info.func = function() self:AddNewTask(groupInfo) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = true
    info.text = "Delete"
    info.func = function() 
        local numTasks = Todoloo.TaskManager:GetNumTasks(groupInfo.id)
        if numTasks > 0 then
            -- if the group has nested tasks, we should ask the player for confirmation
            StaticPopup_Show("TODLOO_DELETE_GROUP", groupInfo.name, nil, { groupInfo = groupInfo })
        else
            Todoloo.TaskManager:RemoveGroup(groupInfo.id)
        end
    end

    UIDropDownMenu_AddButton(info, level)
end

function TodolooTaskListMixin:InitializeTaskContextMenu(dropDown, level)
    local taskInfo = UIDROPDOWNMENU_MENU_VALUE
    local info = UIDropDownMenu_CreateInfo()

    info.isTitle = true
    info.notCheckable = true
    info.text = "Reset interval"
    UIDropDownMenu_AddButton(info, level)

    info.isTitle = false
    info.disabled = false

    info.notCheckable = false
    info.checked = taskInfo.reset == TODOLOO_RESET_INTERVALS.Manually
    info.text = "Manually"
    info.func = function() self:SetTaskInterval(taskInfo, TODOLOO_RESET_INTERVALS.Manually) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = taskInfo.reset == TODOLOO_RESET_INTERVALS.Daily
    info.text = "Daily"
    info.func = function() self:SetTaskInterval(taskInfo, TODOLOO_RESET_INTERVALS.Daily) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = taskInfo.reset == TODOLOO_RESET_INTERVALS.Weekly
    info.text = "Weekly"
    info.func = function() self:SetTaskInterval(taskInfo, TODOLOO_RESET_INTERVALS.Weekly) end
    UIDropDownMenu_AddButton(info, level)

    info.isTitle = true
    info.notCheckable = true
    info.text = "Task actions"
    UIDropDownMenu_AddButton(info, level)

    info.isTitle = false
    info.disabled = false

    info.notCheckable = true
    info.text = "Delete"
    info.func = function() self:DeleteTask(taskInfo) end

    UIDropDownMenu_AddButton(info, level)
end

function TodolooTaskListMixin:SetTaskInterval(taskInfo, resetInterval)
    -- reset interval already set to the given value
    if taskInfo.reset == resetInterval then
        return
    end

    taskInfo.reset = resetInterval
    self:UpdateTask(taskInfo)
end

function TodolooTaskListMixin:AddNewTask(groupInfo)
    local task, id = Todoloo.TaskManager:AddTask(groupInfo.id, "", nil, nil)
end

function TodolooTaskListMixin:DeleteTask(taskInfo)
    Todoloo.TaskManager:RemoveTask(taskInfo.groupId, taskInfo.id)
end

function TodolooTaskListMixin:OpenTask(taskInfo, scrollToTask)
    local elementData = self.selectionBehavior:SelectElementDataByPredicate(function(node)
        local data = node:GetData()
        return data.taskInfo and data.taskInfo.id == taskInfo.id and data.taskInfo.groupId == taskInfo.groupId
    end)

    if scrollToTask then
        self.ScrollBox:ScrollToElementData(elementData)
    end

    return elementData
end

function TodolooTaskListMixin:OpenGroup(groupInfo, scrollToTask)
    local elementData = self.selectionBehavior:SelectElementDataByPredicate(function(node)
        local data = node:GetData()
        return data.groupInfo and data.groupInfo.id == groupInfo.id
    end)

    if scrollToTask then
        self.ScrollBox:ScrollToElementData(elementData)
    end

    return elementData
end

function TodolooTaskListMixin:UpdateTask(taskInfo)
    Todoloo.TaskManager:UpdateTask(
        taskInfo.groupId,
        taskInfo.id,
        taskInfo.name,
        taskInfo.describing,
        taskInfo.reset
    )
end

-- *****************************************************************************************************
-- ***** GROUP
-- *****************************************************************************************************
TodolooTaskListGroupMixin = {}

function TodolooTaskListGroupMixin:Initialize(node)
    local elementData = node:GetData()
    self.groupInfo = elementData.groupInfo
    
    self.Name:SetText(self.groupInfo.name)
    self.Label:SetText(self.groupInfo.name)

    self:SetCollapseState(node:IsCollapsed())
end

function TodolooTaskListGroupMixin:SetCollapseState(collapsed)
    local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
end

function TodolooTaskListGroupMixin:SetEditMode(enable)
    if enable then
        self.Label:Hide()
        self.Name:Show()
        self.Name:SetFocus()
    else
        self.Label:Show()
        self.Name:Hide()
    end
end

function TodolooTaskListGroupMixin:OnEditFocusLost()
    self:Save()
end

function TodolooTaskListGroupMixin:Save()
    local isDirty = false

    local newName = self.Name:GetText()
    if self.groupInfo.name ~= newName then
        self.groupInfo.name = newName
        isDirty = true
    end
    
    if isDirty then
        Todoloo.TaskManager:UpdateGroup(self.groupInfo.id, newName)
    end

    self:SetEditMode(false)
end

-- *****************************************************************************************************
-- ***** TASK
-- *****************************************************************************************************
TodolooTaskListTaskMixin = {}

function TodolooTaskListTaskMixin:Initialize(node)
    local elementData = node:GetData()
    self.taskInfo = elementData.taskInfo
    
    self.Name:SetText(self.taskInfo.name)
    self.Label:SetText(self.taskInfo.name)

    if self.taskInfo.completed then
        self.Label:SetVertexColor(DISABLED_FONT_COLOR:GetRGB())
        self.Check:Show()
    else
        self.Label:SetVertexColor(PROFESSION_RECIPE_COLOR:GetRGB())
        self.Check:Hide()
    end

    self:SetResetInterval()
end

function TodolooTaskListTaskMixin:SetResetInterval()
    if self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Manually then
        -- set our custom greyed out quest icon
        self.ResetIcon:SetTexture("Interface/AddOns/Todoloo/Images/questlog-questtypeicon-disabled")
        self.ResetIcon:SetSize(14, 14)
        self.ResetIcon:SetTexCoord(0, 0.575, 0, 0.575)
    else
        local atlas = self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Daily and "questlog-questtypeicon-daily"
        or self.taskInfo.reset == TODOLOO_RESET_INTERVALS.Weekly and "questlog-questtypeicon-weekly"

        self.ResetIcon:SetAtlas(atlas, false, "LINEAR", true)
    end
end

function TodolooTaskListTaskMixin:SetSelected(selected)
    self.SelectedOverlay:SetShown(selected)
end

function TodolooTaskListTaskMixin:OnEditFocusGained()
    self:SetSelected(true)
end

function TodolooTaskListTaskMixin:OnEditFocusLost()
    self:SetSelected(false)
    self:Save()
end

function TodolooTaskListTaskMixin:SetEditMode(enable)
    if enable then
        self.Label:Hide()
        self.HighlightOverlay:Hide()
        self.Name:Show()
        self.Name:SetFocus()
    else
        self.Label:Show()
        self.HighlightOverlay:Show()
        self.Name:Hide()
    end
end

function TodolooTaskListTaskMixin:ToggleCompletion()
    Todoloo.TaskManager:SetTaskCompletion(self.taskInfo.groupId, self.taskInfo.id, not self.taskInfo.completed)
end

function TodolooTaskListTaskMixin:Save()
    local isDirty = false
    
    local newName = self.Name:GetText()
    if self.taskInfo.name ~= newName then
        self.taskInfo.name = newName
        isDirty = true
    end

    -- only update if any changes
    if isDirty then
        Todoloo.TaskManager:UpdateTask(
            self.taskInfo.groupId,
            self.taskInfo.id,
            self.taskInfo.name,
            self.taskInfo.description,
            self.taskInfo.reset
        )
    end

    self:SetEditMode(false)
end

-- *****************************************************************************************************
-- ***** POPUPS
-- *****************************************************************************************************

StaticPopupDialogs["TODLOO_DELETE_GROUP"] = {
    text = "Are you sure you want to delete '%s'?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        Todoloo.TaskManager:RemoveGroup(data.groupInfo.id)
    end,
    timout = 0,
    whileDead = 1,
    exclusive = 1,
    hideOnEscape = 1
}