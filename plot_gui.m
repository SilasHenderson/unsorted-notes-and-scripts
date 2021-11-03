function plot_gui
    
    % ------------------- Gui Layout ------------------------
    
    % Figure Window and Callbacks
    fig = figure( ...
        'color', 'white', ...
        'menubar', 'none', ...
        'name', 'plot gui', ...
        'numbertitle',  'off', ...
        'interruptible', 'on', ...
        'windowkeypressfcn', @key_down, ...
        'windowkeyreleasefcn', @key_up, ...
        'closerequestfcn', @close_fcn);
   
    % Visible Gui Elements
    top_panel = annotation('rectangle', ...
        'units', 'normalized', ...
        'position', [0, .9, 1, .1], ...
        'facecolor', [.2, .2, .2]);
    
    options_btn = uicontrol( 'style', 'pushbutton', ...
        'units', 'normalized', ...
        'position', [.01, .91, .13, .08], ...
        'backgroundcolor', [.3,.3,.3], ...
        'foregroundcolor', [1 1 1], ...
        'fontsize', 12, ...
        'fontweight', 'bold',...
        'fontname',  'arial', ...
        'string', 'options', ...
        'callback', @options_on_off);
  
    plot_btn = uicontrol( 'style', 'pushbutton', ...
        'units', 'normalized', ...
        'position',  [.15, .91, .09, .08], ...
        'backgroundcolor', [.2 .3 .4], ...
        'foregroundcolor', [1 1 1], ...
        'fontsize', 12, ...
        'fontweight', 'bold',...
        'fontname',  'arial', ...
        'string', 'plot', ... 
        'callback', @plot_init);
      
    fn_textedit = uicontrol( 'style', 'edit', ...
        'units', 'normalized', ...
        'position',  [0.25, 0.91, 0.55, 0.08], ...
        'fontsize', 14, ...
        'string', 'cos(2*x) + cos(2*y*t)');
    
    time_textbox = annotation('textbox', ...
        'position', [.82, .9,.1,.1], ...
        'edgecolor', 'none', ....
        'color', [.9, .9, .9], ...
        'fontsize', 14, ...
        'string', ' ', ...
        'horizontalalignment', 'left', ...
        'verticalalignment', 'middle');
    
    % Toggleable Gui Elements
    info_textbox = annotation('textbox', ...
        'position', [.45, 0,.55,.9], ...
        'edgecolor', 'none', ....
        'fontsize', 14, ...
        'interpreter', 'latex', ...
        'visible', 'off', ...
        'string', ...
            {' move, turn, pause';
             ' . e . . . . i . .';
             ' s d f g h j k l enter';});        
          
    options_textedit = uicontrol( 'style', 'edit', ...
        'units', 'normalized', ...
        'position', [0, 0, .45, .9], ...
        'fontsize', 12, ...
        'horizontalalignment', 'left', ...
        'visible', 'off', ...
        'max', 30, ...
        'backgroundcolor', [1,1,1], ...
        'string', char({...
            '% Surface ';
            'xlims = [0, 10];';
            'ylims = [0, 10];';
            'color = [.8, .8, 1];';         
            ' ';
            '% Time ';
            't0 =  0;';
            'dt = .02;';
            'T  = 1;'}));
     
     % ------------------------- Graphics ---------------------------
     
     % Axes with Projection Camera
     ax = axes( ...
        'units', 'normalized', ...
        'position', [0,0,1,1], ...
        'color', [.9, .9, .9], ...
        'projection', 'perspective', ...
        'cameraviewangle', 30, ...
        'dataaspectratio', [1,1,1], ...
        'interruptible', 'on', ...
        'xgrid', 'on', 'ygrid', 'on', 'zgrid', 'on', ...
        'ticklabelinterpreter', 'latex', ...
        'ticklen', [0,0], 'box', 'on');
      
    % Latex Axes Labels
    set(ax.XLabel, 'interpreter','latex', 'string','X', 'color',[ 0, 0,.2]);
    set(ax.YLabel, 'interpreter','latex', 'string','Y', 'color',[ 0,.2, 0]);
    set(ax.ZLabel, 'interpreter','latex', 'string','Z', 'color',[.2, 0, 0], ...
        'rotation', 0);
      
    % Lights
    light('style', 'infinite');
    light('style', 'local', 'position', [5,5,10]);
     
    % Surface data and Graphics Object
    surf_grid_dens = 100; 
       
    surf_x = linspace(0, 10, surf_grid_dens);
    surf_y = linspace(0, 10, surf_grid_dens);
    surf_z = zeros(surf_grid_dens, surf_grid_dens);
       
    surf_obj = surface( 'edgecolor', 'none', 'facelighting', 'gouraud');
    
    % Camera Options
    cam_turn_speed = .005;     
    cam_move_speed = .2;
    
    % Camera Position, Angles
    cam_pos = [-15, -2, 12];
    cam_el  = -.53;       
    cam_az  =  .4;
        
    % Camera Move,Turn Velocity
    cam_el_vel   = 0;           
    cam_az_vel   = 0;
    cam_up_vel   = 0;
    cam_fwd_vel  = 0;
    cam_side_vel = 0;
      
    % ------------------- Options Variables ----------------------- 
    
    % Surface Limits
    xlims   = [];              
    ylims   = [];
    
    % Surface Color and transparency
    color   = [];           
 
    % Plot params for t = t0:dt:T
    t0 = [];              
    dt = [];               
    T  = [];
    
    % Camera speed
    pause_t = [];         
    move_v  = [];              
    turn_v  = [];
        
    % ---------------------- Main ---------------------------
    
    % Gui Variables
    t          = 0;
    plot_func  = '';
    loop_on    = true;
    options_on = false;
    
    % Init Axes and Surface
    cam_update;  
    plot_init;
    
    % Main Program Loop 
    while loop_on
        
        cam_update;
        
        % Update Plot if active t
        if t < T
            t = t + dt;  
            time_textbox.String = sprintf('t = %4.2f', t);
            surf_update;
        end
        
        % Draw
        pause(pause_t);
    end 
       
    % ------------------------ Plot Init Fn --------------------
    function plot_init(~,~)
  
        % Evaluate options
        txt = options_textedit.String;
        dim = size(txt,1);
        for i = 1:dim
            eval(txt(i,:));
        end
        
        % Prepare Options
        ax.XLim = xlims;
        ax.YLim = ylims;
              
        surf_obj.FaceColor = color;
        surf_obj.FaceAlpha = 1;
        surf_obj.EdgeAlpha = 0;
                 
        % Get Plot Function
        func_string = fn_textedit.String;
        if isempty(func_string)
            func_string = '0';
        end
        plot_func = str2func(strcat('@(x,y,t) ', func_string));     
        
        % Handle Static/Dynamic Plot
        if any(func_string == 't') == 0
            t = T;
            time_textbox.String = ' ';
        else
            t = t0;
        end
        
        % Generate X,Y,Z arrays                     
        surf_x = linspace(xlims(1), xlims(2), density);
        surf_y = linspace(ylims(1), ylims(2), density);
        surf_z = zeros( density, density);
          
        % Init Surface Buffers, Update
        surf_obj.XData = surf_x;
        surf_obj.YData = surf_y;
        surf_obj.ZData = zeros( density, density); 
        
        surf_update;
    end

    % --------------------- Surface Update Fn -----------------
    function surf_update
        
        % Run z = f(x,y,t)
        for I = 1:surf_grid_dens
            for J = 1:surf_grid_dens
                
                x = surf_x(J);
                y = surf_y(I);
                z = plot_func(x,y,t);
                
                surf_z(I,J) = z;
            end
        end  
        
        % Update Surface
        surf_obj.ZData = surf_z;           
    end
    % -------------------- Camera Update Function ---------------
    function cam_update
        
        % Time-step for elevation and azimuth
        cam_el = cam_el + cam_el_vel;
        cam_az = cam_az + cam_az_vel;
        
        % Time-step for position
        cam_pos = cam_pos + ...
            cam_up_vel*[0,0,1] + ...
            cam_fwd_vel*unit_vec(cam_el, cam_az) + ...
            cam_side_vel*unit_vec( 0, cam_az + pi/2);
        
        % Update axes camera
        ax.CameraPosition = cam_pos;
        ax.CameraTarget   = cam_pos + unit_vec(cam_el, cam_az);
    end

    % ---------------------- Unit Vec Function ------------------
    function u = unit_vec(el,az)
        u = [ ...
            cos(el)*cos(az), ...
            cos(el)*sin(az), ...
            sin(el)];
    end

    % ----------------- Options Toggle Function --------------------
    function options_on_off(~,~)
        
        if options_on == false
            options_on = true;
            info_textbox.Visible     = 'on';
            options_textedit.Visible = 'on';
            ax.Position = [.6,0,.3,1];
        else
            options_on = false;
            info_textbox.Visible     = 'off';
            options_textedit.Visible = 'off'; 
            ax.Position = [0,0,1,1];
        end
        pause(.001);
    end
    
    % --------------------- Keyboard Callbacks ---------------------
    function key_down(~,e)
        switch e.Key
            case 'e', cam_fwd_vel  =   cam_move_speed;
            case 'd', cam_fwd_vel  = - cam_move_speed;
            case 's', cam_side_vel =   cam_move_speed;
            case 'f', cam_side_vel = - cam_move_speed;
            case 'i', cam_el_vel   =   cam_turn_speed/2;
            case 'k', cam_el_vel   = - cam_turn_speed/2;
            case 'j', cam_az_vel   =   cam_turn_speed;
            case 'l', cam_az_vel   = - cam_turn_speed;
            case 'h', cam_up_vel   =   cam_move_speed;
            case 'g', cam_up_vel   = - cam_move_speed;   
            
            case 'return', t = T;
        end
    end

    function key_up(~,~)
        cam_fwd_vel  = 0;
        cam_side_vel = 0;
        cam_el_vel   = 0;
        cam_az_vel   = 0;            
        cam_up_vel   = 0;
    end
    
    % Figure Close Fn
    function close_fcn(~,~)
        loop_on = false;
        delete(fig);
    end
end