-- *****************************************************************************************************
-- ***** GROUP LIST
-- *****************************************************************************************************

--TODO: Move to /Pages
TodolooTaskListMixin = CreateFromMixins(CallbackRegistryMixin)

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
            local function Initializer(button, node)
                button:Initialize(node)

                button:SetScript("OnClick", function(button, buttonName)
                    node:ToggleCollapsed()
                    button:SetCollapseState(node:IsCollapsed())
                end)
            end
            factory("TodolooTaskListGroupTemplate", Initializer);
        elseif elementData.taskInfo then
            -- if the element is a task
            local function Initializer(button, node)
                button:Initialize(node)

                local selected = self.selectionBehaviour:IsElementDataSelected(node)
                button:SetSelected(selected)

                button:SetScript("OnClick", function(button, buttonName, down)
                    if buttonName == "Leftbutton" then
                        self.selectionBehaviour:Select(button)
                    end

                    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK);
                end)

                --TODO: Implement
                -- button:SetScript("OnEnter", function()
				-- 	TodolooTaskListTaskMixin.OnEnter(button);
				-- end);
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
        if button then
            button:SetSelected(selected)
        end

        if selected then
            local data = elementData:GetData()
            assert(data.taskInfo)

            local newTaskId = data.taskInfo.id
            local changed = self.previousTaskId ~= newTaskId
            if changed then
                --EventRegistry:TriggerEvent("TodolooTaskListMixin.Event.OnTaskSelected", data.taskInfo, self)

                if newTaskId then
                    self.previousTaskId = newTaskId
                end
            end
        end
    end

    self.selectionBehaviour = ScrollUtil.AddSelectionBehavior(self.ScrollBox)
    self.selectionBehaviour:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self)
end

function TodolooTaskListMixin:SelectTask(taskInfo, scrollToTask)
    local elementData = self.selectionBehaviour:SelectElementDataByPredicate(function(node)
        local data = node:GetData()
        return data.taskInfo and data.taskInfo.id == taskInfo.id
    end)

    if scrollToTask then
        self.ScrollBox:ScrollToElementData(elementData)
    end

    return elementData
end

-- *****************************************************************************************************
-- ***** GROUP
-- *****************************************************************************************************
TodolooTaskListGroupMixin = {}

function TodolooTaskListGroupMixin:Initialize(node)
    local elementData = node:GetData()
    print(elementData)
    local groupInfo = elementData.groupInfo
    self.Label:SetText(groupInfo.name)
    self.Label:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())

    self:SetCollapseState(node:IsCollapsed())
end

function TodolooTaskListGroupMixin:OnEnter()
    self.Label:SetFontObject(GameFontHighlight_NoShadow)
end

function TodolooTaskListGroupMixin:OnLeave()
    self.Label:SetFontObject(GameFontNormal_NoShadow)
end

function TodolooTaskListGroupMixin:SetCollapseState(collapsed)
    local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
end

-- *****************************************************************************************************
-- ***** TASK
-- *****************************************************************************************************
TodolooTaskListTaskMixin = {}

function TodolooTaskListTaskMixin:Initialize(node)
    local elementData = node:GetData()
    local taskInfo = elementData.taskInfo

    self.Label:SetText(taskInfo.name)
    self.Label:SetVertexColor(PROFESSION_RECIPE_COLOR:GetRGB())
end

function TodolooTaskListTaskMixin:OnEnter()
    self.Label:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB())

    if self.Label:IsTruncated() then
        --TODO: Show tooltip if the task name is too long to show and is truncated
    end
end

function TodolooTaskListTaskMixin:OnLeave()
    self.Label:SetVertexColor(PROFESSION_RECIPE_COLOR:GetRGB())

    --TODO: Hide tooltip if shown
end

function TodolooTaskListTaskMixin:SetSelected(selected)
    self.SelectedOverlay:SetShown(selected)
    self.HighlightOverlay:SetShown(not selected)

    --TODO: Hide tooltip if shown
end