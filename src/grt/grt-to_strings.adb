--  GHDL Run Time (GRT) -  'image subprograms.
--  Copyright (C) 2002 - 2014 Tristan Gingold
--
--  GHDL is free software; you can redistribute it and/or modify it under
--  the terms of the GNU General Public License as published by the Free
--  Software Foundation; either version 2, or (at your option) any later
--  version.
--
--  GHDL is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with GCC; see the file COPYING.  If not, write to the Free
--  Software Foundation, 59 Temple Place - Suite 330, Boston, MA
--  02111-1307, USA.
--
--  As a special exception, if other files instantiate generics from this
--  unit, or you link this unit with other files to produce an executable,
--  this unit does not by itself cause the resulting executable to be
--  covered by the GNU General Public License. This exception does not
--  however invalidate any other reasons why the executable file might be
--  covered by the GNU Public License.

with Interfaces;
with Grt.Fcvt;

package body Grt.To_Strings is
   generic
      type Ntype is range <>;
      --Max_Len : Natural;
   procedure Gen_To_String (Str : out String; First : out Natural; N : Ntype);

   procedure Gen_To_String (Str : out String; First : out Natural; N : Ntype)
   is
      subtype R_Type is String (1 .. Str'Length);
      S : R_Type renames Str;
      P : Natural := S'Last;
      V : Ntype;
   begin
      if N > 0 then
         V := -N;
      else
         V := N;
      end if;
      loop
         S (P) := Character'Val (48 - (V rem 10));
         V := V / 10;
         exit when V = 0;
         P := P - 1;
      end loop;
      if N < 0 then
         P := P - 1;
         S (P) := '-';
      end if;
      First := P;
   end Gen_To_String;

   procedure To_String_I32 is new Gen_To_String (Ntype => Ghdl_I32);

   procedure To_String (Str : out String; First : out Natural; N : Ghdl_I32)
     renames To_String_I32;

   procedure To_String_I64 is new Gen_To_String (Ntype => Ghdl_I64);

   procedure To_String (Str : out String; First : out Natural; N : Ghdl_I64)
     renames To_String_I64;

   procedure To_String (Str : out String; Last : out Natural; N : Ghdl_F64) is
   begin
      Grt.Fcvt.Format_Image (Str, Last, Interfaces.IEEE_Float_64 (N));
   end To_String;

   procedure To_String (Str : out String;
                        Last : out Natural;
                        N : Ghdl_F64;
                        Nbr_Digits : Ghdl_I32) is
   begin
      Grt.Fcvt.Format_Digits
        (Str, Last, Interfaces.IEEE_Float_64 (N), Natural (Nbr_Digits));
   end To_String;

   procedure To_String (Str : out String_Real_Format;
                        Last : out Natural;
                        N : Ghdl_F64;
                        Format : Ghdl_C_String)
   is
      procedure Snprintf_Fmtf (Str : in out String;
                               Len : Natural;
                               Format : Ghdl_C_String;
                               V : Ghdl_F64);
      pragma Import (C, Snprintf_Fmtf, "__ghdl_snprintf_fmtf");
   begin
      --  FIXME: check format ('%', f/g/e/a)
      Snprintf_Fmtf (Str, Str'Length, Format, N);
      Last := strlen (To_Ghdl_C_String (Str'Address));
   end To_String;

   procedure To_String (Str : out String_Time_Unit;
                        First : out Natural;
                        Value : Ghdl_I64;
                        Unit : Ghdl_I64)
   is
      V, U : Ghdl_I64;
      D : Natural;
      P : Natural := Str'Last;
      Has_Digits : Boolean;
   begin
      --  Always work on negative values.
      if Value > 0 then
         V := -Value;
      else
         V := Value;
      end if;

      Has_Digits := False;
      U := Unit;
      loop
         if U = 1 then
            if Has_Digits then
               Str (P) := '.';
               P := P - 1;
            else
               Has_Digits := True;
            end if;
         end if;

         D := Natural (-(V rem 10));
         if D /= 0 or else Has_Digits then
            Str (P) := Character'Val (48 + D);
            P := P - 1;
            Has_Digits := True;
         end if;
         U := U / 10;
         V := V / 10;
         exit when V = 0 and then U = 0;
      end loop;
      if not Has_Digits then
         Str (P) := '0';
      else
         P := P + 1;
      end if;
      if Value < 0 then
         P := P - 1;
         Str (P) := '-';
      end if;
      First := P;
   end To_String;
end Grt.To_Strings;
