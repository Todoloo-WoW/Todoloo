-- *****************************************************************************************************
-- ***** SCROLL UTILITIES
-- *****************************************************************************************************

-- Returns a cursor y relative to the bottom of the frame, and the height of the frame accounting for insets.
local function GetRelativeCursorRange(frame, cy, dragBehavior)
	local insetBottom, insetTop = dragBehavior:GetCursorHitInsets();
	local bottom = frame:GetBottom() + insetBottom;
	local height = frame:GetHeight() - (insetBottom + insetTop);
	local relativeCursorY = cy - bottom;
	return relativeCursorY, height;
end

local function GetAreaOfRelativeCursor(dragBehavior, relativeCursorY, height, frame)
	local destinationData = {};
	local parentFrame = dragBehavior.childToParent[frame];
	if parentFrame then
		destinationData.parentElementData = parentFrame:GetElementData();
	end

	local contextData = {
		sourceData = dragBehavior.sourceData,
		destinationData = destinationData,
	}

	local elementData = frame:GetElementData();
	local areaMargin = dragBehavior:GetAreaIntersectMargin(elementData, sourceElementData, contextData);
	if relativeCursorY < areaMargin then
		return DragIntersectionArea.Below;
	elseif relativeCursorY + areaMargin > height then
		return DragIntersectionArea.Above;
	end
	return DragIntersectionArea.Inside;
end

local function GetTreeCursorIntersectionArea(frame, cy, dragBehavior)
	local relativeCursorY, height = GetRelativeCursorRange(frame, cy, dragBehavior);
	-- Unlike linear, tree interactions require the cursor to be within the frame bounds.
	if relativeCursorY < 0 or relativeCursorY > height then
		return nil;
	end

	return GetAreaOfRelativeCursor(dragBehavior, relativeCursorY, height, frame);
end

---Add scroll box drag behavior
---@param scrollBox ScrollFrame Scroll box
---@return table # Drag behavior
function Todoloo.ScrollUtil.AddTaskListDragBehavior(scrollBox)
    local dragBehavior = CreateScrollBoxDragBehavior(scrollBox)

    local function OnDragUpdate(cx, cy)
        local sourceData = dragBehavior.sourceData
		local sourceElementData = sourceData.elementData
		local sourceElementDataIndex = sourceData.elementDataIndex

		local candidate = dragBehavior.candidate
		
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

			local area = GetTreeCursorIntersectionArea(frame, cy, dragBehavior)
			if area then
                local contextData =
                {
                    area = area,
                    frame = frame,
                    elementData = elementData
                }

                local dropPredicate = dragBehavior:GetDropPredicate()
                if dropPredicate and not dropPredicate(dragBehavior.sourceData.elementData, contextData) then
                    return false
                end

				candidate.frame = frame
				candidate.area = area
				candidate.elementData = elementData

				local elementDataIndex = frame:GetElementDataIndex()
				if elementDataIndex < sourceElementDataIndex then
					return ScrollBoxConstants.StopIteration
				end
			end
		end)

		return candidate.frame ~= nil
    end

    local function OnDragStop()
        local candidate = dragBehavior.candidate
        if candidate.elementData then
            local area = candidate.area
            local candidateElementData = candidate.elementData

            local sourceData = dragBehavior.sourceData
            local sourceElementData = sourceData.elementData

            local destinationData = {
                elementData = candidateElementData
            }

            if candidateElementData and area then
                if area == DragIntersectionArea.Above then
                    local parent = candidateElementData:GetParent();
                    parent:MoveNodeRelativeTo(sourceElementData, candidateElementData, 0);
                elseif area == DragIntersectionArea.Inside then
                    candidateElementData:MoveNode(sourceElementData);
                elseif area == DragIntersectionArea.Below then
                    local parent = candidateElementData:GetParent();
                    parent:MoveNodeRelativeTo(sourceElementData, candidateElementData, 1);
                end
    
                dragBehavior.dropResult = {
                    sourceData = sourceData,
                    destinationData = destinationData,
                    area = area
                }
    
                return true;
            end
        end

		return false;
    end

    dragBehavior:Register(OnDragStop, OnDragUpdate)
    return dragBehavior;
end
