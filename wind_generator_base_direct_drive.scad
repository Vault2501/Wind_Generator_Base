$fn=32;

// Which part to render. Choose 1 for top, 2 for bottom, 3 for middle, 4 for all parts
render_part = 1;

// Render walls or leave open
render_wall = 0;

// rod diameter
rod_dia = 10;

// case screws
case_screw_dia = 4.4;

// case screw indents
case_screw_indent = 3;

// motor screw diameter
motor_screw_dia = 3.8;

// motor diameter
motor_dia = 28;

// motor screw distance
motor_screw_dist = 19;

// motor height (complete with axle and connector)
motor_height = 60;

// height of frame for motor
motor_frame_height = 4;

// bearing dia
bearing_dia = 22.4;

// bearing height
bearing_height = 7;

// upper layer height
upper_layer_height = 30;

// wall thickness
wall = 4;

// gap
gap = 0.3;

//////////////////
// calculations //
//////////////////

case_height = wall+2*max(bearing_height,wall)+motor_height+upper_layer_height;
case_width = 4*wall+2*case_screw_dia+motor_dia;
case_length = 4*wall+2*case_screw_dia+motor_dia;

echo ("case_length:", case_length);
echo ("case_width:", case_width);
echo ("case_height:", case_height);


// render top part
if(render_part == 1 || render_part == 4)
{
    difference()
    {
        main_case();
        // upper cutout
        translate([-case_length/2,-case_width/2,-case_height/2+motor_height+wall])
        {
            cube([case_length,case_width,wall+2*max(wall,bearing_height)+upper_layer_height]);
        }
    }
    difference()
    {
        translate([0,0,-case_height/2+motor_height])
        {
            part_connectors(gap=gap);
        }
        case_screw_holes();
    } 
}

// render middle part
if(render_part == 2 || render_part == 4)
{
    difference()
    {
        main_case();
        // lower cutout
        translate([-case_length/2,-case_width/2,-case_height/2])
        {
            cube([case_length,case_width,wall+motor_height]);
        }
        // upper cutout
        translate([-case_length/2,-case_width/2,-case_height/2+wall+motor_height+max(wall,bearing_height)+upper_layer_height])
        {
            cube([case_length,case_width,wall+max(wall,bearing_height)]);
        }
        translate([0,0,-case_height/2+motor_height])
        {
            part_connectors();
        }
    }
    difference()
    {
        translate([0,0,-case_height/2+motor_height+max(wall,bearing_height)+upper_layer_height-wall/2])
        {
            part_connectors(gap=gap);
        }
        case_screw_holes();
    }
}

// render lower part
if(render_part == 3 || render_part == 4)
{
    difference()
    {
        main_case();
        // lower cutout
        translate([-case_length/2,-case_width/2,-case_height/2])
        {
            cube([case_length,case_width,wall+motor_height+max(wall,bearing_height+upper_layer_height)]);
        }
        // part connector cutout
        translate([0,0,-case_height/2+motor_height+max(wall,bearing_height)+upper_layer_height-wall/2])
        {
            part_connectors();
        }
    }
}

// main case
module main_case()
{
    difference()
    {
        union(){
            difference()
            {
                // main case
                translate([-case_length/2,-case_width/2,-case_height/2])
                {
                    cube_round([case_length,case_width,case_height],mki=2*case_screw_dia+wall);
                }
                // case cutouts
                if(render_wall)
                {
                    // lower cutout for motor
                    translate([-case_length/2+wall,-case_width/2+wall,-case_height/2+wall])
                    {
                        cube_round([case_length-2*wall,case_width-2*wall,motor_height],mki=2*case_screw_dia+wall);
                    }
                    // upper cutout for rod
                    translate([-case_length/2+wall,-case_width/2+wall,-case_height/2+wall+motor_height+max(wall,bearing_height)])
                    {
                        cube_round([case_length-2*wall,case_width-2*wall,upper_layer_height],mki=2*case_screw_dia+wall);
                    }
                }
                else
                {
                    // lower cutout for motor
                    translate([-case_length/2,-case_width/2,-case_height/2+2*wall])
                    {
                        cube_round([case_length,case_width,motor_height-wall],mki=2*case_screw_dia+wall);
                    }
                    translate([-case_length/2+wall,-case_width/2+wall,-case_height/2+wall])
                    {
                        cube_round([case_length-2*wall,case_width-2*wall,motor_height],mki=2*case_screw_dia+wall);
                    }
                    // upper cutout for rod
                    translate([-case_length/2,-case_width/2,-case_height/2+2*wall+motor_height+max(wall,bearing_height)])
                    {
                        cube_round([case_length,case_width,upper_layer_height-wall],mki=2*case_screw_dia+wall);
                    }
                    translate([-case_length/2+wall,-case_width/2+wall,-case_height/2+wall+motor_height+max(wall,bearing_height)])
                    {
                        cube_round([case_length-2*wall,case_width-2*wall,upper_layer_height],mki=2*case_screw_dia+wall);
                    }
                }
                
                // upper cutout for bearing
                translate([0,0,case_height/2-max(wall,bearing_height)])
                {
                    cylinder(d=bearing_dia,h=max(wall,bearing_height));
                }
                // lower cutout for bearing
                translate([0,0,case_height/2-2*max(wall,bearing_height)-upper_layer_height])
                {
                    cylinder(d=bearing_dia,h=max(wall,bearing_height));
                }
                // motor screw and cable cutouts
                translate([0,0,-case_height/2+wall])
                {
                    motor_cutout();
                }
            }
            // case_screw enclosure
            case_screws();
        }
        // case screw cutouts
        case_screw_holes();
    }
    // upper bearing
    translate([0,0,case_height/2-max(wall,bearing_height)])
    {
        bearing_holder();
    }
    // lower bearing
    translate([0,0,case_height/2-2*max(wall,bearing_height)-upper_layer_height])
    {
        bearing_holder();
    }
    // motor holder
    translate([0,0,-case_height/2+wall])
    {
        motor_holder();
    }
}

// case screws
module case_screws()
{
    for(i = [1,-1])
    {
        for(j = [1,-1])
        {
            translate([0,j*(case_width/2-(2*case_screw_dia+wall)/2),0])
            {
                translate([i*(case_length/2-(2*case_screw_dia+wall)/2),0,-case_height/2])
                {
                    cylinder(h=case_height,d=2*case_screw_dia+wall);
                }
            }
        }
    }
}

// case screw holes
module case_screw_holes(fn=6)
{
    for(i = [1,-1])
    {
        for(j = [1,-1])
        {
            translate([0,j*(case_width/2-(2*case_screw_dia+wall)/2),0])
            {
                translate([i*(case_length/2-(2*case_screw_dia+wall)/2),0,-case_height/2])
                {
                    cylinder(h=case_height,d=case_screw_dia);
                    cylinder(h=case_screw_indent,d=2*case_screw_dia,$fn=fn);
                    translate([0,0,case_height-case_screw_indent]){
                        cylinder(h=case_screw_indent,d=2*case_screw_dia,$fn=fn);
                    }
                }
            }
        }
    }
}

// bearing holder
module bearing_holder()
{
    translate([0,0,wall]) {
        difference()
        {
            cylinder(d=bearing_dia+2*wall,h=bearing_height);
            cylinder(d=bearing_dia,h=bearing_height);
        }
    }
    difference()
    {
        cylinder(d=bearing_dia+2*wall,h=wall);
        cylinder(d=rod_dia,h=bearing_height);
    }
}

// motor cutout
module motor_cutout()
{
    // motor shape
    cylinder(d=motor_dia,h=motor_height);
    // motor screws
    rotate([0,0,45])
    {
        for(i=[-1,1]) {
            translate([0,i*motor_screw_dist/2,-wall])
            {
                cylinder(d=motor_screw_dia,h=wall);
                cylinder(d2=motor_screw_dia,d1=2*motor_screw_dia,h=1);
            }
        }
    }
    // lower cutout for cables
    translate([-(motor_dia+4)/2,-(motor_screw_dist-motor_screw_dia*2-4)/2,-wall/2])
    {
        cube([motor_dia+4,motor_screw_dist-motor_screw_dia*2-4,wall/2]);
    }
}

// motor holder
module motor_holder()
{
    difference()
    {
        cylinder(d=motor_dia+2*wall,h=motor_frame_height);
        translate([-(motor_dia+2*wall)/2,-(motor_dia-2*wall)/2,0])
        {
            cube([motor_dia+2*wall,motor_dia-2*wall,motor_frame_height]);
        }
        cylinder(d=motor_dia,h=motor_height);
    }
}

// part connectors
module part_connectors(gap=0)
{
    for(i = [1,-1])
    {
        for(j = [1,-1])
        {
            translate([0,j*(case_width/2-(2*case_screw_dia+wall)/2),0])
            {
                translate([i*(case_length/2-(2*case_screw_dia+wall)/2),0,0])
                {
                    cylinder(h=2*wall-gap,d=2*case_screw_dia-gap);
                }
            }
        }
    }
}

// round cube
module cube_round(dim,center=false,mki=5,plane="xy")
{
    if(mki<=0)
    {
        cube(dim);
    }
    else
    {
        if(plane=="xy")
        {
            translate([mki/2,mki/2,0])
            {
                linear_extrude(dim[2])
                {
                    minkowski()
                    {
                        square([dim[0]-mki,dim[1]-mki],center=center);
                        circle(d=mki);
                    }
                }
            }
        }
        if(plane=="yz")
        {
            translate([0,mki/2,dim[2]-mki/2])
            {
                rotate([0,90,0])
                {
                    linear_extrude(dim[0])
                    {
                        minkowski()
                        {
                            square([dim[2]-mki,dim[1]-mki],center=center);
                            circle(d=mki);
                        }
                    }
                }
            }
        }
        if(plane=="xz")
        {
            translate([mki/2,dim[1],mki/2])
            {
                rotate([90,0,0])
                {
                    linear_extrude(dim[1])
                    {
                        minkowski()
                        {
                            square([dim[0]-mki,dim[2]-mki],center=center);
                            circle(d=mki);
                        }
                    }
                }
            }
        }
    }
}