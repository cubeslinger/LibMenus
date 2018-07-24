--
-- Addon       __menus_voices.lua
-- Author      marcob@marcob.org
-- StartDate   30/05/2018
--
--
--
-- mano.events.savetrigger,      mano.events.saveevent      =  Utility.Event.Create(addon.identifier, "userinput.save")
--
--
local addon, __menus = ...

function __createvoices(parent, t)
   -- the new instance
   local self =   {
                  initialized =  false
                  voices      =  {}
                  maxwidth    =  0
                  voiceid     =  0
                  submenu     =  {}
                  }



   local function createobjs(parent, t)

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
         o.icon:SetTexture("Rift", tbl.icon)
         o.icon:SetHeight(fs * 1.5)
         o.icon:SetWidth(fs * 1.5)
         o.icon:SetLayer(100)
         o.icon:SetBackgroundColor(unpack(__menus.color.black))
         width  =  width + o.icon:GetWidth() + __menus.borders.l
      end

      o.text	=  UI.CreateFrame("Text", "voice_" .. self.voiceid .. "_text", parent)                       -- Voice Text
      o.text:SetFontSize(fs)
      o.text:SetText(tbl.name)
      o.text:SetBackgroundColor(unpack(__menus.color.black))
      o.text:SetLayer(100)
      width  =  width + o.text:GetWidth()

      if type(t.callback) == 'string' and t.callback == "_submenu_" then
         o.smicon  =  UI.CreateFrame("Texture", "voice_" .. self.voiceid .. "_smicon", parent)                 -- Voice Sub-menu Icon
         o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
         o.smicon:SetHeight(fs)
         o.smicon:SetWidth(fs)
         o.smicon:SetLayer(100)
         o.smicon:SetBackgroundColor(unpack(__menus.color.black))
         width  =  width + o.smicon:GetWidth() + __menus.borders.left
      end

      if t.callback ~= nil then

         -- CALLBACK _SUBMENU_
         if type(t.callback) == 'string' then and  t.callback == "_submenu_" then
            self.submenu[t.name]  =  menu(v, t.submenu)
            o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                 function()   self.submenu[t.name]:flip() end,
                                 "__menu: submenu " .. t.name )
         end

         -- CALLBACK FUNCTION
         if type(tbl.callback)   == 'table'  then
            o.text:EventAttach(  Event.UI.Input.Mouse.Left.Click,
                                 function()  local func, param, trigger =  unpack(tbl.callback) func(param) end,
                                 "__menu: callback" .. t.name )
         end
      end

      o.container:SetWidth(width)

      return o
   end


   for _, tbl in pairs(t.voices) do

      width  =  0

--       if tbl["name"] == nil then goto continue  end

      self.voices   =  createobjs(lastvoiceframe, tbl)

      local w  =  self.voices:GetWidth()
      if self.maxwidth < w then  self.maxwidth  =  w

      if voiceid == 1 then
         --             print("container first voice")
         -- first voice attaches to framecontainer with border spaces
         self.voices.container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
         self.voices.container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
      else
         --             print("container NOT first voice")
         -- other voices attach to last one
         self.voicescontainer:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
         self.voicescontainer:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
      end

      self.voices.icon:SetPoint("TOPLEFT",      self.voices.container, "TOPLEFT")

      -- Sub-Menu Icon
      if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then
         self.voices.smicon:SetPoint("CENTERLEFT", self.voices.text, "CENTERRIGHT")
      end

      if tbl.icon ~= nil then
         self.voices.text:SetPoint("TOPLEFT",   self.voices.icon, "TOPRIGHT", __menus.borders.l, 0)
      else
         self.voices.text:SetPoint("TOPLEFT",   self.voices.container, "TOPLEFT")
      end

      if self.voices.smicon and next(self.voices.smicon) then
         self.voices.smicon:SetPoint("CENTERLEFT", self.voices.container,  "CENTERRIGHT")
      else
         self.voices.text:SetPoint("TOPRIGHT",  self.voices.container, "TOPRIGHT")
      end

      if self.voices.icon ~= nil and next(self.voices.icon) then
         self.voices.container:SetHeight(self.voices.icon:GetHeight())
      else
         self.voices.container:SetHeight(self.voices.text:GetHeight())
      end

      lastvoiceframe                      =  self.voices.container

      ::continue::

   end


   for _, obj in ipairs(self.voicesuid] ~= nil) do  obj:SetWidth(self.maxwidth)   end
   end



   return self
end
