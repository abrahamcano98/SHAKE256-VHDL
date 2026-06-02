library ieee;
use ieee.std_logic_1164.all;

use work.keccak_pkg.all;

entity chi is
    port(
        input_state: in state_array_t;
        output_state: out state_array_t
    );
end chi;

architecture behavioral of chi is
    begin 
    process(input_state) is
    begin
        for y in 0 to 4 loop
            for x in 0 to 4 loop
                output_state(idx(x, y)) <= input_state(idx(x, y)) xor ((not input_state(idx((x + 1) mod 5, y))) and input_state(idx((x + 2) mod 5, y)));
            end loop;
        end loop;
    end process;
end architecture behavioral;
