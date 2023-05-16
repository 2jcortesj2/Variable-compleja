classdef Taller2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        CompletarButton    matlab.ui.control.Button
        Real               matlab.ui.control.EditField
        uLabel             matlab.ui.control.Label
        Nombres            matlab.ui.control.Label
        Punto3             matlab.ui.control.Label
        Punto2             matlab.ui.control.Label
        Punto1             matlab.ui.control.Label
        VerificarButton    matlab.ui.control.Button
        f_z                matlab.ui.control.EditField
        fzLabel            matlab.ui.control.Label
        Imag               matlab.ui.control.EditField
        vLabel             matlab.ui.control.Label
        harmoniccheckText  matlab.ui.control.EditField
        Input_f            matlab.ui.control.EditField
        fLabel             matlab.ui.control.Label
    end

    % Funciones variable compleja
    methods (Access = private)
            
        function is_harmonic = check_harmonic(app, f)
            syms x y;
            % Calcula las segundas derivadas parciales de f 
            % con respecto a x e y
            d2f_dx2 = diff(f, x, 2);
            d2f_dy2 = diff(f, y, 2);
            
            % Verifica si la función es armónica 
            % (comprueba si las segundas derivadas parciales suman cero)
            is_harmonic = simplify(d2f_dx2 + d2f_dy2) == 0;
        end

        function fz = get_f_z(app, f)
            syms x y z
            % Si f (x, y) es analítica, 
            % 
            % se tiene que al sustituir en 
            % f (x, y) la x = z y y = 0, entonces la función es 
            % f (x, y) = f (z)
            % 
            % Además se tiene que al sustituir
            % f (x, y) la x = 0 y y = zi, entonces la función es 
            % f (x, y) = f (z)
            try
                % Este try lo cree para evitar el error de división por
                % cero que se genera en algunos casos particulares.
                fz = subs(f, [x, y], [z, 0]);
            catch
                fz = subs(f, [x, y], [0, z*1i]);
            end
        end

        function conj_harm = conjugado_harm(app, f, part)
            % Obtiene las variables simbólicas de f
            sym_vars = symvar(f);
            x = sym('x');
            y = sym('y');
            
            % f puede ser tanto v(x,y) como u(x,y)
            if strcmp(part, 'Real')
                firts_int = int(diff(f, x), y);
                conj_harm = firts_int - (diff(firts_int, x) + diff(f, y));
            
            elseif strcmp(part, 'Imag')
                firts_int = int(diff(f, y), x);
                conj_harm = firts_int - (diff(firts_int, y) + diff(f, x));
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: VerificarButton
        function VerificarButtonPushed(app, event)
            % Obtener la función de la celda input
            f = str2sym(app.Input_f.Value);
            % x^3 - 3*x*y^2 + i*3*y*x^2 - i*y^3

            % Chequear que la funcion es harmónica
            is_harmonic = app.check_harmonic(f);

            % Hallar f(z)
            fz = app.get_f_z(f);

            % Mostrar resultados en la caja de texto
            if is_harmonic  
                app.harmoniccheckText.Value = 'La función es armónica';
                app.f_z.Value = char(simplify(fz));

            else
                app.harmoniccheckText.Value = 'La función NO es armónica';
                app.Real.Value = '';
                app.Imag.Value = '';
                app.f_z.Value = '';
            end
            
        end

        % Button pushed function: CompletarButton
        function CompletarButtonPushed(app, event)
            % Obtenemos u, v de las celdas
            u = str2sym(app.Real.Value);
            v = str2sym(app.Imag.Value);
            
            % Verificamos si son armónicas
            is_harmonic_u = app.check_harmonic(u);
            is_harmonic_v = app.check_harmonic(v);

            if isempty(app.Imag.Value) && is_harmonic_u
                % Comprobamos que la celda de v esté vacía
                conj_harm = app.conjugado_harm(u, 'Real');
                app.Imag.Value = char(conj_harm);

                app.Input_f.Value = '';
                app.harmoniccheckText.Value = '';
                app.f_z.Value = '';

            elseif isempty(app.Real.Value) && is_harmonic_v
                % Comprobamos que la celda de u esté vacía
                conj_harm = app.conjugado_harm(v, 'Imag');
                app.Real.Value = char(conj_harm);

                app.Input_f.Value = '';
                app.harmoniccheckText.Value = '';
                app.f_z.Value = '';
            
            elseif ~is_harmonic_u || ~is_harmonic_v
                % Si las funciones no son armónicas sale una pantalla
                % emergente para avisar.
                errordlg('La función ingresada NO es armónica', 'Error');
                
            else
                % Comprobamos que una de las celdas esté vacía
                % (Sale una pantalla emergente)
                errordlg('Una de las celdas debe estar vacía', 'Error');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 638 534];
            app.UIFigure.Name = 'MATLAB App';

            % Create fLabel
            app.fLabel = uilabel(app.UIFigure);
            app.fLabel.HorizontalAlignment = 'right';
            app.fLabel.Position = [239 352 52 22];
            app.fLabel.Text = 'f (x,y)   =';

            % Create Input_f
            app.Input_f = uieditfield(app.UIFigure, 'text');
            app.Input_f.Position = [306 352 100 22];

            % Create harmoniccheckText
            app.harmoniccheckText = uieditfield(app.UIFigure, 'text');
            app.harmoniccheckText.Editable = 'off';
            app.harmoniccheckText.HorizontalAlignment = 'center';
            app.harmoniccheckText.FontWeight = 'bold';
            app.harmoniccheckText.BackgroundColor = [0.9412 0.9412 0.9412];
            app.harmoniccheckText.Position = [232 270 182 22];

            % Create vLabel
            app.vLabel = uilabel(app.UIFigure);
            app.vLabel.HorizontalAlignment = 'right';
            app.vLabel.Position = [273 166 48 22];
            app.vLabel.Text = 'v(x,y)  =';

            % Create Imag
            app.Imag = uieditfield(app.UIFigure, 'text');
            app.Imag.Position = [336 166 100 22];

            % Create fzLabel
            app.fzLabel = uilabel(app.UIFigure);
            app.fzLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.fzLabel.HorizontalAlignment = 'right';
            app.fzLabel.FontColor = [0.149 0.149 0.149];
            app.fzLabel.Position = [183 71 36 22];
            app.fzLabel.Text = 'f(z)  =';

            % Create f_z
            app.f_z = uieditfield(app.UIFigure, 'text');
            app.f_z.Editable = 'off';
            app.f_z.FontColor = [0.149 0.149 0.149];
            app.f_z.BackgroundColor = [0.9412 0.9412 0.9412];
            app.f_z.Position = [234 71 254 22];

            % Create VerificarButton
            app.VerificarButton = uibutton(app.UIFigure, 'push');
            app.VerificarButton.ButtonPushedFcn = createCallbackFcn(app, @VerificarButtonPushed, true);
            app.VerificarButton.Position = [273 312 100 23];
            app.VerificarButton.Text = 'Verificar';

            % Create Punto1
            app.Punto1 = uilabel(app.UIFigure);
            app.Punto1.WordWrap = 'on';
            app.Punto1.Position = [60 388 523 47];
            app.Punto1.Text = 'Construir una interfaz gráfica que reciba una función armónica o no y que sistema defina si la función es o no armónica y que en caso de que sea armónica muestre que la función es armónica.';

            % Create Punto2
            app.Punto2 = uilabel(app.UIFigure);
            app.Punto2.WordWrap = 'on';
            app.Punto2.Position = [61 203 523 32];
            app.Punto2.Text = 'Además esta función armónica puede ser u o v. Si se ingresa a u y ella es armónica, el programa debe mostrar a v y viceversa.';

            % Create Punto3
            app.Punto3 = uilabel(app.UIFigure);
            app.Punto3.WordWrap = 'on';
            app.Punto3.Position = [61 116 523 15];
            app.Punto3.Text = 'Además el programa debe mostrar a f(z) en caso de que la función sea armónica.';

            % Create Nombres
            app.Nombres = uilabel(app.UIFigure);
            app.Nombres.HorizontalAlignment = 'center';
            app.Nombres.WordWrap = 'on';
            app.Nombres.FontWeight = 'bold';
            app.Nombres.Position = [60 456 523 47];
            app.Nombres.Text = {'JUAN JOSÉ CORTÉS'; 'VALENTINA MARQUEZ'; 'OMAR SANTIAGO ACEVEDO'};

            % Create uLabel
            app.uLabel = uilabel(app.UIFigure);
            app.uLabel.HorizontalAlignment = 'right';
            app.uLabel.Position = [85 165 49 22];
            app.uLabel.Text = 'u(x,y)  =';

            % Create Real
            app.Real = uieditfield(app.UIFigure, 'text');
            app.Real.Position = [149 165 100 22];

            % Create CompletarButton
            app.CompletarButton = uibutton(app.UIFigure, 'push');
            app.CompletarButton.ButtonPushedFcn = createCallbackFcn(app, @CompletarButtonPushed, true);
            app.CompletarButton.Position = [480 165 100 23];
            app.CompletarButton.Text = 'Completar';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Taller2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end