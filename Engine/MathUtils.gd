extends RefCounted

func basis_multiply(a: Basis, b: Basis):
	return a * b

func basis_multiply_vector3(a: Basis, b: Vector3):
	return a * b

func basis_multiply_int(a: Basis, b: int):
	return a * b

func basis_divide_float(a: Basis, b: float):
	return a / b

func basis_divide_int(a: Basis, b: int):
	return a / b

func basis_equal(a: Basis, b: Basis):
	return a == b

func color_multiply(a: Color, b: Color):
	return a * b

func color_multiply_float(a: Color, b: float):
	return a * b

func color_multiply_int(a: Color, b: int):
	return a * b

func color_add(a: Color, b: Color):
	return a + b

func color_subtract(a: Color, b: Color):
	return a - b

func color_divide(a: Color, b: Color):
	return a / b

func color_divide_float(a: Color, b: float):
	return a / b

func color_divide_int(a: Color, b: int):
	return a / b

func color_equal(a: Color, b: Color):
	return a == b

func plane_multiply(a: Plane, b: Transform3D):
	return a * b

func plane_equals(a: Plane, b: Plane):
	return a == b

func projection_multiply(a: Projection, b: Projection):
	return a * b
	
func projection_multiply_vector4(a: Projection, b: Vector4):
	return a * b

func projection_equals(a: Projection, b: Projection):
	return a == b

func quaternion_multiply(a: Quaternion, b: Quaternion):
	return a * b

func quaternion_multiply_vector3(a: Quaternion, b: Vector3):
	return a * b

func quaternion_multiply_float(a: Quaternion, b: float):
	return a * b

func quaternion_multiply_int(a: Quaternion, b: int):
	return a * b

func quaternion_add(a: Quaternion, b: Quaternion):
	return a + b

func quaternion_subrtact(a: Quaternion, b: Quaternion):
	return a - b

func quaternion_divide_float(a: Quaternion, b: float):
	return a / b

func quaternion_divide_int(a: Quaternion, b: int):
	return a / b

func quaternion_equals(a: Quaternion, b: Quaternion):
	return a == b

func rect2_equals(a: Rect2, b: Rect2):
	return a == b

func rect2i_equals(a: Rect2i, b: Rect2i):
	return a == b

func t2d_multiply(a: Transform2D, b: Transform2D):
	return a * b

func t2d_multiply_pv2a(a: Transform2D, b: PackedVector2Array):
	return a * b

func t2d_multiply_rect2(a: Transform2D, b: Rect2):
	return a * b

func t2d_multiply_vector2(a: Transform2D, b: Vector2):
	return a * b

func t2d_multiply_float(a: Transform2D, b: float):
	return a * b

func t2d_multiply_int(a: Transform2D, b: int):
	return a * b

func t2d_divide_float(a: Transform2D, b: float):
	return a / b

func t2d_divide_int(a: Transform2D, b: int):
	return a / b

func t2d_equals(a: Transform2D, b: Transform2D):
	return a == b

func t3d_multiply(a: Transform3D, b: Transform3D):
	return a * b

func t3d_multiply_aabb(a: Transform3D, b: AABB):
	return a * b

func t3d_multiply_plane(a: Transform3D, b: Plane):
	return a * b

func t3d_multiply_vector3(a: Transform3D, b: Vector3):
	return a * b

func t3d_multiply_float(a: Transform3D, b: float):
	return a * b

func t3d_multiply_int(a: Transform3D, b: int):
	return a * b

func t3d_divide_float(a: Transform3D, b: float):
	return a / b

func t3d_divide_int(a: Transform3D, b: int):
	return a / b

func t3d_equals(a: Transform3D, b: Transform3D):
	return a == b
