$fn=32;

// Which part to render. Choose 1 for top, 2 for bottom, 3 for both
render_part = 3;

// Render gears - set to true to render gear shape
render_gears = 0;

// Render motor - set to true to render motor shape
render_motor = 0;

// rod diameter
rod_dia = 10;

// case screws
case_screw_dia = 4.4;

// case screw indents
case_screw_indent = 5;

// motor screw diameter
motor_screw_dia = 4;

// motor diameter
motor_dia = 36;

// motor screw distance
motor_screw_dist = 20;

// motor height
motor_height = 81;

// height of frame for motor
motor_frame_height = 10;

// bearing dia
bearing_dia = 22.4;

// bearing height
bearing_height = 7;

// rod gear diameter
gear_rod_dia = 52.3;

// motor gear diameter
gear_motor_dia = 13.9;

// gear height
gear_height = 8.1;

// gear overlap
gear_overlap = 2;

// wall thickness
wall = 4;


/***************
* Calculations *
***************/

case_height = gear_height + motor_height + bearing_height + 3 * wall;
case_length = gear_rod_dia + gear_motor_dia + motor_dia + 2*wall;
case_width = max(motor_dia,gear_rod_dia+4*wall);


/*****************
* Render section *
*****************/

if (render_part == 1 || render_part == 3 )
{
    part_top();
}

if (render_part == 2 || render_part == 3)
{
    part_bottom();
}

if (render_gears)
{
    gears();
}

if (render_motor)
{
    motor();
}


/************
* Functions *
************/

// top part
module part_top()
{
    difference()
    {
        case();
        translate([-case_length/2,-case_width/2,-case_height/2])
        {
            cube([case_length,case_width,case_height-(wall+gear_height)]);
        }
    }
    difference()
    {
        connectors(gap=0.8);
        case_screw_holes();
    }
}

// bottom part
module part_bottom()
{
    difference()
    {
        case();
        translate([-case_length/2,-case_width/2,+case_height/2-(wall+gear_height)])
        {
            cube([case_length,case_width,wall+gear_height]);
        }
        connectors();
    }
}

// case
module case()
{
    difference(){
        main_case();
        translate([gear_rod_dia/2+gear_motor_dia/2-gear_overlap,0,-case_height/2+wall]){
            motor_cutout();
        }
        cylinder(d=rod_dia,h=case_height,center=true);
        case_screw_holes();
        // bearing opening
        translate([0,0,case_height/2-bearing_height])
        {
            cylinder(d=bearing_dia,h=bearing_height);
        }
    }

    // motor frame
    translate([gear_rod_dia/2+gear_motor_dia/2-gear_overlap,0,-case_height/2+wall])
    {
        motor_frame();
    }

    // bearing holder top
    translate([0,0,case_height/2-bearing_height-wall])
    {
        bearing();
    }

    // bearing holder bottom - motor cutout
    difference()
    {
        translate([0,0,-case_height/2])
        {
            bearing();
        }
        translate([gear_rod_dia/2+gear_motor_dia/2-gear_overlap,0,-case_height/2+wall])
        {
            translate([-(motor_dia+2*wall)/2,-(motor_dia-2*wall)/2,0])
            {
                #cube([motor_dia+2*wall,motor_dia-2*wall,motor_frame_height]);
            }
        }
    }
}

// gears
module gears()
{
    translate([0,0,-case_height/2+motor_height+wall]){
        cylinder(d=gear_rod_dia,h=gear_height);
        translate([gear_rod_dia/2+gear_motor_dia/2-gear_overlap,0,0]){
            cylinder(d=gear_motor_dia,h=gear_height);
        }
    }
}

// motor shape
module motor()
{
    translate([gear_rod_dia/2+gear_motor_dia/2-gear_overlap,0,-case_height/2+wall])
    {
        cylinder(d=motor_dia,h=motor_height);
    }
}

// motor cutout
module motor_cutout()
{
    // motor shape
    cylinder(d=motor_dia,h=motor_height);
    // motor screws
    for(i=[-1,1]) {
        translate([0,i*motor_screw_dist/2,-wall])
        {
            cylinder(d=motor_screw_dia,h=wall);
            cylinder(d2=motor_screw_dia,d1=2*motor_screw_dia,h=1);
        }
    }
    // lower cutout for cables
    translate([-(motor_dia+4)/2,-(motor_screw_dist-motor_screw_dia*2-2)/2,-wall/2])
    {
        cube([motor_dia+4,motor_screw_dist-motor_screw_dia*2-2,wall/2]);
    }
}

// motor frame
module motor_frame()
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

module bearing()
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

// main case
module main_case()
{
    difference()
    {
        translate([-case_length/2,-case_width/2,-case_height/2])
            cube_round([case_length,case_width,case_height],mki=2*case_screw_dia+wall);
        translate([-case_length/2,-case_width/2,-case_height/2+wall])
            cube_round([case_length,case_width,case_height-2*wall],mki=2*case_screw_dia+wall);
    }
    // case_screws
    case_screws();
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

module connectors(gap=0)
{
    for(i = [1,-1])
    {
        for(j = [1,-1])
        {
            translate([0,j*(case_width/2-(2*case_screw_dia+wall)/2),0])
            {
                translate([i*(case_length/2-(2*case_screw_dia+wall)/2),0,case_height/2-(2*wall+gear_height)])
                {
                    cylinder(h=2*wall,d=2*case_screw_dia-gap);
                }
            }
        }
    }
}

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