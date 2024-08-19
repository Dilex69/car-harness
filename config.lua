Config = {}

--// Progressbars \\--
Config.AttachingHarness = 1000
Config.RemovingHarness = 1000
Config.PuttingOn = 1000
Config.TakingOff = 1000

Config.ProgressBarDuration = {
    Add = 5000,  -- 5 seconds for adding a harness
    Remove = 5000  -- 5 seconds for removing a harness
}

--// AllowedJobs \\--
Config.AllowedJobs = {
    "mechanic",
    "police"
    -- Add more jobs as needed
}

Config.MinigameType = 'ox' -- Choose MinigameType : qb-skillbar / qb-minigames (skillbar) / ps (circle) / ox
Config.SkillbarConfig = {difficulty = 'medium', keys = 'wasd'} -- If MinigameType is qb-minigames or qb-skillbar then choose amount of tries
Config.PSUIConfig = {numcircle = 2, ms = 20} -- If MinigameType is ps-ui then choose number of circles and ms 
Config.OXLibConfig = {      -- If MinigameType is ox_lib then choose difficulty and input characters
    difficulty = {'easy', 'easy', 'medium'}, -- This creates a sequence of three skill checks
    inputs = {'w', 'a', 's', 'd'} -- These are the possible keys that can appear in the skill check
}