% drawing robot 2d bonus example

clear; close all; 

% Define Figure and Axes
set(gcf,'color',[.2,.25, .2], 'menubar', 'none', ...
        'numbertitle', 'off', 'name', 'robot 2d bonus');

set(gca, 'xMinorGrid',    'on', 'ticklen', [0,0], ...
         'yMinorGrid',    'on', 'DataAspectRatio', [1 1 1], ...
 'PlotBoxAspectRatio', [1 1 1], 'XLim',[-2, 2], 'YLim',[-1.7, 1.7])

% Generate Solver Function for ang1, ang2, where
syms x y ySym ang1 ang2                                         
[ang1,ang2] = solve([x,y] == [cos(ang1) + cos(ang2), ...
                              sin(ang1) + sin(ang2)], [ang1,ang2]);   
                     
% Translate symbolic function to string representation of non-symbolic function
ang1Chars = char(ang1(1));                          
ang2Chars = char(ang2(1));                          
pos2angsStr = '@(x,y) [';                            

for i = 1:length(ang1Chars)                           
    pos2angsStr = strcat(pos2angsStr,ang1Chars(i)); 
end

pos2angsStr = strcat(pos2angsStr,';');
for i = 1:length(ang2Chars)
    pos2angsStr = strcat(pos2angsStr,ang2Chars(i));
end
pos2angsStr = strcat(pos2angsStr,']');
   
% Compile string to function, define line objects, bundle into 'robot' structure     
robot.pos2angs   = str2func(pos2angsStr);
robot.angs2nodes = @(ang1,ang2) [0, cos(ang1), cos(ang1) + cos(ang2); ...
                                 0, sin(ang1), sin(ang1) + sin(ang2)];             
robot.arm        = line('linewidth',8);   
robot.drawing    = animatedline('linestyle','none','marker','.');

% Generate target points
circlePts = shapePts([ 1;  1], .4, 200, 'circle');               
squarePts = shapePts([-1;  1], .4, 200, 'square');
flowerPts = shapePts([ 1; -1], .4, 200, 'flower');
spiralPts = shapePts([-1; -1], .4, 200, 'spiral');
              
% Run Solver + Animation Sequence                                        
drawShape(robot, flowerPts);    airLine(robot, flowerPts, circlePts);
drawShape(robot, circlePts);    airLine(robot, circlePts, squarePts);
drawShape(robot, squarePts);    airLine(robot, squarePts, spiralPts);
drawShape(robot, spiralPts);    airLine(robot, spiralPts,     [2;0]);

% Functions
function drawShape(robot,pts)  
 
    for i = 1:numel(pts)/2    
        angs  = robot.pos2angs(pts(1,i),pts(2,i));
        nodes = robot.angs2nodes(angs(1),angs(2));
    
        set(robot.arm, 'XData',  nodes(1,:), 'YData', nodes(2,:));
        addpoints(robot.drawing, nodes(1,3), nodes(2,3));
        
        pause(.01);
    end
end

function pts = shapePts(center,radius,numPoints,type)    
    
    switch type
    case 'circle'
        pts = repmat(center,[1,numPoints]) + ...
                     [radius*cosd(linspace(0,360,numPoints));
                      radius*sind(linspace(0,360,numPoints))];
    case 'square'
        c    = repmat(center,[1,numPoints]);  
        r    = repmat(radius,[1,numPoints/4]);
        span = linspace(-radius,radius,numPoints/4);
        pts  = c +  [span,      r,  -span,     -r;
                       -r,   span,      r,  -span];
    case 'flower'
        pts = repmat(center,[1,numPoints]) + radius* ...
            [cosd(linspace(0,720,numPoints)).*cosd(linspace(0,360,numPoints));
             cosd(linspace(0,720,numPoints)).*sind(linspace(0,360,numPoints))];
    
    case 'spiral'
        angles = linspace( 0,   5*pi,numPoints);
        rVec   = linspace(.1, radius,numPoints);
        pts    = repmat(center,[1,numPoints]) + [rVec.*cos(angles);
                                                 rVec.*sin(angles)];
    end
end

function airLine(robot,pts1,pts2)
    
    x = linspace(pts1(1,end), pts2(1,1));
    y = linspace(pts1(2,end), pts2(2,1));
    
    for i = 1:100
        angs  = robot.pos2angs(x(i),y(i));
        nodes = robot.angs2nodes(angs(1),angs(2));
        set(robot.arm, 'XData',  nodes(1,:), 'YData', nodes(2,:));   
        pause(.01);
    end
    
    pause(.2);
end