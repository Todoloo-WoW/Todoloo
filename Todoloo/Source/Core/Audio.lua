Todoloo.Audio = {}

local Audio = Todoloo.Audio

Audio.TaskCompletionSounds = {
    {
        key = "none",
        label = TODOLOO_L_AUDIO_SOUND_NONE,
    },
    {
        key = "quest",
        label = TODOLOO_L_AUDIO_SOUND_QUEST_COMPLETE,
        soundKitID = SOUNDKIT.IG_QUEST_LIST_COMPLETE,
    },
    {
        key = "worldquest",
        label = TODOLOO_L_AUDIO_SOUND_WORLD_QUEST_COMPLETE,
        soundKitID = SOUNDKIT.UI_WORLDQUEST_COMPLETE,
    },
    {
        key = "loot",
        label = TODOLOO_L_AUDIO_SOUND_EPIC_LOOT,
        soundKitID = SOUNDKIT.UI_EPICLOOT_TOAST,
    },
    {
        key = "readycheck",
        label = TODOLOO_L_AUDIO_SOUND_READY_CHECK,
        soundKitID = SOUNDKIT.READY_CHECK,
    },
    {
        key = "map",
        label = TODOLOO_L_AUDIO_SOUND_MAP_PING,
        soundKitID = SOUNDKIT.MAP_PING,
    },
}

local taskCompletionSoundByKey = {}

for _, choice in ipairs(Audio.TaskCompletionSounds) do
    taskCompletionSoundByKey[choice.key] = choice
end

local lastTaskCompletionPlaybackTime
local activeTaskCompletionSoundHandle

---Play the configured task completion sound.
---@param preview boolean? Bypass completion throttling when previewing.
function Audio.PlayTaskCompletionSound(preview)
    local key = Todoloo.Config.Get(
        Todoloo.Config.Options.TASK_COMPLETION_SOUND
    )

    local choice = taskCompletionSoundByKey[key]
    if not choice or not choice.soundKitID then
        return
    end

    local now = GetTime()

    -- Combine closely spaced completions into one notification.
    if not preview
        and lastTaskCompletionPlaybackTime
        and now - lastTaskCompletionPlaybackTime < 0.5
    then
        return
    end

    -- Avoid overlapping this feature's sounds.
    if activeTaskCompletionSoundHandle then
        StopSound(activeTaskCompletionSoundHandle)
        activeTaskCompletionSoundHandle = nil
    end

    local played, handle = PlaySound(choice.soundKitID, "SFX")

    if played then
        activeTaskCompletionSoundHandle = handle

        if not preview then
            lastTaskCompletionPlaybackTime = now
        end
    end
end