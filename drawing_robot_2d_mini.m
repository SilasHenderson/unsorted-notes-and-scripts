function drawing_robot_2d_mini
    
    % How it works:
    
    % Here is a drawing of a robot arm, with labels
    %
    %   Schematic               Variables                
    %   ---------               ------
    %                          
    %           b__L2___        a:  ground angle
    %          /                b:  elbow angle
    %         L1                L1: link #1 length 
    %        /                  L2: link #2 length 
    %       a                   
    
    % We can use triangles to define equations that relate
    % the arm's lengths and angles to the arm's end-point 
    
    % x,y coordinates as function of angles 'a' and 'b'
    % --------------------------------------------------
    
    % end pt -->            *       _ _
    %                      /|        |
    %                    L2 |        |    L2*sin(b)
    %                    /  |        |
    %                   b___|       _|_
    %                  /|            |
    %                L1 |            |    L1*sin(a)
    %                /  |            | 
    % fixed pt -->  a___|           _|_
    %
    %               |---|---|
    %                 /   \
    %           L1*cos(a) L1*cos(b)
    
    % The end-point's position is:
    %
    %       x = L1*cos(a) + L2*cos(b), and
    %       y = L1*sin(a) + L2*sin(b)
    
    % What if we have a 'target point', and want to find which 
    % angles to set the robot arm in order to reach that point?
    %                           
    %           b__L2___(x,y)   <-- target (x,y)
    %          /              
    %         L1               
    %        /                
    %       a                   <--  ground position = (0,0)              
    
    %   We would need to solve a system of 2 equations, for 'a' and 'b'  
    %   and find a function of form x,y => a,b instead of a,b => x,y
    
    % We do this with symbolics
    % -------------------------
    
    % Set Arm Lengths
    L1 = 1;
    L2 = 1;
    
    % Generate 'solver_fn' (input position [x,y], output angles [a,b])
    
    syms a b x y
    
    [a,b] = solve( ...                                          % output
        [x,y] == [L1*cos(a)+L2*cos(b), L1*sin(a)+L2*sin(b)], ...% eqn to solve
        [a,b]);                                                 % vars to solve for
       
    % There are 2 solutions returned.  We get string representations
    % of the 1st set of solutions for [a,b] = solver_fn(x,y), 
    % and make it into a function with 'str2func'

    solver_fn = str2func(strcat( ...
        '@(x,y) [',char(a(1)),',',char(b(1)),']'));
     
    % And then make an animation
    % --------------------------
    
    % Define target points
    circle_pts  = .5 + .5*[cosd(0:360); sind(0:360)];   

    % Figure name
    set(gcf, ...
        'numbertitle', 'off', 'name', 'robot mini example', ...
        'menubar', 'none');
    
    % Set axes limits
    set(gca, ...
        'position', [0,0,1,1], ...
        'xlim', [-1,1], 'ylim', [-1,1]);
    
    % For each target point
    for i = 1:361
        
        % get target x and y
        x = circle_pts(1,i);
        y = circle_pts(2,i);
        
        % solve for angles a and b
        ab = solver_fn(x,y);
        A = ab(1);
        B = ab(2);
        
        % Clear axes, draw robot arm
        cla;
        line( ...
            'xdata', [ 0, L1*cos(A), L1*cos(A) + L2*cos(B)], ...
            'ydata', [ 0, L1*sin(A), L1*sin(A) + L2*sin(B)]);
        
        line(circle_pts(1,:), circle_pts(2,:));
  
        pause(.01);
    end
end
