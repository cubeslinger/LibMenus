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
                  color       =  { black = {  0,  0,  0,  1}, grey = {  .5,  .5,  .5,  1}, yellow = { .8, .8, 0, 1} },
                  borders     =  { l=2, r=2, t=2, b=2 },               -- Left, Right, Top, Bottom
                  status      =  {},
                  initialized =  false,
                  maxwidth    =  0,
                  maxlen      =  0,
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
   --          title=[],                           -- menu title or nil
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

      --Global context (parent frame-thing).
      self.o.context = UI.CreateContext("context_menu_" .. self.menuid)

      -- Main Window
      self.o.menu    =  UI.CreateFrame("Frame", "menu_" .. self.menuid, self.o.context)

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

      self.o.menu:SetLayer(10)
      self.o.menu:SetBackgroundColor(unpack(self.color.yellow))

      self.o.menuborder =  UI.CreateFrame("Frame", "menu_title_border_" .. self.menuid, self.o.menu)
      self.o.menuborder:SetPoint("TOPLEFT",     self.o.menu, "TOPLEFT",       self.borders.l,   self.borders.t)
      self.o.menuborder:SetPoint("TOPRIGHT",    self.o.menu, "TOPRIGHT",      -self.borders.r,  self.borders.t)
      self.o.menuborder:SetPoint("BOTTOMLEFT",  self.o.menu, "BOTTOMLEFT",    self.borders.l,   -self.borders.b)
      self.o.menuborder:SetPoint("BOTTOMRIGHT", self.o.menu, "BOTTOMRIGHT",   -self.borders.r,  -self.borders.b)
      self.o.menuborder:SetBackgroundColor(unpack(self.color.black))


--       if t.title ~= nil then
-- --          self.o.menutitleframe =  UI.CreateFrame("Frame", "menu_title_frame_" .. self.menuid, self.o.menu)
--          self.o.menutitleframe =  UI.CreateFrame("Frame", "menu_title_frame_" .. self.menuid, self.o.menuborder)
--          self.o.menutitleframe:SetPoint("TOPLEFT",  self.o.menu, "TOPLEFT",    self.borders.l,   self.borders.t)
--          self.o.menutitleframe:SetPoint("TOPRIGHT", self.o.menu, "TOPRIGHT",   -self.borders.r,  self.borders.t)
--          self.o.menutitleframe:SetHeight(fs + 2)
--          self.o.menutitleframe:SetBackgroundColor(unpack(self.color.black))
--          self.o.menutitleframe:SetLayer(11)
--
--          self.maxwidth  =  math.max(self.maxwidth, self.o.menutitleframe:GetWidth())
--
--          -- Window Title
--          self.o.menutitle =  UI.CreateFrame("Text", "menu_title_" .. self.menuid, self.o.menutitleframe)
--          self.o.menutitle:SetFontSize(fs)
--          self.o.menutitle:SetText(string.format("%s", t.title), true)
--          self.o.menutitle:SetBackgroundColor(unpack(self.color.black))
--          self.o.menutitle:SetLayer(12)
--          self.o.menutitle:SetPoint("TOPLEFT",   self.o.menutitleframe, "TOPLEFT",  0, 1)
--          self.o.menutitle:SetPoint("TOPRIGHT",  self.o.menutitleframe, "TOPRIGHT", 0, 1)
--
--          self.maxwidth  =  math.max(self.maxwidth, self.o.menutitle:GetWidth())
--          self.maxlen    =  math.max(self.maxlen, t.title:len())
--
--          self.o.menuvoicesframe  =  UI.CreateFrame("Frame", "menu_voices_frame_" .. self.menuid, self.o.menutitleframe)
--          self.o.menuvoicesframe:SetBackgroundColor(unpack(self.color.black))
--          self.o.menuvoicesframe:SetPoint("TOPLEFT",      self.o.menutitleframe,  "BOTTOMLEFT")
--          self.o.menuvoicesframe:SetPoint("TOPRIGHT",     self.o.menutitleframe,  "BOTTOMRIGHT")
--          self.o.menuvoicesframe:SetPoint("BOTTOMLEFT",   self.o.menu,  "BOTTOMLEFT",  self.borders.l,    -self.borders.b)
--          self.o.menuvoicesframe:SetPoint("BOTTOMRIGHT",  self.o.menu,  "BOTTOMRIGHT", -self.borders.r,   -self.borders.b)
--       else
         self.o.menuvoicesframe  =  UI.CreateFrame("Frame", "menu_voices_frame_" .. self.menuid, self.o.menu)
         self.o.menuvoicesframe:SetBackgroundColor(unpack(self.color.black))
         self.o.menuvoicesframe:SetPoint("TOPLEFT",      self.o.menu,  "TOPLEFT",     self.borders.l,    self.borders.t)
         self.o.menuvoicesframe:SetPoint("TOPRIGHT",     self.o.menu,  "TOPRIGHT",    -self.borders.r,   self.borders.t)
         self.o.menuvoicesframe:SetPoint("BOTTOMLEFT",   self.o.menu,  "BOTTOMLEFT",  self.borders.l,    -self.borders.b)
         self.o.menuvoicesframe:SetPoint("BOTTOMRIGHT",  self.o.menu,  "BOTTOMRIGHT", -self.borders.r,   -self.borders.b)
--       end

      local voiceid        =  0
      local lastvoiceframe =  {}
--       local maxwidth       =  self.o.menutitle:GetWidth() or self.o.menu:GetWidth()

      for _, tbl in pairs(t.voices) do

         for var, val in pairs(tbl) do
            print(string.format("__menu: processing voice: %s of menu=%s (%s)", tbl.name, t.title, self.menuid))

            voiceid        =  voiceid + 1
            if not next(self.status[self.menuid]) and self.status[self.menuid][voiceid] == nil   then
               self.status[self.menuid][voiceid]   =  false
            end

            local v        =  {}
            local parent   =  {}
--             if voiceid == 1 then parent = self.o.menuvoicesframe
--             else                 parent = lastvoiceframe
--             end
            parent = self.o.menuvoicesframe

--             print(string.format("__menus: self.menuid=%s, voiceid=%s, parent=%s", self.menuid, voiceid, parent))
            v  =  UI.CreateFrame("Text", "menu_" .. self.menuid .. "_voice_" .. voiceid, parent)
            v:SetFontSize(fs)
            v:SetText(string.format("%s", tbl.name))
            v:SetBackgroundColor(unpack(self.color.black))
            v:SetLayer(12)
            if voiceid == 1 then
               -- first voice attaches to framecontainer
               v:SetPoint("TOPLEFT",   parent, "TOPLEFT")
               v:SetPoint("TOPRIGHT",  parent, "TOPRIGHT")
            else
               -- other voices attach to last one
               v:SetPoint("TOPLEFT",   parent, "BOTTOMLEFT")
               v:SetPoint("TOPRIGHT",  parent, "BOTTOMRIGHT")
            end

--             self.maxwidth  =  math.max(self.maxwidth, v:GetWidth())
            self.maxlen    =  math.max(self.maxlen, v:GetText():len())

            if self.status[self.menuid]            ~= nil   then  self.status[self.menuid]  =  {} end

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

            if self.o.voices[self.menuid] == nil then self.o.voices[self.menuid] =  {} end
            self.o.voices[self.menuid][voiceid] =  v
            lastvoiceframe                      =  v
         end
      end


--       if lastvoiceframe then
--          lastvoiceframe:SetPoint("BOTTOMLEFT",   self.o.menuvoicesframe, "BOTTOMLEFT")
--          lastvoiceframe:SetPoint("BOTTOMRIGHT",  self.o.menuvoicesframe, "BOTTOMRIGHT")
--       end


--       -- Adjust HEIGHT
--       self.o.menuvoicesframe:SetHeight(lastvoiceframe:GetBottom() - self.o.menuvoicesframe:GetTop())
--
--       local borderh  = (self.o.menuvoicesframe:GetBottom() - self.o.menuvoicesframe:GetTop()) + self.borders.t + self.borders.b
--       if self.o.menutitleframe ~= nil then
--          borderh  =  borderh + (self.o.menutitleframe:GetBottom() - self.o.menutitleframe:GetTop())
--       end
--
--       self.o.menuborder:SetHeight(borderh)
--       self.o.menu:SetHeight((self.o.menuborder:GetBottom() - self.o.menuborder:GetTop()) + (self.borders.t + self.borders.b) *2)
--
--
--       print(string.format("HEIGHT menu           : %s", self.o.menu:GetBottom() - self.o.menu:GetTop()))
--       print(string.format("HEIGHT menuborder     : %s", self.o.menuborder:GetBottom() - self.o.menuborder:GetTop()))
--       print(string.format("HEIGHT menuvoicesframe: %s", self.o.menuvoicesframe:GetBottom() - self.o.menuvoicesframe:GetTop()))



--       local minY  =  self.o.menu:GetTop()
-- --       local maxY  =  lastvoiceframe:GetBottom()
--       local maxY  =  lastvoiceframe:GetBottom() + (self.borders.t + self.borders.b)
--
--       maxY  =  maxY - (self.borders.t + self.borders.b)
--       self.o.menuvoicesframe:SetHeight(round(maxY - minY))
--
--
--
--       self.o.menuborder:SetHeight(round(maxY - minY))
--
--       maxY  =  maxY + (self.borders.t + self.borders.b)
--       self.o.menu:SetHeight(round(maxY - minY))
--
--
--       -- Adjust WIDTH
--       self.maxlen =  self.maxlen * 0.5
--
--       self.o.menu:SetWidth(self.maxlen * self.fontsize + ((self.borders.l + self.borders.r) *2))
--       self.o.menuborder:SetWidth(self.maxlen * self.fontsize + (self.borders.l + self.borders.r))
--       self.o.menutitleframe:SetWidth(self.maxlen * self.fontsize)
--       self.o.menutitle:SetWidth(self.maxlen * self.fontsize)
--       for vid, _ in pairs(self.o.voices[self.menuid]) do
--          self.o.voices[self.menuid][vid]:SetWidth(self.maxlen * self.fontsize)
--       end


      return self
   end


   function self.show() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(true) end end
   function self.hide() if self.o.menu ~= nil and next(self.o.menu) then self.o.menu:SetVisible(false) end end

   -- return the class instance
   return self
end

--[[
   Error: MaNo/__menus.lua:129: attempt to index a nil value
   In MaNo / MaNo: startup event, event Event.Unit.Availability.Full
   stack traceback:
   [C]: in function '__index'
   MaNo/__menus.lua:129: in function 'new'
   MaNo/MaNo.lua:230: in function <MaNo/MaNo.lua:192>



   ]]--


