

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
    local NewField = {
        pos = {
            z = 0,
            f = 0,
            y = 0,
            x = 0,
        },
        name = "",
        crop = "",
        rows = 0,
        cols = 0,
        right = false,
        interval = 0,
        lastHarvested = 0,
        active = false,
        }
    
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
return NewField
    
end

--*********************************************
-- edit field
function editField()
    field = getField()
    print("Which property should be edited? (pos/right/interval/active)")
    input = read()
    if input == "pos" then
        print("x?")
        field.pos.x = read()
        print("y?")
        field.pos.y = read()
        print("z?")
        field.pos.z = read()
        print("f?")
        field.pos.f = read()

    elseif input == "right" then
        print("Set to true or false?")
        input = read()
        if input == true
            field.right = true
        else
            field.right = false
        end

    elseif input == "interval" then
        print("new interval?")
        field.interval = read()

    elseif input == "active" then
        print("Set to true or false?")
        input = read()
        if input == true
            field.active = true
        else
            field.active = false
        end
    end
return field
end

function userInput()
    while true do
        print("For adding new field enter 'new', for editing fields endet 'edit'.")
        local input = read()
        if input == "new" then
            field=addField()
            store("newfield", field)

        elseif input = "edit" then
            field=editField()
            store("editedfield", field)
        end
    end
end

userInput()