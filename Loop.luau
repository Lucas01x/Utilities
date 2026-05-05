--// Loop

loadstring("LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(f)return f;end;local message = 'if you see this message you are 100% gay'")();
local ensure = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucas01x/Utilities/refs/heads/main/ensure.luau"))()
local ThreadLoop = {};
ensure(ThreadLoop, "Cache", {});
ensure(ThreadLoop, "_Running", false);
local clock = os.clock;
local tspawn = task.spawn;
local twait = task.wait;

--// Start

local start = LPH_NO_VIRTUALIZE(function()
	if ThreadLoop._Running then
		return;
	end;
	ThreadLoop._Running = true;
	tspawn(function()
		while ThreadLoop._Running do
			local now = clock();
			for name, loop in next, ThreadLoop.Cache do
				if loop.Enabled and now >= loop.Next then
					local last = loop.Last or now;
					local delta = now - last;
					loop.Last = now;
					loop.Next = now + loop.Interval;
					local ok, err = pcall(loop.Callback, delta);
					if not ok then
						warn(("[Loop:%s] %s"):format(name, err));
					end;
				end;
			end;
			twait();
		end;
	end);
end);

-- // API

function ThreadLoop.new(name, callback, interval)
	local now = clock();
	local iv = math.max(interval or 0.01, 0.001);
	local loop = {
		Enabled = true,
		Interval = iv,
		Next = now + iv,
		Last = now,
		Callback = callback
	};
	function loop:Destroy()
		ThreadLoop.Cache[name] = nil;
	end;
	local prev = ThreadLoop.Cache[name];
	if prev then
		prev:Destroy();
	end;
	ThreadLoop.Cache[name] = loop;
	start();
	return loop;
end;
function ThreadLoop.stop()
	ThreadLoop._Running = false;
end;

return ThreadLoop;

