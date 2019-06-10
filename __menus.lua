--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2019
--

local addon, __menus = ...

--				    					  obj  tbl   tbl      tbl
function menu(parent, t, subdata, fathers)
   -- the new instance
   local self =   {
                  o           =  {},
                  fontsize    =  12,
                  fontface    =  "",
                  maxlen      =  0,
                  basewidth   =  100,
                  initialized =  false,
                  voices      =  {}, -- menu voice objects
                  submenu     =  {}, -- pointers to nested menus (_submenu_)
						voiceid		=	0,
						childs		=	{},
						fathers		=	fathers or {}
                  }


--    local function round(num, digits)
--       local floor = math.floor
--       local mult = 10^(digits or 0)
--
--       return floor(num * mult + .5) / mult
--    end

   function self.show()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true)    	end end
--    function self.hide()       if self.o.menu ~= nil and next(self.o.menu) then self:flip()   							end end
--    function self.GetVisible() if self.o.menu ~= nil and next(self.o.menu) then return(self.o.menu:GetVisible())   end end
--    function self.SetVisible() if self.o.menu ~= nil and next(self.o.menu) then return(self.o.menu:SetVisible())   end end
--    function self.flip()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(not self.o.menu:GetVisible())   end end
   function self.hide()
		if self.o.menu ~= nil and next(self.o.menu)	then
			for _, obj in ipairs(self.childs) do
				obj.o.menu:SetVisible(false)
-- 				print(string.format("HIDING: (%s)", obj.o.menu:GetName()))
			end
			for _, obj in ipairs(self.fathers) do
				obj.o.menu:SetVisible(false)
-- 				print(string.format("HIDING: (%s)", obj.o.menu:GetName()))
			end
			self.o.menu:SetVisible(false)
		end
	end

   function self.flip()
		if self.o.menu ~= nil and next(self.o.menu) then

			if self.o.menu:GetVisible() == true then
-- 				self.o.menu:hide()
					self:hide()
			else
				self.o.menu:SetVisible(true)
			end
		end
	end

   --
	--	Usage:
	--
   -- t  =  {  fontsize=[],                        -- defaults to
   --          fontface=[],                        -- defaults to Rift Font
   --          voices=< {
   --                      { name="<voice1_name>", [callback={ <function>, <function_params> }, [check=true|false], [icon="iconname.png.dds"]}
   --                      { name="<voice2_name>", [callback={ <function>, <function_params> }, [check=true|false], [icon="iconname.png.dds"]}
   --                      { name="<voice3_name>", [callback="_submenu_", submenu={ voices={<...>} }] }
   --                      { ... },
   --                   } >,
   --       }
   --


--    local function new(parent, menuid, t, subdata)
   local function new(parent, t, subdata, fathers)

		if parent == nil or t == nil or next(t) == nil then
			print(string.format("ERROR: menu.new, parent is (%s), skipping.", parent))
			print(string.format("ERROR: menu.new, t is (%s), skipping.", t))
			print(string.format("ERROR: menu.new, next(%s) is (%s), skipping.", t, next(t)))

		else
			self.menuid = math.random(10000)
--  			print(string.format("menuid=[%s]", self.menuid))

			-- Is Parent a valid one?
			if parent == nil or next(parent) == nil then parent   =  UIParent end

			self.o.voices  =  {}
			local fs       =  t.fontsize or self.fontsize

			--Global context (root frame-thing).
			self.o.context  = UI.CreateContext("menu_context_" .. self.menuid)
			self.o.context:SetStrata("topmost")

			-- Main Window
			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)
			self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
			self.o.menu:SetWidth(self.basewidth)
			self.o.menu:SetLayer((100-1)+self.menuid)

			if subdata and next(subdata)  then
				self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT", __menus.borders.l, 0)
			else
				self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 1)
			end

--	0.18.xx	-------------------------------------------------------------------------------------------------

-- 			local _, lastvoiceframe	=	_createvoices(self.o.menu, self.menuid, t)

			if t.fontsize  ~= nil then self.fontsize  =  t.fontsize end
			if t.fontface  ~= nil then self.fontface  =  t.fontface end

			lastvoiceframe =  self.o.menu

			local	submenuarray	=	{}

			for _, tbl in pairs(t.voices) do

				self.voiceid               =  self.voiceid + 1

--	0.18.xx	-------------------------------------------------------------------------------------------------

-- 				self.voices[self.voiceid]  =  __createvoiceobjs(lastvoiceframe, menuid, tbl)

				local o     =  {}
				o.container =  nil
				o.icon      =  nil
				o.text      =  nil
				o.smicon    =  nil
				flags			=	{ icon=false, text=false, smicon=false }

				o.container =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_container", lastvoiceframe)            -- Voice Container
				o.container:SetLayer(100+self.menuid)
				o.container:SetBackgroundColor(unpack(__menus.color.deepblack))


				if tbl.check	~= nil	then
					o.check  =  UI.CreateFrame("RiftCheckbox", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_check", o.container)                  -- Voice Check (true|false)
					o.check:SetHeight(self.fontsize * 1.5)
					o.check:SetWidth(self.fontsize  * 1.5)
					o.check:SetLayer(100+self.menuid)
					o.check:SetBackgroundColor(unpack(__menus.color.black))
					o.check:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					-- RiftCheckbox.Event:CheckboxChange
					o.check:EventAttach(RiftCheckbox.Event:CheckboxChange,
					                    function()
													local func, param, trigger =  unpack(tbl.callback)
													--
													func(param)
													--
-- 												print(string.format("---> func=(%s) param=(%s) trigger=(%s)", func, param, trigger))
												end,
												"__menus: check change event" )
					flags.check = true
				end

				if tbl.icon   	~= nil   then
					o.icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_icon", o.container)                     -- Voice Icon
					o.icon:SetTexture('Rift', tbl.icon)
					o.icon:SetHeight(self.fontsize * 1.5)
					o.icon:SetWidth(self.fontsize  * 1.5)
					o.icon:SetLayer(100+self.menuid)
					o.icon:SetBackgroundColor(unpack(__menus.color.black))
					o.icon:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					flags.icon = true
					if flags.check == false then
						o.text:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					else
						o.text:SetPoint("TOPLEFT", o.check, "TOPRIGHT")
					end
				end

				o.text	=  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_text", o.container)                       -- Voice Text
				o.text:SetText(tbl.name)
				o.text:SetFontSize(self.fontsize)
				o.text:SetFontColor(unpack(__menus.color.white))
				o.text:SetBackgroundColor(unpack(__menus.color.black))
				o.text:SetLayer(100+self.menuid)

				-- highligth voice text
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.text:SetBackgroundColor(unpack(__menus.color.grey))  end, "__menus: highlight voice menu ON")
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.text:SetBackgroundColor(unpack(__menus.color.black)) end, "__menus: highlight voice menu OFF")
				flags.text	=	true
				if flags.icon == false then
					if flags.check == false then
						o.text:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					else
						o.text:SetPoint("TOPLEFT", o.check, "TOPLEFT")
					end
				else
					o.text:SetPoint("TOPLEFT", o.icon, "TOPLEFT")
				end

				if tbl.callback ~= nil then

					-- CALLBACK _SUBMENU_
					if type(tbl.callback) == 'string' and  tbl.callback == "_submenu_" then

						--	subarray	=	{	obj=o.text, submenu=tbl.submenu, menuid=mnuid, tblname=tbl.name }
-- 						table.insert(submenuarray, {obj=o.text, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

						o.smicon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_smicon", o.container)                 -- Voice Sub-menu Icon
						o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
						o.smicon:SetHeight(self.fontsize)
						o.smicon:SetWidth(self.fontsize)
						o.smicon:SetLayer(100+self.menuid)
						o.smicon:SetBackgroundColor(unpack(__menus.color.black))
						flags.smicon	=	true
 						o.smicon:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')

						table.insert(submenuarray, {obj=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

-- 						local a, b = o.smicon:GetTexture()
-- 						print(string.format("smicon texture=(%s)(%s)(%s) parent=(%s)", o.smicon:GetName(), a, b,o.smicon:GetParent():GetName()))
					else
						-- CALLBACK FUNCTION
						if type(tbl.callback)   == 'table'  then
							o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
														function()
															local func, param, trigger =  unpack(tbl.callback)
															--
															func(param)
															--
-- 															print(string.format("---> func=(%s) param=(%s) trigger=(%s)", func, param, trigger))

															if trigger == 'close' then self:hide()	end

														end,
														"__menu: callback" .. tbl.name )
						else
							print(string.format("ERROR: type(%stbl.callback)=%s", tbl.callback, type(tbl.callback)))
						end
					end
				end

				if flags.icon == true then
					o.container:SetHeight(math.max(o.text:GetHeight(), o.icon:GetHeight()))
				else
					if flags.smicon == true then
						o.container:SetHeight(o.smicon:GetHeight())
					else
						if flags.text == true then
							o.container:SetHeight(o.text:GetHeight())
						end
					end
				end

				-- enlarge text field to max available size
				if	flags.text == true then
					if flags.smicon == true  then
						o.text:SetPoint('TOPRIGHT', o.smicon, 'TOPLEFT')
					else
						o.text:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')
					end
				end

				self.voices[self.voiceid]	=	o

--	0.18.xx	-------------------------------------------------------------------------------------------------

				if self.voiceid == 1 then
					-- first voice attaches to frame container with border spaces
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
				else
					-- other voices attach to last one
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
				end

 				lastvoiceframe =  self.voices[self.voiceid].container
			end


--	0.18.xx	-------------------------------------------------------------------------------------------------

			-- Set Parent Height
			local h     =  lastvoiceframe:GetBottom() - parent:GetTop()
			self.o.menu:SetHeight(h)

			-- Hide newly created menu
  			self.o.menu:SetVisible(false)

			-- delayed generation of nested sub-menus here --

			for _, tbl in pairs(submenuarray) do

				--	table.insert(submenuarray, {obj=o.text, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

				if self.submenu 				 	== nil then self.submenu = {} 				end
				if self.submenu[tbl.menuid]	==	nil then self.submenu[tbl.menuid] = {} end

				table.insert(self.submenu[tbl.menuid], { [tbl.tblname] = {} })

            table.insert(self.fathers, self)

 				self.submenu[tbl.menuid][tbl.tblname]  =  menu(tbl.obj, tbl.tblsubmenu, {1}, self.fathers)

				table.insert(self.childs, self.submenu[tbl.menuid][tbl.tblname])

				tbl.obj:EventAttach( Event.UI.Input.Mouse.Left.Click,
											function()
												self.submenu[tbl.menuid][tbl.tblname]:flip()
											end,
											"__menu: submenu " .. tbl.tblname )
			end
		end

      return self
   end

   -- Initialize
   if not self.initialized then
      if parent ~= nil  and next(parent) ~= nil and t ~= nil  and next(t) ~= nil then

			self  =  new(parent,	t, subdata, fathers)

			self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end
