from config import geo_dir
from AppRecommender.rec_sys.interpolator import *

bari_interpolator = Interpolator(f"{geo_dir}/bari_shape.geojson", grid_density=50);
cork_interpolator = Interpolator(f"{geo_dir}/cork_shape.geojson", grid_density=50);