class Scene_ItemTracker
    TRACKEDITEMS = ["TMs","Mega Stones","Z-Crystals","Other Unique Items","Scan Items","Back"]
    #all we do 'round here is copy other other scripts. this is the pulse dex.
    def initialize(menu_index = 0)
        @menu_index = menu_index
        @pagedata = nil
    end
    
    def main
        fadein = true
        # Makes the text window
        @sprites={}
        @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z=99
        @sprites["background"] = IconSprite.new(0,0)
        @sprites["background"].setBitmap("Graphics/Pictures/navbg")
        @sprites["background"].z=98
        @choices= TRACKEDITEMS
        @sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL("Tracker"),
           2,-18,128,64,@viewport)
        @sprites["header"].baseColor=Color.new(248,248,248)
        @sprites["header"].shadowColor=Color.new(0,0,0)
        @sprites["header"].windowskin=nil
        @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(@choices,324)
        @sprites["command_window"].windowskin=nil
        @sprites["command_window"].baseColor=Color.new(248,248,248)
        @sprites["command_window"].shadowColor=Color.new(0,0,0)
        @sprites["command_window"].index = @menu_index
        @sprites["command_window"].setHW_XYZ(282,324,94,46,256)
        # Execute transition
        Graphics.transition
        # Main loop
        loop do
            # Update game screen
            Graphics.update
            # Update input information
            Input.update
            # Frame update
            update
            # Abort loop if screen is changed
            if $scene != self
                break
            end
        end
        # Prepares for transition
        Graphics.freeze
        # Disposes the windows
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end

    def update
        pbUpdateSpriteHash(@sprites)
        #update command window and the info if it's active
        if @sprites["command_window"].active
            update_command
            return
        end
    end

    def update_command
        # If B button was pressed
        if Input.trigger?(Input::B)
            # Switch to map screen
            $scene = Scene_Pokegear.new
            return
        end
        # If C button was pressed
        if Input.trigger?(Input::C)
            if @sprites["command_window"].index == (TRACKEDITEMS.length - 1)
                $scene = Scene_Pokegear.new
                return
            elsif @sprites["command_window"].index == (TRACKEDITEMS.length - 2)
                $PokemonBag.itemscan
                print("All items have been scanned.")
            else
                $PokemonBag.itemscan if $PokemonBag.itemtracker == nil
                $scene = Scene_ItemTracker_Info.new(@sprites["command_window"].index,@pagedata)
            end
        end
    end
end
                
class Scene_ItemTracker_Info
    attr_accessor :page
    def initialize(page,pagedata)
        @page = page
        @pagedata = pagedata
    end

    #tms, mega stones, zcrystals, silvmemories, crests
    def initPageData
        datahash = $PokemonBag.itemtracker[@page]
        items = datahash.keys
        #get the names of the items
        name_to_id = {}
        for item in items
            name_to_id[PBItems.getName(item)] = item
        end
        #sort by name
        names = name_to_id.keys
        names.sort!
        #make final object containing name, id, and status; sort by name
        pagedata = Array.new(items.length)
        for i in 0...pagedata.length
            pagedata[i] = [names[i],items[i],datahash[items[i]]]
        end
        return pagedata
    end

    def main
        fadein = true
        @pagedata = initPageData
        extra_length = 96 * (@pagedata.length / 8 ).ceil
        viewport = Viewport.new(0, 0, Graphics.width,Graphics.height)
        viewport.z = 102
        @sprites={}
        @sprites["index"] = 0
        @sprites["overlay"]=BitmapSprite.new(Graphics.width, extra_length, viewport)
        # ame: okay so iconsprite is probably the wrong thing to use here but I wasn't having luck getting setbotmap to show up with BitmapSprite fsr
        # so that's probably why we're only getting like one pixel of what i assume is the background 
        # but code is garbage idk your problem now ily
        @sprites["background"] = IconSprite.new(0,0)
        @sprites["background"].setBitmap("Graphics/Pictures/navbg")
        @sprites["background"].z=101
        overlay = @sprites["overlay"].bitmap
        @sprites["overlay"].z=102
        imagePositions=[]
        x=48
        y=48
        for i in 0...@pagedata.length
            item = @pagedata[i]
            if item[2] == true #you have this item!
                image_name = pbItemIconFile(item[1])
                imagePositions.push([image_name,x,y,0,0,-1,-1])
            elsif checkAccess(item[1]) #you can get this item!
                image_name = pbItemIconFile(item[1])
                imagePositions.push([image_name,x,y,0,0,-1,-1])
                #code to gray the item out
            else #you're fucked!
                imagePositions.push(["Graphics/Icons/item000",x,y,0,0,-1,-1])
            end
            x+=48
            if (i+1) %8 == 0
                x-=384
                y+=48
            end
        end
        pbDrawImagePositions(overlay,imagePositions)
        @sprites["selector"] = IconSprite.new(0,0)
        @sprites["selector"].setBitmap("Graphics/Pictures/trackerCursor")
        @sprites["selector"].x=48
        @sprites["selector"].y=48
        @sprites["selector"].z=102
        Graphics.transition
        loop do
            Graphics.update
            Input.update
            update
            if $scene != self
                break
            end
        end
    end

    def update
        if Input.trigger?(Input::LEFT) 
            pbPlayCursorSE()
            @sprites["index"]-=1
            @sprites["index"]=(@pagedata.length-1) if @sprites["index"]<0
        elsif Input.trigger?(Input::RIGHT)
            pbPlayCursorSE()
            @sprites["index"]+=1
            @sprites["index"]=0 if @sprites["index"] > (@pagedata.length-1)
        elsif Input.trigger?(Input::UP)
            pbPlayCursorSE()
            @sprites["index"]-=8
            if @sprites["index"]<0
                col = (@sprites["index"])%8
                row = ((@pagedata.length)/86).floor
                @sprites["index"] = ((row*8) + col)
                if @sprites["index"] > (@pagedata.length-1)
                @sprites["index"] -= 8
                end
            end
        elsif Input.trigger?(Input::DOWN)
            pbPlayCursorSE()
            @sprites["index"]+=8
            @sprites["index"]=@sprites["index"]%8 if @sprites["index"] > @pagedata.length - 1
        end
        if Input.trigger?(Input::B)
            @sprites["selector"].dispose
            @sprites["overlay"].dispose
            $scene = Scene_ItemTracker.new(@page)
            return
        end
        @sprites["selector"].x=(@sprites["index"]%8)*48
        @sprites["selector"].y=(@sprites["index"]/8).floor*48 
        @sprites["selector"].x+=48
        @sprites["selector"].y+=48 + @sprites["overlay"].y
        if @sprites["selector"].y>=Graphics.height
            @sprites["overlay"].y-=96
        elsif @sprites["selector"].y<=0
            @sprites["overlay"].y+=96
        end
        pbUpdateSpriteHash(@sprites)
    end  

    def checkAccess(item)
        return false
    end
end