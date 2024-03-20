local _, Todoloo = ...

-- *****************************************************************************************************
-- ***** SCROLL UTILITIES
-- *****************************************************************************************************

---@enum candidateType Candidate types
Todoloo.ScrollUtil.CandidateType = {
    ---Task element
    Task    = 1,
    ---Group element
    Group   = 2
}

local function GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop)
	local bottom = frame:GetBottom() + cursorHitInsetBottom;
	local height = frame:GetHeight() - (cursorHitInsetBottom - cursorHitInsetTop);
	return (cy - bottom) / height;
end

local function GetTreeCursorIntersectionArea(p)
	-- Tree interaction areas require the cursor to be within the frame bounds.
	if p < 0 or p > 1 then
		return nil;
	end

	if p <= .49 then
		return DragIntersectionArea.Below;
	elseif p >= .50 then
		return DragIntersectionArea.Above;
	end
	return DragIntersectionArea.Below;
end

---Add task list scroll box dragging behavior
---@param scrollBox ScrollFrame Scroll box
---@param cursorFactory function Factory to create the cursor
---@param taskLineIndicatorFactory function Factory to create the task line indiciator, when dragging between tasks
---@param groupLineIndicatorFactory function Factory to create the group line indiciator, when dragging between groups
---@param indicatorAnchorHandler function Function to set anchor on the indiciators
---@param dragProperties DragProperties Various proeprties for the dragging behavior
---@return table # The drag behavior created
function Todoloo.ScrollUtil.AddTaskListDragBehavior(scrollBox, cursorFactory, taskLineIndicatorFactory, groupLineIndicatorFactory, indicatorAnchorHandler, dragProperties)
    local dragBehavior = CreateScrollBoxDragBehavior(scrollBox)
    local candidateArea = nil
    local candidateElementData = nil
    local candidateType = nil

    local groupLineTemplate, groupLineInitializer = groupLineIndicatorFactory(elementData)
    local cursorBox = dragBehavior:AcquireFromPool(groupLineTemplate)
    cursorBox:SetParent(scrollBox)
    cursorBox:SetFrameStrata("DIALOG")
    if groupLineInitializer then
        groupLineInitializer(cursorBox)
    end

    ---Function called every frame as we're dragging an element
    local function OnDragUpdate(cursorFrame, cursorLine, sourceElementData, sourceElementDataIndex, cx, cy)
        -- if we cannot reorder elements in the scroll box, there's no need to continue
        if not dragBehavior:GetReorderable() then
            return
        end

        local sourceData = sourceElementData:GetData()
        local candidate = nil
        candidateArea = nil
        candidateElementData = nil
        candidateType = nil

        cursorBox:Hide()

        local containsCursor = dragBehavior:ScrollBoxContainsCursor(cx, cy)
        if containsCursor then
            local cursorHitInsetBottom, cursorHitInsetTop = dragBehavior:GetCursorHitInsets()

            scrollBox:ForEachFrame(function(frame, elementData)
                if sourceElementData == elementData then
                    return ScrollBoxConstants.ContinueIteration
                end

                local parent = elementData:GetParent()
                while parent do
                    if parent == sourceElementData then
                        return ScrollBoxConstants.ContinueIteration
                    end
                    parent = parent:GetParent()
                end

                candidateType = Todoloo.ScrollUtil.CandidateType.Task
                local percentage = GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop)
                local area = GetTreeCursorIntersectionArea(percentage)

                if area then
                    candidateArea = area
                    local candidateData = elementData:GetData()

                    if not candidateData.groupInfo and not candidateData.taskInfo then
                        -- We're only interested in tasks and groups
                        return
                    end

                    if candidateData.character ~= sourceData.character then
                        -- We're only interested in groups and tasks within the same character.
                        -- It's not possible to drag groups and tasks between characters.
                        return
                    end

                    if candidateData.groupInfo then
                        -- If the element we're currently hovering is a group
                        candidateType = Todoloo.ScrollUtil.CandidateType.Group
                        if sourceData.taskInfo then
                            candidateArea = DragIntersectionArea.Inside
                        end
                    end
                    
                    candidate = frame
                    candidateElementData = elementData

                    local elementDataIndex = scrollBox:FindFrameElementDataIndex(frame)
                    if elementDataIndex < sourceElementDataIndex then
                        return ScrollBoxConstants.StopIteration
                    end
                end
            end)

            if candidate then
                local isInside = candidateArea == DragIntersectionArea.Inside
                local indicatorFrame = isInside and cursorBox or cursorLine
                indicatorFrame:Show()
                indicatorFrame:ClearAllPoints()
                indicatorAnchorHandler(indicatorFrame, candidate, candidateType, candidateArea)
            end
        end
    end

    ---Function called when we stop dragging and it's time to reorder the tasks
    local function OnDragStop(sourceElementData)
        if not candidateElementData or not candidateArea then
            return
        end

        local sourceData = sourceElementData:GetData()
        local candidateData = candidateElementData:GetData()

        if sourceData.groupInfo and candidateData.groupInfo then
            -- if we're moving a group
            local sourceId = sourceData.groupInfo.id
            local newGroupId = candidateData.groupInfo.id
            if candidateArea == DragIntersectionArea.Below then
                newGroupId = candidateData.groupInfo.id + 1
            end

            PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
            Todoloo.TaskManager:MoveGroup(sourceId, newGroupId, candidateData.character)
        elseif sourceData.taskInfo then
            -- if we're moving a task
            local sourceId = sourceData.taskInfo.id
            local sourceGroupId = sourceData.taskInfo.groupId

            if candidateArea == DragIntersectionArea.Inside and candidateData.groupInfo and candidateData.groupInfo.id ~= sourceData.taskInfo.groupId then
                -- moving to new group not relative to task
                if candidateData.groupInfo.id == sourceData.taskInfo.groupId then
                    -- same group, do nothing
                    return
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, candidateData.groupInfo.id, nil, candidateData.character)
            elseif candidateData.taskInfo and candidateData.taskInfo.groupId ~= sourceData.taskInfo.groupId then
                -- moving to new group (move relative to task)
                local offset
                if candidateArea == DragIntersectionArea.Above then
                    offset = 0
                elseif candidateArea == DragIntersectionArea.Below then
                    offset = 1
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                local newTaskId = candidateData.taskInfo.id + offset
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, candidateData.taskInfo.groupId, newTaskId, candidateData.character)
            else
                -- moving within the same group but relative to another task
                local offset
                if candidateArea == DragIntersectionArea.Above then
                    offset = 0
                elseif candidateArea == DragIntersectionArea.Below then
                    offset = 1
                end

                PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
                local newTaskId = candidateData.taskInfo.id + offset
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, sourceGroupId, newTaskId, candidateData.character)
            end
        end

        cursorBox:Hide()

        candidateArea = nil
        candidateElementData = nil
        candidateType = nil
    end

    dragBehavior:Register(cursorFactory, taskLineIndicatorFactory, OnDragStop, OnDragUpdate, dragProperties)
    return dragBehavior;
end

do
    local function TaskLineIndicatorFactory(_)
        return "TodolooScrollBoxDragLineTemplate"
    end

    local function GroupLineIndicatorFactory(_)
        return "TodolooScrollBoxDragGroupTemplate"
    end

    local sourceFrameData

    local function NotifyDragSource(sourceFrame, drag)
        sourceFrame:SetAlpha(drag and .5 or 1)
        sourceFrame:SetMouseMotionEnabled(not drag)
        
        if sourceFrame.GetElementData == nil then
            -- If the source frame is no longer visible in the scrollbox.
            -- This can happen if we're is scrolling whilst dragging.
            return
        end

        local node = sourceFrame:GetElementData()

        if drag then
            sourceFrameData = sourceFrame:GetData()

            if sourceFrameData.groupInfo then
                node:SetCollapsed(true)
                sourceFrame:SetCollapseState(true)
            end
        else
            if sourceFrameData.groupInfo then
                node:SetCollapsed(false)
                sourceFrame:SetCollapseState(false)
            end

            sourceFrameData = nil
        end
    end

    local function NotifyDragCandidates(candidateFrame, drag)
        candidateFrame:SetMouseMotionEnabled(not drag)
        local node = candidateFrame:GetElementData()
        local candidateData = candidateFrame:GetData()

        if drag and sourceFrameData then
            if sourceFrameData.groupInfo and candidateData.groupInfo then
                node:SetCollapsed(true)
                candidateFrame:SetCollapseState(true)
            end

            if sourceFrameData.character ~= candidateData.character then
                -- If the candidate frame's registered character is not the same as the source frame beign dragged,
                -- make sure to visualize that it's not possible to drag between characters
                candidateFrame:SetAlpha(.5)
            else
                -- This only exists to handle the scenario where tasks and groups on the same character
                -- disappears from the scroll box because of scrolling whilst dragging, and getting
                -- added again when being rendered back into the scroll box
                candidateFrame:SetAlpha(1)
            end
        else
            if candidateData.groupInfo then
                node:SetCollapsed(false)
                candidateFrame:SetCollapseState(false)
            end

            candidateFrame:SetAlpha(1)
        end
    end

    local function GenerateCursorFactory(scrollbar)
        local function CursorFactory(elementData)
            local view = scrollbar:GetView()
            local function CursorIntializer(cursorFrame, candidateFrame, elementData)
                cursorFrame:SetSize(candidateFrame:GetSize())

                local _, initializer = view:GetFactoryDataFromElementData(elementData)
                initializer(cursorFrame, elementData)
            end

            local template = view:GetFactoryDataFromElementData(elementData)
            return template, CursorIntializer
        end

        return CursorFactory
    end

    local function ConfigureDragBehavior(dragBehavior)
        dragBehavior:SetNotifyDragSource(NotifyDragSource)
        dragBehavior:SetNotifyDragCandidates(NotifyDragCandidates)
        dragBehavior:SetDragRelativeToCursor(true)
    end

    local function IndicatorAnchorHandler(indiciatorFrame, candidateFrame, candidateType, candidateArea)
        if candidateType == Todoloo.ScrollUtil.CandidateType.Task then
            -- if our candidate is a task element
            if candidateArea == DragIntersectionArea.Above then
                indiciatorFrame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", 40, 0);
                indiciatorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", -40, 0);
            elseif candidateArea == DragIntersectionArea.Below then
                indiciatorFrame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", 40, 0);
                indiciatorFrame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", -40, 0);
            elseif candidateArea == DragIntersectionArea.Inside then
                indiciatorFrame:SetPoint("TOPLEFT", candidateFrame, "TOPLEFT", 0, 5);
                indiciatorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "BOTTOMRIGHT", 0, 1);
            end
        elseif candidateType == Todoloo.ScrollUtil.CandidateType.Group then
            -- if our candidate is group element
            if candidateArea == DragIntersectionArea.Above then
                indiciatorFrame:SetPoint("BOTTOMLEFT", candidateFrame, "TOPLEFT", 40, 0);
                indiciatorFrame:SetPoint("BOTTOMRIGHT", candidateFrame, "TOPRIGHT", -40, 0);
            elseif candidateArea == DragIntersectionArea.Below then
                indiciatorFrame:SetPoint("TOPLEFT", candidateFrame, "BOTTOMLEFT", 40, 0);
                indiciatorFrame:SetPoint("TOPRIGHT", candidateFrame, "BOTTOMRIGHT", -40, 0);
            end
        end
    end

    function Todoloo.ScrollUtil.InitDefaultTaskListDragBehavior(scrollBox)
        local dragBehavior = Todoloo.ScrollUtil.AddTaskListDragBehavior(scrollBox, GenerateCursorFactory(scrollBox),
            TaskLineIndicatorFactory, GroupLineIndicatorFactory, IndicatorAnchorHandler, {})

        ConfigureDragBehavior(dragBehavior)
        return dragBehavior
    end
end

-- *****************************************************************************************************
-- ***** DOCUMENTATION
-- *****************************************************************************************************

---@class DragProperties
---@field notifyDragSource function? Callback to notify the source element when dragging begins
---@field sourceDragCondition function? Function to set the drag condition on the source element (must return either nil, true, or false)
---@field dragRelativeToCursor boolean? Is the cursor  positioned relative to the source element?
---@field notifyDragCandidates function? Callback to notify all other elements than the source, when dragging begins
---@field notifyDragReceived function? --TODO: Not sure what this does
---@field reorderable boolean? Is reordering be enabled?
