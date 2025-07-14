TODOLOO_LOCALES.deDE = function()
    local L = {};
    
    -- Konfigurationen.
    L["CONFIG_BASIC_OPTIONS_LABEL"] = "Grundlegende Optionen";
    L["CONFIG_BASIC_OPTIONS_DESCRIPTION"] = "Grundlegende Optionen zur Aktivierung von Funktionen in Todoloo.";
    L["CONFIG_GENERAL_SECTION_HEADER"] = "Allgemein";
    
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_LABEL"] = "Zurücksetzungen ankündigen";
    L["CONFIG_ANNOUNCE_RESET_TOOLTIP_DESCRIPTION"] = "Wenn diese Einstellung aktiviert ist, werden tägliche und wöchentliche Zurücksetzungen von Gruppen und Aufgaben im Chat angekündigt.";
    L["CONFIG_ANNOUNCE_RESET_LABEL"] = "Tägliche und wöchentliche Zurücksetzungen von Gruppen und Aufgaben im Chat ankündigen";
    
    L["CONFIG_TASK_TRACKER_SECTION_HEADER"] = "Aufgabenverfolgung";
    L["CONFIG_SHOW_TASK_TRACKER_LABEL"] = "Aufgabenverfolgung anzeigen";
    
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_LABEL"] = "Aufgabenverfolgung im Kampf ausblenden";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_LABEL"] = "Im Kampf ausblenden";
    L["CONFIG_HIDE_TRACKER_IN_COMBAT_TOOLTIP_DESCRIPTION"] = "Blendet die Aufgabenverfolgung im Kampf aus und zeigt sie automatisch wieder an, sobald der Kampf beendet ist (diese Einstellung gilt nur für den schwebenden Tracker).";
    
    L["CONFIG_ATTACH_TRACKER_LABEL"] = "Aufgabenverfolgung an Zielverfolgung anhängen";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_LABEL"] = "Angehängte Aufgabenverfolgung";
    L["CONFIG_ATTACH_TRACKER_TOOLTIP_DESCRIPTION"] = "Die Aufgabenverfolgung wird an Blizzards Zielverfolgung angehängt. Beachte, dass sie immer als letztes Modul ganz unten angezeigt wird. Wenn die Zielverfolgung voll ist, musst du andere Module minimieren, um die Aufgabenverfolgung sehen zu können.";
    
    L["CONFIG_SHOW_COMPLETED_GROUPS_LABEL"] = "Abgeschlossene Gruppen anzeigen";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_LABEL"] = "Abgeschlossene Gruppen anzeigen";
    L["CONFIG_SHOW_COMPLETED_GROUPS_TOOLTIP_DESCRIPTION"] = "Wenn diese Einstellung aktiviert ist, bleiben abgeschlossene Gruppen im Aufgabenverfolger sichtbar.";
    
    L["CONFIG_SHOW_COMPLETED_TASKS_LABEL"] = "Abgeschlossene Aufgaben anzeigen";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_LABEL"] = "Abgeschlossene Aufgaben anzeigen";
    L["CONFIG_SHOW_COMPLETED_TASKS_TOOLTIP_DESCRIPTION"] = "Wenn diese Einstellung aktiviert ist, bleiben abgeschlossene Aufgaben im Aufgabenverfolger sichtbar.";
    
    L["CONFIG_ORDER_BY_COMPLETION_LABEL"] = "Abgeschlossene Aufgaben ans Ende der Gruppen verschieben";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_LABEL"] = "Nach Abschluss sortieren";
    L["CONFIG_ORDER_BY_COMPLETION_TOOLTIP_DESCRIPTION"] = "Wenn diese Einstellung aktiviert ist, werden alle abgeschlossenen Aufgaben innerhalb der Gruppe im Aufgabenverfolger nach unten verschoben – unabhängig von der vordefinierten Reihenfolge im Aufgabenmanager.";
    
    L["CONFIG_SHOW_PROGRESS_LABEL"] = "Gruppenfortschritt anzeigen";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_LABEL"] = "Fortschritt anzeigen";
    L["CONFIG_SHOW_PROGRESS_TOOLTIP_DESCRIPTION"] = "Legt fest, ob der Fortschritt (abgeschlossen vs. nicht abgeschlossen) neben dem Gruppennamen im Aufgabenverfolger angezeigt wird.";
    
    L["CONFIG_MINIMAP_SECTION_HEADER"] = "Minikartensymbol";
    
    L["CONFIG_SHOW_MINIMAP_ICON_LABEL"] = "Minikartensymbol anzeigen";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_LABEL"] = "Minikartensymbol anzeigen";
    L["CONFIG_SHOW_MINIMAP_ICON_TOOLTIP_DESCRIPTION"] = "Zeigt/versteckt das Symbol auf der Minikarte.";
    
    -- Aufgabenmanager
    L["TASK_MANAGER_FRAME_HEADER"] = "Todoloo – Aufgabenverwaltung";
    L["TASK_MANAGER_BUTTON_CREATE_GROUP"] = "Gruppe erstellen";
    
    L["TASK_MANAGER_CHARACTER_ADD_NEW_GROUP"] = "Neue Gruppe hinzufügen";
    
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_LABEL"] = "Zurücksetzintervall";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_NONE"] = "Keines";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_MANUALLY"] = "Manuell";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_DAILY"] = "Täglich";
    L["TASK_MANAGER_GROUP_RESET_INTERVAL_WEEKLY"] = "Wöchentlich";
    L["TASK_MANAGER_GROUP_ACTIONS_LABEL"] = "Gruppenaktionen";
    L["TASK_MANAGER_GROUP_ACTIONS_ADD_NEW_TASK"] = "Neue Aufgabe hinzufügen";
    L["TASK_MANAGER_GROUP_ACTIONS_DELETE"] = "Löschen";
    
    L["TASK_MANAGER_TASK_RESET_INTERVAL_LABEL"] = "Zurücksetzintervall";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_CONTROLLED_BY_GROUP"] = "Zurücksetzintervall wird von der übergeordneten Gruppe gesteuert";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_MANUALLY"] = "Manuell";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_DAILY"] = "Täglich";
    L["TASK_MANAGER_TASK_RESET_INTERVAL_WEEKLY"] = "Wöchentlich";
    L["TASK_MANAGER_TASK_ACTION_LABEL"] = "Aufgabenaktionen";
    L["TASK_MANAGER_TASK_ACTION_DELETE"] = "Löschen";
    
    L["TASK_MANAGER_DELETE_GROUP_DIALOG_QUESTION"] = "Bist du sicher, dass du löschen möchtest";
    
    L["TASK_MANAGER_HELP_CREATE_GROUP_HELP"] = "Erstelle eine neue Gruppe, um mit der Aufgabenverwaltung zu beginnen!";
    L["TASK_MANAGER_HELP_FILTER_TIP"] = "Tipp: Suche nach einer bestimmten Aufgabe oder Gruppe, um sie schneller zu finden.";
    L["TASK_MANAGER_HELP_TASK_LIST_HELP"] = "Dies ist deine Übersicht über alle aktuellen Gruppen und Aufgaben.\n\n[Doppelklick] auf Gruppen und Aufgaben, um den Namen zu ändern.\n\n[Umschalt]+[Linksklick] auf Gruppen zum Ein-/Ausklappen.\n\n[Rechtsklick] auf Gruppen, um Aufgaben hinzuzufügen, das Zurücksetzintervall festzulegen oder zu löschen.\n\n[Umschalt]+[Linksklick] auf Aufgaben, um den Abschlussstatus umzuschalten.\n\n[Rechtsklick] auf Aufgaben, um das Zurücksetzintervall festzulegen oder sie zu löschen.";
    
    -- Aufgabenverfolgung
    L["TASK_TRACKER_GROUP_COMPLETE"] = "Gruppenaufgaben abgeschlossen";
    
    -- Zurücksetzmanager
    L["RESET_MANAGER_GROUP"] = "Gruppe";
    L["RESET_MANAGER_TASK"] = "Aufgabe";
    L["RESET_MANAGER_ON"] = "am";
    L["RESET_MANAGER_HAS_BEEN_RESET"] = "wurde zurückgesetzt";
    
    -- Aufgabenfilter
    L["TASK_FILTER_CHECK_ALL"] = "Alle auswählen";
    L["TASK_FILTER_UNCHECK_ALL"] = "Alle abwählen";
    
    -- Minikartensymbol
    L["MINIMAP_ICON_LEFT_CLICK"] = "Linksklick:";
    L["MINIMAP_ICON_RIGHT_CLICK"] = "Rechtsklick:";
    L["MINIMAP_ICON_OPEN_TASK_MANAGER"] = "Aufgabenmanager öffnen";
    L["MINIMAP_ICON_OPEN_SETTINGS"] = "Einstellungen öffnen";
    
    -- Slash-Befehle
    L["SLASHCMD_UNKNOWN_COMMAND"] = "Unbekannter Befehl";
    L["SLASHCMD_TASK_MANAGER_DESCRIPTION"] = "Öffnet den Aufgabenmanager.";
    L["SLASHCMD_TASK_TRACKER_DESCRIPTION"] = "Schaltet den schwebenden Aufgabenverfolger ein/aus.";
    L["SLASHCMD_SETTINGS_DESCRIPTION"] = "Öffnet die Todoloo-Einstellungen.";
    L["SLASHCMD_HELP"] = "Zeigt diese Hilfenachricht an.";

    return L;
end
