x_origin_base = 0;
y_origin_base = 0;
z_origin_base = 0;

sorter_base_l = 150;
sorter_base_w = 20;
sorter_base_h = 190;

motor_length = 24;
motor_width = 14;
motor_height = 16;

motor_top_part_y = 6.25;
// the brackets outter parts make it 32

miniwalls_width = 5;
miniwalls_height = 40;

motor_coordinates = [
  [0, 5, 100],
  [-44, 5, 0],
  [44, 5, 0]
];

bucket_x = 25;
bucket_y = 40;
bucket_z = 40;

module prism(l, w, h) {
  polyhedron(points = [
    [0, 0, 0],
    [l, 0, 0],
    [l, w, 0],
    [0, w, 0],
    [0, w, h],
    [l, w, h]
  ], faces = [
    [0, 1, 2, 3],
    [5, 4, 3, 2],
    [0, 4, 5, 1],
    [0, 3, 4],
    [5, 2, 1]
  ]);
}

module motor() {
  rotate([90, 90, 180]) {
    translate([0, 0, -4]) {
      // screw bracket indent
      color("blue")
      cube([motor_length + 9.25, motor_width - .75, motor_top_part_y], center = true);
    }
    translate([0, 0, 5]) {
      // motor hole
      cube([motor_length, motor_width, motor_height], center = true);

      translate([0, 0, 2]) {
        // wire expansion
        cube([motor_length + 4, motor_width, motor_height * .75], center = true);
      }
      // screw 1
      translate([-14, 0, 0]) {
        cylinder(40, r = 2, center = true);
      }
      //screw 2
      translate([14, 0, 0]) {
        cylinder(40, r = 2, center = true);

        // This is the wire hole to go in the back
        translate([5, 0, 28]) {
          cube([15, 12, motor_height * 4], center = true);
          prism(10, 10, 10);
        }
      }
    }
  }
};

module motor_cut_out() {
  /////////////////////////

  translate([0, -2, 0]) {
    // motor hole
    rotate([90, 90, 180])
    color("red")
    cube([motor_length + 20, motor_width + 10, motor_height + 15], center = true);
  }
}

module Extenral_motor_Case() {

  // removable motor case

  difference() {
    // motor hole
    rotate([90, 90, 180])
    color("pink")
    cube([motor_length + 18.5, motor_width + 8, motor_height + motor_top_part_y - 1], center = true);
    translate([0, motor_top_part_y - 2.74, 1]) {
      rotate([0, 0, 180])
      color("purple")
      motor();
    }
  }
}
module wall(l) {
  cube([miniwalls_width, miniwalls_height, l], center = true);
  translate([0, 0, l / 2])
  rotate([90, 0, 0]) {
    cylinder(miniwalls_height, r = miniwalls_width / 2, center = true);

  };
};

module path_motor_walls() {
  // NEED TO DOUBLE CHECK THESE! 
  // THE -10 SHOULD BE AROUND THE HEIGHT OF THE
  // THE MOTOR THAT IS EXPOSED IN THE MACHINE
  translate([0, miniwalls_height - 27, 0]) {
    cube([5, miniwalls_height - 12, motor_length * 1.75], center = true);
  }
};

module top_vent() {

  echo("wip");

}
module bucket() {
  cube([bucket_x, bucket_y, bucket_z], center = true);

}

module cutout_prisms(width) {
  rotate([30, 0, 0]) {

    prism(width, 20, 60);

  }
  translate([width, 0, 20]) {
    rotate([30, 180, 0]) {

      prism(width, 20, 60);
    }

  }
};
module the_x_cutout(l, w, h) {
  // starts at bottom corner
  l_count = 1;
  w_count = 1;

  for (y = [0: ((w * 1.75)): h + (w * 1.25)]) {
    for (x = [0: ((w * 1.75)): l + (w * 1.25)]) {
      rotate([90, -180, 180]) {
        translate([x, y - h, -1]) {
          rotate([0, 0, -90]) {
            pyramid(w);
          }

        }
      }
    }
  }
};

module pyramid(size) {
  polyhedron(
    points = [
      [size, size, 0],
      [size, -size, 0],
      [-size, -size, 0],
      [-size, size, 0], // the four points at base
      [0, 0, size * 1.7]
    ], // the apex point 
    faces = [
      [0, 1, 4],
      [1, 2, 4],
      [2, 3, 4],
      [3, 0, 4], // each triangle side
      [1, 0, 3],
      [2, 1, 3]
    ] // two triangles for square base
  );
};

module buckett() {
  translate([0, 38 / 2 + 12, -45]) {
    difference() {
      //main structure
      cube([sorter_base_l, bucket_y + 4, bucket_z], center = true);
      for (i = [((bucket_x + 4) * -2): (bucket_x + 4): ((bucket_x + 4) * 2)])
        translate([i, 0, 3]) {
          // cutouts buckets
          bucket();
        }

    }
  }
};

module skittle_vent() {
  difference() {
    union() {
      difference() {
        rotate([90, 0, 0]) {
          color("orange")
          cylinder(h = 5, r = 33, center = true);
        }
        translate([0, 0, 8.8]) {
          rotate([90, 0, 0]) {
            cylinder(h = 5.5, r = 1, center = true);
          }
        }

        translate([0, 0, -8.3]) {
          rotate([90, 0, 0]) {
            cylinder(h = 5.5, r = 1, center = true);
          }
        }
      }

      // walls on the rotating thing
      list2 = [1, -1];
      for (i = [0: 1]) {
        translate([17 * list2[i], 15, -6]) {
          rotate([0, 20 * list2[i], 0]) {
            color("pink")
            cube([3, 30, 52], center = true);
          }
        }

      }
    }
    list2 = [1, -1];
    for (i = [0: 1]) {
      translate([27 * list2[i], 0, -6]) {
        rotate([0, 20 * list2[i], 0]) {
          color("pink")
          cube([15, 10, 60], center = true);
        }
      }
    }

  }
};

module the_drop_walls() {
  list2 = [1, -1];
  for (i = [0: 1]) {

    translate([8 * list2[i], 15, 15]) {
      rotate([0, 0, 0]) {
        union() {
          difference() {
            rotate([90, 0, 0]) {
              color("orange")
              cube([10, 22, 5], center = true);
            }

            // the screws
            translate([0, 0, 8.8]) {
              rotate([90, 0, 0]) {
                cylinder(h = 5.5, r = 1, center = true);
              }
            }

            translate([0, 0, -8.3]) {
              rotate([90, 0, 0]) {
                cylinder(h = 5.5, r = 1, center = true);
              }
            }
          }

          // walls on the rotating thing

          translate([5 * list2[i], 15.2, 3.5]) {
            rotate([0, 0, -5 * list2[i]]) {
              color("red")

              cube([3, 35, 45], center = true);
            }
          }
        }
        rotate([90, 0, 0]) {
          translate([-9, 6, -30]) {
            //cube([10,35,5], center = true);
          }
        }
      }

    }

  }
};
module the_base() {
  translate([x_origin_base, y_origin_base, z_origin_base]) {
    difference() {
      union() {
        difference() {
          translate([0, 0, 30]) {

            cube([sorter_base_l, sorter_base_w + 10, sorter_base_h], center = true);
          }

          for (i = motor_coordinates) {
            translate(i) {

              motor_cut_out();
              rotate([0, 0, 180])
              motor();
            }
          }

        }

        x_coord = [1, -1];
        y_coord = [-1, 1];
        translate([0, 23, 0]) {
          for (i = [0: 1]) {
            // Walls of the sorter
            translate([30 * x_coord[i], 10, 45]) {
              rotate([0, 40 * y_coord[i], 0]) {
                color("red")
                wall(45);
              }
            }
            translate([20 * x_coord[i], 10, 25]) {
              rotate([0, 30 * (-y_coord[i]), 0]) {
                color("green")
                wall(35);
              }
            }
            translate([15 * x_coord[i], 10, -6]) {
              color("blue")
              wall(35);
            }

            translate([70 * x_coord[i], 10, 5]) {
              color("red")
              rotate([0, 4 * y_coord[i], 0]) {
                wall(60);
              }
            }
            translate([50 * x_coord[i], 10, 60]) {
              rotate([0, 30 * y_coord[i], 0]) {
                wall(60);
              }
            }
            // END of Walls of the sorter
          }
        }
        // Bottom Bucket
        // buckett();
        translate([0, 38 / 2 + 12, -62]) {
          //main structure
          cube([sorter_base_l, bucket_y + 4, 5], center = true);
        }
      }

      // This cuts the top 
      xa_coord = [1, -1];
      for (i = [0: 1]) {
        translate([90 * xa_coord[i], 0, 47]) {
          rotate([70, 0, -90 * xa_coord[i]]) {
            translate([-19, -10, 10]) {
              prism(sorter_base_w + 40, 85, 120);
            }
          }
        }
      }

      translate([-49, -16, 29]) {
        the_x_cutout(100, 6.25, 35);
      }

      translate([-27, -16, -24]) {
        the_x_cutout(49, 6.25, 45);
      }
      translate([-62, -16, -52]) {
        the_x_cutout(60, 6.25, 17);
      }
      translate([17, -16, -52]) {
        the_x_cutout(40, 6.25, 17);
      }
      translate([-62, -16, -18]) {
        the_x_cutout(1, 6.25, 60);
      }
      translate([61, -16, -18]) {
        the_x_cutout(1, 6.25, 60);
      }
    }

  }
}

module back_stand() {
    // holds the base up
  translate([6, 0, 0]) {
    stand_top();
     
         rotate([-30,0,0]){
             translate([0,10,-20]){
    stand_middle(25);}
}
      translate([0,-40,-70]){
          rotate([-70,0,180]){
      stand_bottom();
      }}
  }
}
module stand_top() {
  // this interfaces with the back of the holder
rotate([-10, 0, 0]) {
  basecube_y = 30;
  difference() {
    union() {

      rotate([10, 0, 0]) {

        the_x_cutout(6.25, 6, 6.25);

        translate([5.2, 0, 1]) {
          rotate([90, 0, 0]) {
            pyramid(10.5);
          }
          translate([0, (-basecube_y / 2), 0]) {
            cube([8, basecube_y, 8], center = true);

          }
        }
      }

    }

    rotate([10, 0, 0]) {
      translate([5.2, (-basecube_y * .80), 1]) {
        rotate([90, 0, 0]) {
          translate([4, -4, 0]) {
            cube([8, 20, 15], center = true);
          }
        }
        rotate([0, 90, 0]) {
          // 3m screw hole
          cylinder(h = 30, r = 2.98, center = true);
        }
      }
    }
  }
  }

}


module stand_middle(length){
    // allows angling of the stand_top
    
    
    translate([5, -4, -3]) {
      rotate([0, 90, 0]) {
        translate([0, -20, 0]) {
          stand_screwhole_1();
          rotate([0,0,90]){
          translate([0, (-length/2)-4,3]) {
              
          cube([4, length, 4], center = true);
        }}
         translate([(length)+8, 0, 0]) {
        stand_screwhole_1();
         }
        }
      }
    }
    }
    
    
module stand_bottom(){
    // bottom of the stand, meant to hold the thing
    
    basecube_y = 30;
    translate([0, 0, -2]) {
    rotate([75, 0, 0]) {
    pyramid(10.5);
    }}
    difference(){
          translate([0, (-basecube_y / 2)-3, 0]) {
            cube([8, basecube_y, 8], center = true);

          }
          
      translate([-9, (-basecube_y * .80)-4, 0]) {
        rotate([90, 0, 0]) {
          translate([4, -4, -2]) {
            cube([8, 20, 15], center = true);
          }
        }
        rotate([0, 90, 0]) {
          // 3m screw hole
          cylinder(h = 30, r = 2.98, center = true);
        }
      }
    }
    
    
}
module stand_screwhole_1(){
    
    difference() {
            translate([0, 0, 3]) {
                 
              cylinder(h = 4, r = 5, center = true);
            }
            cylinder(h = 30, r = 2.98, center = true);

          }
    
}
module robot_arm_print(){
    
translate([0,0,-1]){
difference(){
translate([0,0,-.5]){
rotate([-90,0,0]){
 stand_top();
    }
}}}

    translate([10,0,.5]){
rotate([-90,90,0]){

    stand_middle(25);
}
}
translate([-20,0,-9]){
rotate([-75,0,0]){

      stand_bottom();
    }}
    
    }

// this is where you can print the stuff out
translate([0, 23, 0]) {
  rotate([30, 0, 0]) {
   // the_base();
  }
}
// this is for the top motor
translate([0, 23, 0]) {
  //skittle_vent();
}

// this makes the walls for the 2 bottom motors
translate([48, 20, -18]) {
rotate([90,0,0]){
  //the_drop_walls();
}}


// robot arm
//robot_arm_print();

// print out the cases you use to hold the motors
// made this so we can use a larger variety of motors
// and attach the drop walls far easier.
    translate([15,0,5]){
rotate([90,0,0]){

//Extenral_motor_Case();
    }}
    translate([-12,0,5]){
rotate([90,0,0]){

//Extenral_motor_Case();
    }}

