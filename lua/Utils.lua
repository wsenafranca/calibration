-- @header Useful functions that are used by MultipleRuns and SAMDE. It contains
-- basic functions to work with Models, such as checking parameters and creating
-- random instances of a given Model.

--- Verify if a given parameter for a Model using min and max (and possibly range)
-- values is a valid subset for a given Model parameter.
-- @arg model A Model to be instantiated.
-- @arg idx  The name of the parameter to be verified in the Model.
-- @arg Param A table with the values to be verified.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage import("calibration")
--
-- myModel = Model{
--     y = Choice{min = 1, max = 100, step = 1},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {y = Choice{min = 20, max = 40}}
-- ok, err =  pcall(function()
--     checkParametersRange(myModel, "y", parameters.y)
-- end)
--
-- print(err) -- Error: Argument 'y.step' is mandatory.
function checkParametersRange(model, idx, Param, tableName)
	local values
	if tableName ~= nil then
		values = model:getParameters()[tableName][idx]
	else
		values = model:getParameters()[idx]
	end

	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values.
	if values.min == nil and values.max == nil then
		customError("Argument '"..idx.."' should not be a range of values.")
	end

	if Param.min == nil or Param.max == nil then
		customError("Argument '"..idx.."' must have 'min' and 'max' values.")
	end

	if values.min ~= nil then
		if values.min > Param.min then
			customError("Argument '"..idx..".min' should be greater than or equal to "..values.min..", got "..Param.min..".")
		end
	end

	if values.max ~= nil then
		if values.max < Param.max then
			customError("Argument '"..idx..".max' should be less than or equal to "..values.max..", got "..Param.max..".")
		end
	end

	if values.step ~= nil then
		if Param.step == nil then
			customError("Argument '"..idx..".step' is mandatory.")
		elseif Param.step % values.step ~= 0 then
			customError("Argument '"..idx..".step' should be within range of Choice{min = "..values.min..", max = "..values.max..", step = "..values.step.."}, got "..Param.step..".")
		end

		if values.min ~= nil then
			if (Param.min - values.min) % values.step ~= 0 then
				customError("Argument '"..idx..".min' should be within range of Choice{min = "..values.min..", max = "..values.max..", step = "..values.step.."}, got "..Param.min..".")
			end
		end
	end
end

--- Verify if a given parameter for a Model
-- value is a valid subset for a given Model parameter.
-- @arg model A model to be instantiated.
-- @arg idx  The name of the parameter to be checked in the parameters table.
-- @arg idx2  The numerical index, of the parameter value to be checked, in the choosen parameter Choice table.
-- @arg value The value to be checked.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage import("calibration")
--
-- myModel = Model{
--     x = Choice{-100, -1, 0, 1, 2, 100},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {x = Choice{-100, 5, 2}}
-- ok, err =  pcall(function()
--     checkParameterSingle(myModel, "x", 2, 5)
-- end)
--
-- print(err) -- Error: Parameter 5 in #2 is out of the model x range.
function checkParameterSingle(model, idx, idx2, value, tableName)
	local mParam
	if tableName ~= nil then
		mParam = model:getParameters()[tableName][idx]
	else
		mParam = model:getParameters()[idx]
	end

	--test if a value inside the accepted model range of values
	if mParam.min ~= nil then
		if value < mParam.min then
			customError("Argument '"..idx.."' should be greater than or equal to "..mParam.min..", got "..value.." in position "..idx2..".")
		end

		if mParam.step ~= nil then
			if (value - mParam.min) % mParam.step ~= 0 then
				customError("Argument '"..idx.."' should be within range of Choice{min = "..mParam.min..", max = "..mParam.max..", step = "..mParam.step.."}, got "..value.." in position "..idx2..".")
			end
		end
	end

	if mParam.max ~= nil then
		if value > mParam.max then
			customError("Argument '"..idx.."' should be less than or equal to "..mParam.max..", got "..value.." in position "..idx2..".")
		end
	end

	if mParam.values ~= nil then
		if belong(value, mParam.values) == false then
			local values = table.concat(mParam.values, ", ")
			customError("Argument '"..idx.."' should belong to Choice{"..values.."}, got "..value.." in position "..idx2..".")
		end
	end
end

--- Verify if a given parameter for a Model using a table of
-- values is a valid subset for a given Model parameter.
-- @arg model A model to be instantiated.
-- @arg idx  The index of the parameter to be checked in the parameters table.
-- @arg parameters A table with the group of parameter values to be checked.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage
-- import("calibration")
--
-- myModel = Model{
--     x = Choice{-100, -1, 0, 1, 2, 100},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {x = Choice{-100, 1, 3}}
-- ok, err =  pcall(function()
--    checkParametersSet(myModel, "x", parameters.x)
-- end)
--
-- print(err) -- Error: Parameter 3 in #3 is out of the model x range.
function checkParametersSet(model, idx, parameters, tableName)
	-- test if the group of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	forEachOrderedElement(parameters.values, function(idx2, att2)
		checkParameterSingle(model, idx, idx2, att2, tableName)
	end)
end

--- Function to create a copy of a given parameter, returns the copy.
-- @arg mtable The parameter to be copied.
-- @usage
-- import("calibration")
-- local original = {param = 42}
-- local copy = cloneValues(original)
function cloneValues(mtable)
    mandatoryArgument(1, "table", mtable)
    local result = {}
    forEachElement(mtable, function(idx, value, mtype)
        if mtype == "table" then
            result[idx] = cloneValues(value)
        else
            result[idx] = value
        end
    end)

    return result
end

--- Function that returns a random model instance from a set of parameters.
-- Each Choice argument will be instantiated with a random value from the available choices.
-- The other arguments will be instantiated with their exact values.
-- This function can be used by SaMDE as well as by MultipleRuns.
-- @arg tModel The Model to be instantiated.
-- @arg tParameters A table of possible parameters for the model.
-- Multiple Runs or Calibration instance.
-- @usage
-- import("calibration")
-- local myModel = Model{
--   x = Choice{-100, -1, 0, 1, 2, 100},
--   y = Choice{min = 1, max = 10, step = 1},
--   finalTime = 1,
--   init = function(self)
--     self.timer = Timer{
--       Event{action = function()
--         self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
--       end}
--   }
--   end
-- }
-- local parameters = {x = Choice{-100,- 1, 0, 1, 2, 100}, y = Choice{min = 1, max = 8, step = 1}}
-- randomModel(myModel, parameters)
function randomModel(tModel, tParameters)
	mandatoryArgument(1, "Model", tModel)
	mandatoryArgument(1, "table", tParameters)
	local sampleParams = {}
	forEachOrderedElement(tParameters, function (idx, attribute, atype)
		if atype == "Choice" then
			sampleParams[idx] = attribute:sample()
		elseif atype == "table" then
			if sampleParams[idx] == nil then
				sampleParams[idx] = {}
			end

			forEachOrderedElement(attribute, function(idx2, att2, typ2)
				if typ2 == "Choice" then
					sampleParams[idx][idx2] = att2:sample()
				else
					sampleParams[idx][idx2] = att2
				end
			end)
		else
			sampleParams[idx] = attribute
		end
	end)

	return tModel(sampleParams)
end

--- Function that returns the time in a higher-level representation.
-- @arg t The time in seconds.
-- @usage
-- import("calibration")
-- local t = 3670
-- print(timeToString(t)) -- 1 hour and 1 minute
function timeToString(t)
	mandatoryArgument(1, "number", t)
	local seconds = t
	local minutes = math.floor(t / 60);     seconds = math.floor(seconds % 60)
	local hours = math.floor(minutes / 60); minutes = math.floor(minutes % 60)
	local days = math.floor(hours / 24);    hours = math.floor(hours % 24)
	local hasDay = false
	local hasHour = false
	local hasMin = false
	local str = ""
	if days > 0 then
		hasDay = true
		if days == 1 then
			str = str.."1 day"
		else
			str = str..days.." days"
		end
	end

	if hours > 0 then
		hasHour = true
		if hasDay then str = str.." and " end
		if hours == 1 then
			str = str.."1 hour"
		else
			str = str..hours.." hours"
		end
	end

	if not hasDay and minutes > 0 then
		hasMin = true
		if hasHour then str = str.." and " end
		if minutes == 1 then
			str = str.."1 minute"
		else
			str = str..minutes.." minutes"
		end
	end

	if not hasDay and not hasHour and (seconds > 0 or not hasMin) then
		if hasMin then str = str.." and " end
		if seconds == 1 then
			str = str.."1 second"
		elseif seconds == 0 then
			str = "less than one second"
		else
			str = str..seconds.." seconds"
		end
	end

	return str
end
