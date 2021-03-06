lane_data_00 = [
	[[45.0, 2], [11.25, 2]],
    [[11.25, 2], [11.25, 1]],
	[[11.25, 1], [56.25, 1]],
    [[56.25, 1], [56.25, 2]],
	[[56.25, 2], [112.5, 2]],
    [[112.5, 2], [112.5, 0]],
	[[112.5, 0], [168.75, 0]]
];

hole_data_00 = [[168.75, 0]];

lane_data_01 = [
	[[360+11.25, 0], [292.5, 0]],
    [[292.5, 0], [292.5, 1]],
	[[292.5, 1], [315, 1]]
];

hole_data_01 = [[11.25, 0], [315, 1]];

lane_data_02 = [
	[[326.25, 1], [360+0, 1]],
    [[0, 1], [0, 2]],
	[[360+0, 2], [292.5, 2]]
];

hole_data_02 = [[326.25, 1]];

lane_data_03 = [
	[[281.25, 0], [247.5, 0]]
];

hole_data_03 = [[247.5, 0]];

lane_data_04 = [
	[[236.25, 1], [281.25, 1]],
    [[281.25, 1], [281.25, 2]],
	[[281.25, 2], [225, 2]],
    [[225, 2], [225, 1]],
	[[225, 1], [191.25, 1]]
];

hole_data_04 = [[236.25, 1], [191.25, 1]];

lane_data_05 = [
	[[225, 0], [180, 0]],
    [[180, 0], [180, 1]],
	[[180, 1], [123.75, 1]],
    [[123.75, 1], [123.75, 2]], 
	[[123.75, 2], [213.75, 2]]
];

hole_data_05 = [[225, 0]];

lane_data_06 = [
	[[101.25, 0], [33.75, 0]]
];

hole_data_06 = [[33.75, 0]];

lane_data_07 = [
	[[101.25, 1], [67.5, 1]]
];

hole_data_07 = [[67.5, 1]];

circuit_base = 29;
circuit_distance = 2;
circuit_width = 1;
circuit_step_arc = 0.5;
circuit_step_rib = 0.05;

function get_cb(e1) =
    circuit_base - (circuit_width / 2) + e1 * (circuit_distance + circuit_width);

function get_xy(cb, a) =
    [cb * sin(-a), cb * cos(-a), a];

function get_segment_arc_(p1, p2) =
    [for (d = [p1[0] : circuit_step_arc : p2[0]])
        get_xy(get_cb(p1[1]), d)
    ];

function get_segment_rib_(p1, p2) =
    [for(d = [p1[1] : circuit_step_rib : p2[1]])
        get_xy(get_cb(d), p1[0])
    ];

function get_segment_arc(p1, p2) =
    p1[0] < p2[0] ? get_segment_arc_(p1, p2) : get_segment_arc_(p2, p1);

function get_segment_rib(p1, p2) =
    p1[1] < p2[1] ? get_segment_rib_(p1, p2) : get_segment_rib_(p2, p1);

function get_segment(p1, p2) =
    p1[0] == p2[0] ? get_segment_rib(p1, p2) : get_segment_arc(p1, p2);

function flatten(l) =
    [for(a = l) for(b = a) b];
 
lane_coords_00 = flatten([for(segment = lane_data_00) get_segment(segment[0], segment[1])]);
lane_coords_01 = flatten([for(segment = lane_data_01) get_segment(segment[0], segment[1])]);
lane_coords_02 = flatten([for(segment = lane_data_02) get_segment(segment[0], segment[1])]);
lane_coords_03 = flatten([for(segment = lane_data_03) get_segment(segment[0], segment[1])]);
lane_coords_04 = flatten([for(segment = lane_data_04) get_segment(segment[0], segment[1])]);
lane_coords_05 = flatten([for(segment = lane_data_05) get_segment(segment[0], segment[1])]);
lane_coords_06 = flatten([for(segment = lane_data_06) get_segment(segment[0], segment[1])]);
lane_coords_07 = flatten([for(segment = lane_data_07) get_segment(segment[0], segment[1])]);

function get_hole_coords(p) = get_xy(get_cb(p[1]), p[0]);

hole_coords_00 = [for(h = hole_data_00) get_hole_coords(h)];
hole_coords_01 = [for(h = hole_data_01) get_hole_coords(h)];
hole_coords_02 = [for(h = hole_data_02) get_hole_coords(h)];
hole_coords_03 = [for(h = hole_data_03) get_hole_coords(h)];
hole_coords_04 = [for(h = hole_data_04) get_hole_coords(h)];
hole_coords_05 = [for(h = hole_data_05) get_hole_coords(h)];
hole_coords_06 = [for(h = hole_data_06) get_hole_coords(h)];
hole_coords_07 = [for(h = hole_data_07) get_hole_coords(h)];

module lane(c) {
    union()
        for(coords = c)
            translate([coords[0], coords[1], 0])
//                sphere(d=circuit_width, $fn=25, center = true);
                rotate([0, 0, coords[2]])
                    cylinder(h = circuit_width, d = circuit_width, $fn = 10, center = true);
}

module ring(h) {
    translate([h[0], h[1], 0])
        difference() {
            cylinder(h = circuit_width, d = circuit_width * 3, $fn=25, center = true);
            cylinder(h = circuit_width * 2, d = circuit_width * 1.1, $fn = 25, center = true);
        }
}

module _ring(h) {
    translate([h[0], h[1], 0])
        rotate_extrude(convexity = 10, $fn=50)
            translate([circuit_width, 0, 0])
                circle(d = circuit_width, $fn=25);
}

module hole(h) {
    translate([h[0], h[1], 0])
        cylinder(h = circuit_width *2, d = circuit_width * 2, $fn=25, center = true);
}

module circuit() {
    union() {
        difference() {
            lane(lane_coords_00);
            for (h = hole_coords_00) hole(h);
        };
        difference() {
            lane(lane_coords_01);
            for (h = hole_coords_01) hole(h);
        };
        difference() {
            lane(lane_coords_02);
            for (h = hole_coords_02) hole(h);
        };
        difference() {
            lane(lane_coords_03);
            for (h = hole_coords_03) hole(h);
        };
        difference() {
            lane(lane_coords_04);
            for (h = hole_coords_04) hole(h);
        };
        difference() {
            lane(lane_coords_05);
            for (h = hole_coords_05) hole(h);
        };
        difference() {
            lane(lane_coords_06);
            for (h = hole_coords_06) hole(h);
        };
        difference() {
            lane(lane_coords_07);
            for (h = hole_coords_07) hole(h);
        };
        for (h = hole_coords_00) ring(h);
        for (h = hole_coords_01) ring(h);
        for (h = hole_coords_02) ring(h);
        for (h = hole_coords_03) ring(h);
        for (h = hole_coords_04) ring(h);
        for (h = hole_coords_05) ring(h);
        for (h = hole_coords_06) ring(h);
        for (h = hole_coords_07) ring(h);
    }
}

module letter_m() {
    linear_extrude(height = 1) {
        union() {
            difference() {
                text("M", font="Apple LiGothic Medium:style=Regular", size=42, halign = "center", valign = "center");
                text("M", font="Apple LiGothic Medium:style=Regular", size=39, halign = "center", valign = "center");
            };
        };
        text("M", font="Apple LiGothic Medium:style=Regular", size=36, halign = "center", valign = "center");        
    }
}

module maschinendeck() {
    color("black") 
        translate([0, 0, circuit_width / 2]) {
            circuit();
            letter_m();
        }
    color("white")
        translate([0, 0, -circuit_width / 2]) {
            cylinder(r = 40, h = circuit_width, $fn=50, center = true);
        }
}

maschinendeck();

/*
projection() {
    resize([60, 60, 1]) {
        translate([0, 0, circuit_width / 2])
            circuit();
        letter_m();
    };
};
*/

/*
projection() {
	resize([50, 50, 1]) {
		circuit();
		letter_m();
	}
}
*/

// vim: set ts=4 :

