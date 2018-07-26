--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--

local addon, __menus = ...

function menu(parent, t)
   -- the new instance
   local self =   {
                  menuid      =  0,
--                   submenuid   =  0,
                  o           =  {},
                  fontsize    =  12,
                  fontface    =  "",
--                   color       =  {  black       =  {  0,   0,   0,   1  },
--                                     grey        =  { .5,  .5,  .5,   1  },
--                                     yellow      =  { .8,  .8,   0,   1  },
--                                     green       =  {  0,  .8,   0,   1  },
--                                     red         =  {  1,   0,   0,   1  },
--                                     green       =  {  0,   1,   0,   1  },
--                                     deepblack   =  {  0,   0,   0,   1  },
--                                     white       =  {  1,   1,   1,   1  },
--                                  },
--                   borders     =  { l=4, r=4, t=4, b=4 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  maxlen      =  0,
                  basewidth   =  100,
                  maxwidth    =  0, -- 100
                  initialized =  false,
                  voices      =  {}, -- menu voice objects
                  submenu     =  {}, -- pointers to nested menus (_submenu_)
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
   local function new(parent, t, subdata)

      if subdata and next(subdata) then
         self.menuid    =  subdata.menuid
--          self.submenuid =  subdata.submenuid
      else
         self.menuid    =  (self.menuid + 1)
      end

      -- Is Parent a valid one?
      if parent == nil or next(parent) == nil then parent   =  UIParent end

      self.o.voices  =  {}
      local fs       =  t.fontsize or self.fontsize
      if self.status[self.menuid]   == nil   then  self.status[self.menuid]   =  {} end

      --Global context (parent frame-thing).
      self.o.context  = UI.CreateContext("mano_input_context")
      self.o.context:SetStrata("topmost")

      -- Main Window
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_" .. parent:GetName(), self.o.context)
      self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
      self.o.menu:SetWidth(self.basewidth)
      self.o.menu:SetLayer(50)

      if subdata and next(subdata)  then
         self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT", __menus.borders.l, 0)
      else
         self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
      end

      self.voices[self.menuid]   =  self.__createvoices(self.o.menu, t)

      self.o.menu:SetVisible(false)

      return self
   end

-- ---------------------------------------------------------------------------------------------------------------------------
   function self.__createvoices(parent, t)
      -- the new instance
      local self =   {
                     fontsize    =  12,
                     fontface    =  nil,
                     voices      =  {},
                     submenu     =  {},
                     maxwidth    =  0,
                     voiceid     =  0,
                     initialized =  false,
                     }

      local function createvoiceobjs(parent, t)

   --       print("createobjs:\n", __menus.f.dumptable(t))

         local width =  0
         local o     =  {}
         o.container =  nil
         o.icon      =  nil
         o.text      =  nil
         o.smicon    =  nil

         o.container =  UI.CreateFrame("Frame", "voice_" .. self.voiceid .. "_container", parent)                 -- Voice Container
         o.container:SetLayer(90)
         o.container:SetBackgroundColor(unpack(__menus.color.deepblack))
         -- highligth all voice frame on mousover
         o.container:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() o.container:SetBackgroundColor(unpack(__menus.color.grey))  end, "__mouse: highlight voice menu ON")
         o.container:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() o.container:SetBackgroundColor(unpack(__menus.color.black)) end, "__mouse: highlight voice menu OFF")

         if t.icon   ~= nil   then
            o.icon  =  UI.CreateFrame("Texture", "voice_" .. self.voiceid .. "_icon", parent)                     -- Voice Icon
            o.icon:SetTexture("Rift", t.icon)
            o.icon:SetHeight(self.fontsize * 1.5)
            o.icon:SetWidth(self.fontsize  * 1.5)
            o.icon:SetLayer(100)
            o.icon:SetBackgroundColor(unpack(__menus.color.black))
            width  =  width + o.icon:GetWidth() + __menus.borders.l
         end

         o.text	=  UI.CreateFrame("Text", "voice_" .. self.voiceid .. "_text", parent)                       -- Voice Text
         o.text:SetFontSize(self.fontsize)
         o.text:SetText(t.name)
         o.text:SetBackgroundColor(unpack(__menus.color.black))
         o.text:SetLayer(100)
         width  =  width + o.text:GetWidth()

         if type(t.callback) == 'string' and t.callback == "_submenu_" then

            o.smicon  =  UI.CreateFrame("Texture", "voice_" .. self.voiceid .. "_smicon", parent)                 -- Voice Sub-menu Icon
            o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
            o.smicon:SetHeight(self.fontsize)
            o.smicon:SetWidth(self.fontsize)
            o.smicon:SetLayer(100)
            o.smicon:SetBackgroundColor(unpack(__menus.color.black))
            width  =  width + o.smicon:GetWidth() + __menus.borders.l

         end

         if t.callback ~= nil then

            -- CALLBACK _SUBMENU_
            if type(t.callback) == 'string' and  t.callback == "_submenu_" then

   --             print("pre submenu:\n", dumptable(t.submenu))
               print("=============================================")
   --             self.submenu[t.name]  =  menu(o.text, t.submenu)
               self.submenu[t.name]  =  menu(o.text, t.submenu)
   --             print(string.format("self.submenu[%s]:\n", t.name))
   --             print(dumptable(self.submenu[t.name]))
               print("--------------------------------------------")

               o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                    function()   self.submenu[t.name]:flip() end,
                                    "__menu: submenu " .. t.name )
            end

            -- CALLBACK FUNCTION
            if type(t.callback)   == 'table'  then
               o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                    function()  local func, param, trigger =  unpack(t.callback) func(param) end,
                                    "__menu: callback" .. t.name )
            end
         end

   --       o.container:SetWidth(width)

         return o
      end

      local function main(parent, t)


         if t.fontsize  ~= nil then self.fontsize  =  fontsize end
         if t.fontface  ~= nil then self.fontface  =  fontface end

         lastvoiceframe =  parent

         for _, tbl in pairs(t.voices) do

            width                      =  0
            self.voiceid               =  self.voiceid + 1
            self.voices[self.voiceid]  =  createvoiceobjs(lastvoiceframe, tbl)

            if self.voiceid == 1 then
               -- first voice attaches to framecontainer with border spaces
               self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
               self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
            else
               -- other voices attach to last one
               self.voices[self.voiceid].container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
               self.voices[self.voiceid].container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
            end

            if self.voices[self.voiceid].icon ~= nil then
               self.voices[self.voiceid].icon:SetPoint("TOPLEFT",      self.voices[self.voiceid].container, "TOPLEFT")
            end

            -- Sub-Menu Icon
            if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then
               self.voices[self.voiceid].smicon:SetPoint("CENTERLEFT", self.voices[self.voiceid].text, "CENTERRIGHT")
            end

            if tbl.icon ~= nil then
               self.voices[self.voiceid].text:SetPoint("TOPLEFT",   self.voices[self.voiceid].icon, "TOPRIGHT", __menus.borders.l, 0)
            else
               self.voices[self.voiceid].text:SetPoint("TOPLEFT",   self.voices[self.voiceid].container, "TOPLEFT")
            end

            if self.voices[self.voiceid].smicon and next(self.voices[self.voiceid].smicon) then
               self.voices[self.voiceid].smicon:SetPoint("CENTERLEFT", self.voices[self.voiceid].container,  "CENTERRIGHT")
            else
               self.voices[self.voiceid].text:SetPoint("TOPRIGHT",  self.voices[self.voiceid].container, "TOPRIGHT")
            end

            if self.voices[self.voiceid].icon ~= nil and next(self.voices[self.voiceid].icon) then
               self.voices[self.voiceid].container:SetHeight(self.voices[self.voiceid].icon:GetHeight())
            else
               self.voices[self.voiceid].container:SetHeight(self.voices[self.voiceid].text:GetHeight())
            end

            lastvoiceframe =  self.voices[self.voiceid].container

            ::continue::

         end

         -- Set Parent Height
         local h     =  lastvoiceframe:GetBottom() - parent:GetTop()
         parent:SetHeight(h)

         local idx   =  nil
         for idx, _ in pairs(self.voices) do

            print(string.format("idx: %s self.voices[%s].text:GetName(): %s", idx, idx, self.voices[idx].text:GetName()))

            self.voices[idx].container:SetWidth(self.maxwidth)
         end

         return
      end

      main(parent, t)

      return self
   end

-- ---------------------------------------------------------------------------------------------------------------------------

   -- Initialize
   if not self.initialized then
      if parent ~= nil  and next(parent) ~= nil and
         t      ~= nil  and next(t)      ~= nil then

         self  =  new(parent, t)
         self.initialized  =  true
      end
   end

   -- return the class instance
   return self
end
