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

generic
   type T is (<>);
   Wrap : Boolean := True;
package Enum_Next is
   function Next (Elt : T) return T with Inline_Always;
   --  Return the next value of type T, wraps to the first value of the type
   --  if Wrap is True.

   function Prev (Elt : T) return T with Inline_Always;
   --  Return the previous value of type T, wraps to the last value of the
   --  type if Wrap is True.

   procedure Next (Elt : in out T) with Inline_Always;
   procedure Prev (Elt : in out T) with Inline_Always;

   function Next_Fast (Elt : T) return T with Inline_Always;
   --  Same as Next but jumping over 10 values

   function Prev_Fast (Elt : T) return T with Inline_Always;
   --  Same as Prev but jumping over 10 values

   procedure Next_Fast (Elt : in out T) with Inline_Always;
   procedure Prev_Fast (Elt : in out T) with Inline_Always;
end Enum_Next;
