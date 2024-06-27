shader_type spatial;

uniform vec2 eye_pos=vec2(0.5,0.5);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float is_pupil=float(length(UV.xy-eye_pos)>0.25);
	ALBEDO.rgb=vec3(is_pupil);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
