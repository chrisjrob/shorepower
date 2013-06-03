// ./shorepower/shorepower.scad
// Copyright (C) 2013 Christopher Robertsi

// Faceplate
height          = 120;
width           = 98;
depth           = 10;
face_thickness  = 2;
edge_thickness  = 2.2;

// Hinge
hinge_diameter  = 8.3;
pintle_diameter = 3.0;
cutout_offset   = 13.7;
cutout_width    = 10.3;

// Seal
seal_width      = 75.5;
seal_height     = 15.0; // Effectively the radius
seal_depth      = 2.5;
seal_offset     = 11.65; // The distance from the top to the seal
seal_thickness  = 1.25;

// Finger
finger_width    = 20;
finger_depth    = 5.25;
finger_thickness = 1.1;

// Catch
catch_width     = 55.3; // Width of both catches and the space between
catch_height    = 2.5;
catch_depth     = 3.1; // The overhang and edge_thickness together
catch_separator = 25.9; // Width of the space between catches
catch_thickness = 1;    // The thickness

// General
roundedness     = 2.5;
precision       = 50;

module shorepower() {

    // The main module that pulls the thing together

    difference() {

        union() {
            // Things that exist
            faceplate();
            hinge();
            seal();
            finger_hole();
            catch_2d();
        }

        union() {
            // Things to cut away


        }

    }
}

module catch_2d() {

        difference() {
            union() {
                // Things that exist
                translate( v = [ catch_width + (width - catch_width)/2, height, depth - 0.01] )
                    rotate([90,0,270])
                        linear_extrude( height = catch_width ) 
                            polygon(    points =   [ 
                                                    [0, 0],
                                                    [0, catch_height],
                                                    [edge_thickness, catch_height],
                                                    [catch_depth, catch_thickness],
                                                    [catch_depth, 0],
                                                    [edge_thickness, 0],
                                                ],
                                        paths =   [ [ 0, 1, 2, 3, 4, 5, 0 ] ]
                                    );
            }

            union() {
                // Things to cut away
                translate( v = [(width - catch_separator)/2, height - catch_depth * 1.5, depth - 0.01] )
                    cube( size = [catch_separator, catch_depth *2, catch_height *2] );

            }
        }
}

module finger_hole() {

    // Space for a finger to lift the faceplate

    difference() {

        union() {
            // Things that exist
            translate( v = [(width - finger_width)/2, height - finger_depth, face_thickness] ) {
                cube( size = [finger_width, finger_depth - edge_thickness, depth - face_thickness] );
            }
        }

        union() {
            // Things to cut away
            translate( v = [(width - finger_width)/2 + finger_thickness, height - finger_depth + finger_thickness, face_thickness] ) {
                cube( size = [finger_width - finger_thickness *2, finger_depth - edge_thickness, depth - face_thickness] );
            }

        }

    }

}


module seal() {

    // The raised protrusion on the inside of the faceplate
    // presumably to seal against the inside of the socket

    translate( v = [ (width - seal_width)/2, seal_offset, face_thickness]) {
        difference() {

            union() {
                // Things that exist
                rounded_seal( seal_width, seal_height, seal_depth, seal_height );
            }
            
            union() {
                // Things to cut away
                translate( v = [seal_thickness, seal_thickness, 0] ) {
                    rounded_seal( seal_width - seal_thickness*2, seal_height - seal_thickness, seal_depth, seal_height - seal_thickness );
                }

            }
        }
    }
}

module rounded_seal(w, h, d, r) {

    difference() {
        union() {
            translate( v = [r, 0, 0]) {
                cube( size = [w - h*2, h, d]);
            }
            translate( v = [r, r, 0]) {
                cylinder( h = d, r = r, $fn = precision );
            }
            translate( v = [w-r, r, 0]) {
                cylinder( h = d, r = r, $fn = precision );
            }
        }
        union() {
            translate( v = [0, h, 0] ) {
                cube( size = [w, h, d] );
            }
        }
    }

}

module hinge() {

    // The hinge part
    translate( v = [0, 0, 0.01]) 
    difference() {

        union() {
            // Things that exist
            translate( v = [edge_thickness, hinge_diameter/2, hinge_diameter/2 ])
                rotate( a = [0, 90, 0]) 
                    cylinder( h = width - edge_thickness*2, r = hinge_diameter/2, $fn = precision);
        }

        union() {
            // Remove pintle
            translate( v = [-1, hinge_diameter/2, hinge_diameter/2 ])
                rotate( a = [0, 90, 0]) 
                    cylinder( h = width +2, r = pintle_diameter/2, $fn = precision);

            // Remove hinge centre
            translate( v = [cutout_offset + roundedness, edge_thickness+roundedness, face_thickness+roundedness] )
                roundcube( 50+cutout_width*2, 50, hinge_diameter, roundedness, 1 );

            // Remove hinge cut outs
            translate( v = [cutout_offset, -0.1, -0.1] ) {
                cube( size = [cutout_width, hinge_diameter + 0.2, hinge_diameter + 0.2] );
            }
            translate( v = [width - cutout_offset - cutout_width, -0.1, -0.1] ) {
                cube( size = [cutout_width, hinge_diameter +0.2, hinge_diameter +0.2] );
            }
        }
    }


}

module faceplate() {

    // The faceplate

    difference() {

        union() {
            // Things that exist
            translate( v = [roundedness, roundedness, roundedness] ) {
                roundcube( width, height, depth+roundedness, roundedness, 1 );
            }
        }

        union() {

            // Remove roundedness from top
            translate( v = [0, 0, depth] ) {
                cube( size = [ width + 1, height +1, roundedness *2] );
            }

            // Remove inside
            translate( v = [roundedness+edge_thickness, roundedness+edge_thickness, roundedness+face_thickness] ) {
                roundcube( width - edge_thickness*2, height-edge_thickness*2, depth+roundedness, roundedness, 1 );
            }

            // Remove one edge
            translate( v = [edge_thickness, 0, 0] ) {
                cube( size = [width - 2 * edge_thickness, hinge_diameter/2, depth *2] );
            }

            // Remove hinge cut outs
            translate( v = [cutout_offset, 0, 0] )
                cube( size = [cutout_width, hinge_diameter, hinge_diameter] );
            translate( v = [width - cutout_offset - cutout_width, 0, 0] )
                cube( size = [cutout_width, hinge_diameter, hinge_diameter] );

            // Finger cutaway
            translate( v = [(width - finger_width)/2 + finger_thickness, height - finger_depth + finger_thickness, face_thickness] ) {
                cube( size = [finger_width - finger_thickness *2, finger_depth, depth] );
            }

            // Remove pintle
            translate( v = [-1, hinge_diameter/2, hinge_diameter/2 ]) {
                rotate( a = [0, 90, 0]) {
                    cylinder( h = width +2, r = pintle_diameter/2, $fn = precision);
                }
            }
        }
    }
}

module roundcube( w, h, d, r, t ) {

    // Module to create a rounded cube
    // t = 0 for flat top and bottom and rounded sides
    // t = 1 for fully rounded

    minkowski() {
        cube( size = [ w-(r*2), h-(r*2), d-(r*2) ] );
        if (t == 0) {
            cylinder( h = 1, r = r, $fn = precision );
        } else {
            sphere( r = r, $fn = precision);
        }
    }
}

translate( v = [-width/2, -height/2, 0] )
    shorepower();

