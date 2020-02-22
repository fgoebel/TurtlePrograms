-- used in an additional computer to handle user inputs to update
-- and add fields to the fields list

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
        aero = false,
        tobuild = false,
        toplant = false,
        }
    
    print("Please enter field name: ")
    NewField.name = read()

    print("Please enter crop: ")
    NewField.crop = read()

    print("Please enter harvesting interval: ")
    NewField.interval = tonumber(read())

    print("Number of rows?")
    NewField.rows = tonumber(read())

    print("Number of columns?")
    NewField.cols = tonumber(read())

    print("Please add coordinates of first block. z?")
    NewField.pos.z = tonumber(read())

    print("x?")
    NewField.pos.x = tonumber(read())

    print("y?")
    NewField.pos.y = tonumber(read())

    print("f?")
    NewField.pos.f = tonumber(read())

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
        NewField.toplant = false
    elseif input == "n" then
        NewField.tobuild = false
        print("is it already active? (y/n)")
        input = read()
        if input == "y" then
            NewField.active = true
            NewField.toplant = false
        elseif input == "n" then
            NewField.active = false
            print("Should turtle plant seeds? (y/n)")
            if input == "y" then
                NewField.toplant = true
            elseif input == "n" then
                NewField.toplant = false
            end
        end
    end
return NewField
    
end

--*********************************************
-- edit field
function editField(field)
    print("Which property should be edited? (pos/right/interval/active)")
    input = read()
    if input == "pos" then
        print("x? (current: "..field.pos.x .. ")")
        field.pos.x = tonumber(read())
        print("y? (current: "..field.pos.y .. ")")
        field.pos.y = tonumber(read())
        print("z? (current: "..field.pos.z .. ")")
        field.pos.z = tonumber(read())
        print("f? (current: "..field.pos.f .. ")")
        field.pos.f = tonumber(read())

    elseif input == "right" then
        print("Set to true or false?  (current: "..field.right .. ")")
        input = read()
        if input == true then
            field.right = true
        else
            field.right = false
        end

    elseif input == "interval" then
        print("new interval?  (current: "..field.interval .. ")")
        field.interval = tonumber(read())

    elseif input == "active" then
        print("Set to true or false?  (current: "..field.active .. ")")
        input = read()
        if input == true then
            field.active = true
        else
            field.active = false
        end
    end
return field
end

--*********************************************
-- get field
function getField()
    while true do
        -- get current field file from manager
        gotFields = false
        while not gotFields do
            rednet.send(ManagerID,"send fields","Input")        -- ask for fields table
            ID, message = rednet.receive("Input",2)             -- wait for answer

            if message ~= nil then
                if textutils.unserialize(message) ~= nil then       -- message was fields
                    fields = textutils.unserialize(message)
                    gotFields = true
                end
            end
        end
        -- ask for field name
        print("type field name of the field, which is to edit. Type help to get list of all field names.")
        local input = read()
        if input == "help" then
            for k,field in ipairs(fields) do
                print(field.name .. ", ")
            end
        else                                -- search for field
            name = input
            fieldIndex = 0
            for k,field in ipairs(fields) do
                if field.name == name then
                    fieldIndex = k
                end
            end
            if fieldIndex == 0 then
                print("field not known.")
            else
                return fields[fieldIndex]
            end
        end
    end
end

--*********************************************
-- send field to manager
function sendField(field,multi)
    while true do
        if multi ~= nil then
            protocol = "Input"
        elseif multi == "multi" then
            protocol = "InputMulti"
        end
        local field = textutils.serialize(field)       -- serialize fields table
        rednet.send(ManagerID,field,protocol) 
        ID,message = rednet.receive("Input",2)
        if message == "got it" then
            return
        end
    end
end

--*********************************************
-- user input manager/ main function
function userInput()
    ManagerID, message = rednet.receive("Init")              -- waits for a broadcast to receive ID of manager

    while true do
        print("For adding new field enter 'new', for editing fields enter 'edit', for updating field from github enter 'update'.")
        local input = read()
        if input == "new" then
            field=addField()
            sendField(field)
            store("newfield", field)

        elseif input == "edit" then
            field = getField()
            field = editField(field)
            sendField(field)
            store("editedfield", field)

        elseif input == "update" then
            r = http.get("https://raw.githubusercontent.com/fgoebel/TurtlePrograms/cct-clique27/farm/fields").readAll()
            fields = textutils.unserialize(data)
            sendField(fields,"multi")
        end
    end
end

rednet.open("right")
userInput()