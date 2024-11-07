# AirTOWN: A Privacy-Preserving Mobile App for Real-time Pollution-Aware POI Suggestion

![POI recsys schemde condensed updated](https://github.com/user-attachments/assets/cb7a8ea0-5675-497e-b089-c86b6617f268)

:iphone: AirTOWN is a privacy-preserving mobile application that provides real-time, pollution-aware recommendations for points of interest (POIs) in urban environments. By combining real-time Air Quality Index (AQI) data with user preferences, the proposed system aims to help users make health-conscious decisions about the locations they visit. The application utilizes collaborative filtering for personalized suggestions, and federated learning for privacy protection, and integrates AQI data from sensor networks in cities such as Bari, Italy, and Cork, UK. In areas with sparse sensor coverage, interpolation techniques approximate AQI values, ensuring broad applicability. This system offers a poromsing, health-oriented POI recommendation solution that adapts dynamically to current urban air quality conditions while safeguarding user privacy.

:arrow_right: **Click [here](link) to see the demo.**

# System overview:

![image](https://github.com/user-attachments/assets/e25a6981-d3e0-4abe-8570-67649840bbc5)


## Server

### Prerequisites: 
In order for the API to run properly, it is necessary to have an active PostgreSQL database on port 5432 on the same machine. 
Running the database on a container is recommended:Pass
```bash
$ docker pull postgres:alpine 

$ docker run --name postgres-0 -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres:alpine 
```

To access the container terminal, run
```bash
$ docker exec -it postgres-0 bash 
```


### Run the project
After downloading the repo (and configured the container), 
install pip requirements

    pip install -r requirements.txt

Then run the python file *main.py*
```bash
python3 main.py 
```


## Client
