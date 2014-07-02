--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:26d3b9694561d7587eb27458c3489187:9413a47c954d57af1fbcc18b3140e360:a8bb9f6fe1624449381316bb0c22d939$
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
            x=4,
            y=399,
            width=291,
            height=462,

        },
        {
            -- bag_paper
            x=301,
            y=399,
            width=291,
            height=422,

        },
        {
            -- bag_plastic
            x=504,
            y=4,
            width=291,
            height=362,

        },
        {
            -- food_apple
            x=598,
            y=372,
            width=254,
            height=314,

        },
        {
            -- food_burrito
            x=4,
            y=4,
            width=494,
            height=389,

        },
        {
            -- food_orange
            x=598,
            y=692,
            width=254,
            height=280,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 254,
            sourceHeight = 288
        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["bag_canvas"] = 1,
    ["bag_paper"] = 2,
    ["bag_plastic"] = 3,
    ["food_apple"] = 4,
    ["food_burrito"] = 5,
    ["food_orange"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
