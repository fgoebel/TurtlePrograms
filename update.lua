-- function for updating programs by http get from github
-- must be loaded once for each turtle

-- load json API from github if it does not exist yet
if not fs.exists("json.lua") then
	r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/json.lua")
    f = fs.open("json.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
end
os.loadAPI("json.lua") 

-- get Current Commit
CommitTable = http.get("https://api.github.com/repos/fgoebel/TurtlePrograms/commits/cct-clique27").readAll()
Commit = json.decode(CommitTable)
CommitSha = Commit.sha

if fs.exists("lastCommit") then
    lastCommitSha = fs.open("lastCommit","r").readAll()
    -- compare Commpits
    if lastCommitSha ~= CommitSha then
        updateFiles()
    else
        --print indicator
        print("no new files available.")
    end
else
    updateFiles()
end

function updateFiles()
    -- save CurrentCommit as last Commit
    handle = fs.open("lastCommit","w")
    handle.write(lastCommitSha)
    handle.close()
    -- update files
    r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/FarmingNew.lua")
    f = fs.open("goTo.lua", "w")
    f.write(r.readAll())
    f.close()
    r.close()
    if fs.exists("fields") then      -- will be reloaded on start of farming
        fs.delete("fields")
    end
    if fs.exists("goTo.lua") then   -- will be reloaded on start of farming
        fs.delete("goTo.lua")
    end
    -- print indicator
    print("new files available. updated")
end