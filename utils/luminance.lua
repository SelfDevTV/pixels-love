local function luminance(r, g, b)
    return 0.299 * r + 0.587 * g + 0.114 * b
end

return luminance
