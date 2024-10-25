---@class Todoloo
local Todoloo = select(2, ...);

-- ***** CORE
Todoloo.Tasks = {};
Todoloo.Reset = { ResetManager = {} };
Todoloo.EventBus = {};

-- ***** SETTINGS & CONFIG
Todoloo.Config = {};
Todoloo.MinimapIcon = {};

-- ***** FRAME UTILS
Todoloo.ScrollUtil = {};

-- ***** OTHERS
Todoloo.Utils = {};
Todoloo.Messenger = {};
Todoloo.SlashCmd = {};