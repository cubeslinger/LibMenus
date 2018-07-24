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

function __createvoice(parent, t)
   -- the new instance
   local self =   {
                  initialized =  false
                  voices      =  {}
                  maxwidth    =  0
                  voiceid     =  0
                  }



   local function createobjs(parent, t)

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
      end

      o.text	=  UI.CreateFrame("Text", "voice_" .. self.voiceid .. "_text", parent)                       -- Voice Text
      o.text:SetFontSize(fs)
      o.text:SetText(tbl.name)
      o.text:SetBackgroundColor(unpack(__menus.color.black))
      o.text:SetLayer(100)


      if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then
         o.smicon  =  UI.CreateFrame("Texture", "voice_" .. self.voiceid .. "_smicon", parent)                 -- Voice Sub-menu Icon
         o.smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
         o.smicon:SetHeight(fs)
         o.smicon:SetWidth(fs)
         o.smicon:SetLayer(100)
         o.smicon:SetBackgroundColor(unpack(__menus.color.black))
      end










      return o
   end


   for _, tbl in pairs(t.voices) do

      self.maxwidth  =  0

      if tbl["name"] == nil then goto continue  end

      --          print(string.format("\nNAME: %s", tbl.name))
      --          print(string.format("CALL: %s\n", tbl.callback))

      self.voiceid  =  self.voiceid + 1

      self.voices[self.menuid]   =  createobjs(lastvoiceframe, tbl)

--       local container    =  UI.CreateFrame("Frame", "menu_container_" .. self.menuid .. "_" .. "_submenuid_".. (tostring(self.submenuid) or "0") .. parent:GetName(), lastvoiceframe)
--       container:SetLayer(90)
--       container:SetBackgroundColor(unpack(__menus.color.deepblack))
      if voiceid == 1 then
         --             print("container first voice")
         -- first voice attaches to framecontainer with border spaces
         container:SetPoint("TOPLEFT",   lastvoiceframe, "TOPLEFT",     __menus.borders.l, __menus.borders.t)
         container:SetPoint("TOPRIGHT",  lastvoiceframe, "TOPRIGHT",    -__menus.borders.r, __menus.borders.t)
      else
         --             print("container NOT first voice")
         -- other voices attach to last one
         container:SetPoint("TOPLEFT",   lastvoiceframe, "BOTTOMLEFT",  0, __menus.borders.t)
         container:SetPoint("TOPRIGHT",  lastvoiceframe, "BOTTOMRIGHT", 0, __menus.borders.t)
      end

      local icon  =  {}
      if tbl.icon ~= nil then
         icon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
         icon:SetTexture("Rift", tbl.icon)
         icon:SetHeight(fs * 1.5)
         icon:SetWidth(fs * 1.5)
         icon:SetLayer(100)
         icon:SetBackgroundColor(unpack(__menus.color.black))
         icon:SetPoint("TOPLEFT",      container, "TOPLEFT")
         if self.maxwidth < (icon:GetWidth() + __menus.borders.l) then self.maxwidth  =  (icon:GetWidth() + __menus.borders.l)  end
         print(string.format("    max width: (%s) - %s (icon)", self.maxwidth, tbl.name))
      end

--       local v  =  UI.CreateFrame("Text", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid, lastvoiceframe)
--       v:SetFontSize(fs)
--       v:SetText(tbl.name)
--       v:SetBackgroundColor(unpack(__menus.color.black))
--       v:SetLayer(100)
      local w = self.maxwidth + v:GetWidth()
      if self.maxwidth < w then self.maxwidth  =  w end
      print(string.format("    max width: (%s) - %s (v)", self.maxwidth, tbl.name))

      -- Sub-Menu Icon
      if type(tbl.callback) == 'string' and tbl.callback == "_submenu_" then

--          local smicon  =  {}
--          smicon  =  UI.CreateFrame("Texture", "menu_" .. self.menuid  .. "_submenuid_".. (tostring(self.submenuid) or "0") .. "_voice_" .. voiceid .. "_icon", lastvoiceframe)
--          smicon:SetTexture("Rift", "btn_arrow_R_(normal).png.dds")
--          smicon:SetHeight(fs)
--          smicon:SetWidth(fs)
--          smicon:SetLayer(100)
--          smicon:SetBackgroundColor(unpack(__menus.color.black))
         smicon:SetPoint("CENTERLEFT", v,          "CENTERRIGHT")

         local w = self.maxwidth + smicon:GetWidth() + __menus.borders.l
         if self.maxwidth < w then self.maxwidth  =  w end
         print(string.format("    max width: (%s) - %s (smicon)", self.maxwidth, tbl.name))
      end

      if tbl.icon ~= nil then
         v:SetPoint("TOPLEFT",   icon,       "TOPRIGHT", __menus.borders.l, 0)
      else
         v:SetPoint("TOPLEFT",   container, "TOPLEFT")
      end

      if smicon and next(smicon) then
         smicon:SetPoint("CENTERLEFT", container,  "CENTERRIGHT")
      else
         v:SetPoint("TOPRIGHT",  container, "TOPRIGHT")
      end

      if tbl.callback ~= nil then
         if type(tbl.callback) == 'string' then
            if tbl.callback == "_submenu_" then

               self.submenuid  =  self.submenuid  + 1

               local tt = new(v, tbl.submenu, {menuid=self.menuid, submenuid=self.submenuid})

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
      v:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() v:SetBackgroundColor(unpack(__menus.color.grey))  end, "__mouse: highlight voice menu ON")
      v:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() v:SetBackgroundColor(unpack(__menus.color.black)) end, "__mouse: highlight voice menu OFF")

      if icon ~= nil and next(icon) then  container:SetHeight(icon:GetHeight())
      else                                container:SetHeight(v:GetHeight())
      end

      if self.o.voices[self.menuid] == nil then self.o.voices[self.menuid] =  {} end
      self.o.voices[self.menuid][voiceid] =  container
      lastvoiceframe                      =  container

      --          lastvoiceframe:SetWidth(self.maxwidth + __menus.borders.l + __menus.borders.r)
      --          print(string.format("  max width: (%s) - (lastvoiceframe)", self.maxwidth))

      ::continue::

   end

   return
end
