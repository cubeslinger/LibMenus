--
-- Addon       LibMenus.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2019
--

-- local addon, LibMenus = ...
--
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
--				    					  obj  tbl   tbl      tbl
function Library.LibMenus.menu(Parent, t, subdata, fathers)
   -- the new instance
   local self =   {
                  o           	=  {},
                  fontsize    	=  12,
                  fontface    	=  "",
                  maxlen      	=  0,
                  basewidth   	=  100,
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
	self.baseheight	=	self.fontsize


	function self.hidemenu()	self.o.menu:SetVisible(false)	end

   function self.hidechilds()
-- 		if self.o.menu ~= nil and next(self.o.menu)	then
		if self.childs ~= nil and next(self.childs)	then
			for _, obj in ipairs(self.childs) do
				obj.o.menu:SetVisible(false)
				print(string.format("hiding (%s) of (%s)", obj.o.menu:GetName(), self.menuid))
			end
		else
			print("Nothing to hide")
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
			print(string.format("Showing (%s)", self.menuid))
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
				print("Visbile->Hidden")
			else
				self:show()
				print("Hidden->Visible")
			end
		end

		return
	end


   local function new(Parent, t, subdata, fathers)

		if Parent == nil or t == nil or next(t) == nil then
			print(string.format("ERROR: menu.new, Parent is (%s), skipping.", Parent))
			print(string.format("ERROR: menu.new, t is (%s), skipping.", t))
			print(string.format("ERROR: menu.new, next(%s) is (%s), skipping.", t, next(t)))

		else
			self.menuid = math.random(10000)

			-- Is Parent a valid one?
			if Parent == nil or next(Parent) == nil then Parent   =  UIParent end

			self.o.voices  =  {}
			local fs       =  t.fontsize or self.fontsize

			--	Global context (root frame-thing).
			self.o.context  = UI.CreateContext("menu_context_" .. self.menuid)
			self.o.context:SetStrata("topmost")

			-- Root Object
 			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)

			self.o.menu:SetBackgroundColor(unpack(Library.LibMenus.color.deepblack))
			self.o.menu:SetWidth(self.basewidth)
			self.baselayer	=	10 + Parent:GetLayer()
			self.o.menu:SetLayer(self.baselayer)

			if subdata and next(subdata)  then
				self.o.menu:SetPoint("TOPLEFT", Parent, "TOPRIGHT", Library.LibMenus.borders.l, 0)
			else
				self.o.menu:SetPoint("TOPLEFT", Parent, "BOTTOMLEFT", 0, 1)
			end

			if t.fontsize  ~= nil then self.fontsize  =  t.fontsize end
			if t.fontface  ~= nil then self.fontface  =  t.fontface end

			lastvoiceframe =  self.o.menu

			local	submenuarray		=	{}
			local voiceidstoenlarge	=	{}
			self.maxvoicewidth		=	self.basewidth

			for _, tbl in pairs(t.voices) do

				self.voiceid               =  self.voiceid + 1

				local	voicewidth	=	0

				local o     =  {}
				o.container =  nil
				o.icon      =  nil
				o.text      =  nil
				o.smicon    =  nil
				flags			=	{	check		=	nil,
				                  icon		=	false,
				                  text		=	false,
				                  smicon	=	false,
				               }

				o.container =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_container", lastvoiceframe)            -- Voice Container
				o.container:SetLayer(self.baselayer)
				o.container:SetBackgroundColor(unpack(Library.LibMenus.color.deepblack))

				if tbl.check	~= nil	then
					o.check  =  UI.CreateFrame("RiftCheckbox", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_check", o.container)                  -- Voice Check (true|false)
					o.check:SetHeight(self.fontsize * 1.5)
					o.check:SetWidth(self.fontsize  * 1.5)
					o.check:SetLayer(self.baselayer)
					o.check:SetBackgroundColor(unpack(Library.LibMenus.color.black))
					o.check:SetPoint("TOPLEFT", o.container, "TOPLEFT")
					o.check:SetChecked(tbl.check)
					flags.check = tbl.check
					voicewidth	=	o.check:GetWidth()
				end

				if tbl.icon   	~= nil   then
					o.icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_icon", o.container)                     -- Voice Icon
					o.icon:SetTexture('Rift', tbl.icon)
					o.icon:SetHeight(self.fontsize * 1.5)
					o.icon:SetWidth(self.fontsize  * 1.5)
					o.icon:SetLayer(self.baselayer)
					o.icon:SetBackgroundColor(unpack(Library.LibMenus.color.black))
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
				o.text:SetFontColor(unpack(Library.LibMenus.color.white))
				o.text:SetBackgroundColor(unpack(Library.LibMenus.color.black))
				o.text:SetLayer(self.baselayer)

				-- highligth voice text
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.text:SetBackgroundColor(unpack(Library.LibMenus.color.grey))  end, "LibMenus: highlight voice menu ON")
				o.text:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.text:SetBackgroundColor(unpack(Library.LibMenus.color.black)) end, "LibMenus: highlight voice menu OFF")
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

						--	subarray	=	{ 	otext=o.text, 	osmicon=o.smicon,	menuid=self.menuid,	tblsubmenu=tbl.submenu,	tblname=tbl.name }
						--	table.insert(submenuarray, {otext=o.text, osmicon=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

						o.smicon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_smicon", o.container)                 -- Voice Sub-menu Icon
						o.smicon:SetTexture("Rift", "GuildFinder_I73.dds")
						o.smicon:SetHeight(self.fontsize)
						o.smicon:SetWidth(self.fontsize)
						o.smicon:SetLayer(self.baselayer)
						o.smicon:SetBackgroundColor(unpack(Library.LibMenus.color.black))
						flags.smicon	=	true
 						o.smicon:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')
						voicewidth	=	voicewidth + o.smicon:GetWidth()

						table.insert(submenuarray, {otext=o.text, osmicon=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})
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

				--
				--	compute voice container height - begin
				--
				local height		=	self.baseheight
				if flags.check		~=	nil 	then 	height	=	math.max(height, o.check:GetHeight())	end
				if flags.icon		==	true 	then 	height	=	math.max(height, o.icon:GetHeight())	end
				if flags.text		==	true 	then 	height	=	math.max(height, o.text:GetHeight())	end
				if flags.smicon	==	true 	then	height	=	math.max(height, o.smicon:GetHeight())	end
				o.container:SetHeight(height)
				--
				--	compute voice container height - end
				--
				--
				-- enlarge text field to max available size	-	begin
				--
				if	flags.text == true then
					if flags.smicon == true  then
						o.text:SetPoint('TOPRIGHT', o.smicon, 'TOPLEFT')
					else
						o.text:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')
					end
				end
				--
				-- enlarge text field to max available size	-	end
				--

				self.maxvoicewidth	=	math.max(voicewidth, self.maxvoicewidth)

				self.voices[self.voiceid]	=	o
				table.insert(voiceidstoenlarge, self.voiceid)

				if self.voiceid == 1 then
					-- first voice attaches to frame container with border spaces
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     Library.LibMenus.borders.l, Library.LibMenus.borders.t)
  					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -Library.LibMenus.borders.r, Library.LibMenus.borders.t)
				else
					-- other voices attach to last one
					self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, Library.LibMenus.borders.t)
  					self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, Library.LibMenus.borders.t)
				end

 				lastvoiceframe =  self.voices[self.voiceid].container
			end

			-- Set Parent Height
			local h     =  lastvoiceframe:GetBottom() - Parent:GetTop()
			self.o.menu:SetHeight(h)

			-- enlarge containers
			for _, vid in ipairs(voiceidstoenlarge) do
				self.voices[vid].container:SetWidth(self.maxvoicewidth)
			end

			-- add some space between menu and voices container
			self.o.menu:SetWidth(self.maxvoicewidth + Library.LibMenus.borders.l + Library.LibMenus.borders.r)

			--	reset voice size
			self.maxvoicewidth	=	self.basewidth

			--	attach borders
			Library.LibBordify.addborders(self.o.menu)

			-- Hide newly created menu
  			self.o.menu:SetVisible(false)

			-- delayed generation of nested sub-menus here --

			for _, tbl in pairs(submenuarray) do

				--	table.insert(submenuarray, {otext=o.text, osmicon=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

				if self.submenu 				 	== nil then self.submenu = {} 				end
				if self.submenu[tbl.menuid]	==	nil then self.submenu[tbl.menuid] = {} end

				table.insert(self.submenu[tbl.menuid], { [tbl.tblname] = {} })

            table.insert(self.fathers, self)

 				self.submenu[tbl.menuid][tbl.tblname]  =  Library.LibMenus.menu(tbl.osmicon, tbl.tblsubmenu, {1}, self.fathers)


 				table.insert(self.childs, self.submenu[tbl.menuid][tbl.tblname])

				tbl.otext:EventAttach( Event.UI.Input.Mouse.Left.Click,
											function()
												self.submenu[tbl.menuid][tbl.tblname]:flip()
											end,
											"__menu: submenu " .. tbl.tblname )

				tbl.osmicon:EventAttach( Event.UI.Input.Mouse.Left.Click,
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
      if Parent			~= nil  	and
			next(Parent) 	~=	nil	and
			t 					~= nil  	and
			next(t) 			~= nil 	then

			self  =  new(Parent,	t, subdata, fathers)

			self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end
