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

with WNM.Sample_Library; use WNM.Sample_Library;

package WNM.GUI.Menu.Create_Sample is

   procedure Push_Window;

private

   type Create_Sample_State is (Select_Source,
                                Rec_In_Progress,
                                Trim,
                                Enter_Name,
                                Assign_To_Track);

   type Create_Sample_Menu is new Menu_Window with record
      State        : Create_Sample_State;
      Sample_Entry : Sample_Entry_Index := Invalid_Sample_Entry;
   end record;

   overriding
   procedure Draw (This   : in out Create_Sample_Menu;
                   Screen : not null HAL.Bitmap.Any_Bitmap_Buffer)
   is null;

   overriding
   procedure On_Event (This  : in out Create_Sample_Menu;
                       Event : Menu_Event)
   is null;

   overriding
   procedure On_Pushed (This  : in out Create_Sample_Menu);

   overriding
   procedure On_Focus (This       : in out Create_Sample_Menu;
                       Exit_Value : Window_Exit_Value);

end WNM.GUI.Menu.Create_Sample;
