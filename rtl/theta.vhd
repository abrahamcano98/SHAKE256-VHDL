library ieee;
use ieee.std_logic_1164.all;

use work.keccak_pkg.all;

entity theta is
    port(
        input_state: in state_array_t;
        output_state: out state_array_t
    );
end theta;

architecture behavioral of theta is
    signal C: plane_array_t;
    signal D: plane_array_t;

begin
    compute_C: process(input_state) is
    begin
        for x in 0 to 4 loop
            C(x) <= input_state(idx(x, 0)) xor input_state(idx(x, 1)) xor input_state(idx(x, 2)) xor input_state(idx(x, 3)) xor input_state(idx(x, 4));
        end loop;
    end process compute_C;

    compute_D: process(C) is
    begin
        for x in 0 to 4 loop
            D(x) <= C((x + 4) mod 5) xor rotl64(C((x + 1) mod 5), 1);
        end loop;
    end process compute_D;

    compute_output: process(input_state, D) is
    begin
        for y in 0 to 4 loop
            for x in 0 to 4 loop
                output_state(idx(x, y)) <= input_state(idx(x, y)) xor D(x);
            end loop;
        end loop;
    end process compute_output;

end architecture behavioral;