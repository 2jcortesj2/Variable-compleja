% Cadena de texto original
str = 'real(x^2*y*3i) - 3*real(x*y^2) + imag(y^3) + real(x^3)';

% Expresión regular para extraer las partes dentro de "real()" con signos y multiplicadores
pattern = '([^+^-]*)real\((.*?)\)';

% Buscar todas las coincidencias en la cadena de texto
matches = regexp(str, pattern, 'tokens');

% Concatenar las partes encontradas con signos y multiplicadores
result = '';
for i = 1:length(matches)
    match = matches{i};
    if numel(match) == 2
        pre_text = match{1};
        inner_text = match{2};
        result = [result pre_text 'real(' inner_text ') '];
    end
end

% Eliminar los espacios en blanco adicionales al inicio y al final
result = strtrim(result);

% Mostrar el resultado
disp(result);