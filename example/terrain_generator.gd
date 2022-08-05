# terrain generator

extends Node2D



var noise = OpenSimplexNoise.new()

## Sample
#print("Values:")
#print(noise.get_noise_2d(1.0, 1.0))
#print(noise.get_noise_3d(0.5, 3.0, 15.0))
#print(noise.get_noise_4d(0.5, 1.9, 4.7, 0.0))


func _ready():
	setup_noise("bubble")
	generate_polygon(120)


func generate_polygon(iteration):
	var points : PoolVector2Array = []
	var p0 = Vector2(-get_viewport_rect().size.x * 2, get_viewport_rect().size.y*2)
	var p1 = Vector2( get_viewport_rect().size.x * 3, get_viewport_rect().size.y*2)
	points.append(p0)
	points.append(p1)
	
	
	
	for i in range (iteration+1):
		var new_point = Vector2()
		new_point.x = (1- float(i)/iteration) * get_viewport_rect().size.x * 5
		new_point.x -= get_viewport_rect().size.x * 2
		new_point.y = get_viewport_rect().size.y/3.8 * noise.get_noise_2d(new_point.x/200, 1.0)
		new_point.y += get_viewport_rect().size.y * 2.0/3.0
		
		points.append(new_point)
	$poly.polygon = points
	$static_collision/coll.polygon = points


func setup_noise(val : String):
	noise.seed = int(val.to_ascii().hex_encode())
	noise.octaves = 4
	noise.period = 15.0
	noise.persistence = 0.8

