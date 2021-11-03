vector = [40,40,25];

% axisplot
for angle = 1:30
    clf
    hold on
    Rstar = Rmake('x',angle);
    axisplot(vector)
    axisplot(vector,'blue',Rstar)
    pause(.01)
end

% ------------------------functions---------------------------------%

% rotation matrix maker
function R = Rmake(axis,angle)
    if axis == 'x'
    R =  [1              0            0          ; 
          0              cosd(angle)  sind(angle);
          0             -sind(angle)  cosd(angle)];
    end
    if axis == 'y'
    R =  [cosd(angle)    0           -sind(angle);
          0              1            0            ;
          sind(angle)    0            cosd(angle)  ];
    end
    if axis ==  'z'
    R =  [cosd(angle)    sind(angle)  0          ;
         -sind(angle)    cosd(angle)  0            ;
          0              0            1            ];
    end
end

function axisplot(vector,color,ijk)
% input properties
if nargin<3
    ijk   = [1 0 0;0 1 0;0 0 1];
end
if nargin<2
    color = 'black';
end

view(135,30) ; set(gcf,'color',[.95 .98 .98]) ; axis('off')
% plot properties
limits = [-max(vector),max(vector)];
xlim(limits);ylim(limits);zlim(limits);

% plot vector
line([0,vector(1)],[0,vector(2)],[0,vector(3)],'color','red')

% ijk lines (scaled ijk called IJK)
IJK = ijk.*max(vector);
line([0 IJK(1,1)],[0 IJK(2,1)],[0,IJK(3,1)],'color',color,'linewidth',2)
line([0 IJK(1,2)],[0 IJK(2,2)],[0,IJK(3,2)],'color',color,'linewidth',2)
line([0 IJK(1,3)],[0 IJK(2,3)],[0,IJK(3,3)],'color',color,'linewidth',2)

% axis labels
text(IJK(1,1)*1.1, IJK(2,1)*1.1, IJK(3,1)*1.1,'x axis','color',color)
text(IJK(1,2)*1.1, IJK(2,2)*1.1, IJK(3,2)*1.1,'y axis','color',color)
text(IJK(1,3)*1.1, IJK(2,3)*1.1, IJK(3,3)*1.1,'z axis','color',color)

% reference lines
xyz = vector*ijk;
xyz = diag(xyz);
xyz = ijk*xyz;                       % matrix of component vectors
basept = xyz(:,1) + xyz(:,2);        % projection to xy plane

line([vector(1),basept(1)], [vector(2),basept(2)], [vector(3),basept(3)]...
    ,'color',color,'linewidth',.2,'linestyle','--')
line([xyz(1,1), basept(1)], [xyz(2,1), basept(2)], [xyz(3,1), basept(3)]...
    ,'color',color,'linewidth',.2,'linestyle','--')
line([xyz(1,2), basept(1)], [xyz(2,2), basept(2)], [xyz(3,2), basept(3)]...
    ,'color',color,'linewidth',.2,'linestyle','--')
end

% function refplot(vector,ijk)
% 
% xyz = diag(vector*ijk)*ijk          % matrix of component vectors
% basept = xyz(:,1) + xyz(:,2)        % projection to xy plane
% 
% % reference lines
% line([vector(1),basept(1)], [vector(2),basept(2)], [vector(3),basept(3)]...
%     ,'color',[.8 .8 .8])
% line([xyz(1,1), basept(1)], [xyz(2,1), basept(2)], [xyz(3,1), basept(3)]...
%     ,'color',[.8 .8 .8])
% line([xyz(1,2), basept(1)], [xyz(2,2), basept(2)], [xyz(3,2), basept(3)]...
%     ,'color',[.8 .8 .8])
% end

% line([vector(1),basept(1), xyz(1,1)],   ... 
%      [vector(2),basept(2), xyz(2,1)],   ... 
%      [vector(3),basept(3), xyz(3,1)]