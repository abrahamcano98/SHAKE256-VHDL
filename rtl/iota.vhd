library ieee;
use ieee.std_logic_1164.all;

entity iota is
    port(
        input_s0: in std_logic_vector(63 downto 0);
        round_constant: in std_logic_vector(63 downto 0);
        output_s0: out std_logic_vector(63 downto 0)
    );
end iota;

architecture behavioral of iota is
begin
    output_s0 <= input_s0 xor round_constant;
end architecture behavioral;


