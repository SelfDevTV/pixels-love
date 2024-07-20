local function plotLine(x0, y0, x1, y1, pixels, currentDrawingColor)
    local pixelsChanged = {}
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy
    local e2
    while true do
        -- +1 to to account for 0 based indexing to 1 based indexing
        local pixel = pixels[x0 + 1][y0 + 1]
        pixel:setColor(currentDrawingColor)

        table.insert(pixelsChanged, pixel)

        if x0 == x1 and y0 == y1 then
            return pixelsChanged
        end
        e2 = 2 * err
        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
        end
        if e2 <= dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
end

return plotLine
