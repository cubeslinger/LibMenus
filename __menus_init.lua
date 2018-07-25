--
-- Addon       __menus_init.lua
-- Author      marcob@marcob.org
-- StartDate   24/07/2018
--
local addon, __menus = ...

__menus.color     =  {  black       =  {  0,   0,   0,   1  },
                        grey        =  { .5,  .5,  .5,   1  },
                        yellow      =  { .8,  .8,   0,   1  },
                        green       =  {  0,  .8,   0,   1  },
                        red         =  {  1,   0,   0,   1  },
                        green       =  {  0,   1,   0,   1  },
                        deepblack   =  {  0,   0,   0,   1  },
                        white       =  {  1,   1,   1,   1  },
                     }

-- Left, Right, Top, Bottom
__menus.borders	=  { l=4, r=4, t=4, b=4 }

-- local print nested tables
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

__menus.f   =  {}
__menus.f.dumptable  =  dumptable


