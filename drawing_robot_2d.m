function drawing_robot_2d
    
%       Robot Arm Schematic         Variables           
%       -------------------         ---------
%                          
%            b__L2___               a:  ground angle
%           /                       b:  elbow angle
%          L1                       L1: link #1 length 
%         /                         L2: link #2 length 
%        a                   
    
%       Two Triangles define equations to find the arm's end-point 
%       from the arm's lengths and angles 
        
% 	                  _ _
% 	             /|    |
% 	           L2 |    |    L2*sin(b)
% 	           /  |    |
% 	          b___|   _|_
% 	         /|        |
% 	       L1 |        |    L1*sin(a)
% 	       /  |        | 
% 	      a___|       _|_

% 	      |---|---|
% 	        /   \
%  	 L1*cos(a), L2*cos(b)
    
%   	The end-point's position is:
%
%       x = L1*cos(a) + L2*cos(b)
%       y = L1*sin(a) + L2*sin(b)

%   Angles 'a' and 'b' are found as functions of x,y,L1,L2  

    % Set Axes limits
    axes('xlim', [-1,1], 'ylim', [-1,1]);

    % Arm Lengths
    L1 = 1;
    L2 = 1;
    
    % Generate 'solver_fn' (input position [x,y], output angles [a,b])
    syms a b x y
    
    [a,b] = solve( ...                                          
        [x,y] == [L1*cos(a)+L2*cos(b), L1*sin(a)+L2*sin(b)], ... 
        [a,b]);                                                 
       
    solver_fn = str2func(strcat( ...
        '@(x,y) [',char(a(1)),',',char(b(1)),']'));
     
    % Define target points
    circle_pts  = .5 + .5*[cosd(0:360); sind(0:360)];   

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
