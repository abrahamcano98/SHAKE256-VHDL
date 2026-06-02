library ieee;
use ieee.std_logic_1164.all;

use work.keccak_pkg.all;

entity rho_pi is
    port(
        input_state: in state_array_t;
        output_state: out state_array_t
    );
end rho_pi;

architecture behavioral of rho_pi is
begin
    process(input_state) is
    begin
        output_state(idx(0, 0)) <= input_state(idx(0, 0));
        output_state(idx(0, 2)) <= rotl64(input_state(idx(1, 0)), 1);
        output_state(idx(0, 4)) <= rotl64(input_state(idx(2, 0)), 62);
        output_state(idx(0, 1)) <= rotl64(input_state(idx(3, 0)), 28);
        output_state(idx(0, 3)) <= rotl64(input_state(idx(4, 0)), 27);

        output_state(idx(1, 3)) <= rotl64(input_state(idx(0, 1)), 36);
        output_state(idx(1, 0)) <= rotl64(input_state(idx(1, 1)), 44);
        output_state(idx(1, 2)) <= rotl64(input_state(idx(2, 1)), 6);
        output_state(idx(1, 4)) <= rotl64(input_state(idx(3, 1)), 55);
        output_state(idx(1, 1)) <= rotl64(input_state(idx(4, 1)), 20);

        output_state(idx(2, 1)) <= rotl64(input_state(idx(0, 2)), 3);
        output_state(idx(2, 3)) <= rotl64(input_state(idx(1, 2)), 10);
        output_state(idx(2, 0)) <= rotl64(input_state(idx(2, 2)), 43);
        output_state(idx(2, 2)) <= rotl64(input_state(idx(3, 2)), 25);
        output_state(idx(2, 4)) <= rotl64(input_state(idx(4, 2)), 39);

        output_state(idx(3, 4)) <= rotl64(input_state(idx(0, 3)), 41);
        output_state(idx(3, 1)) <= rotl64(input_state(idx(1, 3)), 45);
        output_state(idx(3, 3)) <= rotl64(input_state(idx(2, 3)), 15);
        output_state(idx(3, 0)) <= rotl64(input_state(idx(3, 3)), 21);
        output_state(idx(3, 2)) <= rotl64(input_state(idx(4, 3)), 8);

        output_state(idx(4, 2)) <= rotl64(input_state(idx(0, 4)), 18);
        output_state(idx(4, 4)) <= rotl64(input_state(idx(1, 4)), 2);
        output_state(idx(4, 1)) <= rotl64(input_state(idx(2, 4)), 61);
        output_state(idx(4, 3)) <= rotl64(input_state(idx(3, 4)), 56);
        output_state(idx(4, 0)) <= rotl64(input_state(idx(4, 4)), 14);
    end process;
end architecture behavioral;