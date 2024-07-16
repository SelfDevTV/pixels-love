local pixel = require "gameobjects.pixel"
local color = require "gameobjects.color"
local kmeans = require "utils.kmeans"


---Returns a 2d array of all pixels in the image
---@param imageData table
---@param pixelSize number
---@param totalColors number
---@return table
---@return table
---@return table
local function generatePixelsFromImage(imageData, pixelSize, totalColors)
    local pixels = {}
    local pixelsFlat = {}
    local pixelSize = pixelSize or 10
    local totalColors = totalColors or 10
    print(imageData:getWidth() * imageData:getHeight())

    local w = math.floor(imageData:getWidth() / pixelSize)
    local h = math.floor(imageData:getHeight() / pixelSize)

    -- Get the color of each pixel in the image and create 10 x 10 pixel blocks




    for y = 0, w - 1, 1 do
        for x = 0, h - 1, 1 do
            local r, g, b = imageData:getPixel(x * pixelSize, y * pixelSize)
            -- Create a block of pixelSize x pixelSize of the same color
            table.insert(pixelsFlat, pixel(x, y, color(r, g, b)))
        end
    end

    print(pixelsFlat[1].color)



    local centroids, assignments = kmeans(pixelsFlat, totalColors)

    for i, px in ipairs(pixelsFlat) do
        local centroid = centroids[assignments[i]]
        px.color = color(centroid.r, centroid.g, centroid.b)
        for y = 0, pixelSize - 1 do
            for x = 0, pixelSize - 1 do
                local newY = px.y * pixelSize + y
                local newX = px.x * pixelSize + x
                table.insert(pixels, pixel(newX, newY, px.color))
            end
        end
    end


    local pixels2D = {}

    for i, px in ipairs(pixels) do
        -- Initialize the sub-table for this x-coordinate if it doesn't exist
        if not pixels2D[px.x] then
            pixels2D[px.x] = {}
        end

        -- Insert the pixel into the 2D table at the correct x and y position
        -- Note: This assumes .y values are sequential and start from 0 or 1. Adjust accordingly.
        pixels2D[px.x][px.y] = px -- Storing just the color, but you can store the whole pixel object if needed
    end


    pixelsFlat = pixels


    return pixelsFlat, pixels2D, centroids
end


return generatePixelsFromImage
