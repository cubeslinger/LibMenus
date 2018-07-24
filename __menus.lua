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
                  voices      =  {} -- menu voice objects
                  submenu     =  {} -- pointers to nested menus (_submenu_)
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

      local voiceid        =  0
      local lastvoiceframe =  self.o.menu

--       print("-------------------------------------------------")
--       print("t.voices is nil:\n", dumptable(t.voices)) print("\n")
--       print("-------------------------------------------------")

      self.voices[self.menuid]   =  __createvoices(t.voices)

--       local h = lastvoiceframe:GetBottom() - self.o.menu:GetTop()
--       self.o.menu:SetHeight(h + __menus.borders.t + __menus.borders.b)
--       self.o.menu:SetWidth(self.maxwidth + __menus.borders.l + __menus.borders.r)

      self.o.menu:SetVisible(false)

--       if self.o.sub and next(self.o.sub) then
--          for _, obj in ipairs(self.o.sub[self.menuid])   do obj:SetVisible(false)   end
--       end

--       if self.o.voices[self.menuid] ~= nil then
--          for _, obj in ipairs(self.o.voices[self.menuid] ~= nil) do  obj:SetWidth(self.maxwidth)   end
--       end

--       print(string.format("MAX WIDTH: (%s)", self.maxwidth))

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
