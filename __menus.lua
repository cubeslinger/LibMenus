--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2019
--

local addon, __menus = ...

function menu(parent, menuid, t)
   -- the new instance
   local self =   {
                  o           =  {},
                  fontsize    =  12,
                  fontface    =  "",
                  maxlen      =  0,
                  basewidth   =  100,
                  maxwidth    =  0, -- 100
                  initialized =  false,
                  voices      =  {}, -- menu voice objects
                  submenu     =  {}, -- pointers to nested menus (_submenu_)
						voiceid		=	0
                  }


   local function round(num, digits)
      local floor = math.floor
      local mult = 10^(digits or 0)

      return floor(num * mult + .5) / mult
   end

   function self.show()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true)    end end
   function self.hide()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(false)   end end
   function self.flip()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(not self.o.menu:GetVisible())   end end
   function self.GetVisible() if self.o.menu ~= nil and next(self.o.menu) then return(self.o.menu:GetVisible())   end   end
   function self.SetVisible() if self.o.menu ~= nil and next(self.o.menu) then return(self.o.menu:SetVisible())   end   end

   --
	--	Usage:
	--
   -- t  =  {  fontsize=[],                        -- defaults to
   --          fontface=[],                        -- defaults to Rift Font
   --          voices=< {
   --                      { name="<voice1_name>", [callback={ <function>, <function_params> }, [icon="iconname.png.dds"]}
   --                      { name="<voice2_name>", [callback={ <function>, <function_params> }, [icon="iconname.png.dds"] }
   --                      { name="<voice3_name>", [callback="_submenu_", submenu={ voices={<...>} }] }
   --                      { ... },
   --                   } >,
   --       }
   --


   local function new(parent, menuid, t, subdata)

		if parent == nil or t == nil or next(t) == nil then
			print(string.format("ERROR: menu.new, parent is (%s), skipping.", parent))
			print(string.format("ERROR: menu.new, t is (%s), skipping.", t))
			print(string.format("ERROR: menu.new, next(%s) is (%s), skipping.", t, next(t)))

		else

			self.menuid	=	menuid
-- 			print(string.format("menuid=[%s]", self.menuid))

			-- Is Parent a valid one?
			if parent == nil or next(parent) == nil then parent   =  UIParent end

			self.o.voices  =  {}
			local fs       =  t.fontsize or self.fontsize

			--Global context (root frame-thing).
			self.o.context  = UI.CreateContext("menu_context_"..self.menuid)
			self.o.context:SetStrata("topmost")

			-- Main Window
			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "-" .. parent:GetName(), self.o.context)
			self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
			self.o.menu:SetWidth(self.basewidth)
			self.o.menu:SetLayer((100-1)+menuid)

			if subdata and next(subdata)  then
				self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT", __menus.borders.l, 0)
			else
				self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 1)
			end

--	0.18.xx	-------------------------------------------------------------------------------------------------

-- 			local _, lastvoiceframe	=	_createvoices(self.o.menu, self.menuid, t)

			if t.fontsize  ~= nil then self.fontsize  =  fontsize end
			if t.fontface  ~= nil then self.fontface  =  fontface end

			lastvoiceframe =  self.o.menu

			for _, tbl in pairs(t.voices) do

				local width                =  0
				self.voiceid               =  self.voiceid + 1

--	0.18.xx	-------------------------------------------------------------------------------------------------

-- 				self.voices[self.voiceid]  =  __createvoiceobjs(lastvoiceframe, menuid, tbl)

				local o     =  {}
				o.container =  nil
				o.icon      =  nil
				o.text      =  nil
				o.smicon    =  nil

-- 				o.container =  UI.CreateFrame("Frame", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_container", parent)                 -- Voice Container
				o.container =  UI.CreateFrame("Frame", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_container", lastvoiceframe)            -- Voice Container
				o.container:SetLayer(100+menuid)
				o.container:SetBackgroundColor(unpack(__menus.color.deepblack))

				if tbl.icon   ~= nil   then
					o.icon  =  UI.CreateFrame("Texture", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_icon", o.container)                     -- Voice Icon
					o.icon:SetTexture('Rift', tbl.icon)
					o.icon:SetHeight(self.fontsize * 1.5)
					o.icon:SetWidth(self.fontsize  * 1.5)
					o.icon:SetLayer(100+menuid)
					o.icon:SetBackgroundColor(unpack(__menus.color.black))
				end

				o.text	=  UI.CreateFrame("Text", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_text", o.container)                       -- Voice Text
				o.text:SetText(tbl.name)
				o.text:SetFontSize(self.fontsize)
				o.text:SetFontColor(unpack(__menus.color.white))
				o.text:SetBackgroundColor(unpack(__menus.color.black))
				--
				o.text:SetLayer(100+menuid)
				--
				width  =  width + o.text:GetWidth()

				-- highligth voice text
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.text:SetBackgroundColor(unpack(__menus.color.grey))  end, "__mouse: highlight voice menu ON")
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.text:SetBackgroundColor(unpack(__menus.color.black)) end, "__mouse: highlight voice menu OFF")

				if tbl.callback ~= nil then

					-- CALLBACK _SUBMENU_
					if type(tbl.callback) == 'string' and  tbl.callback == "_submenu_" then

						if self.submenu 			== nil then self.submenu = {} 			end
-- 						if next(self.submenu)	==	nil then self.submenu[menuid] = {}  end
						if self.submenu[menuid]	==	nil then self.submenu[menuid] = {}  end

						print(string.format("menuid=%s self.submenu[menuid]=%s tbl.name=%s", menuid, self.submenu[menuid], tbl.name))

						table.insert(self.submenu[menuid], { [tbl.name] = {} })

						print("Menu call to SUB Menu ---------------------BEGIN---")
						__menus.f.dumptable(tbl.submenu)
						print("Menu call to SUB Menu ----------------------END----")


-- 						self.submenu[menuid][tbl.name]  =  new(o.text, menuid+1, tbl.submenu)
						local submenuid	=	math.random(10000)
						self.submenu[menuid][tbl.name]  =  new(o.text, submenuid, tbl.submenu)

						o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
													function()
		-- 												print(string.format("self.submenu[%s][%s]:flip()", menuid, tbl.name))
														__menus.f.dumptable(self.submenu[menuid][tbl.name])
														self.submenu[menuid][tbl.name]:flip()
													end,
													"__menu: submenu " .. tbl.name )
					else
						-- CALLBACK FUNCTION
						if type(tbl.callback)   == 'table'  then
							o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
														function()
		-- 													print("menu function callback")
															local func, param, trigger =  unpack(tbl.callback) func(param)
														end,
														"__menu: callback" .. tbl.name )
						else
							print(string.format("ERROR: type(%stbl.callback)=%s", tbl.callback, type(tbl.callback)))
						end
					end
				end

				if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then

					o.smicon  =  UI.CreateFrame("Texture", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_smicon", o.container)                 -- Voice Sub-menu Icon
					o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
					o.smicon:SetHeight(self.fontsize)
					o.smicon:SetWidth(self.fontsize)
					o.smicon:SetLayer(100+menuid)
					o.smicon:SetBackgroundColor(unpack(__menus.color.black))
					width  =  width + o.smicon:GetWidth() + __menus.borders.l

				end

				if o.icon ~= nil then
					o.container:SetHeight(math.max(o.text:GetHeight(), o.icon:GetHeight()))
				else
					o.container:SetHeight(o.text:GetHeight())
				end

				self.voices[self.voiceid]	=	o

--	0.18.xx	-------------------------------------------------------------------------------------------------

	-- 			print("(1)" .. self.voiceid)

				if self.voiceid == 1 then
					-- first voice attaches to framecontainer with border spaces
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
				else
					-- other voices attach to last one
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
				end

	-- 			print("(2)" .. self.voiceid)

				if self.voices[self.voiceid].icon ~= nil and next(self.voices[self.voiceid].icon)  ~= nil then
					self.voices[self.voiceid].icon:SetPoint("TOPLEFT",  self.voices[self.voiceid].container, "TOPLEFT")
					self.voices[self.voiceid].text:SetPoint("TOPLEFT",  self.voices[self.voiceid].icon, "TOPRIGHT", __menus.borders.l, 0)
					self.voices[self.voiceid].text:SetPoint("TOPRIGHT", self.voices[self.voiceid].icon, "TOPRIGHT", __menus.borders.r, 0)
				else
					self.voices[self.voiceid].text:SetPoint("TOPLEFT",  self.voices[self.voiceid].container, "TOPLEFT")
					self.voices[self.voiceid].text:SetPoint("TOPRIGHT", self.voices[self.voiceid].container, "TOPRIGHT", __menus.borders.r, 0)
				end

	-- 			print("(3)" .. self.voiceid)

				-- Sub-Menu Icon
				if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then
					self.voices[self.voiceid].smicon:SetPoint("CENTERLEFT", self.voices[self.voiceid].text, "CENTERRIGHT")
					self.voices[self.voiceid].smicon:SetPoint("CENTERLEFT", self.voices[self.voiceid].container,  "CENTERRIGHT")
				else
					self.voices[self.voiceid].text:SetPoint("TOPRIGHT",  self.voices[self.voiceid].container, "TOPRIGHT")
				end

	-- 			print("(4)" .. self.voiceid)

				if self.voices[self.voiceid].icon ~= nil and next(self.voices[self.voiceid].icon) then
					self.voices[self.voiceid].container:SetHeight(self.voices[self.voiceid].icon:GetHeight())
				else
					self.voices[self.voiceid].container:SetHeight(self.voices[self.voiceid].text:GetHeight())
				end

	-- 			print("(5)" .. self.voiceid)

 				lastvoiceframe =  self.voices[self.voiceid].container
			end


--	0.18.xx	-------------------------------------------------------------------------------------------------

			-- Set Parent Height
			local h     =  lastvoiceframe:GetBottom() - parent:GetTop()
			self.o.menu:SetHeight(h)
			-- Set Width for all menu voices
			--       local idx   =  nil
			--       for idx, _ in pairs(self.voices) do	self.voices[idx].container:SetWidth(self.maxwidth)	end
			--
 			self.o.menu:SetVisible(false)
		end

      return self
   end

   -- Initialize
   if not self.initialized then
      if parent ~= nil  and next(parent) ~= nil and
         t      ~= nil  and next(t)      ~= nil then

			print("Menu Init - First call to menu ---------------")
			__menus.f.dumptable(t)
			print("Menu Init - ----------------------------------")

--          self  =  new(parent, menuid, t)

			local randommenuid	=	math.random(10000)
			self  =  new(parent, randommenuid, t)

         self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end

--[[

Error: MaNo/_mano_ui.lua:550: attempt to call global 'menu' (a nil value)
    In MaNo / MaNo: startup event, event Event.Unit.Availability.Full
stack traceback:
	[C]: in function 'menu'
	MaNo/_mano_ui.lua:550: in function '__mano_ui'
	MaNo/mano.lua:158: in function <MaNo/mano.lua:140>

]]
