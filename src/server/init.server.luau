local knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

require(game:GetService("ReplicatedStorage").Shared.BiBFSService.BiBFSService)

local friendGraph = {
    [1] = {2, 3, 4},
    [2] = {1, 5, 6},
    [3] = {1, 7, 8},
    [4] = {1, 9, 10},
    [5] = {2, 11, 12},
    [6] = {2, 13, 14},
    [7] = {3, 15, 16},
    [8] = {3, 17, 18},
    [9] = {4, 19, 20},
    [10] = {4, 21, 22},
    [11] = {5, 23, 24},
    [12] = {5, 25, 26},
    [13] = {6, 27, 28},
    [14] = {6, 29, 30},
    [15] = {7, 31, 32},
    [16] = {7, 33, 34},
    [17] = {8, 35, 36},
    [18] = {8, 37, 38},
    [19] = {9, 39, 40},
    [20] = {9, 41, 42},
    [21] = {10, 43, 44},
    [22] = {47},
    [23] = {11},
    [24] = {11},
    [25] = {12},
    [26] = {12},
    [27] = {13},
    [28] = {13},
    [29] = {14},
    [30] = {14},
    [31] = {15},
    [32] = {15},
    [33] = {16},
    [34] = {16},
    [35] = {17},
    [36] = {17},
    [37] = {18},
    [38] = {18},
    [39] = {19},
    [40] = {19},
    [41] = {20},
    [42] = {20},
    [43] = {21},
    [44] = {21},
    [45] = {22},
    [46] = {22},
    [47] = {22}
}

knit.Start():andThen(function()
	local BiBFS = knit.GetService("BiBFSService")
    local Search = BiBFS:init()

    Search.Update:Connect(function()
        print("Updating")
    end)

    Search.Done:Connect(function(result)
        print(result)
    end)
    local function makeUndirected(graph)
        for node, neighbors in pairs(graph) do
            for _, neighbor in ipairs(neighbors) do
                graph[neighbor] = graph[neighbor] or {}
                local found = false
                for _, v in ipairs(graph[neighbor]) do
                    if v == node then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(graph[neighbor], node)
                end
            end
        end
    end
    
    makeUndirected(friendGraph)
    Search:Traverse(
        function(node)
            return friendGraph[node]
        end,
        1,
        47
    )

end)

