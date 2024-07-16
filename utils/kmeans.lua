local color = require "gameobjects.color"
-- Function to calculate Euclidean distance between two colors
local function colorDistance(c1, c2)
    return math.sqrt((c1.r - c2.r) ^ 2 + (c1.g - c2.g) ^ 2 + (c1.b - c2.b) ^ 2)
end

local function kmeans(pixels, k)
    local centroids = {}
    local assignments = {}

    -- Initialize centroids randomly from the existing pixels
    for i = 1, k do
        centroids[i] = pixels[math.random(#pixels)].color
    end

    local changed = true
    local maxIterations = 100
    local counter = 0
    while changed and counter < maxIterations do
        changed = false
        counter = counter + 1

        -- Assign each pixel to the nearest centroid
        for i, pixel in ipairs(pixels) do
            local minDistance = math.huge
            local minIndex = 1
            for j, centroid in ipairs(centroids) do
                local distance = colorDistance(pixel.color, centroid)
                if distance < minDistance then
                    minDistance = distance
                    minIndex = j
                end
            end
            if assignments[i] ~= minIndex then
                assignments[i] = minIndex
                changed = true
            end
        end

        -- Update centroids based on the mean color of assigned pixels
        local sum = {}
        local count = {}
        for i = 1, k do
            sum[i] = color(0, 0, 0)
            count[i] = 0
        end
        for i, pixel in ipairs(pixels) do
            local assignment = assignments[i]
            sum[assignment].r = sum[assignment].r + pixel.color.r
            sum[assignment].g = sum[assignment].g + pixel.color.g
            sum[assignment].b = sum[assignment].b + pixel.color.b
            count[assignment] = count[assignment] + 1
        end
        for i = 1, k do
            if count[i] > 0 then
                centroids[i] = color(
                    sum[i].r / count[i],
                    sum[i].g / count[i],
                    sum[i].b / count[i]
                )
            end
        end
    end

    return centroids, assignments
end

-- centroids[i] = {
--     r = sum[i].r / count[i],
--     g = sum[i].g / count[i],
--     b = sum[i].b / count[i]
-- }



return kmeans
