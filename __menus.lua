--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--
function menu(parent, t)
--    print("--- ENTERING MENU() ---")
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
                                 },
                  borders     =  { l=4, r=4, t=4, b=4 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  maxwidth    =  0,
                  maxlen      =  0,
                  basewidth   =  100,
                  initialized =  false
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


   local function new(parent, t, oldself)
      
      local pleft, ptop, pright, pbottom  =  nil, nil, nil, nil 

      -- Get Parent Coordinates
      if parent ~= nil and next(parent) ~= nil then
         
         pleft, ptop, pright, pbottom = parent:GetBounds()
         
      end
          
      --
      -- t  =  {  fontsize=[],                        -- defaults to
      --          fontface=[],                        -- defaults to Rift Font
      --          voices=< {
--       --                      { name="<voice1_name>", [callback={ <function>, <function_params> [,'close'] } }
      --                      { name="<voice1_name>", [callback={ <function>, <function_params> } }
      --                      { name="<voice2_name>", [callback="_submenu_", submenu={ voices={<...>} }] }
      --                      { ... },
      --                   } >,
      --       }
      --
      if oldself then self =  oldself  end

      self.o.voices  =  {}
      self.menuid    =  (self.menuid + 1)
      local fs       =  t.fontsize or self.fontsize
      if self.status[self.menuid]   == nil   then  self.status[self.menuid]   =  {} end
                                                      
      --Global context (parent frame-thing).
      self.o.context  = UI.CreateContext("mano_input_context")  
      self.o.context:SetStrata("topmost") 

      -- Main Window
--       self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_" .. parent:GetName(), parent)
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_" .. parent:GetName(), self.o.context)
      self.o.menu:SetBackgroundColor(unpack(self.color.deepblack))
      self.o.menu:SetWidth(self.basewidth)
      self.o.menu:SetLayer(50)

--       if parent ~= nil and next(parent) then
--          self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT")
--       else
--          if t.x ~= nil and t.y ~= nil then
--             -- we have coordinates
--             self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", t.x, t.y)
--          else
--             print(string.format("ERROR: __menu.lua: parent is %s, and (%s,%s)", parent, x, y))
--             return {}
--          end
--       end
                                                      
--       self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", parentx, parenty)                                                      
      self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", pleft, pbottom)

      local voiceid        =  0
      local lastvoiceframe =  self.o.menu

      for _, tbl in pairs(t.voices) do

         voiceid  =  voiceid + 1

         if not next(self.status[self.menuid])           and
            self.status[self.menuid][voiceid]   == nil   then
            self.status[self.menuid][voiceid]   =  false
         end

         local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, lastvoiceframe)
         v:SetFontSize(fs)
         v:SetText(tbl.name)
         v:SetBackgroundColor(unpack(self.color.black))
         v:SetLayer(100)

         if voiceid == 1 then
            -- first voice attaches to framecontainer
            v:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT", self.borders.l, self.borders.t)
            v:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT", -self.borders.r, self.borders.t)
         else
            -- other voices attach to last one
            v:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
            v:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
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
--                                                                   if trigger and trigger == "close" then self:flip() end
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
         self.o.voices[self.menuid][voiceid] =  v
         lastvoiceframe                      =  v
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
