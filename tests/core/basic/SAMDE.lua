local MyModelSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
end}
local c1 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	maximize = true,
	threshold = 200,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
local c2 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
local c3 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 100,
	maximize = true,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
local c4 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
local c5 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	mutation = 0.3,
	threshold = 1,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
local c5 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{2,3,4,9}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model, parameters)
		local m = model(parameters)
		m:execute()
		return m.value
end}
return{
SAMDE = function(unitTest)
unitTest:assertEquals(c1.fit, 184)
unitTest:assertEquals(c1.instance.x, 10)
unitTest:assertEquals(c1.instance.y, 10)
unitTest:assertEquals(c2.fit, 4)
unitTest:assertEquals(c2.instance.x, 1)
unitTest:assertEquals(c2.instance.y, 1)
--The maximun value possible is 184, but ssince the threshold is 100,
--the SaMDE function will stop as soon as it gets a value higher than 100.
unitTest:assertEquals(c3.fit, 142, 42)
unitTest:assertEquals(c3.instance.x, 6, 4)
unitTest:assertEquals(c3.instance.y, 6, 4)
unitTest:assertEquals(c4.fit, 4)
unitTest:assertEquals(c4.instance.x, 1)
unitTest:assertEquals(c4.instance.y, 1)
unitTest:assertEquals(c4.fit, 4)
unitTest:assertEquals(c4.instance.x, 1)
unitTest:assertEquals(c4.instance.y, 1)
unitTest:assertEquals(c5.fit, 5)
unitTest:assertEquals(c5.instance.x, 1)
unitTest:assertEquals(c5.instance.y, 2)
end}