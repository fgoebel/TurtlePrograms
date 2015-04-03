-- from Direwolf20 via Pastebin: http://pastebin.com/4qNyaPav
-- button api via Pastebin: http://pastebin.com/XBbMUYNn
os.loadAPI("button")
 
p = peripheral.find("tile_blockcapacitorbank_name")
m = peripheral.find("monitor")
r = peripheral.find("BigReactors-Reactor")
t = peripheral.find("BigReactors-Turbine")
 
local steamReactor = r.isActivelyCooled()
local menuType = "Reactor"
 
local numCapacitors = 3
local turnOnAt = 50
local turnOffAt = 90
 
local targetSpeed = 1840
 
local energy = 0
local energyStored = 0
local energyMax = 0
local energyStoredPercent = 0
local timerCode
local mode = "Automatic"
local RFProduction = 0
local fuelUse = 0
local coreTemp = 0
local reactorOnline = false
local rodLevel = 0
 
local turbineOnline = false
local turbineRotorSpeed = 0
local turbineRFGen = 0
local turbineFluidRate = 0
local turbineInductor = false
 
local OptFuelRodLevel = 0
 
function autoMenu()
   m.setTextScale(1)
   button.clearTable()
   button.setTable("Automatic", autoMode, "", 3, 13, 6, 6)
   button.setTable("Manual", manualMode, "", 15, 25, 6, 6)
   
   if steamReactor then
      button.setTable("Reactor", reactorMenu, "", 5, 18, 19, 19)
      button.setTable("Turbine", turbineMenu, "", 22, 35, 19, 19)
   end
   button.screen()
   checkMode()
   menuMode()
end
 
function manualMenu()
   m.setTextScale(1)
   button.clearTable()
   button.setTable("Automatic", autoMode, "", 3, 13, 6, 6)
   button.setTable("Manual", manualMode, "", 15, 25, 6, 6)
   button.setTable("Online", online, "", 3, 13, 8, 8)
   button.setTable("Offline", offline, "", 15, 25, 8, 8)
   button.setTable("0", setRods, 0, 11,14, 10, 10)
   button.setTable("10", setRods, 10, 5,8, 12, 12)
   button.setTable("20", setRods, 20, 11,14, 12, 12)
   button.setTable("30", setRods, 30, 17,20, 12, 12)
   button.setTable("40", setRods, 40, 5,8, 14, 14)
   button.setTable("50", setRods, 50, 11,14, 14, 14)
   button.setTable("60", setRods, 60, 17,20, 14, 14)
   button.setTable("70", setRods, 70, 5,8, 16, 16)
   button.setTable("80", setRods, 80, 11,14, 16, 16)
   button.setTable("90", setRods, 90, 17,20, 16, 16)
   button.setTable("+", rodPlus, "", 23, 25, 12, 12)
   button.setTable("-", rodMinus, "", 23, 25, 16, 16)
 
   if steamReactor then
      button.setTable("Reactor", reactorMenu, "", 5, 18, 19, 19)
      button.setTable("Turbine", turbineMenu, "", 22, 35, 19, 19)
         
   end
   button.screen()
   checkMode()
   reactorOnOff()
   menuMode()
end
 
function turbineAutoMenu()
   m.setTextScale(1)
   button.clearTable()
   button.setTable("Automatic", autoMode, "", 3, 13, 6, 6)
   button.setTable("Manual", manualMode, "", 15, 25, 6, 6)
   button.setTable("Reactor", reactorMenu, "", 5, 18, 19, 19)
   button.setTable("Turbine", turbineMenu, "", 22, 35, 19, 19)
   button.screen()
   checkMode()
   menuMode()
end
 
function turbineManualMenu()
   m.setTextScale(1)
   button.clearTable()
   button.setTable("Automatic", autoMode, "", 3, 13, 6, 6)
   button.setTable("Manual", manualMode, "", 15, 25, 6, 6)
   button.setTable("Reactor", reactorMenu, "", 5, 18, 19, 19)
   button.setTable("Turbine", turbineMenu, "", 22, 35, 19, 19)
   button.setTable("Online", setTurbineOnline, "", 3, 13, 8, 8)
   button.setTable("Offline", setTurbineOffline, "", 15, 25, 8, 8)
   button.setTable("Coils On", coilsOn, "", 3, 13, 10, 10)
   button.setTable("Coils Off", coilsOff, "", 15, 25, 10, 10)
   button.screen()
   checkMode()
   turbineOnOff()
   coilsOnOff()
   menuMode()
end
 
function reactorMenu()
   menuType = "Reactor"
   displayScreen()
end
 
function turbineMenu()
   menuType = "Turbine"
   displayScreen()
end
 
function online()
   r.setActive(true)
   --button.flash("Online")
end
 
function offline()
   r.setActive(false)
   --button.flash("Offline")
end
 
function setTurbineOnline()
   t.setActive(true)
   --button.flash("Online")
end
 
function setTurbineOffline()
   t.setActive(false)
   --button.flash("Offline")
end
 
function reactorOnOff()
   button.setButton("Online", r.getActive())
   button.setButton("Offline", not r.getActive())
end
 
function turbineOnOff()
   button.setButton("Online", t.getActive())
   button.setButton("Offline", not t.getActive())
end
 
function coilsOnOff()
   button.setButton("Coils On", t.getInductorEngaged())
   button.setButton("Coils Off", not t.getInductorEngaged())
end
 
function coilsOn()
   t.setInductorEngaged(true)
end
 
function coilsOff()
   t.setInductorEngaged(false)
end
 
function menuMode()
   if steamReactor then
   if menuType == "Reactor" then
     button.setButton("Reactor", true)
     button.setButton("Turbine", false)
   else
     button.setButton("Reactor", false)
     button.setButton("Turbine", true)
   end
   end
end
 
function setRods(setLevel)
   print("Setting Rod Level: "..setLevel)
   button.flash(tostring(setLevel))
   r.setAllControlRodLevels(setLevel)
   fuelRodLevel()
end
 
function rodPlus()
   button.flash("+")
   r.setAllControlRodLevels(rodLevel+1)
   fuelRodLevel()
end
 
function rodMinus()
   button.flash("-")
   r.setAllControlRodLevels(rodLevel-1)
   fuelRodLevel()
end
 
function checkMode()
   button.toggleButton(mode)
end
   
function manualMode()
   mode = "Manual"
   manualMenu()
end
 
function autoMode()
   mode = "Automatic"
   displayScreen()
end
 
function comma_value(amount)
   local formatted = amount
   local swap = false
   if formatted < 0 then
      formatted = formatted*-1
      swap = true
   end
   while true do
      formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", '%1,%2')
      if k == 0 then
         break
      end
   end
   if swap then
     formatted = "-"..formatted
   end
   return formatted
end
 
function displayEn()
   m.clear()
   m.setCursorPos(1,1)
   --print("Energy Use: "..energy)
   m.write("Energy Use: ")
   if energy < 0 then
      m.setTextColor(colors.red)
   else
      m.setTextColor(colors.green)
   end
   m.write(comma_value(math.floor(energy)).. "RF/t")
   m.setTextColor(colors.white)
   m.setCursorPos(1,2)
   m.write("Energy Stored: "..energyStoredPercent.."%")
   if menuType == "Reactor" then
      m.setCursorPos(1,3)
      m.write("Reactor is: ")
      if reactorOnline then
           m.setTextColor(colors.green)
           m.write("Online")
      else
       m.setTextColor(colors.red)
           m.write("Offline")
      end
      m.setTextColor(colors.white)
      m.setCursorPos(22,1)
      if steamReactor then
         m.write("Steam: ")
             m.setTextColor(colors.green)
         m.write(comma_value(math.floor(RFProduction)).."MB/t")
      else
         m.write("RF Gen: ")
             m.setTextColor(colors.green)
         m.write(comma_value(math.floor(RFProduction)).."RF/t")
      end
      m.setTextColor(colors.white)
      m.setCursorPos(22,2)
      m.write("Core Temp: "..math.floor(coreTemp).."c")
      m.setCursorPos(22,3)
      m.write("Fuel Use: "..fuelUse.."MB/t")  
  else
      m.setCursorPos(1,3)
      m.write("Turbine is: ")
      if turbineOnline then
           m.setTextColor(colors.green)
           m.write("Online")
      else
       m.setTextColor(colors.red)
           m.write("Offline")
      end
      m.setCursorPos(1,4)
      m.setTextColor(colors.white)
      m.write("Reactor is: ")
      if reactorOnline then
         m.setTextColor(colors.green)
         m.write("Online")
      else
         m.setTextColor(colors.red)
         m.write("Offline")
      end
      m.setTextColor(colors.white)
          m.setCursorPos(22,1)
          m.write("RFGen: ")
          m.setTextColor(colors.green)
      m.write(comma_value(math.floor(turbineRFGen)).."RF/t")
          m.setTextColor(colors.white)
          m.setCursorPos(22,2)
      m.write("Rotor: "..comma_value(math.floor(turbineRotorSpeed)).." RPM")
          m.setCursorPos(22,3)
      m.write("Steam: "..comma_value(turbineFluidRate).."MB/t")  
  end
 
end
 
function checkEn()
   local tempEnergy = 0
   energyStored = p.getEnergyStored()
   energyMax = p.getMaxEnergyStored()
   energyStoredPercent = math.floor((energyStored/energyMax)*100)
   RFProduction = r.getEnergyProducedLastTick()
   fuelUse = r.getFuelConsumedLastTick()
   fuelUse = math.floor(fuelUse*100)
   fuelUse = fuelUse/100
   coreTemp = r.getFuelTemperature()
   reactorOnline = r.getActive()
   tempEnergy = p.getEnergyStored()
   sleep(0.1)
   energy = (p.getEnergyStored()-tempEnergy)/2
   energy = energy*numCapacitors
   if steamReactor then
     turbineOnline = t.getActive()
     turbineRotorSpeed = t.getRotorSpeed()
     turbineRFGen = t.getEnergyProducedLastTick()
     turbineFluidRate = t.getFluidFlowRate()
   end
end
 
function fuelRodLevel()
   rodLevel = r.getControlRodLevel(0)
   --print(rodLevel)
   m.setCursorPos(30,5)
   m.write(tostring(rodLevel).."%")
   m.setBackgroundColor(colors.white)
   m.setCursorPos(28,6)
   m.write("       ")
   for i = 1,10 do
      m.setCursorPos(28,i+6)
          m.setBackgroundColor(colors.white)
          m.write(" ")
          m.setBackgroundColor(colors.yellow)
          m.write(" ")
          if rodLevel/10 >= i then
             m.setBackgroundColor(colors.red)
          else
             m.setBackgroundColor(colors.yellow)
          end
          m.write("   ")
          m.setBackgroundColor(colors.yellow)
          m.write(" ")
          m.setBackgroundColor(colors.white)
          m.write(" ")
   end
   m.setCursorPos(28,17)
   m.write("       ")
   m.setBackgroundColor(colors.black)
end
 
function turbineInductorDisplay()
   turbineInductor = t.getInductorEngaged()
   m.setCursorPos(30,5)
   if turbineInductor then
      m.write("On")
   else
      m.write("Off")
   end
   m.setBackgroundColor(colors.gray)
   m.setCursorPos(28,6)
   m.write("       ")
   for i = 1,7 do
      m.setCursorPos(28,i+6)
          m.setBackgroundColor(colors.gray)
          m.write(" ")
          m.setBackgroundColor(colors.lightGray)
          m.write(" ")
          if i % 2 == 0 then
             m.setBackgroundColor(colors.gray)
          end
          m.write(" ")
          m.setBackgroundColor(colors.gray)
          m.write(" ")
          if i % 2 ~= 0 then
             m.setBackgroundColor(colors.lightGray)
          end
          m.write(" ")
          m.setBackgroundColor(colors.lightGray)
          m.write(" ")
          m.setBackgroundColor(colors.gray)
          m.write(" ")
   end
   for i = 8,10 do
   m.setCursorPos(28,i+6)
          m.setBackgroundColor(colors.gray)
          m.write(" ")
          m.setBackgroundColor(colors.lightGray)
          m.write(" ")
          if turbineInductor then
             m.setBackgroundColor(colors.red)
      else
             m.setBackgroundColor(colors.blue)
          end
          m.write(" ")
          m.setBackgroundColor(colors.gray)
          m.write(" ")
          if turbineInductor then
             m.setBackgroundColor(colors.red)
      else
             m.setBackgroundColor(colors.blue)
          end
          m.write(" ")
          m.setBackgroundColor(colors.lightGray)
          m.write(" ")
          m.setBackgroundColor(colors.gray)
          m.write(" ")
   end
   m.setCursorPos(28,17)
   m.write("       ")
   m.setBackgroundColor(colors.black)
end
function getClick()
   local event, side, x, y = os.pullEvent("monitor_touch")
   button.checkxy(x,y)
end
 
function findOptFuelRods()
   m.clear()
   r.setActive(false)
   checkEn()
   displayEn()
   fuelRodLevel()
   while r.getFuelTemperature() > 99 do
      for i= 1,3 do
            checkEn()
        displayEn()
        fuelRodLevel()
                m.setCursorPos(3,6)
        m.write("Finding Optimal Rod Level")
            m.setCursorPos(3,7)
            m.write("Core Temp: "..r.getFuelTemperature())
                m.setCursorPos(3,8)
                m.write("Waiting for 99c")
            sleep(1)
          end
   end
   while r.getHotFluidAmount() > 10000 do
     for i = 1,3 do
            checkEn()
        displayEn()
        fuelRodLevel()
                m.setCursorPos(3,6)
        m.write("Finding Optimal Rod Level, please wait....")
            m.setCursorPos(3,7)
            m.write("Fluid Amount: "..comma_value(r.getHotFluidAmount()).."mb")
                m.setCursorPos(3,8)
                m.write("Waiting for 10,000mb")
            sleep(1)
          end
   end
   r.setAllControlRodLevels(99)
   r.setActive(true)
   
   while r.getFuelTemperature() < 100 do
   for i = 1,5 do
     checkEn()
     displayEn()
     fuelRodLevel()
         m.setCursorPos(3,6)
         m.write("Set all rod levels to 99")
         m.setCursorPos(3,7)
         m.write("Waiting 5 seconds...")
     sleep(1)
   end
   end
   for i = 1,5 do
     checkEn()
     displayEn()
     fuelRodLevel()
         m.setCursorPos(3,6)
         m.write("Set all rod levels to 99")
         m.setCursorPos(3,7)
         m.write("Waiting 5 seconds...")
     sleep(1)
   end
   local tempMB = r.getEnergyProducedLastTick()
   print(tempMB.."MB/t of steam")
   local tempRodLevels = math.floor(2000/tempMB)
   print("2000/"..tempMB.." = "..tempRodLevels)
   tempRodLevels = 100-tempRodLevels+5
   print("Adding 5 to Rod Levels: "..math.floor(tempRodLevels))
   r.setAllControlRodLevels(math.floor(tempRodLevels))
   print("Waiting 10 seconds to confirm...")
   for i = 1,10 do
     checkEn()
     displayEn()
     fuelRodLevel()
         m.setCursorPos(3,6)
         m.write("Estimated Level: "..tempRodLevels)
         m.setCursorPos(3,7)
         m.write("Waiting 10 seconds...")
     sleep(1)
   end
   tempMB = r.getEnergyProducedLastTick()
   while tempMB > 2000 do
          tempRodLevels = tempRodLevels+1
          r.setAllControlRodLevels(math.floor(tempRodLevels))
          print("Setting Rod Levels to: "..tempRodLevels)
          for i = 1,5 do
           checkEn()
       displayEn()
       fuelRodLevel()
           m.setCursorPos(3,6)
       m.write("Getting below 2000mb/t")
           m.setCursorPos(3,7)
           m.write("Currently at: "..tempMB)
       sleep(1)
          end
          tempMB = r.getEnergyProducedLastTick()
   end
   while tempMB < 2000 do
      tempRodLevels = tempRodLevels -1
          r.setAllControlRodLevels(math.floor(tempRodLevels))
          print("Setting Rod Levels to: "..tempRodLevels)
          for i = 1,5 do
           checkEn()
       displayEn()
       fuelRodLevel()
           m.setCursorPos(3,6)
           m.write("Getting Above 2000mb/t")
           m.setCursorPos(3,7)
           m.write("Currently at: "..tempMB)
       sleep(1)
          end
          tempMB = r.getEnergyProducedLastTick()
   end
   OptFuelRodLevel = tempRodLevels
end
   
 
function autoReactor()
   if not steamReactor then
      r.setAllControlRodLevels(0)
      if energyStoredPercent < turnOnAt then
       if not reactorOnline then
             online()
           end
      end
      if energyStoredPercent > turnOffAt then
       if reactorOnline then
             offline()
           end
          end
        else
           r.setAllControlRodLevels(OptFuelRodLevel)
           if energyStoredPercent < turnOnAt then
         --online()
                 setTurbineOnline()
                 coilsOn()
           end
           if energyStoredPercent > turnOffAt then
             --if turbineRotorSpeed > 1800 then
             --   offline()
             --else
                    --   online()
             --end
                 setTurbineOnline()
                 coilsOff()
           end
    if turbineRotorSpeed > targetSpeed then
       offline()
    else
       online()
    end
        end
end
 
function displayScreen()
 --  repeat
          checkEn()
          displayEn()
          if menuType == "Reactor" then
            fuelRodLevel()
            if mode == "Automatic" then
               autoMenu()
                   autoReactor()
            else
               manualMenu()
                end
               
          else
            turbineInductorDisplay()
                if mode == "Automatic" then
               turbineAutoMenu()
                   autoReactor()
            else
               turbineManualMenu()
                end
           
          end
     
          timerCode = os.startTimer(1)
          local event, side, x, y
          repeat
                event, side, x, y = os.pullEvent()
                print(event)
                if event == "timer" then
                   print(timerCode..":"..side)
                   if timerCode ~= side then
                      print("Wrong Code")
                        else
                          print("Right Code")
                        end
                end
           until event~= "timer" or timerCode == side
           if event == "monitor_touch" then
                print(x..":"..y)
                        button.checkxy(x,y)
                end
 --  until event ~= "timer"
end
 
if steamReactor then
   findOptFuelRods()
end
 
while true do
   displayScreen()
end
