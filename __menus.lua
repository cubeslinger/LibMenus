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
                  o           	=  {},
                  fontsize    	=  12,
                  fontface    	=  "",
                  maxlen      	=  0,
                  basewidth   	=  110,
                  initialized 	=  false,
                  voices      	=  {}, -- menu voice objects
                  submenu     	=  {}, -- pointers to nested menus (_submenu_)
						voiceid			=	0,
						childs			=	{},
						fathers			=	fathers or {},
						lastvoicewidth	=	0,
						baselayer		=	0,
                  }

	self.maxwidth		=	self.basewidth


	function self.hidemenu()
		self.o.menu:SetVisible(false)
	end

   function self.hidechilds()
		if self.o.menu ~= nil and next(self.o.menu)	then
			for _, obj in ipairs(self.childs) do
				obj.o.menu:SetVisible(false)
			end
		end
		return
	end

   function self.hidefathers()
 		if self.o.menu ~= nil and next(self.o.menu)	then
			for _, obj in ipairs(self.fathers) do
				obj.o.menu:SetVisible(false)
			end
		end
		return
	end

   function self.show()

		self.hidechilds()
		self.hidemenu()

		if self.o.menu ~= nil and next(self.o.menu) then
			self.o.menu:SetVisible(true)
			local p	=	self.o.menu:GetParent()
		end
		return
	end

   function self.hide()

		self.hidechilds()
		self.hidefathers()
		self.hidemenu()

		return
	end

   function self.flip()
		if self.o.menu ~= nil and next(self.o.menu) then

 			if self.o.menu:GetVisible() == true then
 				self:hidechilds()
				self:hidemenu()
			else
				self:show()
			end
		end
		return
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

-- 			--Global context (root frame-thing).
			self.o.context  = UI.CreateContext("menu_context_" .. self.menuid)
			self.o.context:SetStrata("topmost")

			-- Root Object
 			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)
-- 			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, parent)

			self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
			self.o.menu:SetWidth(self.basewidth)
-- 			self.o.menu:SetLayer((100-1)+self.menuid)
-- 			__menus.f.dumptable(self.o.menu:GetStrataList())
			local parentlayer	=	parent:GetLayer()
			self.baselayer	=	parentlayer + 10
			self.o.menu:SetLayer(self.baselayer + self.menuid)


			if subdata and next(subdata)  then
				self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT", __menus.borders.l, 0)
			else
				self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 1)
			end

			--
			--
			--

			if t.fontsize  ~= nil then self.fontsize  =  t.fontsize end
			if t.fontface  ~= nil then self.fontface  =  t.fontface end

			lastvoiceframe =  self.o.menu

			local	submenuarray	=	{}

			for _, tbl in pairs(t.voices) do

				self.voiceid               =  self.voiceid + 1

				local	voicewidth	=	0

				local o     =  {}
				o.container =  nil
				o.icon      =  nil
				o.text      =  nil
				o.smicon    =  nil
				flags			=	{ icon=false, text=false, smicon=false, check=nil }

				o.container =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_container", lastvoiceframe)            -- Voice Container
				o.container:SetLayer(100+self.menuid)
				o.container:SetLayer(self.baselayer + self.menuid)
				o.container:SetBackgroundColor(unpack(__menus.color.deepblack))

				if tbl.check	~= nil	then
					o.check  =  UI.CreateFrame("RiftCheckbox", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_check", o.container)                  -- Voice Check (true|false)
					o.check:SetHeight(self.fontsize * 1.5)
					o.check:SetWidth(self.fontsize  * 1.5)
-- 					o.check:SetLayer(100+self.menuid)
					o.check:SetLayer(self.baselayer + self.menuid)
					o.check:SetBackgroundColor(unpack(__menus.color.black))
					o.check:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					o.check:SetChecked(tbl.check)
					flags.check = tbl.check
-- 					print(string.format("flags.check=(%s)", flags.check))
					voicewidth	=	o.check:GetWidth()
				end

				if tbl.icon   	~= nil   then
					o.icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_icon", o.container)                     -- Voice Icon
					o.icon:SetTexture('Rift', tbl.icon)
					o.icon:SetHeight(self.fontsize * 1.5)
					o.icon:SetWidth(self.fontsize  * 1.5)
-- 					o.icon:SetLayer(100+self.menuid)
					o.icon:SetLayer(self.baselayer + self.menuid)
					o.icon:SetBackgroundColor(unpack(__menus.color.black))
					o.icon:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					flags.icon = true
					if flags.check == nil then
						o.icon:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					else
						o.icon:SetPoint("TOPLEFT", o.check, "TOPRIGHT")
					end
					voicewidth	=	voicewidth + o.icon:GetWidth()
				end

				o.text	=  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_text", o.container)                       -- Voice Text
				o.text:SetText(tbl.name)
				o.text:SetFontSize(self.fontsize)
				o.text:SetFontColor(unpack(__menus.color.white))
				o.text:SetBackgroundColor(unpack(__menus.color.black))
-- 				o.text:SetLayer(100+self.menuid)
				o.text:SetLayer(self.baselayer + self.menuid)

				-- highligth voice text
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.text:SetBackgroundColor(unpack(__menus.color.grey))  end, "__menus: highlight voice menu ON")
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.text:SetBackgroundColor(unpack(__menus.color.black)) end, "__menus: highlight voice menu OFF")
				flags.text	=	true
				voicewidth	=	voicewidth + o.text:GetWidth()

				if flags.icon == false then
					if flags.check	==	nil	then
						o.text:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					else
						o.text:SetPoint("TOPLEFT", o.check, "TOPRIGHT")
					end
				else
					o.text:SetPoint("TOPLEFT", o.icon, "TOPRIGHT")
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
-- 						o.smicon:SetLayer(100+self.menuid)
						o.smicon:SetLayer(self.baselayer + self.menuid)
						o.smicon:SetBackgroundColor(unpack(__menus.color.black))
						flags.smicon	=	true
 						o.smicon:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')
						voicewidth	=	voicewidth + o.smicon:GetWidth()

						table.insert(submenuarray, {obj=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

-- 						local a, b = o.smicon:GetTexture()
-- 						print(string.format("smicon texture=(%s)(%s)(%s) parent=(%s)", o.smicon:GetName(), a, b,o.smicon:GetParent():GetName()))
					else
						-- CALLBACK FUNCTION
						if type(tbl.callback)   == 'table'  then

							local OBJ	=	nil
							if tbl.check	~=	nil	then
								OBJ	=	o.check
							else
								OBJ 	=	o.text
							end

							OBJ:EventAttach(  Event.UI.Input.Mouse.Left.Click,
														function()
															local func, param, trigger =  unpack(tbl.callback)
															--
															func(param, OBJ)
															--
-- 															print(string.format("---> func=(%s) param=(%s) trigger=(%s)", func, param, trigger))

															if trigger == 'close' then
																self:hide()
															end

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

-- 				print(string.format("voicewidth=(%s)", voicewidth))
-- 				o.container:SetWidth(voicewidth)
				self.lastvoicewidth	=	voicewidth

				self.voices[self.voiceid]	=	o

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

			-- Set Parent Height
			local h     =  lastvoiceframe:GetBottom() - parent:GetTop()
			self.o.menu:SetHeight(h)
-- 			self.o.menu:SetWidth(self.lastvoicewidth + __menus.borders.l + __menus.borders.r)

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
      if parent 			~= nil  	and
			next(parent) 	~=	nil	and
			t 					~= nil  	and
			next(t) 			~= nil 	then

			self  =  new(parent,	t, subdata, fathers)

			self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end
