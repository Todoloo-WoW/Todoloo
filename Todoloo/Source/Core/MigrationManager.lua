TodolooMigrationManagerMixin = {}

local CURRENT_DATA_VERSION = 1

local function MigrateTaskProgress()
    for _, character in pairs(TODOLOO_TASKS) do
        for _, group in ipairs(character.groups) do
            for _, task in ipairs(group.tasks) do
                -- Ordinary tasks require one completion
                if task.target == nil then
                    task.target = 1
                end

                -- Preserve completion on older tasks.
                -- Preserve recoreded progress when already present.
                if task.progress == nil then
                    task.progress = task.completed and task.target or 0
                end

                task.progress = math.max(0, math.min(task.progress, task.target))

                task.completed = task.progress >= task.target
            end
        end
    end
end

local migrations = {
    -- Introduced in v12.1.5.1
    [1] = MigrateTaskProgress
}

function TodolooMigrationManagerMixin:Run()
    assert(TODOLOO_TASKS, "Task data must be initialized before migration.")

    local version = TODOLOO_DATA_VERSION or 0

    assert(
        version <= CURRENT_DATA_VERSION,
        "Saved data was created by a newer addon version"
    )

    while version < CURRENT_DATA_VERSION do
        local nextVersion = version + 1
        local migrate = migrations[nextVersion]

        assert(migrate, "Missing migration for version " .. nextVersion)

        migrate()

        version = nextVersion
        TODOLOO_DATA_VERSION = version
    end
end