--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   21/05/2019
--

local addon, __menus = ...

function menu(parent, menuid, t)
   -- the new instance
   local self =   {
--                   menuid      =  0,
--                   submenuid   =  0,
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

   local function __createvoiceobjs(parent, menuid, t)

--       local width =  0
      local o     =  {}
      o.container =  nil
      o.icon      =  nil
      o.text      =  nil
      o.smicon    =  nil

      o.container =  UI.CreateFrame("Frame", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_container", parent)                 -- Voice Container
      o.container:SetLayer(100+menuid)
      o.container:SetBackgroundColor(unpack(__menus.color.deepblack))

      if t.icon   ~= nil   then
--          o.icon  =  UI.CreateFrame("Texture", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_icon", parent)                     -- Voice Icon
			o.icon  =  UI.CreateFrame("Texture", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_icon", o.container)                     -- Voice Icon
--          o.icon:SetTexture("Rift", t.icon)
-- 			o.icon:SetTexture(addon.identifier, t.icon)
			o.icon:SetTexture('Rift', t.icon)
         o.icon:SetHeight(self.fontsize * 1.5)
         o.icon:SetWidth(self.fontsize  * 1.5)
         o.icon:SetLayer(100+menuid)
         o.icon:SetBackgroundColor(unpack(__menus.color.black))
--          width  =  width + o.icon:GetWidth() + __menus.borders.l
      end

--       o.text	=  UI.CreateFrame("Text", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_text", parent)                       -- Voice Text
		o.text	=  UI.CreateFrame("Text", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_text", o.container)                       -- Voice Text
		o.text:SetText(t.name)
      o.text:SetFontSize(self.fontsize)
		o.text:SetFontColor(unpack(__menus.color.white))
      o.text:SetBackgroundColor(unpack(__menus.color.black))
-- 		o.text:SetBackgroundColor(unpack(__menus.color.green))
		--
		o.text:SetLayer(100+menuid)
		--
		width  =  width + o.text:GetWidth()
		-- highligth voice text
      o.text:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.text:SetBackgroundColor(unpack(__menus.color.grey))  end, "__mouse: highlight voice menu ON")
      o.text:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.text:SetBackgroundColor(unpack(__menus.color.black)) end, "__mouse: highlight voice menu OFF")

      if t.callback ~= nil then

         -- CALLBACK _SUBMENU_
         if type(t.callback) == 'string' and  t.callback == "_submenu_" then

				if self.submenu == nil 			 then self.submenu = {} 			end
				if next(self.submenu)	==	nil then self.submenu[menuid] = {}  end
				table.insert(self.submenu[menuid], { [t.name] = {} })

            self.submenu[menuid][t.name]  =  menu(o.text, menuid+1, t.submenu)

            o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                 function()
-- 												print(string.format("self.submenu[%s][%s]:flip()", menuid, t.name))
												__menus.f.dumptable(self.submenu[menuid][t.name])
												self.submenu[menuid][t.name]:flip()
											end,
                                 "__menu: submenu " .. t.name )
         else
            -- CALLBACK FUNCTION
            if type(t.callback)   == 'table'  then
               o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                    function()
-- 													print("menu function callback")
													local func, param, trigger =  unpack(t.callback) func(param)
												end,
                                    "__menu: callback" .. t.name )
            else
               print(string.format("ERROR: type(%st.callback)=%s", t.callback, type(t.callback)))
            end
         end
      end

      if type(t.callback) == 'string' and t.callback == "_submenu_" then

         o.smicon  =  UI.CreateFrame("Texture", "menu_" .. menuid .. "_voice_" .. self.voiceid .. "_smicon", o.container)                 -- Voice Sub-menu Icon
         o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
         o.smicon:SetHeight(self.fontsize)
         o.smicon:SetWidth(self.fontsize)
         o.smicon:SetLayer(100+menuid)
         o.smicon:SetBackgroundColor(unpack(__menus.color.black))
         width  =  width + o.smicon:GetWidth() + __menus.borders.l

      end

		o.container:SetHeight(math.max(o.text:GetHeight(), o.icon:GetHeight()))

      return o
   end


	local function _createvoices(parent, menuid, t)

      if t.fontsize  ~= nil then self.fontsize  =  fontsize end
      if t.fontface  ~= nil then self.fontface  =  fontface end

      lastvoiceframe =  parent

      for _, tbl in pairs(t.voices) do

         width                      =  0
         self.voiceid               =  self.voiceid + 1
         self.voices[self.voiceid]  =  __createvoiceobjs(lastvoiceframe, menuid, tbl)

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

      return self, lastvoiceframe
   end

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

			local _, lastvoiceframe	=	_createvoices(self.o.menu, self.menuid, t)

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

         self  =  new(parent, menuid, t)

         self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end
