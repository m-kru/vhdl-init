library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library linit;
   use linit.mif;

library ltypes;
   use ltypes.types;


entity tb_mif is
end entity;


architecture test of tb_mif is
begin

   main : process
      constant FILEPATH : string := "../../../mif/mem.mif";

      variable memory_bv : types.bitv_vector(0 to 7)(2 downto 0) := mif.read(FILEPATH);
      variable data_bv : bit_vector(2 downto 0);

      variable memory_slv : types.slv_vector(0 to 7)(2 downto 0) := mif.read(FILEPATH);
      variable data_slv : std_logic_vector(2 downto 0);
   begin
      report "Testing bit_vector functions";

      report "Testing whole content read";
      for i in memory_bv'range loop
         report to_string(memory_slv(i));
         assert memory_bv(i) = to_bitvector(std_logic_vector(to_unsigned(i, 3)));
      end loop;

      report "Testing particular address read";
      for i in 0 to 7 loop
         data_bv := mif.read(FILEPATH, i);
         report to_string(data_bv);
         assert data_bv = to_bitvector(std_logic_vector(to_unsigned(i, 3)));
      end loop;


      report "Testing std_logic_vector functions";

      report "Testing whole content read";
      for i in memory_slv'range loop
         report to_string(memory_slv(i));
         assert memory_slv(i) = std_logic_vector(to_unsigned(i, 3));
      end loop;

      report "Testing particular address read";
      for i in memory_slv'range loop
         data_slv := mif.read(FILEPATH, i);
         report to_string(data_slv);
         assert data_slv = std_logic_vector(to_unsigned(i, 3));
      end loop;

      -- Suppress GHDL no-wait warning.
      wait for 0 ns;
      std.env.finish;
   end process;

end architecture;
