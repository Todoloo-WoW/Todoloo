-- *****************************************************************************************************
-- ***** SCROLL UTILITIES
-- *****************************************************************************************************

Todoloo.ScrollUtil = {}

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

    local boxTemplate, boxInitializer = groupLineIndicatorFactory(elementData)
    local cursorBox = dragBehavior:AcquireFromPool(boxTemplate)
    cursorBox:SetParent(scrollBox)
    cursorBox:SetFrameStrata("DIALOG")
    if boxInitializer then
        boxInitializer(cursorBox)
    end

    ---Function called every frame as we're dragging and element
    local function OnDragUpdate(cursorFrame, cursorLine, sourceElementData, sourceElementDataIndex, cx, cy)
        -- we cannot reorder elements in the scroll box, and there's no need to continue
        if not dragBehavior:GetReorderable() then
            return
        end

        local candidate = nil
        candidateArea = nil
        candidateElementData = nil

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

                local percentage = GetCursorIntersectPercentage(frame, cy, cursorHitInsetBottom, cursorHitInsetTop)
                local area = GetTreeCursorIntersectionArea(percentage)

                if area then
                    candidateArea = area
                    local candidateData = elementData:GetData()

                    if not candidateData.groupInfo and not candidateData.taskInfo then
                        -- we're only interested in tasks and groups - not dividers and padding
                        return
                    end

                    if candidateData.groupInfo then
                        -- if the element we're currently hovering is a group
                        candidateArea = DragIntersectionArea.Inside
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
                local candidateFrame = isInside and cursorBox or cursorLine
                --local candidateFrame = cursorLine
                candidateFrame:Show()
                candidateFrame:ClearAllPoints()
                indicatorAnchorHandler(candidateFrame, candidate, candidateArea)
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
        if sourceData.groupInfo then
            -- if we're moving a group
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

                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, candidateData.groupInfo.id)
            elseif candidateData.taskInfo and candidateData.taskInfo.groupId ~= sourceData.taskInfo.groupId then
                -- moving to new group (move relative to task)
                local offset
                if candidateArea == DragIntersectionArea.Above then
                    offset = 0
                elseif candidateArea == DragIntersectionArea.Below then
                    offset = 1
                end

                local newTaskId = candidateData.taskInfo.id + offset
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, candidateData.taskInfo.groupId, newTaskId)
            else
                -- moving within the same group but relative to another task
                local newTaskId = candidateData.taskInfo.id
                Todoloo.TaskManager:MoveTask(sourceId, sourceGroupId, sourceGroupId, newTaskId)
            end
        end

        cursorBox:Hide()

        candidateArea = nil
        candidateElementData = nil
    end

    dragBehavior:Register(cursorFactory, taskLineIndicatorFactory, OnDragStop, OnDragUpdate, dragProperties)
    return dragBehavior;
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
