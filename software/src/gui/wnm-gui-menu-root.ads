-------------------------------------------------------------------------------
--                                                                           --
--                              Wee Noise Maker                              --
--                                                                           --
--                  Copyright (C) 2016-2017 Fabien Chouteau                  --
--                                                                           --
--    Wee Noise Maker is free software: you can redistribute it and/or       --
--    modify it under the terms of the GNU General Public License as         --
--    published by the Free Software Foundation, either version 3 of the     --
--    License, or (at your option) any later version.                        --
--                                                                           --
--    Wee Noise Maker is distributed in the hope that it will be useful,     --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of         --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU       --
--    General Public License for more details.                               --
--                                                                           --
--    You should have received a copy of the GNU General Public License      --
--    along with We Noise Maker. If not, see <http://www.gnu.org/licenses/>. --
--                                                                           --
-------------------------------------------------------------------------------

package WNM.GUI.Menu.Root is

   procedure Push_Root_Window;

private

   type Menu_Items is (Create_Sample,
                       Change_Sample,
                       Test_Text_Input,
                       Load,
                       Save,
                       Settings,
                       Shutdown);

   type Root_Menu is new Menu_Window with record
      Item : Menu_Items;
   end record;

   overriding
   procedure Draw (This   : in out Root_Menu;
                   Screen : not null HAL.Bitmap.Any_Bitmap_Buffer);

   overriding
   procedure On_Event (This  : in out Root_Menu;
                       Event : Menu_Event);

   overriding
   procedure On_Pushed (This  : in out Root_Menu);

   overriding
   procedure On_Focus (This       : in out Root_Menu;
                       Exit_Value : Window_Exit_Value);

end WNM.GUI.Menu.Root;
