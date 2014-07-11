--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:7421a4af3e213504efa857b1d4e45a55:ab6b26ebfdf370e8f48e050a85b5ba5c:a8bb9f6fe1624449381316bb0c22d939$
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
            -- bag_canvas
            x=504,
            y=399,
            width=291,
            height=462,

        },
        {
            -- bag_paper
            x=4,
            y=505,
            width=291,
            height=422,

        },
        {
            -- bag_plastic
            x=301,
            y=867,
            width=291,
            height=362,

        },
        {
            -- food_apple
            x=4,
            y=933,
            width=254,
            height=314,

        },
        {
            -- food_burrito
            x=504,
            y=4,
            width=494,
            height=389,

        },
        {
            -- food_orange
            x=598,
            y=867,
            width=254,
            height=280,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 254,
            sourceHeight = 288
        },
        {
            -- food_pizza
            x=4,
            y=4,
            width=494,
            height=495,

        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 2048
}

SheetInfo.frameIndex =
{

    ["bag_canvas"] = 1,
    ["bag_paper"] = 2,
    ["bag_plastic"] = 3,
    ["food_apple"] = 4,
    ["food_burrito"] = 5,
    ["food_orange"] = 6,
    ["food_pizza"] = 7,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
