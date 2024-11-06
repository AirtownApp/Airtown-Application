import numpy as np
import matplotlib.pyplot as plt 
from scipy.interpolate import RBFInterpolator


class fakeAQIgenerator:
    
    def __init__(self):
        
        self.rbf = self._compute_rbf();
        
    
    def get_aqi(self,
                position: np.array):
    
        aqi = self.rbf(position)[0];
        
        return aqi;
    
    
    def _compute_rbf(self):
        
     
        # * 2km grid 
        maxlat = 41.12816;
        minlat = 41.11025;
        maxlng = 16.88196;
        minlng = 16.85781;
        centlat = 41.11912;
        centlng = 16.86990;
        
        '''
        # * 1km grid
        maxlat = 41.12364;
        minlat = 41.114685;
        maxlng = 16.87593;
        minlng = 16.863855;
        centlat = 41.11912;
        centlng = 16.86990;
        '''
        
        # position = [[centlat,centlng]];

        # * NB: logitude, latitude
        upLeftCorner = [minlng,maxlat];
        downLeftCorner = [minlng,minlat];
        upRightCorner = [maxlng,maxlat];
        downRightCorner = [maxlng,minlat];
        middleLeftpoint = [minlng,centlat];
        middleRightpoint = [maxlng,centlat];
        middleUppoint = [centlng,maxlat];
        middleDownpoint = [centlng,minlat];

        simSensorsCoorsList = [
                            upLeftCorner,
                            downLeftCorner,
                            upRightCorner,
                            downRightCorner,
                            middleLeftpoint,
                            middleRightpoint,
                            middleUppoint,
                            middleDownpoint
                        ];

        # simSensorsAQIList = [25,70,18,65,38,32,27,60];
        
              
        np.random.seed(seed = 8);
        simSensorsAQIList = np.random.randint(20, high=70, size=(8,), dtype=int).tolist();
        print(f"[fAQI]: {simSensorsAQIList}");
        

        simSensorsAQIArr = np.array(simSensorsAQIList);
        simSensorsCoorsArr = np.array(simSensorsCoorsList);

        return RBFInterpolator(simSensorsCoorsArr, simSensorsAQIArr, epsilon=1, kernel='linear');
    
    
    def plot_scatter(self,
                     points: np.array,
                     density: int = 1000,
                     view: bool = False,
                     savePath: str = None):

        ''' 
            This is a debug function to show were are received points. 
            
            # * NB: y = latitude, x = longitude
        '''
        
        maxlat = 41.12816;
        minlat = 41.11025;
        maxlng = 16.88196;
        minlng = 16.85781;

        ys = np.linspace(minlat, maxlat, density);
        xs = np.linspace(minlng, maxlng, density);

        background = np.zeros((density, density));

        for i,x in enumerate(xs):
            for j,y in enumerate(ys):
                pos = np.array([[x,y]]);
                background[i,j] = self.get_aqi(pos);
        
        
        aqi_list = [];
        xpoints = [];
        ypoints = [];
        for r in range(points.shape[0]):
            coors = points[r];
            
            if coors[1] < maxlat and coors[1] > minlat and coors[0] < maxlng and coors[0] > minlng:
                ypoints.append(self._minmax_norm(coors[1], minlat, maxlat, 0, density));
                xpoints.append(self._minmax_norm(coors[0], minlng, maxlng, 0, density));
                aqi_list.append(self.get_aqi([coors]));
            else: 
                print("[RBF] Point out of bounds.");
        
        
        _, ax = plt.subplots();
         
        p = ax.pcolor(background);
        ax.scatter(xpoints,ypoints, c = "red", s = 20);
        ax.figure.colorbar(p);
        ax.grid(.3);
        
        if view:
            plt.show();
        
        if savePath is not None:
            ax.figure.savefig(f"{savePath}/RBF_fakeAQI_scatter.png");
        
        
    def _minmax_norm(self,
                     num:float,
                     min: float,
                     max: float,
                     a: float,
                     b: float):
        
        return (num - min)/(max - min)*(b-a) + a;