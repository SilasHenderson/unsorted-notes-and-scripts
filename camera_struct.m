clc; close all;
 
plot(0:.1:1, cos(0:.1:1))

cam = Camera(gca);

tic;
while toc < 10
    
    cam.update() 
end

function cam = Camera(ax)

    cam = struct( ...
        'pos', [0,0,0], ...
        'el', 0, ...
        'az', 0, ...     
        'az_vel', 0, ...
        'el_vel', 0, ...
        'up_vel', 0, ...
        'fwd_vel', 0, ...
        'side_vel', 0, ...
        'move_speed', .02, ...
        'turn_speed', .02, ...
        'update', @update);
     
   ax.Parent.Color = [1,1,1];
   ax.Parent.KeyPressFcn   = @key_down;
   ax.Parent.KeyReleaseFcn = @key_up;
   
   ax.Units           = 'normalized';
   ax.Position        = [0,0,1,1];
   ax.Color           = [.9, .9, .9];
   ax.Projection      = 'perspective';
   ax.CameraViewAngle = 30;
   ax.DataAspectRatio = [1,1,1];
   ax.Interruptible   = 'on';
   ax.XGrid = 'on';
   ax.YGrid = 'on';
   ax.ZGrid = 'on';
   ax.Box   = 'on';
   
   ax.TickLength = [0,0];
   ax.TickLabelInterpreter = 'latex';
  
   ax.XLabel.Interpreter = 'latex';
   ax.YLabel.Interpreter = 'latex';
   ax.ZLabel.Interpreter = 'latex';
   
   function update
     
        unit_vec = @(el,az)[
            cos(el)*cos(az), ...
            cos(el)*sin(az), ...
            sin(el)];
     
        cam.el = cam.el + cam.el_vel;
        cam.az = cam.az + cam.az_vel;
     
        cam.pos = cam.pos + ...
            cam.up_vel*[0,0,1] + ...
            cam.fwd_vel*unit_vec(cam.el,cam.az) + ...
            cam.side_vel*unit_vec( 0, cam.az + pi/2);
     
        cam.target = cam.pos + unit_vec(cam.el, cam.az);
        
        ax.CameraPosition = cam.pos;
        ax.CameraTarget   = cam.target;
        drawnow;
    end

    function key_down(~,e)
        switch e.Key
            case 'e', cam.fwd_vel  =   cam.move_speed;
            case 'd', cam.fwd_vel  = - cam.move_speed;
            case 's', cam.side_vel =   cam.move_speed;
            case 'f', cam.side_vel = - cam.move_speed;
            case 'i', cam.el_vel   =   cam.turn_speed/2;
            case 'k', cam.el_vel   = - cam.turn_speed/2;
            case 'j', cam.az_vel   =   cam.turn_speed;
            case 'l', cam.az_vel   = - cam.turn_speed;
            case 'h', cam.up_vel   =   cam.move_speed;
            case 'g', cam.up_vel   = - cam.move_speed;   
        end
    end

    function key_up(~,~)
        cam.fwd_vel  = 0;
        cam.side_vel = 0;
        cam.el_vel   = 0;
        cam.az_vel   = 0;            
        cam.up_vel   = 0;
    end
end
