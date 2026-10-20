--!nocheck
local TestPlanner = require("./testez/TestPlanner")
local TestRunner = require("./testez/TestRunner")
local TextReporter = require("./testez/Reporters/TextReporter")
local specs = require("./specs")

local modules = {}
for _, spec in specs do
	table.insert(modules, {
		method = require(spec.path),
		path = { spec.name },
		pathStringForSorting = string.lower(spec.name),
	})
end

local results = TestRunner.runPlan(TestPlanner.createPlan(modules, nil, {}))
TextReporter.report(results)

if results.failureCount > 0 then
	error("tests failed")
end
