--
-- Addon       __menus.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--
function menu()
   -- the new instance
   local self =   {
                  menuid      =  0,
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
                  initialized =  false,
                  maxwidth    =  0,
                  maxlen      =  0,
                  basewidth   =  100
                  }

   local function round(num, digits)
      local floor = math.floor
      local mult = 10^(digits or 0)

      return floor(num * mult + .5) / mult
   end

   --
   -- t  =  {  parent=[],                          -- parent menu or nil (need x and y)
   --          voices=< {
   --                      { name="", callback=""},
   --                      { ... },
   --                   },
   --          fontsize=[],                        -- defaults to
   --          fontface=[],                        -- defaults to Rift Font
   --          hide=[],                            -- defaults to start hidden, use :show() to reveal the menu
   --       }
   --
   function self.new(t)

      if not initialized then self = menu() end

      self.menuid       =  (self.menuid + 1)
      if self.status[self.menuid]   == nil   then
         self.status[self.menuid]   =  {}
      end

      self.o.voices     =  {}
      local fs          =  t.fontsize or self.fontsize

      -- Main Window
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, t.parent)
      self.o.menu:SetBackgroundColor(unpack(self.color.black))
      self.o.menu:SetWidth(self.basewidth)

      if t.parent ~= nil and next(t,parent) then
         self.o.menu:SetPoint("TOPLEFT", t.parent, "TOPRIGHT")
      else
         if t.x ~= nil and t.y ~= nil then
            -- we have coordinates
            self.o.menu:SetPoint("TOPLEFT", UIParent, "TOPLEFT", t.x, t.y)
         else
            print(string.format("ERROR: __menu.lua: t.parent is %s, and (%s,%s)", t.parent, x, y))
            return {}
         end
      end

      local voiceid        =  0
      local lastvoiceframe =  self.o.menu

      for _, tbl in pairs(t.voices) do

         for var, val in pairs(tbl) do
            print(string.format("__menu: processing voice: %s of menu=%s (%s)", tbl.name, t.title, self.menuid))

            voiceid        =  voiceid + 1
            if not next(self.status[self.menuid]) and self.status[self.menuid][voiceid] == nil   then
               self.status[self.menuid][voiceid]   =  false
            end

--             local vf =  UI.CreateFrame("Frame", "menu_" .. self.menuid .. "_voiceframe_" .. voiceid, lastvoiceframe)
--             vf:SetHeight(fs + 4)
--             vf:SetBackgroundColor(unpack(self.color.red))

--             if voiceid == 1 then
--                -- first voice attaches to framecontainer
--                vf:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT")
--                vf:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT")
--             else
--                -- other voices attach to last one
--                vf:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT")
--                vf:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT")
--             end


--             local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, vf)
            local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, lastvoiceframe)
            v:SetFontSize(fs)
            v:SetText(tbl.name)
            v:SetBackgroundColor(unpack(self.color.black))
            v:SetLayer(12)
--             v:SetPoint("TOPLEFT",      vf, "TOPLEFT",       0, 2)
--             v:SetPoint("TOPRIGHT",     vf, "TOPRIGHT",      0, 2)

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

            if tbl.callback ~= nil and next(tbl.callback) then
               v:EventAttach( Event.UI.Input.Mouse.Left.Click, function()
                                                                  tbl.callback()
                                                               end,
                                                               "__menu: "..self.menuid.."_voice_"..voiceid .."_callback" )
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
            print(string.format("Fw=%s Vw=%s", fw, vw))
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

      if not t.hide then self.o.menu:SetVisible(true) end

      return self
   end


   function self.show() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true) end end
   function self.hide() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(false) end end

   -- return the class instance
   return self
end
