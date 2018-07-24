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
                  submenuid   =  0,
                  o           =  {},
                  fontsize    =  12,
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
                  initialized =  false
                  voices      =  {}
                  }


   local function dumptable(o)
      if type(o) == 'table' then
         local s = '{ '
            for k,v in pairs(o) do
               if type(k) ~= 'number' then
                  k = '"'..k..'"'
               end
               s =   s ..'['..k..'] = ' ..(dumptable(v) or "nil table").. ',\n'
            end
            return s .. '} '
      else
         return tostring(o)
      end
   end


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
         self.submenuid =  subdata.submenuid
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
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_" .. parent:GetName(), self.o.context)
      self.o.menu:SetBackgroundColor(unpack(__menus.color.deepblack))
      self.o.menu:SetWidth(self.basewidth)
      self.o.menu:SetLayer(50)

      if subdata and next(subdata)  then
         self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT", __menus.borders.l, 0)
      else
         self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
      end

      local voiceid        =  0
      local lastvoiceframe =  self.o.menu

--       print("-------------------------------------------------")
--       print("t.voices is nil:\n", dumptable(t.voices)) print("\n")
--       print("-------------------------------------------------")

         self.voices =  __createvoices(t.voices)

--       for _, tbl in pairs(t.voices) do
--
--          self.maxwidth  =  0
--
--          if tbl["name"] == nil then goto continue  end
--
-- --          print(string.format("\nNAME: %s", tbl.name))
-- --          print(string.format("CALL: %s\n", tbl.callback))
--
--          voiceid  =  voiceid + 1
--
--          if not next(self.status[self.menuid])  and
--             self.status[self.menuid][voiceid]   == nil   then
--             self.status[self.menuid][voiceid]   =  false
--          end
--
--          local container    =  UI.CreateFrame("Frame", "menu_container_" .. self.menuid .. "_" .. "_submenuid_".. (tostring(self.submenuid) or "0") .. parent:GetName(), lastvoiceframe)
--          container:SetLayer(90)
--          container:SetBackgroundColor(unpack(__menus.color.deepblack))
--          if voiceid == 1 then
-- --             print("container first voice")
--             -- first voice attaches to framecontainer with border spaces
--             container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
--             container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
--          else
-- --             print("container NOT first voice")
--             -- other voices attach to last one
--             container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
--             container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
--          end
--
--          local icon  =  {}
--          if tbl.icon ~= nil then
--             icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
--             icon:SetTexture("Rift", tbl.icon)
--             icon:SetHeight(fs * 1.5)
--             icon:SetWidth(fs * 1.5)
--             icon:SetLayer(100)
--             icon:SetBackgroundColor(unpack(__menus.color.black))
--             icon:SetPoint("TOPLEFT",      container, "TOPLEFT")
--             if self.maxwidth < (icon:GetWidth() + __menus.borders.l) then self.maxwidth  =  (icon:GetWidth() + __menus.borders.l)  end
--             print(string.format("    max width: (%s) - %s (icon)", self.maxwidth, tbl.name))
--          end
--
--          local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid, lastvoiceframe)
--          v:SetFontSize(fs)
--          v:SetText(tbl.name)
--          v:SetBackgroundColor(unpack(__menus.color.black))
--          v:SetLayer(100)
--          local w = self.maxwidth + v:GetWidth()
--          if self.maxwidth < w then self.maxwidth  =  w end
--          print(string.format("    max width: (%s) - %s (v)", self.maxwidth, tbl.name))
--
--          -- Sub-Menu Icon
--          if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then
--
--             local smicon  =  {}
--             smicon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
--             smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
--             smicon:SetHeight(fs)
--             smicon:SetWidth(fs)
--             smicon:SetLayer(100)
--             smicon:SetBackgroundColor(unpack(__menus.color.black))
--             smicon:SetPoint("CENTERLEFT", v,          "CENTERRIGHT")
--
--             local w = self.maxwidth + smicon:GetWidth() + __menus.borders.l
--             if self.maxwidth < w then self.maxwidth  =  w end
--             print(string.format("    max width: (%s) - %s (smicon)", self.maxwidth, tbl.name))
--          end
--
--           if tbl.icon ~= nil then
--             v:SetPoint("TOPLEFT",   icon,       "TOPRIGHT", __menus.borders.l, 0)
--          else
--             v:SetPoint("TOPLEFT",   container, "TOPLEFT")
--          end
--
--          if smicon and next(smicon) then
--             smicon:SetPoint("CENTERLEFT", container,  "CENTERRIGHT")
--          else
--             v:SetPoint("TOPRIGHT",  container, "TOPRIGHT")
--          end
--
--          if tbl.callback ~= nil then
--             if type(tbl.callback) == 'string' then
--                if tbl.callback == "_submenu_" then
--
--                   self.submenuid  =  self.submenuid  + 1
--
-- --                   local tt = menu(v, tbl.submenu)
--
-- --                   local tt = menu(v, tbl.submenu, self.submenuid)
--
-- --                   local tt = new(v, tbl.submenu, self.submenuid)
--
--                   local tt = new(v, tbl.submenu, {menuid=self.menuid, submenuid=self.submenuid})
--
--                   if self.o.sub              == nil   then self.o.sub               =  {} end
--                   if self.o.sub[self.menuid] == nil   then self.o.sub[self.menuid]  =  {} end
--                   self.o.sub[self.menuid][self.submenuid]                           =  tt
--
--
--                   v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
--                                                                      self.o.sub[self.menuid][self.submenuid]:flip()
--                                                                   end,
--                                                                   "__menu: "..self.menuid.."_submenu_"..self.menuid .."_" .. self.submenuid )
--                end
--             end
--
--             if type(tbl.callback)   == 'table'  then
--                v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
--                                                                   local func, param, trigger =  unpack(tbl.callback)
--                                                                   func(param)
--                                                                end,
--                                                                "__menu: "..self.menuid.."_voice_"..voiceid .."_callback" )
--             end
--          else
--             v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
--                                                                self.status[self.menuid][voiceid]   =  not self.status[self.menuid][voiceid]
--                                                             end,
--                                                             "__menu: "..self.menuid.."_voice_"..voiceid .."_status" )
--          end
--
--          -- highligth menu voice on mousover
--          v:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() v:SetBackgroundColor(unpack(__menus.color.grey))  end, "__mouse: highlight voice menu ON")
--          v:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() v:SetBackgroundColor(unpack(__menus.color.black)) end, "__mouse: highlight voice menu OFF")
--
--          if icon ~= nil and next(icon) then  container:SetHeight(icon:GetHeight())
--          else                                container:SetHeight(v:GetHeight())
--          end
--
--          if self.o.voices[self.menuid] == nil then self.o.voices[self.menuid] =  {} end
--          self.o.voices[self.menuid][voiceid] =  container
--          lastvoiceframe                      =  container
--
-- --          lastvoiceframe:SetWidth(self.maxwidth + __menus.borders.l + __menus.borders.r)
-- --          print(string.format("  max width: (%s) - (lastvoiceframe)", self.maxwidth))
--
--          ::continue::
--
--       end

      local h = lastvoiceframe:GetBottom() - self.o.menu:GetTop()
      self.o.menu:SetHeight(h + __menus.borders.t + __menus.borders.b)
      self.o.menu:SetWidth(self.maxwidth + __menus.borders.l + __menus.borders.r)
      self.o.menu:SetVisible(false)

      if self.o.sub and next(self.o.sub) then
         for _, obj in ipairs(self.o.sub[self.menuid])   do obj:SetVisible(false)   end
      end

      if self.o.voices[self.menuid] ~= nil then
         for _, obj in ipairs(self.o.voices[self.menuid] ~= nil) do  obj:SetWidth(self.maxwidth)   end
      end

      print(string.format("MAX WIDTH: (%s)", self.maxwidth))

      return self
   end

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
