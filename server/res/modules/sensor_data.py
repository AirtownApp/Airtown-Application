from influxdb_client import InfluxDBClient
from config import idbToken, idbOrg

from scipy.interpolate import NearestNDInterpolator
import matplotlib.pyplot as plt
import numpy as np
from scipy.spatial import Voronoi   #, voronoi_plot_2d


def get_sensors_pollutant_and_position():
    store={}

    client = InfluxDBClient(url="https://us-east-1-1.aws.cloud2.influxdata.com/api/v2/query?orgID=7d09b07ae81cf7af",
                            token = idbToken,
                            org = idbOrg);

    query_api = client.query_api()

    #tables = query_api.query('from(bucket:"H2020") |> range(start: -1m) |> filter(fn: (r) => r._measurement == "Pollutant") |> filter(fn: (r) => r._field == "Latitude" or r._field=="Longitude" or r._field=="AQI") |> group(columns: ["DeviceID"])')

    tables = query_api.query('from(bucket:"H2020") |> range(start: -1m) |> filter(fn: (r) => r._measurement == "Pollutant")  |> group(columns: ["DeviceID"])')

    

    for table in tables:


        coordinates=[None,None]
        for row in table.records:
            deviceID=row.values['DeviceID']

            if deviceID not in store.keys():
                store[deviceID] = {}

            store[deviceID][row.values['_field']] = row.values['_value']

            
            if row.values['_field'] == 'Latitude':
                coordinates[1] = row.values['_value']

            if row.values['_field'] ==  'Longitude':
                coordinates[0] = row.values['_value']

            
            if None not in coordinates and ("coordinates" not in store[deviceID].keys()): # append coordinates to dict if present
                store[deviceID]["coordinates"] = coordinates
                


    return store




class VoronoiRegion:
    def __init__(self, region_id):
        self.id = region_id
        self.vertices = []
        self.is_inf = False
        self.point_inside = None

    def __str__(self):
        text = f'region id={self.id}'
        if self.point_inside:
            point_idx, point = self.point_inside
            text = f'{text}[point:{point}(point_id:{point_idx})]'
        text += ', vertices: '
        if self.is_inf:
            text += '(inf)'
        for v in self.vertices:
            text += f'{v}'
        return text

    def __repr__(self):
        return str(self)

    def add_vertex(self, vertex, vertices):
        if vertex == -1:
            self.is_inf = True
        else:
            point = vertices[vertex]
            self.vertices.append(point)


def remove_duplicates(store):
    return {i:store[i] for i in store if "coordinates" in store[i].keys()}  # remove points without coordinates

def do_voronoi_ALL():

    #store = get_sensors_AQI_position()

    store = get_sensors_pollutant_and_position()
    store = remove_duplicates(store)

    print(f"LEN store: {len(store)}")
    #print(f"store: ")
    #[print(f'{i} : {store[i]["coordinates"]} ' ) for i in store]

    points=[]
    values=[]
    for key in store:
        
        points.append(store[key]["coordinates"])

        values=[]
        for key in store:
            values.append(store[key]["AQI"])

    print(f"points: {points}")

    x=[]
    y=[]
    for i in range(len(store.keys())):
        x.append(points[i][0])
        y.append(points[i][1])




    
    points = np.array(points)
    values = np.array(values)


    myInterpolator = NearestNDInterpolator(points, values)

    myInterpolator(41.1025005,16.872581)



    X = np.linspace(min(x), max(x))
    Y = np.linspace(min(y), max(y))

    X, Y = np.meshgrid(X, Y)  # 2D grid for interpolation
    interp = NearestNDInterpolator(list(zip(x, y)), values)

    print(f" AQI IN POINT {interp(41.1025005,16.872581)}")

    Z = interp(X, Y)
    plt.pcolormesh(X, Y, Z, shading='auto')
    plt.plot(x, y, "ok", label="input point")
    plt.legend()
    plt.colorbar()
    plt.axis("equal")
    plt.show()



    def voronoi_to_voronoi_regions(voronoi):
        voronoi_regions = []

        for i, point_region in enumerate(voronoi.point_region):
            region = voronoi.regions[point_region]
            vr = VoronoiRegion(point_region)
            for r in region:
                vr.add_vertex(r, voronoi.vertices)
            vr.point_inside = (i, voronoi.points[i])
            voronoi_regions.append(vr)
        return voronoi_regions

    vor = Voronoi(points)
    #print(vor)
    regions = voronoi_to_voronoi_regions(vor)
    print(f"regions: {regions} ")

    #fig = voronoi_plot_2d(regions)

    plt.show()


    to_send = {}
    to_send_list = []

    for r in regions:
        
        #print(r.region_id)
        print(r.id)
        print([[i[0], i[1]] for i in r.vertices])
        pass
       

def get_points_coordinates(numpy=False):
    store = get_sensors_pollutant_and_position()
    store = {i:store[i] for i in store if "coordinates" in store[i].keys()} # remove points without coordinates

    points=[]
    values=[]
    for key in store:
        
        points.append(store[key]["coordinates"])

        values=[]
        for key in store:
            values.append(store[key]["AQI"])
    if numpy:
        return np.array(points)
    else:
        return points

if __name__=="__main__":
    #do_voronoi_AQI()
    #do_voronoi_ALL()
    print(get_sensors_pollutant_and_position())

