-- *****************************************************************************************************
-- ***** GROUP LIST
-- *****************************************************************************************************

TodolooTaskListMixin = CreateFromMixins(CallbackRegistryMixin)
TodolooTaskListMixin:GenerateCallbackEvents(
{
    "OnGroupDeleted",
    "OnTaskCreated",
    "OnTaskUpdated",
    "OnTaskDeleted"
})

function TodolooTaskListMixin:OnLoad()
    CallbackRegistryMixin.OnLoad(self);

    -- setup scroll box
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
                        print("Should open group context menu")
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
        local numTasks = Todoloo.TaskManager.GetNumTasks(groupInfo.id)
        if numTasks > 0 then
            StaticPopup_Show("TODLOO_DELETE_GROUP", groupInfo.name, { callback = self.DeleteGroupCallback, groupInfo = groupInfo })
        else
            self:DeleteGroup(groupInfo)
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
    info.checked = taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Manually
    info.text = "Manually"
    info.func = function() self:SetTaskInterval(taskInfo, Todoloo.TaskManager.ResetIntervals.Manually) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Daily
    info.text = "Daily"
    info.func = function() self:SetTaskInterval(taskInfo, Todoloo.TaskManager.ResetIntervals.Daily) end
    UIDropDownMenu_AddButton(info, level)

    info.notCheckable = false
    info.checked = taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Weekly
    info.text = "Weekly"
    info.func = function() self:SetTaskInterval(taskInfo, Todoloo.TaskManager.ResetIntervals.Weekly) end
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

function TodolooTaskListMixin:DeleteGroupCallback()
    EventRegistry:TriggerEvent("TodolooTaskListMixin.Event.OnGroupDeleted", self)
end

function TodolooTaskListMixin:AddNewTask(groupInfo)
    local task, id = Todoloo.TaskManager.AddTask(groupInfo.id, "", nil, nil)
    EventRegistry:TriggerEvent("TodolooTaskListMixin.Event.OnTaskCreated", task, id, groupInfo.id, self)
end

function TodolooTaskListMixin:DeleteTask(taskInfo)
    Todoloo.TaskManager.RemoveTask(taskInfo.groupId, taskInfo.id)
    EventRegistry:TriggerEvent("TodolooTaskListMixin.Event.OnTaskDeleted", taskInfo, self)
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
    Todoloo.TaskManager.UpdateTask(
        taskInfo.groupId,
        taskInfo.id,
        taskInfo.name,
        taskInfo.describing,
        taskInfo.reset
    )

    EventRegistry:TriggerEvent("TodolooTaskListMixin.Event.OnTaskUpdated", taskInfo, self)
end

-- *****************************************************************************************************
-- ***** GROUP
-- *****************************************************************************************************
TodolooTaskListGroupMixin = CreateFromMixins(CallbackRegistryMixin)
TodolooTaskListGroupMixin:GenerateCallbackEvents(
{
    "OnGroupSaved"
})

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
        Todoloo.TaskManager.UpdateGroup(self.groupInfo.id, newName)
        EventRegistry:TriggerEvent("TodolooTaskListGroupMixin.Event.OnGroupSaved", self.groupInfo, self)
    end

    self:SetEditMode(false)
end

-- *****************************************************************************************************
-- ***** TASK
-- *****************************************************************************************************
TodolooTaskListTaskMixin = CreateFromMixins(CallbackRegistryMixin)
TodolooTaskListTaskMixin:GenerateCallbackEvents(
{
    "OnTaskSaved"
})

function TodolooTaskListTaskMixin:Initialize(node)
    local elementData = node:GetData()
    self.taskInfo = elementData.taskInfo

    self.Name:SetText(self.taskInfo.name)
    self.Label:SetText(self.taskInfo.name)

    local resetInterval = self.taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Manually and "M"
        or self.taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Daily and "D"
        or self.taskInfo.reset == Todoloo.TaskManager.ResetIntervals.Weekly and "W"

    self.ResetInterval:SetText(resetInterval)
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

function TodolooTaskListTaskMixin:Save()
    local isDirty = false
    
    local newName = self.Name:GetText()
    if self.taskInfo.name ~= newName then
        self.taskInfo.name = newName
        isDirty = true
    end

    -- only update if any changes
    if isDirty then
        Todoloo.TaskManager.UpdateTask(
            self.taskInfo.groupId,
            self.taskInfo.id,
            self.taskInfo.name,
            self.taskInfo.description,
            self.taskInfo.reset
        )
        EventRegistry:TriggerEvent("TodolooTaskListTaskMixin.Event.OnTaskSaved", self.taskInfo, self)
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
    OnAccept = function(self)
        Todoloo.TaskManager.RemoveGroup(self.data.groupInfo.id)
        self.data.callback()
    end,
    timout = 0,
    whileDead = 1,
    exclusive = 1,
    hideOnEscape = 1
}