
x_origin = 0;
y_origin = 0;
z_origin = 0;

base_radius = 91;
base_radius_buffer = 3;

base_Z = 1;
base_Z_buffer = 0;

screw_radius = 2.5;
screw_radius_buffer = 1;

Skittle_radius = 7.6;

outter_cylinder_Z = 10;

outter_cylinder_Z_mathed = (base_Z + base_Z_buffer) + outter_cylinder_Z + 30;
outter_cylinder_radius_mathed = base_radius + base_radius_buffer;

LID_cylinder_Z = 2.5;

LID_cylinder_Z_mathed = (base_Z + base_Z_buffer) + LID_cylinder_Z;
LID_cylinder_radius_mathed = base_radius + base_radius_buffer + 1;

detector_hole_z = 58;

thecubez_y = 0;
thecubez_x = base_radius - Skittle_radius - 4;
thecubez_z = -36;

pink_bottom_support_legs_height = 190;
module rep_rotate(count)
for (i = [0: count - 1])
  rotate((i * 360 / count) + 65)
children();

module rep_rotate2(count, rotation, thiccness = 45) rotate(-5)
for (i = [0: count - 1])
  rotate((i * thiccness / count) + rotation)
children();

module the_pink_lid_bottom() {
  color("pink") {
    // main base section
    translate([0, 0, -3]) {
      difference() {

        cylinder(base_Z + base_Z_buffer + 5, r = base_radius + base_radius_buffer + 9, center = true);
        // This is the centeral screw
        cylinder(base_Z + base_Z_buffer + .3 + 50, r = (
          screw_radius * 2) + screw_radius_buffer, center = true);

        // this is the skittlehole, if you want more holes
        // change rep_rotate(x) to how ever many you wantx
        color("green")
        rep_rotate(1) translate([base_radius - Skittle_radius, 0, -3]) cylinder(r = Skittle_radius, h = 16, center = true);

        // this makes the hollow parts   
      }
    }
  }

};

module pink_base_support_holes() {
  for (i = [0: 22.5: 360]) {
    // support hole 1
    rotate([0, 0, i]) {
      translate([96, 0, -3.8]) {

        color("pink")

        cube([4, 4, 7], center = true);
      }
      translate([48, 0, -3.8]) {

        color("pink")

        cube([4, 4, 7], center = true);
      }
    }
  }

}
module hole_adapter(length) {
  difference() {
    translate([0, 0, -40]) {
      color("blue") {

        difference() {
          translate([0, 0, 2]) {
            cylinder(base_Z + base_Z_buffer + 10, r = base_radius + base_radius_buffer + 9, center = true);

          }

          rotate([0, 0, 12]) {
            //pink_base_support_holes_long();

          }
          translate([-150, 0, -20]) {
            cube([300, 150, 40]);
          }

          translate([-150, -150, -20]) {
            cube([150, 300, 40]);
          }

          translate([0, 0, -3]) {
            cylinder(base_Z + base_Z_buffer + 30, r = base_radius + base_radius_buffer - 4, center = true);
          }
        }

      }
      rotate([0, 0, 12]) {
        translate([0, 0, (-length / 2) - .9]) {
    // this prints the legs
pink_bottom_support_legs_module_support_struct(length);
        }
      }
    }
    // the top pins
    for (i = [-78: 22.5: 10.5]) {
      rotate([0, 0, i]) {
        translate([96, 0, -35.5]) {
          cube([3.25, 3.3, 10], center = true);
        }
      }
    }

  }
  translate([80, 0, -39.9]) {
  cube([2.8, 2.9, 16], center = true);
}
translate([80, -20,  -39.9]) {
  cube([2.95, 3, 15], center = true);
}
translate([80, -10,  -39.9]) {
  cube([2.95, 3, 15], center = true);
}
translate([80, -30,  -39.9]) {
  cube([2.95, 3, 15], center = true);
}
translate([70, -40,  -39.9]) {
  cube([2.95, 3, 15], center = true);
}
}
module pink_bottom_support_legs_module_support_struct(length) {

  for (i = [270: 22.5: 338]) {

    // support beams
    rotate([0, 0, i]) {
      translate([96, 0, 0]) {
        pink_bottom_support_legs_individual(length);

      }
    }
  }

}

module pink_base_support_holes_long() {
  for (i = [0: 22.5: 360]) {
    // support hole 1
    rotate([0, 0, i]) {

      rotate([0, 0, 5]) {
        translate([96, 0, -1.6]) {
          cube([4, 4, 4], center = true);
        }
      }
      rotate([0, 0, -5]) {
        translate([96, 0, -1.6]) {
          cube([4, 4, 4], center = true);
        }
      }
      translate([96, 0, -4]) {

        color("pink")

        cube([4, 4, 13.1], center = true);
      }
      translate([48, 0, -7]) {

        color("pink")

        cube([4, 4, 15], center = true);
      }
    }
  }

}
module the_pink_lid_bottom_supports() {
  difference() {
    color("pink") {
      // main base section
      translate([0, 0, -3]) {
        difference() {

          cylinder(base_Z + base_Z_buffer + 5, r = base_radius + base_radius_buffer + 9, center = true);

        }
      }
    }
    translate([8, 15, -10]) {
      rotate([0, 0, 22.8]) {
        cube([120, 120, 40], center = false);
      }
    }

    // leg hole maker 
    // They are around 2.5 deep
    translate([0, 0, -98.5]) {
      pink_bottom_support_legs();
    }
    translate([0, 0, pink_bottom_support_legs_height - 97.5]) {
      pink_bottom_support_legs();
    }
  }
};

module the_pink_lid_bottom_supports_ground() {
  difference() {

    // main base section
    translate([0, 0, -1]) {

      color("pink") {
        cylinder(base_Z + base_Z_buffer + 5, r = base_radius + base_radius_buffer + 9, center = true);
      }
      translate([0, 0, 3.5]) {
        color("blue") {
          
                
            motor_shell_2();
            translate([0,0,60.4]){
               motor_shell();
               }
        }
      }
    }
    base_cube_cut();
    // leg hole maker

    translate([0, 0, pink_bottom_support_legs_height + -98]) {
      pink_bottom_support_legs();
    }
  }
};
module motor_shell_2() {
    the_cube_z= 24;
    translate([0, 0, 13]) {
  translate([0, 0, the_cube_z/2-2]) {
    
      //cube([46, 46, 20], center = true);
      translate([0, 0, 2]) {
        cube([42, 42, the_cube_z], center = true);
        translate([0,0,18]){
            translate([0,0,5.4]){
            color("red"){
            cube([46, 46, 23], center = true);
            }}
                //cube([46, 46, 20], center = true);
            }

    
  }
}}}

module motor_shell_3() {
    the_cube_z= 24;
    translate([0, 0, 13]) {
  translate([0, 0, the_cube_z/2-2]) {
    
      //cube([46, 46, 20], center = true);
      translate([0, 0, 2]) {
        cube([42, 42, 20], center = true);
        translate([0,0,16]){
            translate([0,0,-4.3]){
            color("red"){
            cube([46, 46, 4], center = true);
            }}
                //cube([46, 46, 20], center = true);
            }

    
  }
}}}


module base_cube_cut() {
  // used in the_pink_lid_bottom_supports_ground 
  // and the_pink_lid_bottom_supports
  // this gives space for the bottom skittle sorter
  rotate([0, 0, 20]) {
    translate([20, 20, -10]) {
      rotate([0, 0, 0]) {

        cube([120, 120, 40], center = false);

      }
    }
  }

}
module pink_bottom_support_legs_module(length) {
  inner_outer_x = [48, 96];
  for (x = [0: 1]) {
    for (i = [0: 22.5: 360]) {

      // support beams
      rotate([0, 0, i]) {
        translate([inner_outer_x[x], 0, 0]) {
          pink_bottom_support_legs_individual(length);

        }
      }
    }

  }
}

module pink_bottom_support_legs_module_print(length, count) {

  for (x = [1: count]) {
    // support beams
    translate([0, x * 18, 0]) {
      pink_bottom_support_legs_individual(length);

    }

  }

}

module pink_bottom_support_legs_individual(length) {
  color("pink") {
    translate([-.63, 0, 0]) {
      cube([3.25, 3.3, length], center = true);
    }
    // Thick center
    cube([4.5, 4.4, length - 5], center = true);
    
    
    translate([0, 0, length/4-2]) {
    
        // this gives a bit more sturdness for the print
        // this makes the bottom half that is thicker
        cube([6.5, 6.4, length/2], center = true);
    }
    // top bezzel
    translate([2.76, 0, (length - 10) / 2]) {
      //cube([10, 10.4, 5], center = true);
    }

    // bottom bezzel
    translate([1.5, 0, -(length - 9) / 2]) {
      difference() {
        cube([7.5, 15.4, 5], center = true);
          
        translate([2.76, 0, 2.1]) {
          cube([2, 19.4, 1], center = true);
        }

        translate([3.4, 0, 1.2]) {
          cube([1, 19.4, 1], center = true);
        }
        //rotate
        translate([0,-4,0]) {
        rotate([0,0,-90]){
            
            translate([2.76, 0, 2.1]) {
          cube([2, 19.4, 1], center = true);
        }

        translate([3.4, 0, 1.2]) {
          cube([1, 19.4, 1], center = true);
        }}
    }
    translate([0,4,0]) {
        rotate([0,0,90]){
            
            translate([2.76, 0, 2.1]) {
          cube([2, 19.4, 1], center = true);
        }

        translate([3.4, 0, 1.2]) {
          cube([1, 19.4, 1], center = true);
        }}
    }
      }

    }
    // bottom longer stub
    translate([-.34, 0, -(length - 1) / 2]) {
      cube([3.75, 8.5, 4.5], center = true);
    }
  }

}

module pink_bottom_support_legs() {
  inner_outer_x = [48, 96];
  for (x = [0: 1]) {
    for (i = [0: 22.5: 360]) {
      // support beams
      rotate([0, 0, i]) {
        translate([inner_outer_x[x], 0, 0]) {
          //center cube for the top
          translate([0, 0, .5]) {
            cube([4, 4, pink_bottom_support_legs_height], center = true);
          }
          translate([0, 0, -2.6]) {
            color("pink")
            // for the bottom holes
            cube([4, 10, pink_bottom_support_legs_height - 6], center = true);
          }

        }

      }
    }
  }
}

module inner_celling_ring() {
  difference() {
    // this makes the base
    cylinder(h = LID_cylinder_Z_mathed, r = LID_cylinder_radius_mathed + 2, center = true);

    // hollows out the center
    cylinder(h = LID_cylinder_Z_mathed + 2, r = LID_cylinder_radius_mathed - 10, center = true);

  }
}

module red_center_peace_sign() {
  difference() {
    translate([0, 0, (LID_cylinder_Z_mathed * 1.5) + 45]) {
      // This is the middle peace sign thing
      color("red")
      for (i = [0: 120: 360]) {

        translate([0, 0, 0])
        rep_rotate2(3, i, 70) translate([(base_radius / 2), 0, -18]) cube(size = [(base_radius + 5), 5, LID_cylinder_Z_mathed + 36], center = true);

      }

    }

  }
};

module detector_hole_1() {
  translate([0, 0, detector_hole_z]) {
    // detector hole
    color("green") {
      rotate(29) translate([base_radius - Skittle_radius - 4, 0, -32]) cube([23, 23, 50], center = true);

    }
  }
}
module detector_hole_11() {
  translate([0, 0, detector_hole_z]) {
    // detector hole
    color("green") {
      rotate([0, 0, 29]) translate([base_radius - Skittle_radius - 9, 0, -27.95]) cube([35, 28, 40], center = true);

    }
  }
}
module detector_hole_2() {

  translate([0, 0, detector_hole_z - 9.5]) {
    rotate(29) {
      translate([thecubez_x, thecubez_y, thecubez_z]) {

        cube([19, 19, 5], center = true);
      }
    }
  }
}

module detector_hole_3() {

  translate([0, 0, detector_hole_z - 9.5]) {
    difference() {

      translate([thecubez_x, thecubez_y, thecubez_z])
      cube([19, 19, 30], center = true);
    }
  }
}

module detector_hole_bottom_cuts() {
  rotate([0, 0, 28.8]) {
    translate([85, 0, 22.5]) {
      color("orange")

      cube([45, 26, 20], center = true);
    }

    // the indent inside the detector that catches the detector card thing
    translate([65, 0, 12.6]) {
      color("pink")

      cube([2, 20, 6], center = true);
    }
  }

}



module SKITTLE_WALL() {
  color("red")
  translate([0, 0, 22]) {
    difference() {
      cylinder(h = outter_cylinder_Z_mathed + 3, r = outter_cylinder_radius_mathed + 9, center = true);

      color("pink")
      cylinder(h = outter_cylinder_Z_mathed + 12, r = outter_cylinder_radius_mathed + 1, center = true);
    }
  }

}

module detector_slide() {
  // strap detector into this and we then slide it into the detector hole

}

module lid_upper_lip() {

  // set in hole clip in
  translate([0, 0, (LID_cylinder_Z_mathed * 1.5) + 41]) {
    difference() {
      cylinder(h = LID_cylinder_Z_mathed + 4, r = LID_cylinder_radius_mathed + 18, center = true);
      cylinder(h = LID_cylinder_Z_mathed + 6, r = LID_cylinder_radius_mathed + 1.5, center = true);
    }

  }
  //makes the wing for the set in
  color("purple")
  translate([0, 0, (LID_cylinder_Z_mathed * 1.5) + 31]) {
    difference() {
      cylinder(h = LID_cylinder_Z_mathed + 11, r = LID_cylinder_radius_mathed + 18, center = true);
      cylinder(h = LID_cylinder_Z_mathed + 14, r = LID_cylinder_radius_mathed + 14, center = true);
    }

  }
};

module toplid() {
  translate([x_origin, y_origin, z_origin]) {
    union() {

      difference() {
        translate([0, 0, -2]) {
          translate([0, 0, (LID_cylinder_Z_mathed * 1.5) + 45]) {
            inner_celling_ring();
          }
          red_center_peace_sign();
        }
        detector_hole_1();
      }
      // this makes the lip of the detector holes
      difference() {
        detector_hole_11();

        detector_hole_2();
        detector_hole_3();
      }
    }

    lid_upper_lip();

  }
};

module detector_sd_card() {

  //diffrence lid  holder 1

  rotate([0, 0, 28.8]) {
    translate([65, 0, -2]) {
      difference() {
        union() {

          translate([0, 0, 11.6]) {
            color("pink")

            cube([1.5, 19, 7], center = true);
          }
          translate([28, 0, 15.6]) {
            color("pink")

            cube([60, 24, 2], center = true);

          }
          translate([43, 0, 13.7]) {
            color("blue")
            cube([30, 24, 2], center = true);
          }

        }
        translate([14, 0, 15.6]) {
          cube([19, 19, 5], center = true);
        }
      }
    }
  }

}

module lid_rotation_support(rot) {
  rotate([0, 0, rot]) {
    translate([98, 0, 40]) {

      color("pink")

      cube([5, 4.5, 14], center = true);
    }
  }
}
module lid_rotation_support_pin() {

    translate([0,0,0]) {

      color("pink")

      cube([4, 3.5, 15.5], center = true);
    }
  
}

module lid_rotation_support_print(count) {
  for (x = [1: count]) {
    translate([0, 8 * x, 0]) {
      difference() {
        color("pink")

        cube([4.4, 3.8, 13.2], center = true);
        translate([3, 0, 0]) {
          cube([2, 2, 6], center = true);
        }
      }

    }

  }
}
module top_lid() {
  // The WHOLE THING
  difference() {
    union() {
      toplid();
      the_pink_lid_bottom();
      SKITTLE_WALL();
    }
    detector_hole_bottom_cuts();
    //diffrence lid  holder 1
    lid_rotation_support(0);
    //diffrence lid  holder 2
    lid_rotation_support(180);
    pink_base_support_holes();
  }
  //detector_sd_card();
}

module bottom_supports() {
  translate([0, 0, -90]) {
    //the_pink_lid_bottom_supports();
  }
  // ground support
  translate([0, 0, -150]) {
    the_pink_lid_bottom_supports_ground();
  }

  // legs
  translate([0, 0, -45]) {
    // pink_bottom_support_legs_module(85);

  }
  translate([.5, 0, -110]) {
    //pink_bottom_support_legs_module(30);

  }
}

module screw_hole_temp_fix() {

  translate([0, 0, -3]) {
    difference() {
      union() {
        cylinder(base_Z + base_Z_buffer + 6, r = (
          screw_radius * 1.85) + screw_radius_buffer, center = true);

        translate([0, 0, 3.28]) {
          cylinder(.5, r = (
            screw_radius * 3) + screw_radius_buffer, center = true);
        }
      }
      cylinder(base_Z + base_Z_buffer + 9, r = (
        screw_radius * 1.25) + screw_radius_buffer, center = true);
    }
  }
}

module motor_shell() {
  translate([0, 0, 9]) {
    difference() {
      cube([46, 46, 20], center = true);
      translate([0, 0, 1]) {
        cube([43, 43, 24], center = true);
        rotate([0, 0, 180]) {
          translate([20, 0, 0]) {

            cube([20, 20, 24], center = true);
          }
        }

      }
      rotate([0, 0, -90]) {
        translate([20, 0, 0]) {

          cube([20, 20, 24], center = true);
        }
      }

    }
  }
}


top_lid();
// normal support
//bottom_supports();

//the_pink_lid_bottom_supports_ground();

//screw_hole_temp_fix();
//pink_bottom_support_legs_module_print(85,5);
translate([0, -9, 0]) {
  //lid_rotation_support_print(2);
}

//pink_bottom_support_legs();
rotate([0, 180, 0]) {
  translate([-24, 24, 25]) {
   //hole_adapter(185);
  }
} 

rotate([180, 0, 0]) {
  translate([-24, 24, 25]) {
   //hole_adapter(160);
  }
} 
translate([0, 0, -5.5]) {
    translate([0,0,-9]){
//motor_shell_3();
        }
translate([0,0,30]){
//motor_shell();
}}

// the pin for the legs
translate([85, 0, -39.9]) {
  //cube([2.8, 2.9, 16], center = true);
}

//upper lid 
translate([0, 0, 0]) {
//lid_rotation_support_pin();
}
translate([10, 0, 0]) {
//lid_rotation_support_pin();
}
