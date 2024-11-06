from influxdb_client import InfluxDBClient
from scipy.interpolate import RBFInterpolator
import numpy as np
import geopandas as gpd
from config import idbToken, idbOrg
from shapely.geometry import Point, MultiPolygon, Polygon
from geovoronoi import voronoi_regions_from_coords

measurements = ['AQI', 'CO', 'CO-correction', 'CO2', 'CO2-correction', 'Elevation', 'Humidity',
                'Humidity_OB', 'LUX', 'LUX-correction', 'Latitude', 'Longitude', 'NO', 'NO-correction',
                'NO2', 'NO2-correction', 'Noise', 'Noise-correction', 'Noise_LEQ', 'Noise_MAX', 'O3', 'O3-correction',
                'PM1', 'PM1-correction', 'PM10', 'PM10-correction', 'PM2_5', 'PM2_5-correction',
                'Pressure', 'Pressure_OB', 'SO2', 'SO2-correction', 'Speed', 'Temperature', 'Temperature_OB'
                                                                                            'UV', 'UV-correction']
selected_pollutants = ['AQI', 'CO', 'NO2', 'PM10', 'SO2']

def convert_to_googleMap_coords(geoms):
    """
    Convert polygon or multupolygon in list of coordinates suitable for (google) maps plotting
    param: geom is Polygon or MultiPolygon
    returns: list [polygon, ...]
    """

    def convert_to_maps_polygon(geometry):
        xs, ys = geometry.exterior.xy
        reslist = zip(ys, xs)
        return list([list(i) for i in reslist])

    if type(geoms) == Polygon:

        geoms = smooth_polygon(geoms)

        return convert_to_maps_polygon(geoms)

    elif type(geoms) == MultiPolygon:

        polygons_list = []
        intersection_number = len(geoms.geoms)
        # check = [list(x.exterior.coords) for x in check.geoms]
        for geom in geoms.geoms:
            geom = smooth_polygon(geom)

            # print(geom.contains(user_location))
            polygons_list.append(convert_to_maps_polygon(geom))

        return polygons_list[0]


class Interpolator:
    def __init__(self, shape_file, grid_density=100):
        self.location_name = shape_file.split("/")[-1].split(".")[-2]
        area = gpd.read_file(shape_file)
        self.bbox = ((area.bounds['minx'].values, area.bounds['maxx'].values),
                     (area.bounds['miny'].values, area.bounds['maxy'].values))
        x_space = np.linspace(self.bbox[0][0], self.bbox[0][1], grid_density)
        y_space = np.linspace(self.bbox[1][0], self.bbox[1][1], grid_density)
        self.grid_x, self.grid_y = np.meshgrid(x_space, y_space)
        self.points, self.area_shape = self._initialize(area)
        self.sensors_data = {}
        self.interpolators_dict = {}

    def _initialize(self, area):

        area_shape = area.iloc[0].geometry
        points = []
        if self.grid_x.shape == self.grid_y.shape:
            for i in range(self.grid_x.shape[0]):
                for j in range(self.grid_x.shape[1]):
                    if area_shape.contains(Point(self.grid_x[i][j], self.grid_y[i][j])):
                        points.append(np.array([self.grid_x[i][j], self.grid_y[i][j]]))
        return np.array(points), area_shape

    def _get_sensors_data(self):
        store = {}
        client = InfluxDBClient(url = "https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=7d09b07ae81cf7af",
                                token = idbToken,
                                org = idbOrg)
        query_api = client.query_api()
        tables = query_api.query('from(bucket:"H2020") |> range(start: -1m) '
                                 '|> filter(fn: (r) => r._measurement == "Pollutant")  '
                                 '|> group(columns: ["DeviceID"])')

        for table in tables:
            coordinates = [None, None]
            for row in table.records:
                deviceID = row.values['DeviceID']
                if deviceID not in store.keys():
                    store[deviceID] = {}
                store[deviceID][row.values['_field']] = row.values['_value']
                if row.values['_field'] == 'Latitude':
                    coordinates[1] = row.values['_value']
                if row.values['_field'] == 'Longitude':
                    coordinates[0] = row.values['_value']
                if None not in coordinates and (
                        "coordinates" not in store[deviceID].keys()):  # append coordinates to dict if present
                    store[deviceID]["coordinates"] = coordinates
        return store

    def create_interpolators(self):
        self.sensors_data = self._get_sensors_data()
        for pollutant in measurements:
            sensors_coords, values = self.extract_pollutant_value(pollutant)
            if len(sensors_coords) != 0 and len(values) != 0:
                rbf = RBFInterpolator(sensors_coords, values, epsilon=2, kernel='linear')
                self.interpolators_dict[pollutant] = rbf

    def extract_pollutant_value(self, pollutant):
        x_coord = []
        y_coord = []
        values = []
        long = self.bbox[0]
        lat = self.bbox[1]
        for devId in self.sensors_data.keys():
            try:
                if lat[0] < self.sensors_data[devId]['Latitude'] < lat[1] \
                        and long[0] < self.sensors_data[devId]['Longitude'] < long[1]:
                    values.append(self.sensors_data[devId][pollutant])
                    x_coord.append(self.sensors_data[devId]['Latitude'])
                    y_coord.append(self.sensors_data[devId]['Longitude'])
            except:
                pass
                #print(f'Pollutant not detected for device {devId}')

        return np.array([np.array([x, y]) for x, y in zip(x_coord, y_coord)]), values

    def create_dict(self):
        reconstruction_dict = {}
        region_polys, region_pts = voronoi_regions_from_coords(self.points, self.area_shape)
        new_region_polys={}
        new_region_pts={}
        for polys in region_polys:
            if type(region_polys[polys]) == MultiPolygon:
                for i in range(len(region_polys[polys].geoms)):
                    new_region_polys[f"{polys}_{i}"] = region_polys[polys].geoms[i]
                    new_region_pts[f"{polys}_{i}"] = region_pts[polys]
        # print(new_region_polys.keys())

        region_polys.update(new_region_polys)
        region_pts.update(new_region_pts)

        for idx in region_pts.keys():
            if type(region_polys[idx]) == Polygon:
                dict_key = self.location_name + "_" + str(len(reconstruction_dict))
                point = self.points[region_pts[idx]]
                reconstruction_dict[dict_key] = {"bounds": convert_to_googleMap_coords(region_polys[idx]), "coordinates": point}
                for pollutant in self.interpolators_dict.keys():
                    interpolator = self.interpolators_dict[pollutant]
                    value = interpolator(point)
                    reconstruction_dict[dict_key][pollutant] = value[0]

        return reconstruction_dict
        # {1: [bounds[0], coords[0], value_list[0]]}:


def smooth_polygon(polygon, debug=False):  # if geom is too complex, reduce points (otherwise we can have problem in app visualization)

    # print(f"VALIDITY:{explain_validity(geoms)}")
    pol_len = len(polygon.exterior.xy[0])
    if debug:
        print(f"len is : {pol_len}")
    if pol_len > 400:  # if polygon is too big, smooth it
        return polygon.simplify(0.00008, preserve_topology=True)
    else:  # no changes
        return polygon



if __name__ == '__main__':
    interp_objects = Interpolator('./shape_files/bari_shape.geojson')
    interp_objects.create_interpolators()
    reconstruction_dict = interp_objects.create_dict()
