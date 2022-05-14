shader_type canvas_item;

uniform vec4 color_prim_0 : hint_color;
uniform vec4 color_sec_0 : hint_color;
uniform vec4 color_shadow_0 : hint_color;
uniform float pixels = 1;
uniform float color_steps = 3;



float dist_squared(vec3 v1,vec3 v2) {
	return (v1.x-v2.x)*(v1.x-v2.x)+(v1.y-v2.y)*(v1.y-v2.y)+(v1.z-v2.z)*(v1.z-v2.z);
}
vec3 project(vec3 u, vec3 v) {
	return (dot(u,v)/dot(u,u))*u;
}
void fragment() {
	vec3 color_prim = color_prim_0.rgb;
	vec3 color_sec = color_sec_0.rgb;
	vec3 color_shadow = color_shadow_0.rgb;
	
	vec3 loaded = textureLod(SCREEN_TEXTURE, floor(SCREEN_UV*pixels)/pixels, 0).rgb;
	float a_dist = dist_squared(loaded,color_prim);
	float b_dist = dist_squared(loaded,color_sec);
	float d_dist = dist_squared(loaded,color_shadow);

	if (a_dist <= b_dist && a_dist <= d_dist) {
		COLOR.rgb = project(color_prim,loaded);
	}
	else if (b_dist <= d_dist) {
		COLOR.rgb = project(color_sec,loaded);
	}
	else {
		COLOR.rgb = project(color_shadow,loaded);
	}
}
