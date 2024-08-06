TODOLOO_TRACKER_HEADER_HEIGHT   = 25
TODOLOO_TRACKER_TASK_WIDTH      = 248
TODOLOO_TRACKER_HEADER_OFFSET_X = -10
TODOLOO_TRACKER_MAX_HEIGHT      = 700

-- calculated values
TODOLOO_TRACKER_DASH_WIDTH = 0
TODOLOO_TRACKER_TEXT_WIDTH = 0

-- colors used throughout the task tracker
TODOLOO_TRACKER_COLOR = {
    ["Normal"] = { r = 0.8, g = 0.8, b = 0.8 },
    ["NormalHighlight"] = { r = HIGHLIGHT_FONT_COLOR.r, g = HIGHLIGHT_FONT_COLOR.g, b = HIGHLIGHT_FONT_COLOR.b },
    ["Header"] = { r = 0.75, g = 0.61, b = 0 },
    ["HeaderHighlight"] = { r = NORMAL_FONT_COLOR.r, g = NORMAL_FONT_COLOR.g, b = NORMAL_FONT_COLOR.b },
    ["Complete"] = { r = 0.6, g = 0.6, b = 0.6 },
    ["CompleteHighlight"] = { r = HIGHLIGHT_FONT_COLOR.r, g = HIGHLIGHT_FONT_COLOR.g, b = HIGHLIGHT_FONT_COLOR.b }
}
    TODOLOO_TRACKER_COLOR["Normal"].reverse = TODOLOO_TRACKER_COLOR["NormalHighlight"]
    TODOLOO_TRACKER_COLOR["NormalHighlight"].reverse = TODOLOO_TRACKER_COLOR["Normal"]
    TODOLOO_TRACKER_COLOR["Header"].reverse = TODOLOO_TRACKER_COLOR["HeaderHighlight"]
    TODOLOO_TRACKER_COLOR["HeaderHighlight"].reverse = TODOLOO_TRACKER_COLOR["Header"]
    TODOLOO_TRACKER_COLOR["Complete"].reverse = TODOLOO_TRACKER_COLOR["CompleteHighlight"]
    TODOLOO_TRACKER_COLOR["CompleteHighlight"].reverse = TODOLOO_TRACKER_COLOR["Complete"]

-- task states
TODOLOO_TRACKER_TASK_STATE_PRESENT     = 0
TODOLOO_TRACKER_TASK_STATE_ADDING      = 1
TODOLOO_TRACKER_TASK_STATE_COMPLETING  = 2
TODOLOO_TRACKER_TASK_STATE_COMPLETED   = 3
TODOLOO_TRACKER_TASK_STATE_FADING      = 4

-- dash styles for tasks
TODOLOO_TRACKER_DASH_STYLE_SHOW                = 1
TODOLOO_TRACKER_DASH_STYLE_HIDE                = 2
TODOLOO_TRACKER_DASH_STYLE_HIDE_AND_COLLAPSE   = 3