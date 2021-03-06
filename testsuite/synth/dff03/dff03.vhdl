library ieee;
use ieee.std_logic_1164.all;

entity dff03 is
  port (q : out std_logic;
        d : std_logic;
        en1 : std_logic;
        en2 : std_logic;
        clk : std_logic);
end dff03;

architecture behav of dff03 is
begin
  process (clk) is
  begin
    if (rising_edge (clk) and en1 = '1') and en2 = '1' then
      q <= d;
    end if;
  end process;
end behav;
