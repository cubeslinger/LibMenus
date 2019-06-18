--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   28/05/2019
--

local addon, __menus = ...
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
function menu(P, t, subdata, fathers)
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

 	function self.addborders(frametomodify)

		--	widths
		local size				=	{}
		size.height				=	{}
		size.height.corner	=	12
		size.height.top 		=	size.height.corner
		size.height.bottom 	=	size.height.corner
		size.width				=	{}
		size.width.corner		=	12
		size.width.left 		=	size.width.corner
		size.width.right 		=	size.width.corner

		local parent 			=	{}
		parent.obj				=	frametomodify
		parent.layer			=	parent.obj:GetLayer()
		parent.name				=	parent.obj:GetName()
		parent.bgcolor			=	{}
		parent.bgcolor.r, parent.bgcolor.g, parent.bgcolor.b, parent.bgcolor.a	=	parent.obj:GetBackgroundColor()

		local obj				=	{}

		--	long	borders
		obj.t		=	UI.CreateFrame("Texture", "border_" .. parent.name .. "_top", 				parent.obj)
		obj.b		=	UI.CreateFrame("Texture", "border_" .. parent.name .. "_bottom", 			parent.obj)
		obj.l		=	UI.CreateFrame("Texture", "border_" .. parent.name .. "_left", 			parent.obj)
		obj.r		=	UI.CreateFrame("Texture", "border_" .. parent.name .. "_right",			parent.obj)
		--	corners
		obj.tl	=	UI.CreateFrame("Texture", "corner_" .. parent.name .. "_topleft", 		parent.obj)
		obj.tr	=	UI.CreateFrame("Texture", "corner_" .. parent.name .. "_topright", 		parent.obj)
		obj.bl	=	UI.CreateFrame("Texture", "corner_" .. parent.name .. "_bottomleft", 	parent.obj)
		obj.br	=	UI.CreateFrame("Texture", "corner_" .. parent.name .. "_bottomright",	parent.obj)

		obj.t:SetLayer(parent.layer)
		obj.b:SetLayer(parent.layer)
		obj.l:SetLayer(parent.layer)
		obj.r:SetLayer(parent.layer)
		--
		obj.tl:SetLayer(parent.layer)
		obj.tr:SetLayer(parent.layer)
		obj.bl:SetLayer(parent.layer)
		obj.br:SetLayer(parent.layer)

		obj.t:SetTexture(addon.name, __menus.gfx.t)
		obj.b:SetTexture(addon.name, __menus.gfx.b)
		obj.l:SetTexture(addon.name, __menus.gfx.l)
		obj.r:SetTexture(addon.name, __menus.gfx.r)
		--
		obj.tl:SetTexture(addon.name, __menus.gfx.tl)
		obj.tr:SetTexture(addon.name, __menus.gfx.tr)
		obj.bl:SetTexture(addon.name, __menus.gfx.bl)
		obj.br:SetTexture(addon.name, __menus.gfx.br)
		--
		--
		--	top
		obj.t:SetPoint( 'BOTTOMLEFT', 	parent.obj, 'TOPLEFT')
		obj.t:SetPoint( 'BOTTOMRIGHT', 	parent.obj, 'TOPRIGHT')
		--	top left
		obj.tl:SetPoint( 'BOTTOMRIGHT', 	parent.obj, 'TOPLEFT')
		--	top right
		obj.tr:SetPoint( 'BOTTOMLEFT', 	parent.obj, 'TOPRIGHT')
		--	left
		obj.l:SetPoint( 'TOPRIGHT', 		parent.obj, 'TOPLEFT')
		obj.l:SetPoint( 'BOTTOMRIGHT', 	parent.obj, 'BOTTOMLEFT')
		--	right
		obj.r:SetPoint( 'TOPLEFT', 		parent.obj, 'TOPRIGHT')
		obj.r:SetPoint( 'BOTTOMLEFT', 	parent.obj, 'BOTTOMRIGHT')
		--	bottom
		obj.b:SetPoint( 'TOPLEFT', 		parent.obj, 'BOTTOMLEFT')
		obj.b:SetPoint( 'TOPRIGHT', 		parent.obj, 'BOTTOMRIGHT')
		--	bottom left
		obj.bl:SetPoint( 'TOPRIGHT', 		parent.obj, 'BOTTOMLEFT')
		obj.br:SetPoint( 'TOPLEFT', 		parent.obj, 'BOTTOMRIGHT')

		return
	end


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


   local function new(P, t, subdata, fathers)

		if P == nil or t == nil or next(t) == nil then
			print(string.format("ERROR: menu.new, P is (%s), skipping.", P))
			print(string.format("ERROR: menu.new, t is (%s), skipping.", t))
			print(string.format("ERROR: menu.new, next(%s) is (%s), skipping.", t, next(t)))

		else
			self.menuid = math.random(10000)

			-- Is Parent a valid one?
			if P == nil or next(P) == nil then P   =  UIParent end

			self.o.voices  =  {}
			local fs       =  t.fontsize or self.fontsize

			--	Global context (root frame-thing).
			self.o.context  = UI.CreateContext("menu_context_" .. self.menuid)
			self.o.context:SetStrata("topmost")

			-- Root Object
 			self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)

			self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
			self.o.menu:SetWidth(self.basewidth)
			local Player	=	P:GetLayer()
			self.baselayer	=	Player + 10
			self.o.menu:SetLayer(self.baselayer + self.menuid)


			if subdata and next(subdata)  then
				self.o.menu:SetPoint("TOPLEFT", P, "TOPRIGHT", __menus.borders.l, 0)
			else
				self.o.menu:SetPoint("TOPLEFT", P, "BOTTOMLEFT", 0, 1)
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
				flags			=	{ icon=false, text=false, smicon=false, check=nil }

				o.container =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_container", lastvoiceframe)            -- Voice Container
				o.container:SetLayer(self.baselayer + self.menuid)
				o.container:SetBackgroundColor(unpack(__menus.color.deepblack))

				if tbl.check	~= nil	then
					o.check  =  UI.CreateFrame("RiftCheckbox", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_check", o.container)                  -- Voice Check (true|false)
					o.check:SetHeight(self.fontsize * 1.5)
					o.check:SetWidth(self.fontsize  * 1.5)
					o.check:SetLayer(self.baselayer + self.menuid)
					o.check:SetBackgroundColor(unpack(__menus.color.black))
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
						--	table.insert(submenuarray, {obj=o.text, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})

						o.smicon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. self.voiceid .. "_smicon", o.container)                 -- Voice Sub-menu Icon
-- 						o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
						o.smicon:SetTexture("Rift", "GuildFinder_I73.dds")
						o.smicon:SetHeight(self.fontsize)
						o.smicon:SetWidth(self.fontsize)
-- 						o.smicon:SetLayer(100+self.menuid)
						o.smicon:SetLayer(self.baselayer + self.menuid)
						o.smicon:SetBackgroundColor(unpack(__menus.color.black))
						flags.smicon	=	true
 						o.smicon:SetPoint('TOPRIGHT', o.container, 'TOPRIGHT')
						voicewidth	=	voicewidth + o.smicon:GetWidth()

						table.insert(submenuarray, {obj=o.smicon, menuid=self.menuid, tblsubmenu=tbl.submenu, tblname=tbl.name})
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

				self.maxvoicewidth	=	math.max(voicewidth, self.maxvoicewidth)

				self.voices[self.voiceid]	=	o
				table.insert(voiceidstoenlarge, self.voiceid)

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
			local h     =  lastvoiceframe:GetBottom() - P:GetTop()
			self.o.menu:SetHeight(h)

			-- enlarge containers
			for _, vid in ipairs(voiceidstoenlarge) do
-- 				print(string.format("Vid: (%s) voicewidth (%s)", vid, self.maxvoicewidth))
-- 				__menus.f.dumptable(self.voices[vid])
				self.voices[vid].container:SetWidth(self.maxvoicewidth)
			end
			self.o.menu:SetWidth(self.maxvoicewidth + __menus.borders.l + __menus.borders.r)

			--	reset voice size
			self.maxvoicewidth	=	self.basewidth

			--	attach borders
			self.addborders(self.o.menu)

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
      if P 			~= nil  	and
			next(P) 	~=	nil	and
			t 					~= nil  	and
			next(t) 			~= nil 	then

			self  =  new(P,	t, subdata, fathers)

			self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end


--[[
Error: Incorrect function usage.
  Parameters: (userdata: 7f11d0e13140), "__menus", "gfx/rounded_top.png"
  Parameter types: userdata, string, string
Function documentation:
	Sets the current texture used for this element.
		Texture:SetTexture(source, texture)   -- string, string
Parameters:
		source:	The source of the resource. "Rift" will take the resource from Rift's internal data. Anything else will take the resource from the addon with that identifier.
		texture:	The actual texture identifier. Either a resource identifier or a filename.
    In MaNo / MaNo: startup event, event Event.Unit.Availability.Full
stack traceback:
	[C]: ?
	[C]: in function 'SetTexture'
	MaNo/__menus/__menus.lua:98: in function 'addborders'
	MaNo/__menus/__menus.lua:449: in function 'new'
	MaNo/__menus/__menus.lua:489: in function 'menu'
	MaNo/_mano_ui.lua:630: in function '__mano_ui'
	MaNo/mano.lua:159: in function <MaNo/mano.lua:141>

]]
