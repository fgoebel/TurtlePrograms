

--*********************************************
-- Store values
function store(sName, stuff)
	local handle = fs.open(sName, "w")
	handle.write(textutils.serialize(stuff))
	handle.close()
end

--*********************************************
-- add field
function addField()
    print("For adding new field enter 'new', for editing fields endet 'edit'.")
    local input = read()
    if input == "y" then
        local NewField = {}
        local NewField.pos={}

        print("Please enter field name: ")
        NewField.name = read()

        print("Please enter crop: ")
        NewField.crop = read()

        print("Please enter harvesting interval: ")
        NewField.interval = read()

        print("Number of rows?")
        NewField.rows = read()

        print("Number of columns?")
        NewField.cols = read()

        print("Please add coordinates of first block. z?")
        NewField.pos.z = read()

        print("x?")
        NewField.pos.x = read()

        print("y?")
        NewField.pos.y = read()

        print("f?")
        NewField.pos.f = read()

        print("Turn right on first turn? (y/n)")
        input = read()
        if input == "y" then
            NewField.right = true
        elseif input == "n" then
            NewField.right = false
        end

        print("Is it an Aero-field? (y/n)")
        input = read()
        if input == "y" then
            NewField.aero = true
        elseif input == "n" then
            NewField.aero = false
        end

        print("Should it be build by turtle? (y/n)")
        input = read()
        if input == "y" then
            NewField.tobuild = true
            NewField.active = false
        elseif input == "n" then
            NewField.tobuild = false
            print("is it already active? (y/n)")
            input = read()
            if input == "y" then
                NewField.active = true
            elseif input == "n" then
                NewField.active = false
            end
        end

        NewField.lastHarvested = 0

        store("newfield", NewField)
    end

end