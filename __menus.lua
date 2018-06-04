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
                  color       =  {  black  = {  0,   0,   0,   1},
                                    grey   = { .5,  .5,  .5,   1},
                                    yellow = { .8,  .8,   0,   1},
                                    red    = {  1,   0,   0,   1},
                                    green  = {  0,   1,   0,   1},
                                 },
                  borders     =  { l=2, r=2, t=2, b=2 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  maxwidth    =  0,
                  maxlen      =  0,
                  basewidth   =  100
                  }

   local function round(num, digits)
      local floor = math.floor
      local mult = 10^(digits or 0)

      return floor(num * mult + .5) / mult
   end
   
   function self.show() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true)    end end
   function self.hide() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(false)   end end
      
      
   --
   -- t  =  {  fontsize=[],                        -- defaults to
   --          fontface=[],                        -- defaults to Rift Font
   --          voices=< {
   --                      { name="<v1_name>", [callback="function()||'_submenu_'], [submenu={}] },
   --                      { name="<v2_name>", [callback="function()||'_submenu_'], [submenu={}] },
   --                      { ... },
   --                   } >,
   --       }
   --
   self.o.voices  =  {}
   self.menuid    =  (self.menuid + 1)   
   local fs       =  t.fontsize or self.fontsize        
   if self.status[self.menuid]   == nil   then  self.status[self.menuid]   =  {} end

   -- Main Window  
   self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_" .. parent:GetName(), parent)
   self.o.menu:SetBackgroundColor(unpack(self.color.black))
   self.o.menu:SetWidth(self.basewidth)

   if parent ~= nil and next(parent) then
      self.o.menu:SetPoint("TOPLEFT", parent, "TOPRIGHT")
   else
      if t.x ~= nil and t.y ~= nil then
         -- we have coordinates
         self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", t.x, t.y)
      else
         print(string.format("ERROR: __menu.lua: parent is %s, and (%s,%s)", parent, x, y))
         return {}
      end
   end

   local voiceid        =  0
   local lastvoiceframe =  self.o.menu
   
   print(string.format("__menu: (m=%s, s=%s)",  self.menuid, self.submenuid)) 

   for _, tbl in pairs(t.voices) do

      for var, val in pairs(tbl) do
         voiceid        =  voiceid + 1
         
         print(string.format("  __menu: (m=%s, s=%s, v=%s) processing voice: %s",  self.menuid, self.submenuid, voiceid, tbl.name))         
         
         if not next(self.status[self.menuid]) and self.status[self.menuid][voiceid] == nil   then
            self.status[self.menuid][voiceid]   =  false
         end

         local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, lastvoiceframe)
         v:SetFontSize(fs)
         v:SetText(tbl.name)
         v:SetBackgroundColor(unpack(self.color.black))
         v:SetLayer(12)

         if voiceid == 1 then
            -- first voice attaches to framecontainer
            v:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT")
            v:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT")
         else
            -- other voices attach to last one
            v:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
            v:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
         end


         if self.status[self.menuid] ~= nil then self.status[self.menuid]  =  {} end

         -- ------------------------------
         
         if tbl.callback ~= nil and (tbl.callback == "_submenu_" or next(tbl.callback)) then
            
            -- SubMenu
            if tbl.callback == "_submenu_" then
               
               self.submenuid  =  self.submenuid  + 1
               
               if self.o.sub  == nil               then self.o.sub               =  {} end
               if self.o.sub[self.menuid] == nil   then self.o.sub[self.menuid]  =  {} end
               
               local a, b = nil, nil
               for a, b in pairs(tbl.submenu) do 
                  print(string.format("  __menu tbl.submenu: (m=%s, s=%s, v=%s) a=%s b=%s",  self.menuid, self.submenuid, voiceid, a, b))
                  local c, d
                  for c, d in pairs(b) do 
                     local e, f
--                      print(string.format("    __menu: (m=%s, s=%s, v=%s) c=%s d=%s",  self.menuid, self.submenuid, voiceid, c, d))
                     for e, f in pairs(d) do 
                        print(string.format("      __menu tbl.submenu: (m=%s, s=%s, v=%s) e=%s f=%s",  self.menuid, self.submenuid, voiceid, e, f))
                     end
                  end
               end
               self.o.sub[self.menuid][self.submenuid]      =  menu(v, tbl.submenu)
              
               v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                  self.o.sub[self.menuid][self.submenuid]:show()
                                                               end,
                                                               "__menu: "..self.menuid.."_submenu_"..self.menuid .."_" .. self.submenuid )           
            else
               v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                  tbl.callback()
                                                               end,
                                                               "__menu: "..self.menuid.."_voice_"..voiceid .."_callback" )
            end
         else
            v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                               self.status[self.menuid][voiceid]   =  not self.status[self.menuid][voiceid]
                                                            end,
                                                            "__menu: "..self.menuid.."_voice_"..voiceid .."_status" )
         end
         
         -- ------------------------------            

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
   end

   local h = lastvoiceframe:GetBottom() - self.o.menu:GetTop()
   self.o.menu:SetHeight(h)
   local w = lastvoiceframe:GetRight() - lastvoiceframe:GetLeft()
   self.o.menu:SetWidth(math.max(self.o.menu:GetWidth(), w))

   self.o.menu:SetVisible(false)

   -- return the class instance
   return self
end
