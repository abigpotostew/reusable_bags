--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:3d9675e9a76ad85761fd8b5cdfc8a80f:db5f03c50b34b945f0a5374e187b9e8f:a8bb9f6fe1624449381316bb0c22d939$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- apple
            x=598,
            y=372,
            width=254,
            height=314,

        },
        {
            -- burrito
            x=4,
            y=4,
            width=494,
            height=389,

        },
        {
            -- canvas_bag
            x=4,
            y=399,
            width=291,
            height=462,

        },
        {
            -- orange
            x=598,
            y=692,
            width=254,
            height=280,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 254,
            sourceHeight = 288
        },
        {
            -- paper_bag
            x=301,
            y=399,
            width=291,
            height=422,

        },
        {
            -- plastic_bag
            x=504,
            y=4,
            width=291,
            height=362,

        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["apple"] = 1,
    ["burrito"] = 2,
    ["canvas_bag"] = 3,
    ["orange"] = 4,
    ["paper_bag"] = 5,
    ["plastic_bag"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
