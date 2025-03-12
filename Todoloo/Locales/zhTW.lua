TODOLOO_LOCALES.zhTW = function()
    local L = {};

    -- Configurations.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "基本選項";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Todoloo 的基本功能設定選項。";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "一般";
    
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_LABEL"] = "通告重置";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "啟用此設定後，將在聊天視窗中通告任務組和任務的每日和每週重置。";
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "在聊天視窗中通告任務組和任務的每日和每週重置";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "任務追蹤器";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "顯示任務追蹤器";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "戰鬥中隱藏任務追蹤器";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_LABEL"] = "戰鬥中隱藏";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "在戰鬥中隱藏任務追蹤器，脫離戰鬥後自動顯示（此設定僅在使用浮動任務追蹤器時有效）。";

    L["CONFIG_ATTACH_TRACKER_LABEL"] = "將任務追蹤器附加到目標追蹤器";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_LABEL"] = "附加任務追蹤器";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "任務追蹤器將附加到暴雪的目標追蹤器上。請注意，任務追蹤器將始終作為最後一個模組顯示在底部。如果目標追蹤器已滿，您需要最小化其他模組才能看到任務追蹤器。";

    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "顯示已完成的任務組";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_LABEL"] = "顯示已完成的任務組";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "啟用此設定後，任務組完成時仍會在任務追蹤器中保持可見。";

    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "顯示已完成的任務";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_LABEL"] = "顯示已完成的任務";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "啟用此設定後，任務完成時仍會在任務追蹤器中保持可見。";

    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "將已完成的任務移至組底部";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_LABEL"] = "依完成狀態排序";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "啟用此設定後，所有已完成的任務將被移至任務追蹤器中該組的底部，無論任務管理器中預設的順序為何。";

    L["CONFIG_SHOW_PROGRESS_LABEL"] = "顯示任務組進度文字";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_LABEL"] = "顯示進度";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "是否在任務追蹤器中的任務組名稱旁顯示已完成與未完成的任務數量。";

    L["CONFIG_MINIMAP_SECTION_HEADER"] = "小地圖圖示";

    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "顯示小地圖圖示";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_LABEL"] = "顯示小地圖圖示";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "顯示/隱藏小地圖上的圖示。";

    -- Task manager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo - 任務管理";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "建立任務組";

    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "新增任務組";

    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "重置間隔";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "無";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "手動";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "每日";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "每週";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "任務組操作";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "新增任務";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "刪除";

    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "重置間隔";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "重置間隔由父任務組控制";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "手動";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "每日";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "每週";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "任務操作";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "刪除";

    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "您確定要刪除嗎？";

    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "建立一個新任務組來開始管理您的任務！";
    L["TASK_MANAGER_HELP_FILTER_TIP"] = "提示：搜尋特定任務或任務組可以更輕鬆地找到您要找的項目。";
    L["TASK_MANAGER_HELP_TASK_LIST_HELP"] = "這是您目前所有任務組和任務的概覽。\n\n[雙擊]任務組和任務可以更改名稱。\n\n[Shift]+[左鍵點擊]任務組可以摺疊。\n\n[右鍵點擊]任務組可以新增任務、設定組重置間隔和刪除。\n\n[Shift]+[左鍵點擊]任務可以切換完成狀態。\n\n[右鍵點擊]任務可以設定重置間隔和刪除。";

    -- Task tracker
    L["TASK_TRACKER_GROUP_COMPLETE"] = "任務組已完成";

    -- Reset manager
    L["RESET_MANAGER_GROUP"] = "任務組";
    L["RESET_MANAGER_TASK"] = "任務";
    L["RESET_MANAGER_ON"] = "於";
    L["RESET_MANAGER_HAS_BEEN_RESET"] = "已重置";

    -- Task filter
    L["TASK_FILTER_CHECK_ALL"] = "全選";
    L["TASK_FILTER_UNCHECK_ALL"] = "取消全選";

    -- Minimap icon
    L["MINIMAP_ICON_LEFT_CLICK"] = "左鍵點擊：";
    L["MINIMAP_ICON_RIGHT_CLICK"] = "右鍵點擊：";
    L["MINIMAP_ICON_OPEN_TASK_MANAGER"] = "開啟任務管理器";
    L["MINIMAP_ICON_OPEN_SETTINGS"] = "開啟設定";

    -- Slash commands.
    L["SLASHCMD_UNKNOWN_COMMAND"] = "未知指令";
    L["SLASHCMD_TASK_MANAGER_DESCRIPTION"] = "開啟任務管理器。";
    L["SLASHCMD_TASK_TRACKER_DESCRIPTION"] = "切換浮動任務追蹤器。";
    L["SLASHCMD_SETTINGS_DESCRIPTION"] = "開啟 Todoloo 設定。";
    L["SLASHCMD_HELP"] = "顯示此說明訊息。";

    return L;
end