--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--
function menu(parent, t)
   -- the new instance
   local self =   {
                  menuid      =  0,
                  submenuid   =  0,
                  o           =  {},
                  fontsize    =  12,
                  color       =  {  black       =  {  0,   0,   0,   1  },
                                    grey        =  { .5,  .5,  .5,   1  },
                                    yellow      =  { .8,  .8,   0,   1  },
                                    red         =  {  1,   0,   0,   1  },
                                    green       =  {  0,   1,   0,   1  },
                                    deepblack   =  {  0,   0,   0,   1  },
                                    white       =  {  1,   1,   1,   1  },
                                 },
                  borders     =  { l=4, r=4, t=4, b=4 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  maxwidth    =  0,
                  maxlen      =  0,
                  basewidth   =  100,
                  initialized =  false
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
--    function self.flip()       if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(not self.o.menu:GetVisible())   end end


   function self.flip()
      if self.o.menu ~= nil and next(self.o.menu) then
         local state =  not self.o.menu:GetVisible()
         for obj, _ in pairs(self.o.menu:GetChildren()) do
            print("obj:\n", dumptable(obj))
            obj:SetVisible(state)
         end
      end
      return
   end


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
   local function new(parent, t, oldself)

      -- Is Parent a valid one?
      if parent == nil or next(parent) == nil then parent   =  UIParent end

      if oldself then self =  oldself  end

      self.o.voices  =  {}
      self.menuid    =  (self.menuid + 1)
      local fs       =  t.fontsize or self.fontsize
      if self.status[self.menuid]   == nil   then  self.status[self.menuid]   =  {} end

      --Global context (parent frame-thing).
      self.o.context  = UI.CreateContext("mano_input_context")
      self.o.context:SetStrata("topmost")

      -- Main Window
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_" .. parent:GetName(), self.o.context)
      self.o.menu:SetBackgroundColor(unpack(self.color.deepblack))
      self.o.menu:SetWidth(self.basewidth)
      self.o.menu:SetLayer(50)
      self.o.menu:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")

      local voiceid        =  0
      local lastvoiceframe =  self.o.menu

      for _, tbl in pairs(t.voices) do

         voiceid  =  voiceid + 1

         if not next(self.status[self.menuid])  and
            self.status[self.menuid][voiceid]   == nil   then
            self.status[self.menuid][voiceid]   =  false
         end


--          local icon  =  {}
--          if tbl.icon ~= nil then
--             icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
--             icon:SetTexture("Rift", tbl.icon)
--             icon:SetHeight(fs * 1.5)
--             icon:SetWidth(fs * 1.5)
--             icon:SetLayer(100)
--             icon:SetBackgroundColor(unpack(self.color.black))
--
--             if voiceid == 1 then
--                -- first voice attaches to framecontainer with border spaces
--                icon:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT", self.borders.l, self.borders.t)
--             else
--                -- other voices attach to last one
--                icon:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
--             end
--
--          end
--
--          local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, lastvoiceframe)
--          v:SetFontSize(fs)
--          v:SetText(tbl.name)
--          v:SetBackgroundColor(unpack(self.color.black))
--          v:SetLayer(100)
--
--          if tbl.icon ~= nil then
--             v:SetPoint("TOPLEFT",   icon, "TOPRIGHT", self.borders.l, 0)
--             if voiceid == 1 then
--                v:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT", -self.borders.r, 0)
--             else
--                v:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
--             end
--          else
--             if voiceid == 1 then
--                -- first voice attaches to framecontainer with border spaces
--                v:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT", self.borders.l, self.borders.t)
--                v:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT", -self.borders.r, self.borders.t)
--             else
--                -- other voices attach to last one
--                v:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
--                v:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
--             end
--          end

         local container    =  UI.CreateFrame("Frame", "menu_container_" .. self.menuid .. "_" .. parent:GetName(), self.o.context)
         container:SetLayer(90)
         if voiceid == 1 then
            -- first voice attaches to framecontainer with border spaces
            container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT", self.borders.l, self.borders.t)
            container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT", -self.borders.r, self.borders.t)
         else
            -- other voices attach to last one
            container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
            container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
         end

         local icon  =  {}
         if tbl.icon ~= nil then
            icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
            icon:SetTexture("Rift", tbl.icon)
            icon:SetHeight(fs * 1.5)
            icon:SetWidth(fs * 1.5)
            icon:SetLayer(100)
            icon:SetBackgroundColor(unpack(self.color.black))
            icon:SetPoint("TOPLEFT",   container, "TOPLEFT", self.borders.l, self.borders.t)
         end

         local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, lastvoiceframe)
         v:SetFontSize(fs)
         v:SetText(tbl.name)
         v:SetBackgroundColor(unpack(self.color.black))
         v:SetLayer(100)

         if tbl.icon ~= nil then
            v:SetPoint("TOPLEFT",   icon, "TOPRIGHT", self.borders.l, 0)
            v:SetPoint("TOPRIGHT",  container, "TOPRIGHT")
         else
            v:SetPoint("TOPLEFT",   container, "TOPLEFT", self.borders.l, self.borders.t)
            v:SetPoint("TOPRIGHT",  container, "TOPRIGHT", -self.borders.r, self.borders.t)
         end

         if tbl.callback ~= nil then
            if type(tbl.callback) == 'string' then
               if tbl.callback == "_submenu_" then

                  self.submenuid  =  self.submenuid  + 1

                  local tt = menu(v, tbl.submenu)
                  if self.o.sub              == nil   then self.o.sub               =  {} end
                  if self.o.sub[self.menuid] == nil   then self.o.sub[self.menuid]  =  {} end
                  self.o.sub[self.menuid][self.submenuid]                           =  tt


                  v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                     self.o.sub[self.menuid][self.submenuid]:flip()
                                                                  end,
                                                                  "__menu: "..self.menuid.."_submenu_"..self.menuid .."_" .. self.submenuid )
               end
            end

            if type(tbl.callback)   == 'table'  then
               v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                  local func, param, trigger =  unpack(tbl.callback)
                                                                  func(param)
                                                               end,
                                                               "__menu: "..self.menuid.."_voice_"..voiceid .."_callback" )
            end
         else
            v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                               self.status[self.menuid][voiceid]   =  not self.status[self.menuid][voiceid]
                                                            end,
                                                            "__menu: "..self.menuid.."_voice_"..voiceid .."_status" )
         end

         -- highligth menu voice on mousover
         v:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() v:SetBackgroundColor(unpack(self.color.grey))  end, "__mouse: highlight voice menu ON")
         v:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() v:SetBackgroundColor(unpack(self.color.black)) end, "__mouse: highlight voice menu OFF")

         local fb =  {}
         fb.left, fb.top, fb.right, fb.bottom  =  self.o.menu:GetBounds()
         local vb =  {}
         vb.left, vb.top, vb.right, vb.bottom  =  v:GetBounds()

         local fw =  fb.right - fb.left
         local vw =  vb.right - vb.left
         if vw > fw then self.o.menu:SetWidth(vw)  end

         if self.o.voices[self.menuid] == nil then self.o.voices[self.menuid] =  {} end
--          self.o.voices[self.menuid][voiceid] =  v
--          lastvoiceframe                      =  v
         self.o.voices[self.menuid][voiceid] =  container
         lastvoiceframe                      =  container

      end

      local h = lastvoiceframe:GetBottom() - self.o.menu:GetTop()
      self.o.menu:SetHeight(h + self.borders.t + self.borders.b)
      local w = lastvoiceframe:GetRight() - lastvoiceframe:GetLeft()
      self.o.menu:SetWidth(math.max(self.o.menu:GetWidth(), w))

      self.o.menu:SetVisible(false)

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
