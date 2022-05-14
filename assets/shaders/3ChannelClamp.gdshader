shader_type canvas_item;

uniform vec3 color_prim;
uniform vec3 color_sec;
uniform vec3 color_shadow;

float dist_squared(vec3 v1,vec3 v2) {
	return (v1.x-v2.x)*(v1.x-v2.x)+(v1.y-v2.y)*(v1.y-v2.y)+(v1.z-v2.z)*(v1.z-v2.z);
}
void fragment() {
	vec3 loaded = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0).rgb;
	float a_dist = dist_squared(loaded,color_prim);
	float b_dist = dist_squared(loaded,color_sec);
	float d_dist = dist_squared(loaded,color_shadow);
	
	if (a_dist <= b_dist && a_dist <= d_dist) {
		COLOR.rgb = color_prim
	}
	else if (b_dist <= d_dist) {
		COLOR.rgb = color_sec
	}
	else {
		COLOR.rgb = color_shadow;
	}
}
