library ieee;
   use ieee.std_logic_1164.all;

library std;
   use std.textio.all;

library ltypes;
   use ltypes.types;


-- Mif package provides functions for reading MIF (Memory Information File) files.
package mif is

   -- Read whole MIF file content.
   impure function read(filepath : string) return types.bitv_vector;
   -- Read data from particular address.
   impure function read(filepath : string; addr : natural) return bit_vector;

   -- Read whole MIF file content.
   impure function read(filepath : string) return types.slv_vector;
   -- Read data from particular address.
   impure function read(filepath : string; addr : natural) return std_logic_vector;

end package;


package body mif is

   type t_file_attributes is record
      line_count : natural;
      data_width : natural;
   end record;

   impure function get_file_attributes(filepath: string) return t_file_attributes is
      file f : text open read_mode is filepath;
      variable l : line;
      variable attr : t_file_attributes;
   begin
      while not endfile(f) loop
         readline(f, l);
         if attr.line_count = 0 then
            attr.data_width := l'length;
         else
            if l'length /= attr.data_width then
               report
                  filepath & ": line " & to_string(attr.line_count + 1) &
                     ": invalid data width " & to_string(l'length) & ", " &
                     "expected width " & to_string(attr.data_width)
                  severity failure;
            end if;
         end if;
         attr.line_count := attr.line_count + 1;
      end loop;
      return attr;
   end function;


   impure function read(filepath : string) return types.bitv_vector is
      variable attr : t_file_attributes := get_file_attributes(filepath);
      variable mem : types.bitv_vector(0 to attr.line_count - 1)(attr.data_width - 1 downto 0);
      variable bv : bit_vector(attr.data_width - 1 downto 0);
      variable l : line;
      file f : text open read_mode is filepath;
      variable ok : boolean;
   begin
      for i in 0 to attr.line_count - 1 loop
         readline(f, l);
         read(l, bv, ok);
         if ok = false then
            report
               filepath & ": line " & to_string(i + 1) & ": bit_vector read failure"
               severity failure;
         end if;
         mem(i) := bv;
      end loop;
      return mem;
   end function;


   impure function read(filepath : string; addr : natural) return bit_vector is
      variable attr : t_file_attributes := get_file_attributes(filepath);
      variable bv : bit_vector(attr.data_width - 1 downto 0);
      variable l : line;
      file f : text open read_mode is filepath;
      variable ok : boolean;
   begin
      if addr > attr.line_count - 1 then
         report
            "cannot read address " & to_string(addr) & " from " & filepath &
               " file, file has only " & to_string(attr.line_count - 1) & " addresses"
            severity failure;
      end if;

      for i in 0 to attr.line_count - 1 loop
         readline(f, l);
         if i = addr then
            read(l, bv, ok);
            if ok = false then
               report
                  filepath & ": line " & to_string(i + 1) & ": bit_vector read failure"
                  severity failure;
            end if;
         end if;
         exit when i = addr;
      end loop;
      return bv;
   end function;


   alias read_bvv is read[string return types.bitv_vector];
   alias read_bv  is read[string, natural return bit_vector];


   impure function read(filepath : string) return types.slv_vector is
   begin
      return types.to_slv_vector(read_bvv(filepath));
   end function;


   impure function read(filepath : string; addr : natural) return std_logic_vector is
   begin
      return to_std_logic_vector(read_bv(filepath, addr));
   end function;

end package body;
