local function getPaletteFromPixels(pixels)
    local palette = {}
    for i, row in ipairs(pixels) do
        for j, pixel in ipairs(row) do
            local color = pixel.correctColor
            local found = false
            for k, pal in ipairs(palette) do
                if color == pal then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(palette, color)
            end
        end
    end
    return palette
end
return getPaletteFromPixels
