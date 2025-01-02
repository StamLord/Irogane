shader_type sky;

uniform vec3 horizon_color : source_color = vec3(0.1, 0.1, 0.3); 
uniform vec3 sky_color : source_color = vec3(0.0, 0.0, 0.2); 
uniform vec3 ground_color : source_color = vec3(0.0, 0.0, 0.2);
uniform float horizon_blend = 0.5;

uniform float star_density : hint_range(0.0, 1.0) = 0.3;
uniform float twinkle_speed : hint_range(0.1, 10.0) = 2.0;
uniform float twinkle_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec3 star_color : source_color = vec3(0.0, 0.0, 0.2);

uniform float supernova_density = 0.02;
uniform vec3 supernova_color : source_color = vec3(0.0, 0.0, 0.2);

vec2 hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453123);
}

vec3 galaxy_cloud(vec2 uv, float time) {
	// Center the coordinates
	uv -= 0.5; // Center UV at (0, 0)
	uv *= vec2(2.0, 2.5); // Scale up the UV space for a larger galaxy
	
	// Apply vertical scaling for tilt effect
	float vertical_scale = 1.0 + uv.y * 2.0; // Scale more toward the top/bottom
	uv.x *= vertical_scale;
	
	// Spiral galaxy parameters
	float r = length(uv); // Distance from the center
	float angle = atan(uv.y, uv.x); // Angle around the center
	float arms = 4.0; // Number of spiral arms
	float spiral = sin(angle * arms + r * 80.0 - time) * 0.5 + 0.5; // Spiral structure

	// Noise for randomness
	vec2 noise_coord = uv * 10.0;
	float noise = fract(sin(dot(noise_coord, vec2(12.9898, 78.233))) * 43758.5453123);

	// Combine spiral structure with noise
	float galaxy = smoothstep(0.8, 1.0, spiral + noise * 0.3 - r * 1.5);

	// Add color to the galaxy
	vec3 color = mix(vec3(0.1, 0.1, 0.3), vec3(1.0, 0.8, 0.6), galaxy); // Blue to yellow gradient
	color += vec3(0.3, 0.0, 0.5) * noise * galaxy * 0.5; // Add purple for nebulae

	return color * galaxy;
}

void sky() {
	if (AT_CUBEMAP_PASS) {
		// Sets the radiance cubemap to a nice shade of blue instead of doing
		// expensive sky calculations
		COLOR = sky_color;
	} else {
		// Gradient based on vertical position
		float height = EYEDIR.y + horizon_blend * 0.5;
		
		// Smooth transitions using step and smoothstep
		float sky_factor = smoothstep(0.0, horizon_blend, height);
		float ground_factor = smoothstep(0.0, -horizon_blend, -height);
		
		// Mix colors based on the factors
		vec3 color = mix(ground_color, horizon_color, ground_factor);
		color = mix(color, sky_color, sky_factor);
		
		// Starfield
		vec2 coord = SKY_COORDS * vec2(1920.0, 1080.0); // Adjust for resolution
		vec2 grid = floor(coord);
		vec2 offset = hash(grid);
		float from_horizon = 1.0 - abs(SKY_COORDS.y - 0.5) * 2.0; // 0.0 at sphere poles, 1.0 at horizon
		float density = mix(0, star_density, from_horizon);
		if (offset.x < density) {
			// Calculate twinkle
			float time = TIME * twinkle_speed;
			float twinkle = sin(time + dot(grid, vec2(12.9898, 78.233))) * 0.5 + 0.5;
			twinkle = pow(twinkle, 1.0 + twinkle_intensity);
			float star_brightness = step(0.95, offset.y) * twinkle;
			color += star_color * vec3(star_brightness); // Add stars to the color
		}
		
		//vec3 galaxy_color = galaxy_cloud(SKY_COORDS, TIME * 0.5);
		//color = mix(color, galaxy_color, length(galaxy_color));
		
		COLOR = color;
	}
}
