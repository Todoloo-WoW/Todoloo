TODOLOO_LOCALES.ruRU = function()
    local L = {};
    -- Translator: ZamestoTV
    -- Configurations.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "Основные настройки";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Основные настройки для включения функций в Todoloo.";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "Общее";
    
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "Оповещение о сбросах";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "При активации этой настройки ежедневные и еженедельные сбросы групп и задач будут объявляться в чате.";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "Трекер задач";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "Показывать трекер задач";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "Скрывать трекер задач в бою";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "Скрывать трекер задач во время боя и автоматически показывать его снова после выхода из боя (эта настройка актуальна только при использовании плавающего трекера задач).";

    L["CONFIG_ATTACH_TRACKER_LABEL"] = "Прикрепить трекер задач к трекеру целей";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "Трекер задач будет прикреплен к трекеру целей Blizzard. Учтите, что трекер задач всегда будет последним модулем и отображаться внизу. Если трекер целей заполнен, вам нужно будет свернуть другие модули, чтобы увидеть трекер задач.";

    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "Показывать завершенные группы";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "При активации этой настройки группы останутся видимыми в трекере задач после их завершения.";

    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "Показывать завершенные задачи";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "При активации этой настройки задачи останутся видимыми в трекере задач после их завершения.";

    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "Сортировка по завершению";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "При активации этой настройки все завершенные задачи будут перемещены в конец группы в трекере задач, независимо от заранее заданного порядка в менеджере задач.";

    L["CONFIG_SHOW_PROGRESS_LABEL"] = "Показывать текст прогресса группы";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "Показывать количество завершенных и незавершенных задач рядом с названием группы в трекере задач.";

    L["CONFIG_MINIMAP_SECTION_HEADER"] = "Иконка миникарты";

    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "Показывать иконку миникарты";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_LABEL"] = "Показывать иконку миникарты";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "Показывать/скрывать иконку на миникарте.";

    -- Task manager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo - Управление задачами";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "Создать группу";

    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "Добавить новую группу";

    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "Интервал сброса";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "Нет";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "Вручную";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "Ежедневно";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "Еженедельно";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "Действия с группой";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "Добавить новую задачу";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "Удалить";

    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "Интервал сброса";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "Интервал сброса контролируется родительской группой";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "Вручную";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "Ежедневно";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "Еженедельно";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "Действия с задачей";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "Удалить";

    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "Вы уверены, что хотите удалить";

    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "Создайте новую группу, чтобы начать управлять задачами!";
    L["TASK_MANAGER_HELP_FILTER_TIP"] = "Совет: Ищите конкретную задачу или группу, чтобы легче найти нужный элемент.";
    L["TASK_MANAGER_HELP_TASK_LIST_HELP"] = "Это обзор всех ваших текущих групп и задач.\n\n[Двойной клик] по группам и задачам для изменения названия.\n\n[Shift]+[ЛКМ] по группам для сворачивания.\n\n[ПКМ] по группам для добавления задач, установки интервала сброса группы и удаления.\n\n[Shift]+[ЛКМ] по задачам для переключения статуса завершения.\n\n[ПКМ] по задачам для установки интервала сброса и удаления.";

    -- Task tracker
    L["TASK_TRACKER_GROUP_COMPLETE"] = "Задачи группы выполнены";

    -- Reset manager
    L["RESET_MANAGER_GROUP"] = "Группа";
    L["RESET_MANAGER_TASK"] = "Задача";
    L["RESET_MANAGER_ON"] = "в";
    L["RESET_MANAGER_HAS_BEEN_RESET"] = "была сброшена";

    -- Task filter
    L["TASK_FILTER_CHECK_ALL"] = "Выбрать все";
    L["TASK_FILTER_UNCHECK_ALL"] = "Снять все";

    -- Minimap icon
    L["MINIMAP_ICON_LEFT_CLICK"] = "ЛКМ:";
    L["MINIMAP_ICON_RIGHT_CLICK"] = "ПКМ:";
    L["MINIMAP_ICON_OPEN_TASK_MANAGER"] = "Открыть менеджер задач";
    L["MINIMAP_ICON_OPEN_SETTINGS"] = "Открыть настройки";

    -- Slash commands.
    L["SLASHCMD_UNKNOWN_COMMAND"] = "Неизвестная команда";
    L["SLASHCMD_TASK_MANAGER_DESCRIPTION"] = "Открыть менеджер задач.";
    L["SLASHCMD_TASK_TRACKER_DESCRIPTION"] = "Переключить плавающий трекер задач.";
    L["SLASHCMD_SETTINGS_DESCRIPTION"] = "Открыть настройки Todoloo.";
    L["SLASHCMD_HELP"] = "Показать это справочное сообщение.";

    return L;
end
