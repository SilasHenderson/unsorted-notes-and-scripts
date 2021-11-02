
function ImageTexture(gl, texture_unit, image_src) {

    let texture = gl.createTexture();
    let image = new Image();
    
    image.src = image_src;
    image.crossOrigin = "Anonymous";

    image.onload = () => {
        gl.activeTexture( gl.TEXTURE0 +  texture_unit);
        gl.bindTexture(   gl.TEXTURE_2D, texture);     
        gl.pixelStorei(   gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.texImage2D(    gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
        gl.generateMipmap(gl.TEXTURE_2D);
    } 
    return texture;
}

function ProgramBundle(gl, vertex_code, fragment_code) {

    // Returns program and attrib/uniform locations

    let prog = {};

    prog.program        = gl.createProgram();
    
    let vertex_shader   = gl.createShader(gl.VERTEX_SHADER);    
    let fragment_shader = gl.createShader(gl.FRAGMENT_SHADER);

    vertex_code   = "#version 300 es\n precision highp float;\n" + vertex_code;
    fragment_code = "#version 300 es\n precision highp float;\n" + fragment_code;

    gl.shaderSource( fragment_shader, fragment_code);
    gl.shaderSource( vertex_shader,   vertex_code);
    gl.compileShader(vertex_shader);     
    gl.compileShader(fragment_shader);  

    gl.attachShader( prog.program, vertex_shader);
    gl.attachShader( prog.program, fragment_shader);
    gl.linkProgram(  prog.program); 
    gl.useProgram(   prog.program);  

    /* - - - Make Bundle - - - */

    let attrib_count = gl.getProgramParameter(prog.program, gl.ACTIVE_ATTRIBUTES); 
    for (let i= 0; i < attrib_count; i++) {

        let attrib_name     = gl.getActiveAttrib(  prog.program, i).name;   
        let attrib_location = gl.getAttribLocation(prog.program, attrib_name);
        gl.enableVertexAttribArray(attrib_location);

        prog[attrib_name] = attrib_location;  
    }

    let uniform_count = gl.getProgramParameter( prog.program, gl.ACTIVE_UNIFORMS);
    for (let i = 0; i < uniform_count; i++) {  

        let uniform_name     = gl.getActiveUniform(  prog.program, i).name;
        let uniform_location = gl.getUniformLocation(prog.program, uniform_name);

        prog[uniform_name] = uniform_location;
    }

    return prog;
}

function Camera(position, target) {
    
    let cam = {};

    /*
    _ _                Target    
     |             Y  /|         
     |             | / |      
   unit.y          |/  |         
     =     Position)el |___X     _ _
   sin(el)        /_\  |  /      /
     |           /az \ | /      /    unit.z = cos(az)*cos(el)
    _|_         /_ _ _\|/     _/_
               Z             
              /-------/ 
              unit.x = sin(az)*cos(el)      
    */

    let dx = position[0] - target[0];
    let dy = position[1] - target[1];
    let dz = position[2] - target[2];

    let dxz  = Math.sqrt(dx*dx + dz*dz);
    let dxyz = Math.sqrt(dx*dx + dy*dy + dz*dz);

    let cos_az = dz/dxz; // need fix
    let sin_el = dy/dxyz;

    cam.eye           = position;
    cam.azimuth       = Math.acos(cos_az);
    cam.elevation     = Math.asin(sin_el);
    
    cam.move_speed    =   2;
    cam.turn_speed    = .03;
  
    cam.forward_vel   = 0;
    cam.up_vel        = 0;
    cam.side_vel      = 0;  

    cam.elevation_vel = 0;
    cam.azimuth_vel   = 0;

    cam.Unit = () => { return [

        Math.cos(cam.elevation)*Math.sin(cam.azimuth),
        Math.sin(cam.elevation),
        Math.cos(cam.elevation)*Math.cos(cam.azimuth)]; 
    }

    cam.Update = (dt = .01) => { 

        cam.elevation += cam.elevation_vel;                      
        cam.azimuth   += cam.azimuth_vel; 
                
        cam.eye[0] -= cam.side_vel*Math.cos(cam.azimuth);   
        cam.eye[1] += cam.up_vel;
        cam.eye[2] += cam.side_vel*Math.sin(cam.azimuth);

        cam.eye = Add(cam.eye, Scale(cam.Unit(), cam.forward_vel));
    }

    cam.Matrix = () => {

        let fwd  = Scale(cam.Unit(),-1);
        let left = Normalize(Cross([0,1,0], fwd));
        let up   = Normalize(Cross(fwd, left));

        let mat = new Float32Array([

            ...left, -Dot( left, cam.eye),
              ...up, -Dot(   up, cam.eye),
             ...fwd, -Dot(  fwd, cam.eye),
            0, 0, 0, 1
        ]);
        return mat;
    }

    cam.Info = () => {

        let info_string = 
        "<b> Camera </b><br><br>" + 
        "   Position X: "  + cam.eye[0].toFixed(2)    + "<br>" + 
        "   Position Y: "  + cam.eye[1].toFixed(2)    + "<br>" + 
        "   Position Z: "  + cam.eye[2].toFixed(2)    + "<br>" + 
        "   Azimuth: "     + cam.azimuth.toFixed(2)   + "<br>" + 
        "   Elevation: "   + cam.elevation.toFixed(2) + "<br><br>" + 
        "<b> View Matrix </b> <br><br>";

        let mat = cam.Matrix();

        for (let row = 0; row < 4; row++) {
            for (let col = 0; col < 4; col++) {
                let val = (mat[4*row + col]).toFixed(2);
                info_string += ('       ' + val).slice(-7) + ', ';
            }
            info_string += '<br>';
        }
        return info_string;
    }

    cam.ProjectionMatrix = () => {

       return new Float32Array([
        1, 0, 0, 0, 
        0, 1, 0, 0, 
        0, 0, 1, 1, 
        0, 0, 0, 1 ]);
    }
    document.onkeydown = (e) => {

        if (e.key == "l")  cam.azimuth_vel   =  cam.turn_speed;
        if (e.key == "j")  cam.azimuth_vel   = -cam.turn_speed;
        if (e.key == "k")  cam.elevation_vel =  cam.turn_speed;
        if (e.key == "i")  cam.elevation_vel = -cam.turn_speed;
        if (e.key == "h")  cam.up_vel        =  cam.move_speed;
        if (e.key == "g")  cam.up_vel        = -cam.move_speed;
        if (e.key == "s")  cam.side_vel      = -cam.move_speed;
        if (e.key == "f")  cam.side_vel      =  cam.move_speed;
        if (e.key == "e")  cam.forward_vel   = -cam.move_speed;
        if (e.key == "d")  cam.forward_vel   =  cam.move_speed; 
    }
    
    document.onkeyup = (e) => {

        if (e.key == "j" || e.key == "l") cam.azimuth_vel   = 0;
        if (e.key == "i" || e.key == "k") cam.elevation_vel = 0;
        if (e.key == "e" || e.key == "d") cam.forward_vel   = 0;
        if (e.key == "h" || e.key == "g") cam.up_vel        = 0;
        if (e.key == "s" || e.key == "f") cam.side_vel      = 0; 
    }
   
    return cam;
}
/* - - - Functions - - - */

function Buffer(gl, data) {

    let buffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);

    return buffer;
}

/* - - - Vector Functions - - - */

function Add(A,B) {

    let AB = [];    
    for (let i in A) AB.push(A[i]+B[i]);    

    return AB; 
}

function Cross(A,B) { return [

    A[1] * B[2] - A[2] * B[1], 
    A[2] * B[0] - A[0] * B[2],
    A[0] * B[1] - A[1] * B[0]
]};

function Dot(A,B) {

    let sum = 0;
    for (let i in A) sum += A[i]*B[i]; 

    return sum;
}

function Scale(A, b) {

    let A_new = [];
    for (let i in A) A_new.push(A[i]*b);

    return A_new;
}

function Normalize(vec) {

    let L2   = 0;
    let unit = [0,0,0];

    for (let i in vec) L2 += vec[i]*vec[i];
    for (let i in vec) unit[i] = vec[i]/Math.sqrt(L2);

    return unit; 
}

function Rand() {

    return Math.random();
}
