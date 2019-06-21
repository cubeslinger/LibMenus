--
-- Addon       LibMenus_init.lua
-- Author      marcob@marcob.org
-- StartDate   24/07/2018
--

--	local addon, LibMenus = ...

-- Main initialization code for the library.

if not Library then Library = {} end
if not Library.LibMenus then Library.LibMenus = {} end



Library.LibMenus.color     =  {  black       =  {  0,   0,   0,   1  },
											grey        =  { .5,  .5,  .5,   1  },
											yellow      =  { .8,  .8,   0,   1  },
											green       =  {  0,  .8,   0,   1  },
											red         =  {  1,   0,   0,   1  },
											green       =  {  0,   1,   0,   1  },
											deepblack   =  {  0,   0,   0,   1  },
											white       =  {  1,   1,   1,   1  },
										}

-- Left, Right, Top, Bottom
Library.LibMenus.borders	=  { l=4,
                                r=4,
                                t=4,
                                b=4 }

-- local print indented nested tables
   function dumptable(tbl, indent)

      if not indent then indent = 0 end

      for k, v in pairs(tbl) do

         formatting = string.rep("  ", indent) .. '[' .. k .. ']' .. ": "

         if type(v) == "table" then
            print(formatting)
            dumptable(v, indent+1)
         else
            if type(v) == "function" then
               print(formatting .. tostring(v))
            else
               print(formatting .. v)
            end
         end
      end
   end

--	functions
Library.LibMenus.f   			=  {}
Library.LibMenus.f.dumptable	=  dumptable
