TODOLOO_LOCALES.zhCN = function()
    local L = {};

    -- Configurations.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "基本选项";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Todoloo 的基本功能设置选项。";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "常规";
    
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_LABEL"] = "通告重置";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "启用此设置后，将在聊天框中通告任务组和任务的每日和每周重置。";
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "在聊天框中通告任务组和任务的每日和每周重置";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "任务追踪器";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "显示任务追踪器";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "战斗中隐藏任务追踪器";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_LABEL"] = "战斗中隐藏";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "在战斗中隐藏任务追踪器，脱离战斗后自动显示（此设置仅在使用浮动任务追踪器时有效）。";

    L["CONFIG_ATTACH_TRACKER_LABEL"] = "将任务追踪器附加到目标追踪器";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_LABEL"] = "附加任务追踪器";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "任务追踪器将附加到暴雪的目标追踪器上。请注意，任务追踪器将始终作为最后一个模块显示在底部。如果目标追踪器已满，您需要最小化其他模块才能看到任务追踪器。";

    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "显示已完成的任务组";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_LABEL"] = "显示已完成的任务组";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "启用此设置后，任务组完成时仍会在任务追踪器中保持可见。";

    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "显示已完成的任务";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_LABEL"] = "显示已完成的任务";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "启用此设置后，任务完成时仍会在任务追踪器中保持可见。";

    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "将已完成的任务移至组底部";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_LABEL"] = "按完成状态排序";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "启用此设置后，所有已完成的任务将被移至任务追踪器中该组的底部，无论任务管理器中预设的顺序如何。";

    L["CONFIG_SHOW_PROGRESS_LABEL"] = "显示任务组进度文本";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_LABEL"] = "显示进度";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "是否在任务追踪器中的任务组名称旁显示已完成与未完成的任务数量。";

    L["CONFIG_MINIMAP_SECTION_HEADER"] = "小地图图标";

    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "显示小地图图标";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_LABEL"] = "显示小地图图标";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "显示/隐藏小地图上的图标。";

    -- Task manager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo - 任务管理";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "创建任务组";

    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "添加新任务组";

    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "重置间隔";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "无";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "手动";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "每日";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "每周";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "任务组操作";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "添加新任务";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "删除";

    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "重置间隔";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "重置间隔由父任务组控制";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "手动";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "每日";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "每周";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "任务操作";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "删除";

    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "您确定要删除吗？";

    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "创建一个新任务组来开始管理您的任务！";
    L["TASK_MANAGER_HELP_FILTER_TIP"] = "提示：搜索特定任务或任务组可以更轻松地找到您要找的项目。";
    L["TASK_MANAGER_HELP_TASK_LIST_HELP"] = "这是您当前所有任务组和任务的概览。\n\n[双击]任务组和任务可以更改名称。\n\n[Shift]+[左键点击]任务组可以折叠。\n\n[右键点击]任务组可以添加任务、设置组重置间隔和删除。\n\n[Shift]+[左键点击]任务可以切换完成状态。\n\n[右键点击]任务可以设置重置间隔和删除。";

    -- Task tracker
    L["TASK_TRACKER_GROUP_COMPLETE"] = "任务组已完成";

    -- Reset manager
    L["RESET_MANAGER_GROUP"] = "任务组";
    L["RESET_MANAGER_TASK"] = "任务";
    L["RESET_MANAGER_ON"] = "于";
    L["RESET_MANAGER_HAS_BEEN_RESET"] = "已重置";

    -- Task filter
    L["TASK_FILTER_CHECK_ALL"] = "全选";
    L["TASK_FILTER_UNCHECK_ALL"] = "取消全选";

    -- Minimap icon
    L["MINIMAP_ICON_LEFT_CLICK"] = "左键点击：";
    L["MINIMAP_ICON_RIGHT_CLICK"] = "右键点击：";
    L["MINIMAP_ICON_OPEN_TASK_MANAGER"] = "打开任务管理器";
    L["MINIMAP_ICON_OPEN_SETTINGS"] = "打开设置";

    -- Slash commands.
    L["SLASHCMD_UNKNOWN_COMMAND"] = "未知命令";
    L["SLASHCMD_TASK_MANAGER_DESCRIPTION"] = "打开任务管理器。";
    L["SLASHCMD_TASK_TRACKER_DESCRIPTION"] = "切换浮动任务追踪器。";
    L["SLASHCMD_SETTINGS_DESCRIPTION"] = "打开 Todoloo 设置。";
    L["SLASHCMD_HELP"] = "显示此帮助信息。";

    return L;
end