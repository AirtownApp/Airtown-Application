# AirTOWN: A Privacy-Preserving Mobile App for Real-time Pollution-Aware POI Suggestion

![POI recsys schemde condensed updated](https://github.com/user-attachments/assets/cb7a8ea0-5675-497e-b089-c86b6617f268)

:iphone: AirTOWN is a privacy-preserving mobile application that provides real-time, pollution-aware recommendations for points of interest (POIs) in urban environments. By combining real-time Air Quality Index (AQI) data with user preferences, the proposed system aims to help users make health-conscious decisions about the locations they visit. The application utilizes collaborative filtering for personalized suggestions, and federated learning for privacy protection, and integrates AQI data from sensor networks in cities such as Bari, Italy, and Cork, UK. In areas with sparse sensor coverage, interpolation techniques approximate AQI values, ensuring broad applicability. This system offers a poromsing, health-oriented POI recommendation solution that adapts dynamically to current urban air quality conditions while safeguarding user privacy.

### :arrow_right: **Click [here](link) to see the demo.**

# System overview:
Airtown App is developed as an application for smartphone, for both android and iOS devices. As the deployment diagram shows, the system has a client-server architecture, which is composed by five main elements.

![image](https://github.com/user-attachments/assets/e25a6981-d3e0-4abe-8570-67649840bbc5)

1. **Smartphone application (client)**, it serves as the user interface on smartphones and performs POI suggestions integrating air quality information; the client include the recommandation system and collects user preferences.
2. **Main Server**, retrieves the information requested by the client by contacting databases through APIs; it also orchestrates the federated learning process.
3. **User Data server**, collects user information for registration/login (i.e.: username, e-mail, hashed password).
4. **AirSENCE database**, collects real-time Air Quality Index (AQI) and pollutant data measured by AirSENCE sensors.
5. **Google services**, collect information about POIs (e.g.: user rating, photos, routing data); the main server contact Google services by Places API and Directions API.

## Server

### Getting started:
:heavy_exclamation_mark: Since the system need to contact Google services and AirSENCE database, **Google API keys and AirSENCE tokens are mandatory**.

After downloading the repo, install pip requirements:

```bash
    pip install -r requirements.txt
```
In the *config.py* file, put the server address (line:9), Google API key (line:23) and AirSENCE tokens (lines:31,32). To use real-time pollutant data, set in *config.py* the variable *fakeAQI* (line:110) to false. Remember to use synthetic AQI data only when the user is in Aldo Moro square (Bari, Italy).

In order for the API to run properly, it is necessary to have an active PostgreSQL database on port 5432 on the same machine. This database serves as the *User Data server* previously presented.
Running the database on a container is recommended:

```bash
$ docker pull postgres:alpine 

$ docker run --name postgres-0 -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres:alpine 
```

## Client

### Getting Started

After cloning the repo, If you get errors in all the libraries do as follows: 
```bash
    flutter clean
    flutter create .
```
Then, put server address (and port) in *lib/commonFunctions/keys.dart* (line:3).
