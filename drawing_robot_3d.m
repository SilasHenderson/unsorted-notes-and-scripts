function drawing_robot_3d
  
%       Robot Arm Schematic             Variables        
%       -------------------             --------       
%                 c
%                / \                    L1: Link 1 length
%              L2   L3                  L2: Link 2 length
%          _ _ /_ _ _\_ _               L3: Link 3 length 
%         \   b       \   \             a:  Ground-Link 1 angle
%          \  |      .     \            b:  Link 1-2 angle
%           \ L1  .R        \           c:  Link 2-3 angle
%            \| .            \          R:  (x,y) Radius
%             a_ _ _ _ _ _ _ _\      
%                                  
%
%       Angles as function of target point found 2 steps:
%
%           Find R(x,y) and a(x,y) from:
%
%               x = R*cos(a)   
%               y = R*sin(a)
%       
%           Find b(x,y,z), c(x,y,z) from:
%
%               R = L2*cos(b) + L3*cos(c) 
%               z = L2*sin(b) + L3*sin(c) + L1

    % ------------------------ Parameters -------------------------
   
    % Arm lengths
    L1 = .5;
    L2 = .9;
    L3 = .9;  
    
    % Target points
    radii = linspace(0, 2*pi, 500);      
    
    target_x = .5 + cos(2*radii).*cos(radii); 
    target_y = .5 + cos(2*radii).*sin(radii);
    
    % --------------------------- Solve ---------------------------
    
    % Define Symbolic Variables 
    syms R x y z a b c                                                        
 
    % Solve system for R(x,y) and a
    [R,a] = solve([x,y] == [R*cos(a), R*sin(a)], [R,a]);
 
    % Select solutions for R,a
    R = R(1);
    a = a(1);
        
    % Solve system for angles b and c
    [b,c] = solve( ...                          
        [R,z] == [ ...                                               
            L2*cos(b) + L3*cos(c), ...          % R
            L2*sin(b) + L3*sin(c) + L1], ...    % z
        [b,c]);                                 % solve for b,c
    
    % Select solutions for each angle function
    b = b(1);
    c = c(1);

    % translate to non-symbolic functions
    A = str2func(strcat('@(x,y,z)', char(a)));
    B = str2func(strcat('@(x,y,z)', char(b)));
    C = str2func(strcat('@(x,y,z)', char(c)));   
   
    % --------------------------- Graphics ------------------------------- 
    delete(gcf);
    
    set(gca, ...
        'xlim', [min(target_x), max(target_x)], ...
        'ylim', [min(target_y), max(target_y)], ...
        'zlim', [0, L1 + L2/2], ...
        'box', 'on', 'clipping', 'off', ...
        'dataaspectratio',[1 1 1],'plotboxaspectratio',[1 1 1]);

    view(30, 20);
    
    arm = line( 'xdata', [], 'ydata', [], 'linewidth', 4);

    % ------------------------------- Loop ------------------------------

    % for each target point
    for i = 1:numel(radii)
        
        % Get target point
        x = target_x(i);
        y = target_y(i);
        z = 0;
        
        % Get angles a,b,c
        a = A(x,y,z);
        b = B(x,y,z);
        c = C(x,y,z);
        
        % Define node positions
        
        % node 1: ground
        n1x = 0;  
        n1y = 0;           
        n1z = 0;
        
        % node 2: shoulder
        n2x = 0;                
        n2y = 0;
        n2z = L1;
        
        % node 3: elbow
        n3x = L2*cos(a);
        n3y = L2*sin(a);
        n3z = L1 + L2*sin(b); 
        
        % node 4: end pt
        n4x = cos(a)*(L2*cos(b) + L3*cos(c));            
        n4y = sin(a)*(L2*cos(b) + L3*cos(c));  
        n4z = L1 + L2*sin(b) + L3*sin(c);
        
        % draw
        set(arm, ...
            'xdata', [n1x, n2x, n3x, n4x], ...
            'ydata', [n1y, n2y, n3y, n4y], ...
            'zdata', [n1z, n2z, n3z, n4z]);
        
        line( ...
            'xdata', n4x, 'ydata', n4y, 'zdata', 0, ...
            'marker', '.','markersize', 5, ...
            'color', [.2, .2, .7]);
        
        pause(.01);
    end
end   
