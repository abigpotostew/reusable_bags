--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:49ac8bfd570a5227f4f0a881d302799b$
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
            -- canvas_bag
            x=4,
            y=4,
            width=291,
            height=462,

        },
        {
            -- paper_bag
            x=301,
            y=4,
            width=291,
            height=422,

        },
        {
            -- plastic_bag
            x=598,
            y=4,
            width=291,
            height=362,

        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["canvas_bag"] = 1,
    ["paper_bag"] = 2,
    ["plastic_bag"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
