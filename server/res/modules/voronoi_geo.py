import numpy as np
import geopandas as gpd
import contextily as ctx

from shapely.ops import cascaded_union

from geovoronoi import voronoi_regions_from_coords, points_to_coords, points_to_region
from res.modules.sensor_data import *
from shapely.geometry import Polygon, mapping, MultiPolygon, Point
import random

# Improt .geoson path:
### From config.py take API key and paths:
from config import geo_dir

# Add work directory path:
import sys
sys.path.append('../backend_airtown_app/');


def smooth_polygon(polygon, debug=False):   # if geom is too complex, reduce points (otherwise we can have problem in app visualization)

    #print(f"VALIDITY:{explain_validity(geoms)}")
    pol_len = len(polygon.exterior.xy[0])
    if debug:
        print(f"len is : {pol_len}")
    if pol_len > 400:    #if polygon is too big, smooth it
        return polygon.simplify(0.00008,  preserve_topology=True)
    else:   # no changes
        return polygon

def convert_to_googleMap_coords(geoms):
    """
    Convert polygon or multupolygon in list of coordinates suitable for (google) maps plotting
    param: geom is Polygon or MultiPolygon
    returns: list [polygon, ...] 
    """
    def convert_to_maps_polygon(geometry):
        xs, ys = geometry.exterior.xy    
        reslist = zip(ys,xs)
        return list([list(i) for i in reslist])

    if type(geoms) == Polygon: 

        geoms = smooth_polygon(geoms)

        return convert_to_maps_polygon(geoms)

    elif type(geoms) == MultiPolygon:
        
        polygons_list = []
        intersection_number = len(geoms.geoms)
        #check = [list(x.exterior.coords) for x in check.geoms]
        for geom in geoms.geoms: 
            geom = smooth_polygon(geom)

            #print(geom.contains(user_location))
            polygons_list.append(convert_to_maps_polygon(geom)) 

        return polygons_list[0]

class get_sensor_data():
    def __init__(self, realdata=None) -> None:
        self.debug = False
        self.sensor_data = remove_duplicates(get_sensors_pollutant_and_position())   # get data from sensors having coordinates 
        # print(self.sensor_data)

        # DUMMY DATA !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
        #self.sensor_data = remove_duplicates(test2.details)   # get data from sensors having coordinates 


        self.val = 'AQI'
        lat, lon = "Latitude", "longitude"
        #print(f"SENSOR DATA: {[print(f'{i} {self.sensor_data[i][self.val]}') for i in  self.sensor_data]}")

        self.area = gpd.read_file(f"{geo_dir}/bari_shape.geojson")        #area = area.to_crs(epsg=3395)    # convert to World Mercator CRS
        #self.area = gpd.read_file("europeshape_simple.geojson")        #area = area.to_crs(epsg=3395)    # convert to World Mercator CRS

        # TODO: fix for other areas (if we have other cities, we should add other shapes, we can also start from sensors position, and get automatically shapes)
        self.area_shape = self.area.iloc[0].geometry   # get the Polygon

        #print(f"!! point contained {[self.area_shape.contains(Point(i[0],i[1])) for i in self.coords_list]}")


        ## REMOVE sensors With NULL AQI 
        #self.sensor_data = {k:self.sensor_data[k] for k in self.sensor_data if "AQI" in self.sensor_data[k].keys() }

        #print(f"sensor data: {self.sensor_data}")


        # ADD AQI RANDOM
        for k in self.sensor_data:
            if "AQI" not in self.sensor_data[k].keys(): 
                self.sensor_data[k]["AQI"] = float(random.randrange(65))

        #random.randrange(20)


        ## REMOVE sensors outside shapes
        self.sensor_data = {k:self.sensor_data[k] for k in self.sensor_data if self.area_shape.contains(Point(self.sensor_data[k]["Longitude"],self.sensor_data[k]["Latitude"]))}
        

        self.temp_list = [[self.sensor_data[i]["coordinates"], i ] for i in self.sensor_data]  # used to create name_list and coords_list

        self.name_list = [i[1] for i in self.temp_list]       # ['AirSENCE-0521BF4640161', 'AirSENCE-0521BF4F40158', 'AirSENCE-0521BF6140160', 'AirSENCE-0521BF8E40159', 'AirSENCE-0521BFB540162', 'AirSENCE-0521C63940157', 'AirSENCE-0521C6C040156']
        self.coords_list = np.array([i[0] for i in self.temp_list])     # [[16.760815, 41.104881], [16.858915, 41.099632], [16.866999, 41.076881], [16.884495, 41.10857], [16.866674, 41.13208], [16.87261, 41.12225], [16.766207, 41.107903]]


        #coords_list.extend(coords_list)    # duplicate

        self.coords = np.array(self.coords_list)  # get_points_coordinates() 
        if self.debug:
            print(f"[!!] coords_list: {self.coords_list}")


        try:
            self.region_polys, self.region_pts = voronoi_regions_from_coords(self.coords, self.area_shape)  # type: ignore      # compute voronoi regions (and get points mapping)
        except ValueError as err:
            raise(err)

        # region_pts: {0: [5], 1: [0], 2: [4], 3: [1], 4: [2], 5: [3]}
        
        # region_polys: {0: <shapely.geometry.polygon.Polygon object at 0x7f6cf1f70910>, 1: <shapely.geometry.polygon.Polygon object at 0x7f6cf1f70d00>, 2: <shapely.geometry.polygon.Polygon object at 0x7f6cf1f70a30>, 3: <shapely.geometry.multipolygon.MultiPolygon object at 0x7f6cf1f70d60>, 4: <shapely.geometry.polygon.Polygon object at 0x7f6cf1f70b50>, 5: <shapely.geometry.multipolygon.MultiPolygon object at 0x7f6cf1f70940>}
        if self.debug:
            print("[!!!] AREAS ")
            print(self.region_polys[0].area)
            [print(self.region_polys[i].area) for i in range(len(self.region_polys))]
        #[print(self.region_pts[i]) for i in self.region_polys]

        self.map_sensor_name_arrayID = {self.name_list[self.region_pts[i][0]]:i for i in self.region_pts}   # maps name of sensors with index of voronoi polygons
        # map_sensor_name_arrayID: {'AirSENCE-0521C6C040156': 0, 'AirSENCE-0521BF6140160': 1, 'AirSENCE-0521BF4640161': 2, 'AirSENCE-0521C63940157': 3, 'AirSENCE-0521BF4F40158': 4, 'AirSENCE-0521BF8E40159': 5, 'AirSENCE-0521BFB540162': 6}


        self.map_arrayID_to_sensor_name = {self.map_sensor_name_arrayID[i]:i for i in self.map_sensor_name_arrayID.keys()}  # index of voronoi polygons with maps name of sensors 
        # map_arrayID_to_sensor_name: {0: 'AirSENCE-0521C6C040156', 1: 'AirSENCE-0521BF6140160', 2: 'AirSENCE-0521BF4640161', 3: 'AirSENCE-0521C63940157', 4: 'AirSENCE-0521BF4F40158', 5: 'AirSENCE-0521BF8E40159', 6: 'AirSENCE-0521BFB540162'}
        
        #   dict mapping name of area with [shapely]
        self.region_polys_dict = { self.map_arrayID_to_sensor_name[i]: self.region_polys[i] for i in self.map_arrayID_to_sensor_name }
        #{'AirSENCE-0521C6C040156': <shapely.geometry.polygon.Polygon object at 0x7fadff135450>, 'AirSENCE-0521BF6140160': <shapely.geometry.multipolygon.MultiPolygon object at 0x7fadff135330>, 'AirSENCE-0521BF4640161': <shapely.geometry.polygon.Polygon object at 0x7fadff1353f0>, 'AirSENCE-0521C63940157': <shapely.geometry.polygon.Polygon object at 0x7fadff135180>, 'AirSENCE-0521BF4F40158': <shapely.geometry.polygon.Polygon object at 0x7fadff134df0>, 'AirSENCE-0521BF8E40159': <shapely.geometry.polygon.Polygon object at 0x7fadff135bd0>, 'AirSENCE-0521BFB540162': <shapely.geometry.multipolygon.MultiPolygon object at 0x7fadff134d90>}


        #self.region_polys_dict = { i: i for i in self.map_arrayID_to_sensor_name }

        #print("NEW_DICT:")
        #print(self.region_polys_dict)

        #print("CONVERTED:")
        #[print(convert_to_googleMap_coords(region_polys[i])) for i in region_polys]


        # add shapely geometry to sensor_data dict
        for sensor_name in self.sensor_data:
            self.sensor_data[sensor_name]["bounds"] = convert_to_googleMap_coords(self.region_polys[self.map_sensor_name_arrayID[sensor_name]])

        self.region_polys_list = [i for i in self.region_polys.values()]
        
        

        #return sensor_data

    #print([sensor_data[i]["AQI"] for i in sensor_data])

    def find_sensorName_from_coords(self, coordinates):
        """param: coordinates is a list [Lon, Lat]"""
        for region_name in self.region_polys_dict:
            self.user_location = Point(coordinates[0], coordinates[1])
            if self.region_polys_dict[region_name].contains(self.user_location):
                if self.debug:
                    print(region_name)
                return region_name
                
            #print(geoms)
        return 0
    #"""PLOTTING
 


    def plot_voronoi(self):
        import matplotlib.pyplot as plt
        from geovoronoi.plotting import subplot_for_map, plot_voronoi_polys_with_points_in_area
        self.fig, self.ax = subplot_for_map()
        plot_voronoi_polys_with_points_in_area(self.ax, self.area_shape, self.region_polys, self.coords, self.region_pts, voronoi_labels=list(self.map_sensor_name_arrayID.keys()))
        #plt.show()


        print(self.region_polys_list)
        print(self.region_polys)


    #"""
        self.user_location = Point(16.872581, 41.1025005)




        self.region_polys_list = [i for i in self.region_polys.values()]

        fig, self.axs = plt.subplots()
        self.axs.set_aspect('equal', 'datalim')
        for geoms in self.region_polys_list: 

            print(geoms.contains(self.user_location))

            if type(geoms) == Polygon: 

                geoms = smooth_polygon(geoms)

                xs, ys = geoms.exterior.xy    
                self.axs.plot(xs, ys)
                reslist = zip(ys,xs)
                google_maps_formatted_polygon = list([list(i) for i in reslist])
                
                #print(google_maps_formatted_polygon)

            elif type(geoms) == MultiPolygon:

                intersection_number = len(geoms.geoms)
                #check = [list(x.exterior.coords) for x in check.geoms]
                for geom in geoms.geoms: 
                    geom = smooth_polygon(geom)

                    #print(geom.contains(user_location))
                    xs, ys = geom.exterior.xy    
                    self.axs.plot(xs, ys)
        plt.show()

#plot_obtained_polygons(region_polys_list)

def find_sensorValue_from_coords_and_regionsPolygon(lon, lat, region_polys_dict):
    """param: lon: float, lat:float, region_polys_dict: dictionary of polygons and values obtained from interpolation
    returns pollutant values if point in polygon, 1 otherwise """
    for region_name in region_polys_dict:
        user_location = Point(lat, lon)
        if Polygon(region_polys_dict[region_name]["bounds"]).contains(user_location):
            # print(region_name)
            return region_polys_dict[region_name]
            
        #print(geoms)
    return 1

if __name__ == "__main__":
    #data = get_sensor_data()
    #sensor_name = data.find_sensorName_from_coords(coordinates=[16.874257862891216, 41.12520829336868])
    #print(f"sensor name: {sensor_name}")
    #print(f"{data.sensor_data[sensor_name]}")
    #data.plot_voronoi()

    #plot_obtained_polygons(data)

    area = gpd.read_file(f"{geo_dir}/bari_shape.geojson")        #area = area.to_crs(epsg=3395)    # convert to World Mercator CRS
    area_shape = area.iloc[0].geometry   # get the Polygon

    print(area.bounds)


    