classdef Taller4_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ValentinaMarquezJuanJosCortsOmarAcevedoLabel  matlab.ui.control.Label
        Paneldeconfiguracin         matlab.ui.container.Panel
        DetalleFourierSliderLabel   matlab.ui.control.Label
        NmerosdetramosSpinner       matlab.ui.control.Spinner
        PeriodoEditField            matlab.ui.control.NumericEditField
        PeriodoEditFieldLabel       matlab.ui.control.Label
        NmerosdetramosSpinnerLabel  matlab.ui.control.Label
        TramoDropDown               matlab.ui.control.DropDown
        TramoDropDownLabel          matlab.ui.control.Label
        FuncionEditField            matlab.ui.control.EditField
        SalvarButton                matlab.ui.control.Button
        EditField                   matlab.ui.control.EditField
        DetalleFourierSlider        matlab.ui.control.Slider
        GraficarButton              matlab.ui.control.Button
        fxLabel                     matlab.ui.control.Label
        UIAxes                      matlab.ui.control.UIAxes
        UIAxesF                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        funcTramos % Celda que va a contener las funciones
        x % Para definir una "x" simbólica
        n % Para definir una "n" simbólica
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: NmerosdetramosSpinner
        function NmerosdetramosSpinnerValueChanged(app, event)
            % Menú dinámico entre "N de intervalos" y "Tramo"
            
            % Se toma el número de intervalos proporcionado por el usuario
            numIntervalos = app.NmerosdetramosSpinner.Value;
            
            % Se salvaguarda la opción de "Todos"
            fixed_op = {'Todos'};
            nuevas_op = {};
            
            % Realizamos una celda iterando los numeros en cada columna
            for i = 1:numIntervalos
                nuevas_op = [nuevas_op, num2str(i)];
            end
            
            % Unimos las opciones numéricas con la fija ("Todos")
            app.TramoDropDown.Items = [fixed_op, nuevas_op];

            % Se limpia la información correspondiente a  EditField si 
            % todos los tramos están definidos.
            app.EditField.Value = '';
        end

        % Button pushed function: SalvarButton
        function SalvarButtonPushed(app, event)
            
            % El objetivo de esta función es crear una celda que contenga
            % la información de las funciones en cada trozo.                    
            
            % Obtenemos la información de las celdas
            numIntervalos = app.NmerosdetramosSpinner.Value;
            numTramo = app.TramoDropDown.Value;
            funcTramo = app.FuncionEditField.Value;
            
            % Verificar si se trata de una función o un escalar
            if ~isnan(str2double(funcTramo))
                % Creamos la función de la forma 0*x + k
                f = @(x) 0*x + str2double(funcTramo);
            elseif isempty(funcTramo)
                % Creamos una función en 0 en caso de salvar vacío
                f = @(x) 0*x;
            else
                % Creamos la función con su variable anónima
                f = @(x) eval(funcTramo);
            end
            
            if numTramo == 'Todos'
                % Agregamos la misma función en las columnas de la celda.
                % Estas columnas son de la misma cantidad que los
                % intervalos
                for i=1:numIntervalos
                    app.funcTramos{i} = f;
                end
                
                % Borramos el espacio donde se ingresa la función
                app.FuncionEditField.Value = '';

                app.EditField.Value = 'Todos los tramos han sido salvados';

            else
                % Si se elige una opción numérica se guarda en la columna
                % seleccionada
                app.funcTramos{str2double(numTramo)} = f;
                
                try
                    % Con este try llamo todas las columnas, si una no
                    % existe da error
                    for i=1:numIntervalos
                        app.funcTramos{i};
                    end
                    app.EditField.Value = 'Todos los tramos han sido salvados';
                catch       
                    app.EditField.Value = 'Faltan tramos por definir';
                end

                % Borramos el espacio donde se ingresa la función
                app.FuncionEditField.Value = '';

                
            end
        end

        % Button pushed function: GraficarButton
        function GraficarButtonPushed(app, event)
            
            % Esta función está enfocada sobre las dos gráficas, la normal
            % a trozos y la representación en series finitas de la misma.
            % 
            % La primera parte se enfoca se enfoca en definir variables, la
            % segunda en graficar la función normal, y la tercera en
            % graficar la aproximación en series
            
            numIntervalos = app.NmerosdetramosSpinner.Value;
            limiteSumatoria = app.DetalleFourierSlider.Value;
            
            % Verificar si la celda no tiene espacios vacíos, esto en
            % general provoca error
            try
                % Llamo todas las funciones, si una no existe, da error
                for i=1:numIntervalos
                    app.funcTramos{i};
                end
                all_defined = true;
            catch
                all_defined = false;
                errordlg('Es necesario definir todos los tramos', 'Error');
            end

            % Define el rango del período
            inicioPeriodo = 0;
            finPeriodo = app.PeriodoEditField.Value;

            % Número de periodos a graficar
            numPeriodos = 4; 
        
            % Define las funciones         
            funciones = app.funcTramos;

            % Ejemplos de funciones
            
            % Calcula el ancho de cada división
            anchoDivision = (finPeriodo - inicioPeriodo) / numIntervalos;
        
            % Limpia el Axes antes de graficar
            cla(app.UIAxes);
            cla(app.UIAxesF);

            %------------------------------------------------------------%
            %                      GRÁFICA A TRAMOS                      %

            % Para resolver este problema hay que evitar volver a evaluar
            % la funcion otra vez, en su lugar vamos a desplazar en x el
            % resultado de y (Primer intervalo)

            % Itera sobre las funciones y gráfica en cada división
            if all_defined
                for periodo=1:numPeriodos
                    
                    % Desplazamiento del periodo
                    desplazamiento = (periodo - 1) * finPeriodo;
                
                    for i=1:numIntervalos
        
                        inicio = (i - 1) * anchoDivision;
                        fin = i * anchoDivision;
                        
                        x_division = linspace(inicio, fin, 100);
                        x_desplazado = linspace(inicio + desplazamiento, ...
                            fin + desplazamiento, 100);
        
                        y = funciones{i}(x_division);
        
                        plot(app.UIAxes, x_desplazado, y, "LineWidth", 2);
                        % Hold es para sobreponer gráficas
                        hold(app.UIAxes, 'on'); 
                    end
    
                end
            end
            hold(app.UIAxes, 'off');

            %------------------------------------------------------------%
            %                    APROXIMACIÓN EN SERIES                  %
            
            % Definimos x, n y w para trabajar simbólicamente
            app.x = sym('x');
            app.n = sym('n');
            w = (2*pi)/finPeriodo;


            
            % ----------------------------a0-----------------------------%
            % a0 = (2/T) * int(funcion, 0, T)
            %
            % Primero vamos a definir la integral, siendo 
            % a0i = int(funcion, 0, T)
            %
            % Después realizamos a0 = (2/T) * a0i
            if all_defined
                a0i = 0;
                tn = 0;
                for intervalo=1:numIntervalos  
                    tn1 = (intervalo) * (finPeriodo/numIntervalos);
                    a0i = a0i + int(funciones{intervalo}, app.x, tn, tn1);
                    tn = tn1;
                end
                a0 = (2/finPeriodo) * a0i;
            end



            % ----------------------------an-----------------------------%
            % an = (2/T) * int(funcion * cos(w*n*t), 0, T)
            % w = 2pi/T
            if all_defined
                ani = 0;
                tn = 0;
                for intervalo=1:numIntervalos  
                    tn1 = (intervalo) * (finPeriodo/numIntervalos);
                    ani = ani + int( ...
                        funciones{intervalo}*cos(w*app.n*app.x), ...
                        app.x, tn, tn1);
                    tn = tn1;
                end
                an = (2/finPeriodo) * ani;
            end



            % ----------------------------bn-----------------------------%
            % bn = (2/T) * int(funcion * sin(w*n*t), 0, T)
            % w = 2pi/T
            if all_defined
                bni = 0;
                tn = 0;
                for intervalo=1:numIntervalos  
                    tn1 = (intervalo) * (finPeriodo/numIntervalos);
                    bni = bni + int( ...
                        funciones{intervalo}*sin(w*app.n*app.x), ...
                        app.x, tn, tn1);
                    tn = tn1;
                end
                bn = (2/finPeriodo) * bni;
            end



            % --------------------------SERIE----------------------------%
            s=0;
            if all_defined
                for n=1:limiteSumatoria
                    an_eval = subs(an, 'n', n);
                    bn_eval = subs(bn, 'n', n);
                    s = s + an_eval*cos(w*n*app.x) + bn_eval*sin(w*n*app.x);
                end
                s = (1/2)*a0 + s;
            end
            

            
            % -----------------------GRÁFICA SERIE-----------------------%
            if all_defined
                x_division = linspace(inicioPeriodo, 4*finPeriodo, 100);
                s_values = double(subs(s, 'x', x_division));
                
                plot(app.UIAxesF, x_division, s_values, "LineWidth", 2);
                % Hold es para sobreponer gráficas
                hold(app.UIAxes, 'on'); 
            end
            hold(app.UIAxes, 'off');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 947 691];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesF
            app.UIAxesF = uiaxes(app.UIFigure);
            title(app.UIAxesF, 'Aproximación en serie de Fourier')
            xlabel(app.UIAxesF, 'X')
            ylabel(app.UIAxesF, 'Y')
            zlabel(app.UIAxesF, 'Z')
            app.UIAxesF.XGrid = 'on';
            app.UIAxesF.YGrid = 'on';
            app.UIAxesF.Position = [451 42 443 289];

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Función')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Position = [451 352 443 298];

            % Create Paneldeconfiguracin
            app.Paneldeconfiguracin = uipanel(app.UIFigure);
            app.Paneldeconfiguracin.TitlePosition = 'centertop';
            app.Paneldeconfiguracin.Title = 'Panel de configuración';
            app.Paneldeconfiguracin.FontWeight = 'bold';
            app.Paneldeconfiguracin.Position = [61 177 361 334];

            % Create fxLabel
            app.fxLabel = uilabel(app.Paneldeconfiguracin);
            app.fxLabel.HorizontalAlignment = 'right';
            app.fxLabel.Position = [80 167 29 22];
            app.fxLabel.Text = 'f(x)  ';

            % Create GraficarButton
            app.GraficarButton = uibutton(app.Paneldeconfiguracin, 'push');
            app.GraficarButton.ButtonPushedFcn = createCallbackFcn(app, @GraficarButtonPushed, true);
            app.GraficarButton.Position = [129 33 100 23];
            app.GraficarButton.Text = 'Graficar';

            % Create DetalleFourierSlider
            app.DetalleFourierSlider = uislider(app.Paneldeconfiguracin);
            app.DetalleFourierSlider.Limits = [10 100];
            app.DetalleFourierSlider.Position = [153 104 150 3];
            app.DetalleFourierSlider.Value = 10;

            % Create EditField
            app.EditField = uieditfield(app.Paneldeconfiguracin, 'text');
            app.EditField.Editable = 'off';
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontWeight = 'bold';
            app.EditField.FontColor = [0.149 0.149 0.149];
            app.EditField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.EditField.Position = [73 132 218 22];

            % Create SalvarButton
            app.SalvarButton = uibutton(app.Paneldeconfiguracin, 'push');
            app.SalvarButton.ButtonPushedFcn = createCallbackFcn(app, @SalvarButtonPushed, true);
            app.SalvarButton.Position = [235 167 47 23];
            app.SalvarButton.Text = 'Salvar';

            % Create FuncionEditField
            app.FuncionEditField = uieditfield(app.Paneldeconfiguracin, 'text');
            app.FuncionEditField.Position = [124 167 100 22];

            % Create TramoDropDownLabel
            app.TramoDropDownLabel = uilabel(app.Paneldeconfiguracin);
            app.TramoDropDownLabel.HorizontalAlignment = 'right';
            app.TramoDropDownLabel.Position = [137 202 39 22];
            app.TramoDropDownLabel.Text = 'Tramo';

            % Create TramoDropDown
            app.TramoDropDown = uidropdown(app.Paneldeconfiguracin);
            app.TramoDropDown.Items = {'Todos'};
            app.TramoDropDown.Position = [191 202 100 22];
            app.TramoDropDown.Value = 'Todos';

            % Create NmerosdetramosSpinnerLabel
            app.NmerosdetramosSpinnerLabel = uilabel(app.Paneldeconfiguracin);
            app.NmerosdetramosSpinnerLabel.HorizontalAlignment = 'right';
            app.NmerosdetramosSpinnerLabel.Position = [66 268 110 22];
            app.NmerosdetramosSpinnerLabel.Text = 'Números de tramos';

            % Create PeriodoEditFieldLabel
            app.PeriodoEditFieldLabel = uilabel(app.Paneldeconfiguracin);
            app.PeriodoEditFieldLabel.HorizontalAlignment = 'right';
            app.PeriodoEditFieldLabel.Position = [130 236 46 22];
            app.PeriodoEditFieldLabel.Text = 'Periodo';

            % Create PeriodoEditField
            app.PeriodoEditField = uieditfield(app.Paneldeconfiguracin, 'numeric');
            app.PeriodoEditField.Limits = [0 Inf];
            app.PeriodoEditField.Position = [191 236 100 22];
            app.PeriodoEditField.Value = 10;

            % Create NmerosdetramosSpinner
            app.NmerosdetramosSpinner = uispinner(app.Paneldeconfiguracin);
            app.NmerosdetramosSpinner.Limits = [1 Inf];
            app.NmerosdetramosSpinner.ValueChangedFcn = createCallbackFcn(app, @NmerosdetramosSpinnerValueChanged, true);
            app.NmerosdetramosSpinner.Position = [191 268 100 22];
            app.NmerosdetramosSpinner.Value = 1;

            % Create DetalleFourierSliderLabel
            app.DetalleFourierSliderLabel = uilabel(app.Paneldeconfiguracin);
            app.DetalleFourierSliderLabel.HorizontalAlignment = 'right';
            app.DetalleFourierSliderLabel.Position = [48 85 84 22];
            app.DetalleFourierSliderLabel.Text = 'Detalle Fourier';

            % Create ValentinaMarquezJuanJosCortsOmarAcevedoLabel
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel = uilabel(app.UIFigure);
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel.HorizontalAlignment = 'center';
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel.FontSize = 18;
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel.FontAngle = 'italic';
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel.Position = [164 102 154 66];
            app.ValentinaMarquezJuanJosCortsOmarAcevedoLabel.Text = {'Valentina Marquez'; 'Juan José Cortés'; 'Omar Acevedo'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Taller4_exported

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