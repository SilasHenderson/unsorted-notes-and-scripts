# trying to figure out m, v, and p matrices

syms px py pz pw

pos = [ px; py; pz; pw];

proj = [ ...
    1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, 1, 0;
    0, 0, 1, 1];

syms x1 x2 x3 y1 y2 y3 z1 z2 z3 d1 d2 d3 w
view = [ ...
    x1, x2, x3, d1;
    y1, y2, y3, d2;
    z1, z2, z3, d3;
     0,  0,  0,  1];
clc;

proj*view
