syms x y; % Variables simbólicas

% Define la función compleja f(x, y)
f = x^2 + 2*x*y - y^2 + 3i*x - 4i*y;

% Halla las partes reales e imaginarias de la funcion
z = symfun(eval(f), x);
u = real(z);
v = imag(z);
function_parts = [u, v];
char(u)
disp(v)