--\\
	--; уод
	--; уоп
--//

--\\Vocal Synthesizer Lore (insert funny_research_compilation.mp4 here)
	--; L = S / F
	--; S = L * F
	--; F = S / L
	--; https://thewolfsound.com/sine-saw-square-triangle-pulse-basic-waveforms-in-synthesis/
	--; https://ru.wikipedia.org/wiki/%D0%A1%D0%B8%D0%BD%D1%82%D0%B5%D0%B7_%D1%80%D0%B5%D1%87%D0%B8
	--; https://ru.wikipedia.org/wiki/%D0%92%D0%BE%D0%BA%D0%BE%D0%B4%D0%B5%D1%80
	--; (Шум для согласных, Вокодер)
	--; https://www.mathworks.com/help/dsp/ref/colorednoise.html#buqdklf-1_sep_mw_437cf358-4478-4c35-ae64-963078342054
	--; https://stackoverflow.com/questions/67085963/generate-colors-of-noise-in-python
	--; https://people.sc.fsu.edu/~jburkardt/presentations/pink_noise.pdf
	--; https://forum.juce.com/t/pink-noise-generator/40013
	--; https://github.com/steveseguin/pink-noise-generator/blob/main/index.html
	--; https://people.sc.fsu.edu/~jburkardt/m_src/pink_noise/pink_noise.html
	--; https://www.firstpr.com.au/dsp/pink-noise/
	--; Приятный набор интересных статей для прочтения, лучше бы я так к зачётам готовился
	--; https://en.wikipedia.org/wiki/Fourier_transform
	--; https://en.wikipedia.org/wiki/Fast_Fourier_transform
	--; В коде создания """голоса""" были совершены преступления против некоторых наук, найдите их и напишите снизу, для дополнительных баллов
	--; https://en.wikipedia.org/wiki/Angular_frequency
	--; https://www.youtube.com/watch?v=eL2b5DEzcqI
	--; Дальше:
	--; https://ccrma.stanford.edu/CCRMA/Courses/152/speech.html
	--; https://en.m.wikipedia.org/wiki/Vocal_tract
	--; SAM
	--; https://habr.com/ru/articles/500764/
	--; Спектрограммы и прочее
	--; https://habr.com/ru/articles/469775/
--//

--\\True info sources
	--; https://youtu.be/79N1O0lF0GY?si=KexQCyL-WYCBfbMw
--//

--\\
	--; В целом звуки речи подразделяются на шумы и тоны: 
	--; тоны в речи возникают в результате колебания голосовых складок; 
	--; шумы образуются в результате непериодических колебаний выходящей из лёгких струи воздуха.
	--; Тонами являются обычно гласные; почти же все глухие согласные относятся к шумам.
	--; Звонкие согласные образуются путём слияния шумов и тонов.
	--; Шумы и тоны исследуются по их высоте, тембру, силе и многим другим характеристикам.
	--; Согласные состоят из шумов...
--//

--\\Звуки
	--; Тональные
	--; Шипящие
	--; Нозальные
--//

--\\Перевод плагиновых штук в ваши штуки
	hg.Synthesizer = hg.Synthesizer or {}
	local PLUGIN = hg.Synthesizer
--//

local function median(...)
	local args = {...}
	
	if(istable(args[1]))then
		args = args[1]
	end
	
	local amt = #args
	local val = 0
	
	for arg_id = 1, amt do
		val = val + args[arg_id]
	end
	
	return val / amt
end

--\\
	local test_1 = 1.0
	local vocal_funcs = {}
	
	--=\\
		vocal_funcs["noise_pink"] = function(args, val, current_frequency, work_table)
			-- local slope = args.Slope
			-- local sample_val = 0
			local rng = xoshiro128(val)
			--; Paul Kellet's method. post on musicdsp.org (paul.kellett@maxim.abel.co.uk)
			local white = -1 + rng() * 2
			work_table.Noise_b0 = work_table.Noise_b0 or 0
			work_table.Noise_b1 = work_table.Noise_b1 or 0
			work_table.Noise_b2 = work_table.Noise_b2 or 0
			work_table.Noise_b3 = work_table.Noise_b3 or 0
			work_table.Noise_b4 = work_table.Noise_b4 or 0
			work_table.Noise_b5 = work_table.Noise_b5 or 0
			work_table.Noise_b6 = work_table.Noise_b6 or 0
			-- local b0, b1, b2, b3, b4, b5, b6 = 0, 0, 0, 0, 0, 0, 0
			work_table.Noise_b0 = 0.99886 * work_table.Noise_b0 + white * 0.0555179
			work_table.Noise_b1 = 0.99332 * work_table.Noise_b1 + white * 0.0750759
			work_table.Noise_b2 = 0.96900 * work_table.Noise_b2 + white * 0.1538520
			work_table.Noise_b3 = 0.86650 * work_table.Noise_b3 + white * 0.3104856
			work_table.Noise_b4 = 0.55000 * work_table.Noise_b4 + white * 0.5329522
			work_table.Noise_b5 = -0.7616 * work_table.Noise_b5 - white * 0.0168980
			local pink = work_table.Noise_b0 + work_table.Noise_b1 + work_table.Noise_b2 + work_table.Noise_b3 + work_table.Noise_b4 + work_table.Noise_b5 + work_table.Noise_b6 + white * 0.5362
			work_table.Noise_b6 = white * 0.115926
			pink = pink / 22
			
			-- if(math.abs(pink) > 1)then
				-- print(pink)
			-- end
			
			return pink
		end

		vocal_funcs["noise_white"] = function(args, val, current_frequency, work_table)
			local sample_val = 0
			local rng = xoshiro128(val)
			sample_val = (-1 + rng() * 2)
			-- sample_val = -sample_val
			
			return sample_val
		end

		vocal_funcs["saw"] = function(args, val, current_frequency, work_table)
			local period = args.Period or 1
			local sample_val = 0
			sample_val = 2 * (val / period - math.floor(0.5 + val / period))
			sample_val = -sample_val
			
			return sample_val
		end

		vocal_funcs["tri"] = function(args, val, current_frequency, work_table)
			local iters, trebble, len, sine_div, mul = math.Round(args.Pitch), args.Trebble or 1, args.Length or 1, args.SineDiv or 1, (args.Mul or -1)
			local sample_val = 0
			iters = math.Round(iters)
			
			for iter = 1, iters do
				sample_val = sample_val + math.acos(math.sin(val * (iter^trebble) / len)) / (math.pi / 2)
			end
			
			sample_val = sample_val * mul
			sample_val = sample_val / iters
			sample_val = sample_val - 1
			
			return sample_val
		end

		vocal_funcs["sqr"] = function(args, val, current_frequency, work_table)
			local iters, trebble = math.Round(args.A or 1), args.B or 1
			local sample_val = 0
			
			if(val % iters < trebble)then
				sample_val = 1
			else
				sample_val = -1
			end
			
			return sample_val
		end
	--=//

	vocal_funcs["sin"] = function(args, val, current_frequency, work_table)
		local iters, trebble, len = math.Round(args.Pitch), args.Trebble or 1, args.Length or 1
		local sin = 0
		iters = math.Round(iters)
		sin = sin + math.sin(val)
		
		for iter = 2, iters do
			sin = sin + math.sin(val * (iter^trebble) / len)
		end
		
		sin = -sin
		
		return sin / iters
	end

	vocal_funcs["saw_a"] = function(args, val, current_frequency, work_table)
		return median(vocal_funcs["saw"](args, val, current_frequency, work_table), vocal_funcs["sin"](args, val, current_frequency, work_table))
	end

	vocal_funcs["saw_sine"] = function(args, val, current_frequency, work_table)
		local sine_div = args.SineDiv or 1
		local sample_val = 0
		sample_val = (vocal_funcs["saw"](args, val, current_frequency, work_table) + math.sin(val) / sine_div) / (1 + (1 / sine_div))
		
		return sample_val
	end

	vocal_funcs["tri_sine"] = function(args, val, current_frequency, work_table)
		local sine_div = args.SineDiv or 1
		local sample_val = 0
		sample_val = (vocal_funcs["tri"](args, val, current_frequency, work_table) + math.sin(val) / sine_div) / (1 + (1 / sine_div))
		
		return sample_val
	end

	vocal_funcs["p"] = function(args, val, current_frequency, work_table)	
		return median(vocal_funcs["sqr"](args, val, current_frequency, work_table), vocal_funcs["tri_sine"](args, val, current_frequency, work_table))
	end

	vocal_funcs["t"] = function(args, val, current_frequency, work_table)	
		return median(vocal_funcs["sqr"](args, val, current_frequency, work_table), vocal_funcs["tri"](args, val, current_frequency, work_table))
	end

	vocal_funcs["saw_a_p"] = function(args, val, current_frequency, work_table)	
		return median(vocal_funcs["saw_a"](args, val, current_frequency, work_table), vocal_funcs["p"](args, val, current_frequency, work_table))
	end
--//

--\\
	local default_args = {}
	default_args["Pitch"] = 1
	default_args["A"] = 1
	default_args["B"] = 0
	default_args["Length"] = 1
	default_args["SineDiv"] = 1
	default_args["Mul"] = -1
	default_args["Period"] = 1
	default_args["Trebble"] = 1
--//

local mh = math.huge
local vocals = {
	--\\Yahe Dogma
		--; Dog + math + Yaher
		--; 12.09.2024
		--; day.month.year

		["わ"] = {
			{0, "sin", 0.0, 0.05, {Pitch = 1}},
			{0.2, "sin", 0.5, 1.0, {Pitch = 7}},
			{0.24, "sin", 0.5, 1.0, {Pitch = 7}},
			{mh, "sin", 0.0, 1.0, {Pitch = 7}},
		},
		["ぱ"] = {
			{0, "p", 0.0, 0.25, {Pitch = 2, Trebble = 0.9, A = 100, B = 4}},
			{0.06, "p", 0.5, 0.25, {Pitch = 2, Trebble = 0.9, A = 100, B = 4}},
			{0.07, "sin", 0.5, 1.0, {Pitch = 4, Trebble = 1.0}},
			{0.1, "sin", 0.5, 1.0, {Pitch = 7, Trebble = 1.0}},
			{0.3, "sin", 0.5, 1.0, {Pitch = 7}},
			{mh, "sin", 0.0, 1.0, {Pitch = 7}},
		},
		["た"] = {	--; НЕ ПОХОЖЕ ДАЖЕ БЛИЗКО
			{0, "saw_a", 0.0, 0.15, {Period = 2, Pitch = 1, Trebble = 0.1}},
			{0.1, "saw_a", 0.5, 0.15, {Period = 2, Pitch = 1, Trebble = 0.1}},
			{0.11, "saw_a", 0.5, 0.2, {Period = 2, Pitch = 16, Trebble = 0.1}},
			{0.3, "saw_a", 0.5, 0.2, {Period = 2, Pitch = 16, Trebble = 0.1}},
			{mh, "saw_a", 0.0, 0.2, {Period = 2, Pitch = 16, Trebble = 0.1}},
			-- {0, "t", 0.0, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			-- {0.1, "t", 0.5, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			-- {0.3, "t", 0.5, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			-- {mh, "t", 0.0, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			-- {0.06, "t", 0.5, 0.05, {Pitch = 2, Trebble = 2.0, A = 100, B = 2, Length = 0.1}},
			-- {0.07, "sin", 0.5, 1.0, {Pitch = 4, Trebble = 1.0}},
			-- {0.1, "sin", 0.5, 1.0, {Pitch = 7, Trebble = 1.0}},
			-- {0.3, "sin", 0.5, 1.0, {Pitch = 7}},
			-- {mh, "sin", 0.0, 1.0, {Pitch = 7}},
		},
		["ま"] = {	--; ЗВУКЧИТ КАК БА А НЕ МА
			{0, "sin", 0.0, 0.85, {Pitch = 5, Trebble = 0.2, A = 1000, B = 4}},
			{0.06, "sin", 0.5, 0.85, {Pitch = 5, Trebble = 0.2, A = 1000, B = 4}},
			{0.07, "sin", 0.5, 1.0, {Pitch = 4, Trebble = 1.0}},
			{0.1, "sin", 0.5, 1.0, {Pitch = 7, Trebble = 1.0}},
			{0.3, "sin", 0.5, 1.0, {Pitch = 7, Trebble = 1.0}},
			{mh, "sin", 0.0, 1.0, {Pitch = 7, Trebble = 1.0}},
		},
		["а"] = {
			{0, "sin", 0.0, 1.0, {Pitch = 7, Trebble = 1.0, Length = 1.00}},
			{0.06, "sin", 0.3, 1.0, {Pitch = 7, Trebble = 1.0, Length = 1.00}},
			{0.2, "sin", 0.3, 1.0, {Pitch = 7, Trebble = 1.0, Length = 1.00}},
			{mh, "sin", 0.0, 1.0, {Pitch = 7, Trebble = 1.0, Length = 1.00}},
		},
		["б"] = {
			{0, {["sin"] = 1, ["noise_pink"] = 0.2}, 0.0, 0.25, {Pitch = 4, Trebble = 1.3, Length = 2.40}},
			{0.15, {["sin"] = 1, ["noise_pink"] = 0.2}, 0.5, 0.25, {Pitch = 4, Trebble = 1.3, Length = 2.40}},
			{0.17, {["sin"] = 1, ["noise_pink"] = 0.2}, 0.3, 0.85, {Pitch = 5, Trebble = 1.0, Length = 0.50}},
			{mh, {["sin"] = 1, ["noise_pink"] = 0.2}, 0.0, 0.85, {Pitch = 5, Trebble = 1.0, Length = 0.50}},
		},
		["в"] = {
			{0, "sin", 0.0, 0.65, {Pitch = 4, Trebble = 1.0, Length = 1.00}},
			{0.15, "sin", 0.5, 0.85, {Pitch = 4, Trebble = 1.0, Length = 1.00}},
			{0.151, "sin", 0.3, 0.85, {Pitch = 5, Trebble = 1.0, Length = 0.50}},
			{mh, "sin", 0.0, 0.85, {Pitch = 5, Trebble = 1.0, Length = 0.50}},
		},
		["г"] = { -- ГОВНО
			{0, {["tri_sine"] = 0.91, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.0, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.01, {["tri_sine"] = 0.21, ["sqr"] = 0.01, ["noise_pink"] = 0.6}, 0.5, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.02, {["tri_sine"] = 0.91, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.5, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.04, {["tri_sine"] = 0.91, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.5, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			-- {0.20, {["tri_sine"] = 0.91, ["sqr"] = 0.11, ["noise_pink"] = 0.2}, 0.5, 1.05, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{mh, {["tri_sine"] = 0.00, ["sqr"] = 0.0, ["noise_pink"] = 0.6}, 0.0, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
		},
		["д"] = {
			{0, {["saw_sine"] = 0.41, ["sqr"] = 0.11, ["noise_pink"] = 0.5}, 0.0, 1.05, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.01, {["saw_sine"] = 0.41, ["sqr"] = 0.51, ["noise_pink"] = 1.1}, 0.3, 0.25, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.02, {["saw_sine"] = 0.41, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.3, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.03, {["saw_sine"] = 0.41, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.3, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			-- {0.03, {["saw_sine"] = 0.91, ["sqr"] = 0.11, ["noise_pink"] = 0.5}, 0.5, 1.05, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{0.04, {["saw_sine"] = 0.41, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.3, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
			{mh, {["saw_sine"] = 0.41, ["sqr"] = 0.11, ["noise_pink"] = 0.6}, 0.0, 0.65, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 2}},
		},
		["е"] = {	--; Непродолжительно
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.15, {Pitch = 5, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.35, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
		},
		["ё"] = {	--; Непродолжительно
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.15, {Pitch = 5, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.35, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.3}, 0.3, 0.65, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.3}, 0.0, 0.65, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
		},
		["ж"] = {
			{0, {["p"] = 0.36, ["noise_pink"] = 0.4}, 0.0, 10.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.06, {["p"] = 0.36, ["noise_pink"] = 0.4}, 0.5, 10.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.2, {["p"] = 0.36, ["noise_pink"] = 0.5}, 0.5, 10.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["p"] = 0.0, ["noise_pink"] = 0.5}, 0.0, 10.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
		},
		["з"] = {
			{0, {["p"] = 0.36, ["noise_pink"] = 0.1}, 0.0, 11.05, {Pitch = 2, Trebble = 1.5, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.06, {["p"] = 0.36, ["noise_pink"] = 0.2}, 0.5, 11.05, {Pitch = 2, Trebble = 1.5, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.2, {["p"] = 0.36, ["noise_pink"] = 0.2}, 0.5, 11.05, {Pitch = 2, Trebble = 1.5, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["p"] = 0.0, ["noise_pink"] = 0.2}, 0.0, 11.05, {Pitch = 2, Trebble = 1.5, A = 100, B = 5, Period = 16, Mul = 1}},
		},
		["и"] = {
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.4}, 0.0, 0.15, {Pitch = 5, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.4}, 0.3, 0.85, {Pitch = 12, Trebble = 1.1, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.4}, 0.3, 0.85, {Pitch = 12, Trebble = 1.1, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.4}, 0.0, 0.85, {Pitch = 12, Trebble = 1.1, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
		},
		["й"] = {
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.15, {Pitch = 5, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.01, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.35, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.10, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.35, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			-- {0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			-- {0.1, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.55, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 1}},
		},
		["к"] = { -- ГОВНО
			{0, {["t"] = 0.8, ["noise_pink"] = 0.1}, 0.0, 17.05, {Pitch = 4, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.01, {["t"] = 0.8, ["noise_pink"] = 0.1}, 0.5, 17.05, {Pitch = 4, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.02, {["t"] = 0.8, ["noise_pink"] = 1.1}, 0.5, 17.05, {Pitch = 4, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.04, {["t"] = 0.0, ["noise_pink"] = 0.1}, 0.2, 15.05, {Pitch = 4, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["t"] = 0.0, ["noise_pink"] = 0.1}, 0.0, 15.05, {Pitch = 4, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
		},
		["л"] = {
			{0, {["tri_sine"] = 0.91, ["sqr"] = 0.31, ["noise_pink"] = 0.2}, 0.0, 1.85, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri_sine"] = 0.91, ["sqr"] = 0.31, ["noise_pink"] = 0.2}, 0.5, 1.85, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri_sine"] = 0.91, ["sqr"] = 0.31, ["noise_pink"] = 0.2}, 0.5, 1.85, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.91, ["sqr"] = 0.31, ["noise_pink"] = 0.2}, 0.0, 1.85, {Pitch = 1, Trebble = 0.1, A = 10, B = 5, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["м"] = {	--; Первый нозальный звук
			{0, {["tri"] = 0.51, ["sqr"] = 0.51, ["noise_pink"] = 0.4}, 0.0, 0.15, {Pitch = 1, Trebble = 0.1, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri"] = 0.51, ["sqr"] = 0.51, ["noise_pink"] = 0.4}, 0.5, 0.75, {Pitch = 1, Trebble = 0.1, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri"] = 0.51, ["sqr"] = 0.51, ["noise_pink"] = 0.4}, 0.5, 0.75, {Pitch = 1, Trebble = 0.1, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri"] = 0.51, ["sqr"] = 0.51, ["noise_pink"] = 0.4}, 0.0, 0.75, {Pitch = 1, Trebble = 0.1, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["н"] = {
			{0, {["tri"] = 0.61, ["sqr"] = 0.51, ["noise_pink"] = 0.3}, 0.0, 0.15, {Pitch = 1, Trebble = 1.0, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri"] = 0.61, ["sqr"] = 0.51, ["noise_pink"] = 0.3}, 0.5, 0.95, {Pitch = 1, Trebble = 1.0, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri"] = 0.61, ["sqr"] = 0.51, ["noise_pink"] = 0.3}, 0.5, 0.95, {Pitch = 1, Trebble = 1.0, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri"] = 0.61, ["sqr"] = 0.51, ["noise_pink"] = 0.3}, 0.0, 0.95, {Pitch = 1, Trebble = 1.0, A = 400, B = 30, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["о"] = {
			{0.0, "sin", 0.0, 0.9, {Pitch = 5, Trebble = 1.0, Length = 1.00}},
			{0.05, "sin", 0.3, 0.9, {Pitch = 5, Trebble = 1.0, Length = 1.00}},
			{0.2, "sin", 0.3, 0.9, {Pitch = 5, Trebble = 1.0, Length = 1.00}},
			{mh, "sin", 0.0, 0.9, {Pitch = 5, Trebble = 1.0, Length = 1.00}},
		},
		["п"] = { -- ПЫХ
			{0, {["p"] = 0.8, ["noise_pink"] = 1.1}, 0.0, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.01, {["p"] = 0.8, ["noise_pink"] = 0.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.02, {["p"] = 0.8, ["noise_pink"] = 1.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.04, {["p"] = 0.0, ["noise_pink"] = 0.1}, 0.1, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["p"] = 0.0, ["noise_pink"] = 0.1}, 0.0, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.05, {["p"] = 0.1, ["noise_pink"] = 0.2}, 0.2, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.1, {["p"] = 0.1, ["noise_pink"] = 0.2}, 0.2, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {mh, {["p"] = 0.1, ["noise_pink"] = 0.2}, 0.0, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.1, "sin", 0.5, 1.0, {Pitch = 7, Trebble = 1.0}},
			-- {0.05, {["noise_white"] = 0.001}, 0.2, 1.05, {Pitch = 7, Trebble = 1.0, Length = 0.50}},
			-- {0.19, {["noise_white"] = 0.001}, 0.2, 1.05, {Pitch = 7, Trebble = 1.0, Length = 0.50}},
			-- {0.2,  {["noise_white"] = 0.001}, 0.2, 1.05, {Pitch = 7, Trebble = 1.0, Length = 0.50}},
			-- {mh,  {["noise_white"] = 0.001}, 0.0, 1.05, {Pitch = 7, Trebble = 1.0, Length = 0.50}},
			-- {mh, "sin", 0.0, 1.0, {Pitch = 7, Trebble = 1.0}},
		},
		["р"] = {
			{0, {["tri"] = 0.21, ["sqr"] = 0.51, ["noise_pink"] = 0.2}, 0.0, 0.15, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri"] = 0.21, ["sqr"] = 0.51, ["noise_pink"] = 0.2}, 0.5, 0.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri"] = 0.21, ["sqr"] = 0.51, ["noise_pink"] = 0.2}, 0.5, 0.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri"] = 0.21, ["sqr"] = 0.51, ["noise_pink"] = 0.2}, 0.0, 0.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["с"] = {
			{0, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.0, 1.15, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.5, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.5, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.0, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["т"] = {
			{0, {["p"] = 1.2, ["noise_pink"] = 2.1}, 0.0, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.01, {["p"] = 1.2, ["noise_pink"] = 1.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.02, {["p"] = 1.2, ["noise_pink"] = 2.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.04, {["p"] = 1.0, ["noise_pink"] = 1.1}, 0.1, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["p"] = 1.0, ["noise_pink"] = 1.1}, 0.0, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
		},
		-- ["п"] = {
			-- {0, {["p"] = 1.0, ["noise_pink"] = 0.1}, 0.0, 25.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.01, {["p"] = 1.0, ["noise_pink"] = 0.1}, 0.5, 25.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.02, {["p"] = 1.0, ["noise_pink"] = 0.1}, 0.5, 25.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.05, {["p"] = 0.5, ["noise_pink"] = 0.2}, 0.2, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {0.1, {["p"] = 0.5, ["noise_pink"] = 0.2}, 0.2, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			-- {mh, {["p"] = 0.5, ["noise_pink"] = 0.2}, 0.0, 35.45, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
		-- },
		["у"] = {	-- ДСП
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.2}, 0.0, 1.15, {Pitch = 2, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.2}, 0.3, 1.15, {Pitch = 2, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.2}, 0.3, 1.15, {Pitch = 2, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.2}, 0.0, 1.15, {Pitch = 2, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
		},
		["ф"] = {
			{0, {["sin"] = 0.41, ["noise_pink"] = 0.7}, 0.0, 0.65, {Pitch = 2, Trebble = 1.0, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["sin"] = 0.41, ["noise_pink"] = 0.7}, 0.5, 1.65, {Pitch = 2, Trebble = 1.0, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["sin"] = 0.41, ["noise_pink"] = 0.7}, 0.5, 1.65, {Pitch = 2, Trebble = 1.0, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["sin"] = 0.41, ["noise_pink"] = 0.7}, 0.0, 1.65, {Pitch = 2, Trebble = 1.0, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["х"] = {
			{0, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.0, 0.15, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.5, 1.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.5, 1.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["sin"] = 0.21, ["noise_pink"] = 0.7}, 0.0, 1.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["ц"] = {
			{0, {["tri_sine"] = 0.21, ["noise_pink"] = 0.4}, 0.0, 8.15, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri_sine"] = 0.21, ["noise_pink"] = 0.4}, 0.5, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri_sine"] = 0.21, ["noise_pink"] = 0.4}, 0.5, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.21, ["noise_pink"] = 0.4}, 0.0, 8.55, {Pitch = 1, Trebble = 0.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["ч"] = {
			{0, {["tri_sine"] = 0.51, ["noise_pink"] = 0.2}, 0.0, 8.15, {Pitch = 3, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.02, {["tri_sine"] = 0.51, ["noise_pink"] = 0.2}, 0.5, 8.55, {Pitch = 3, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{0.04, {["tri_sine"] = 0.51, ["noise_pink"] = 0.2}, 0.5, 8.55, {Pitch = 3, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.51, ["noise_pink"] = 0.2}, 0.0, 8.55, {Pitch = 3, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 1}},
		},
		["ш"] = {
			{0, {["tri_sine"] = 0.51, ["noise_pink"] = 0.3}, 0.0, 2.15, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{0.02, {["tri_sine"] = 0.51, ["noise_pink"] = 0.3}, 0.5, 2.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{0.04, {["tri_sine"] = 0.51, ["noise_pink"] = 0.3}, 0.5, 2.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{mh, {["tri_sine"] = 0.51, ["noise_pink"] = 0.3}, 0.0, 2.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
		},
		["щ"] = {
			{0, {["tri_sine"] = 0.61, ["noise_pink"] = 0.3}, 0.0, 3.15, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{0.02, {["tri_sine"] = 0.61, ["noise_pink"] = 0.3}, 0.5, 3.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{0.04, {["tri_sine"] = 0.61, ["noise_pink"] = 0.3}, 0.5, 3.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
			{mh, {["tri_sine"] = 0.61, ["noise_pink"] = 0.3}, 0.0, 3.55, {Pitch = 1, Trebble = 1.1, A = 20, B = 10, Period = 16, Mul = 1, SineDiv = 2}},
		},
		["ы"] = {
			{0, {["tri_sine"] = 0.7, ["noise_pink"] = 0.2}, 0.0, 1.15, {Pitch = 2, Trebble = 1.1, A = 10000, B = 2, Length = 5, SineDiv = 1}},
			{0.06, {["tri_sine"] = 0.7, ["noise_pink"] = 0.2}, 0.3, 1.15, {Pitch = 2, Trebble = 1.1, A = 10000, B = 2, Length = 5, SineDiv = 1}},
			{0.2, {["tri_sine"] = 0.7, ["noise_pink"] = 0.2}, 0.3, 1.15, {Pitch = 2, Trebble = 1.1, A = 10000, B = 2, Length = 5, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.7, ["noise_pink"] = 0.2}, 0.0, 1.15, {Pitch = 2, Trebble = 1.1, A = 10000, B = 2, Length = 5, SineDiv = 1}},
		},
		["э"] = {	-- ДСП РОБОТИЧЕСКИ2
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, A = 10000, B = 2, Length = 0.70, SineDiv = 2}},
		},
		["ю"] = {
			{0, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 0.15, {Pitch = 3, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{0.06, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 1.15, {Pitch = 3, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{0.2, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.3, 1.15, {Pitch = 3, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
			{mh, {["tri_sine"] = 0.6, ["noise_pink"] = 0.1}, 0.0, 1.15, {Pitch = 3, Trebble = 1.0, A = 10000, B = 2, Length = 10, SineDiv = 1}},
		},
		["я"] = {
			{0, "sin", 0.0, 0.5, {Pitch = 7, Trebble = 1.0, Length = 0.90}},
			{0.06, "sin", 0.3, 1.0, {Pitch = 9, Trebble = 1.0, Length = 0.90}},
			{0.2, "sin", 0.3, 1.0, {Pitch = 9, Trebble = 1.0, Length = 0.90}},
			{mh, "sin", 0.0, 1.0, {Pitch = 9, Trebble = 1.0, Length = 0.90}},
		},
		[" "] = {
			{0, "sin", 0.0, 0.0, {Pitch = 1, Trebble = 1.0, Length = 1}},
			{0.4, "sin", 0.0, 0.0, {Pitch = 1, Trebble = 1.0, Length = 1}},
			-- {0.5, "sin", 0.0, 0.0, {Pitch = 1, Trebble = 1.0, Length = 1}},
			{mh, "sin", 0.0, 0.0, {Pitch = 1, Trebble = 1.0, Length = 1}},
		},
		-- ["э"] = {	-- РОБОТИЧЕСКИ1
			-- {0, {["sin"] = 0.6, ["noise_pink"] = 0.3}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, Length = 0.70}},
			-- {0.1, {["sin"] = 0.6, ["noise_pink"] = 0.3}, 0.5, 0.85, {Pitch = 7, Trebble = 1.0, Length = 0.70}},
			-- {0.11, {["sin"] = 0.6, ["noise_pink"] = 0.3}, 0.5, 0.85, {Pitch = 7, Trebble = 1.0, Length = 0.70}},
			-- {0.3, {["sin"] = 0.6, ["noise_pink"] = 0.3}, 0.5, 0.85, {Pitch = 7, Trebble = 1.0, Length = 0.70}},
			-- {mh, {["sin"] = 0.6, ["noise_pink"] = 0.3}, 0.0, 0.85, {Pitch = 7, Trebble = 1.0, Length = 0.70}},
		-- },
	--//
		
	--\\
		["жужание"] = {
			{0, "t", 0.0, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			{0.1, "t", 0.2, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			{0.3, "t", 0.2, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
			{mh, "t", 0.0, 1.15, {Pitch = 1, Trebble = 1.2, A = 10, B = 1, Length = 1, SineDiv = 1.5}},
		},
		["поп"] = { --
			{0, {["t"] = 0.8, ["noise_pink"] = 1.1}, 0.0, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.01, {["t"] = 0.8, ["noise_pink"] = 0.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.02, {["t"] = 0.8, ["noise_pink"] = 1.1}, 0.9, 1.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{0.04, {["t"] = 0.0, ["noise_pink"] = 0.1}, 0.1, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
			{mh, {["t"] = 0.0, ["noise_pink"] = 0.1}, 0.0, 15.05, {Pitch = 1, Trebble = 1.4, A = 100, B = 5, Period = 16, Mul = 1}},
		},
		["test"] = {
			{mh, "noise_white", 0.1, 25.00, {Pitch = 10, Trebble = 2, Slope = 0}},
		},
		["test2"] = {
			{mh, "noise_pink", 0.1, 25.00, {Pitch = 10, Trebble = 2, Slope = 0}},
		},
	--//
	-- ["た"] = {
		-- {0, 0.0, 3.0, 1},
		-- {0.03, 0.3, 5.0, 2},
		-- {0.04, 0.3, 5.0, 2},
		-- {0.041, 0.5, 1.0, 7},
		-- {0.3, 0.5, 1.0, 7},
		-- {mh, 0.0, 1.0, 7},
	-- },
	-- ["し"] = {
		-- {0, 0.0, 1.0, 4},
		-- {0.1, 0.5, 1.0, 7},
	-- },
}

--\\VoiceQueue
	local samples_per_tick = 5000
	PLUGIN.TTSQueue = PLUGIN.TTSQueue or {}
	PLUGIN.TTSQueueCurrent = PLUGIN.TTSQueueCurrent or 0

	hook.Add("Think", "Synthesizer", function()
		for id, queue_line in pairs(PLUGIN.TTSQueue) do
			-- print(id)
			PLUGIN.TTSQueueCurrent = id
			
			-- print(coroutine.status(queue_line.Coroutine))
			
			if(!queue_line.Coroutine or coroutine.status(queue_line.Coroutine) == "dead" or !coroutine.resume(queue_line.Coroutine))then
				PLUGIN.TTSQueue[id] = nil
			end
		end
		
		PLUGIN.TTSQueueCurrent = 0
	end)

	function PLUGIN.AddSoundToQueue(text, ply)
		PLUGIN.TTSQueue[#PLUGIN.TTSQueue + 1] = {
			Ply = ply,
			Coroutine = coroutine.create(function() PLUGIN.TextToSpeech(text) end),
			Samples = -1,
		}
	end

	net.Receive("Synthesizer(PlayOnPlayer)", function()
		PLUGIN.PlayVocalOnPlayer(net.ReadString(), net.ReadEntity())
	end)
--//

local function vocal_sample_calc(func_name, args, val, current_frequency, work_table)
	local queue_line = PLUGIN.TTSQueue[PLUGIN.TTSQueueCurrent]
	
	if(queue_line)then
		queue_line.Samples = (queue_line.Samples or -1) + 1
		
		if(queue_line.Samples >= samples_per_tick)then
			queue_line.Samples = -1
			
			-- coroutine.yield()	--; Нельзя илдидть Си функцию
		end
	end

	if(istable(func_name))then
		local amt = 0
		local calc_val = 0
		
		for arg_name, vol_mul in pairs(func_name) do
			amt = amt + vol_mul
			calc_val = calc_val + vocal_funcs[arg_name](args, val, current_frequency, work_table) * vol_mul
		end
		
		-- for arg_id = 1, amt do
			-- calc_val = calc_val + vocal_funcs[func_name[arg_id]](args, val, current_frequency, work_table)
		-- end
		
		return calc_val / amt
	else
		return (vocal_funcs[func_name] or vocal_funcs["sin"])(args, val, current_frequency, work_table)
	end
end

local function play_vocal(vocal_id, time)
	local vocal_info = nil
	
	if(istable(vocal_id))then
		vocal_info = vocal_id
	else
		vocal_info = vocals[vocal_id]
	end
	
	if(vocal_info and vocal_info[1])then
		local samplerate = 44100
		time = time or 0.4
		local frequency = 343 / 1.5	--; Female 1.3 - 2, Male 2.2 - 4
		local last_frac = 0
		local last_freq_info_key = 1
		local current_args = vocal_info[1][5]
		local current_sine = 0
		local work_table = {}

		local function generate_func(sample_index)
			local vol_mul = 1
			local freq_mul = 1
			local frac = (sample_index + 1) / (samplerate * time)
			local cur_time = frac * time
			local freq_info = vocal_info[last_freq_info_key]
			local freq_info_next = vocal_info[last_freq_info_key + 1]
			
			if(freq_info_next)then
				local next_time = freq_info_next[1]
				
				if(next_time == math.huge)then
					next_time = time
				end
				
				local diff_time = next_time - freq_info[1]
				local diff_vol_mul = freq_info_next[3] - freq_info[3]
				local diff_frec_mul = freq_info_next[4] - freq_info[4]
				local time_frac = math.ease.InOutSine((cur_time - freq_info[1]) / diff_time)
				vol_mul = freq_info[3] + time_frac * diff_vol_mul
				freq_mul = freq_info[4] + time_frac * diff_frec_mul
				local args_next = freq_info_next[5]
				local reset_args = false
				
				if(istable(freq_info_next[2]))then
					for func_name, _ in pairs(freq_info_next[2]) do
						if(!freq_info[2][func_name])then
							reset_args = true
						end
					end
				end
				
				if(type(freq_info_next[2]) != type(freq_info[2]))then
					reset_args = true
				end
				
				--\\
					for arg_id, val in pairs(args_next) do
						if(current_args[arg_id])then
							local val_prev = freq_info[5][arg_id] or default_args[arg_id] or freq_info_next[5][arg_id] or 1
							
							if(reset_args)then
								val_prev = freq_info_next[5][arg_id]
							end
							
							local val_diff = val - val_prev
							current_args[arg_id] = val_prev + time_frac * val_diff
						end
					end
					
					for arg_id, val in pairs(freq_info[5]) do
						if(!args_next[arg_id])then
							current_args[arg_id] = nil
						end
					end
				--//
			else
				vol_mul = freq_info[3]
				freq_mul = freq_info[4]
				current_args = table.Copy(freq_info[5])
			end
			
			if(freq_info_next and cur_time >= freq_info_next[1])then
				last_freq_info_key = last_freq_info_key + 1
			end
			
			local current_frequency = frequency * freq_mul
			current_sine = current_sine + ((math.pi * 2.0) / samplerate) * current_frequency
			sample = vocal_sample_calc(freq_info[2], current_args, current_sine, freq_mul, work_table) * vol_mul
		
			-- if(math.abs(sample) > 1)then
				-- print(sample)
			-- end
		
			return sample
		end

		test_sound_id = test_sound_id and test_sound_id + 1 or 0
		local test_sound_id_local = test_sound_id
		
		-- print("vocal_" .. test_sound_id)

		sound.Generate("vocal_" .. test_sound_id, samplerate, time, generate_func)
		
		local queue_line = PLUGIN.TTSQueue[PLUGIN.TTSQueueCurrent]
		
		if(queue_line and IsValid(queue_line.Ply))then
			queue_line.Ply:EmitSound("vocal_" .. test_sound_id_local)
		else
			timer.Simple(0.5, function()
				surface.PlaySound("vocal_" .. test_sound_id_local)
			end)
		end
	end
end

PLUGIN.PlayVocal = play_vocal

function PLUGIN.TextToSpeech(text)
	local vocal_info = {}
	local cursor = 1
	local time_offset = 0
	local last_vocal_info = nil
	local ending_added = false
	local start_added = false
	local next_letter = utf8.GetChar(text, cursor)
	
	while next_letter != "" do
		local letter_vocal_info = vocals[next_letter]
	
		if(letter_vocal_info)then
			if(last_vocal_info)then
				-- vocal_info[#vocal_info + 1] = {time_offset, {}, 0.5, 1, {}}
			end
		
			last_vocal_info = letter_vocal_info
		
			if(!start_added)then
				start_added = true
				vocal_info[#vocal_info + 1] = letter_vocal_info[1]
			end
			
			local count = #letter_vocal_info - 1
			
			for i = 2, count do
				local vocal_line = letter_vocal_info[i]
				local vocal_line_copy = table.Copy(vocal_line)
				vocal_line_copy[1] = vocal_line_copy[1] + time_offset
				vocal_info[#vocal_info + 1] = vocal_line_copy
				
				if(i == count)then
					time_offset = time_offset + vocal_line[1]
				end
			end
		end
		
		cursor = cursor + 1
		next_letter = utf8.GetChar(text, cursor)
		
		if(next_letter == "")then
			if(last_vocal_info)then
				vocal_info[#vocal_info + 1] = last_vocal_info[#last_vocal_info]
			end
		end
	end
	
	-- PrintTable(vocal_info)
	
	PLUGIN.PlayVocal(vocal_info, time_offset + 0.4)
end

concommand.Add("dogma_playvocal_one", function(ply, cmd, args)
	PLUGIN.PlayVocal(args[1])
end)

concommand.Add("dogma_playvocal", function(ply, cmd, args)
	local text = args[1]
	
	PLUGIN.TextToSpeech(text)
end)

-- play_vocal("а")
-- play_vocal("п", 0.2)
-- play_vocal("г", 0.2)
-- timer.Simple(0.22 * 2, function() play_vocal("о") end)
-- timer.Simple(0.22 * 3, function() play_vocal("п", 0.2) end)
-- timer.Simple(0.22 * 4, function() play_vocal("а") end)

-- play_vocal("ま")
-- timer.Simple(0.22 * 1, function() play_vocal("ま") end)

-- play_vocal("ぱ")
-- timer.Simple(0.22 * 1, function() play_vocal("ぱ") end)