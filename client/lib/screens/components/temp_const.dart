import 'package:flutter/material.dart';

const String kAssetIconsWay = 'assets/icons';

class PlayListItem {
  String img;
  String title;
  String? creator;
  PlayListItem({required this.title, required this.img, this.creator});
}

/*List<PlayListItem> kPlaylistGrid = [
  PlayListItem(
      title: 'Discover Weekly',
      img:
          'https://i04.fotocdn.net/s120/4817cfcc54ca9dc7/gallery_m/2738200936.jpg'),
  PlayListItem(
      title: 'Daily Mix 1',
      img:
          'https://i0.wp.com/www.noise11.com/wp/wp-content/uploads/2021/11/Adele-30.jpg?fit=875%2C875'),
  PlayListItem(
      title: 'Daily Mix 3',
      img:
          'https://yt3.ggpht.com/ytc/AKedOLSrzEtaB6cNd0sxMDapTZ0ZIIKcGQMtGNaZ6py00Q=s900-c-k-c0x00ffffff-no-rj'),
  PlayListItem(
      title: 'Chill Vibes',
      img:
          'https://www.fashionkibatain.com/wp-content/uploads/2017/04/guided-meditaiton.jpg'),
  PlayListItem(
      title: 'Tea Time',
      img: 'https://yanashla.com/wp-content/uploads/2020/01/9-15.jpg'),
  PlayListItem(
      title: 'Power Hour',
      img:
          'https://i.pinimg.com/originals/83/89/e0/8389e09578661f065d4b63ad86274b85.jpg'),
];*/

/*List<PlayListItem> kPlaylistPodcast = [
  PlayListItem(
      title: 'Supercars and cities',
      img:
          'https://www.wallpaperup.com/uploads/wallpapers/2013/01/01/27232/c59d12f56d7184506feedc70a6e99d07.jpg',
      creator: 'Show • Urban racer'),
  PlayListItem(
      title: 'Best barn finds',
      img:
          'https://avatars.mds.yandex.net/i?id=2a00000179eebf726d02d101ef4e3b2f77b4-2465206-images-thumbs&n=13',
      creator: 'Show • Car finder'),
  PlayListItem(
      title: 'Life at the red line',
      img:
          'https://www.mayrolaw.com/wp-content/uploads/2015/01/bigstock-Reducing-Speed-Safe-Driving-Co-50241104.jpg',
      creator: 'Show • Speedometer'),
];*/

/*List<PlayListItem> kPlaylistForYou = [
  PlayListItem(
    title: 'Current favorites and exciting new music. Cover: Charlie Puth',
    img:
        'https://i.pinimg.com/originals/00/08/f1/0008f11215f57750298696f2f922bdec.jpg',
  ),
  PlayListItem(
    title: 'Viral classics. Yep, we\'re at that stage.',
    img:
        'https://i.guim.co.uk/img/media/e66319b921c674d456265f30cfddb1750516c402/0_122_3905_2343/master/3905.jpg?width=445&quality=45&auto=format&fit=max&dpr=2&s=e8262c27baa05ec6ba2b0f48b95433dd',
  ),
  PlayListItem(
    title: 'A mega mix of 75 favorites from the last few years!',
    img:
        'https://images6.fanpop.com/image/photos/39000000/Billboard-Photoshoot-ed-sheeran-39022303-540-665.jpg',
  ),
];*/

class SearchListItem {
  String img;
  String title;
  String value;
  Color color;
  SearchListItem(
      {required this.title,
      required this.value,
      required this.img,
      required this.color});
}

List<SearchListItem> kPlaylistSdded = [
  SearchListItem(
    title: 'Restaurants',
    value: 'restaurant',
    img:
        'https://cdn.pixabay.com/photo/2014/09/17/20/26/restaurant-449952_960_720.jpg',
    //icon: Icon(Icons.restaurant),
    color: const Color.fromARGB(255, 194, 152, 1),
  ),
  SearchListItem(
    title: 'Bar',
    value: 'bar',
    img:
        'https://cdn.pixabay.com/photo/2017/04/07/01/01/bar-2209813_960_720.jpg',
    color: Colors.black,
  ),
  SearchListItem(
    title: 'Cafe',
    value: 'cafe',
    img:
        'https://cdn.pixabay.com/photo/2015/06/25/16/51/coffee-821490_960_720.jpg',
    color: Colors.brown,
  )
];

List<SearchListItem> kAllSearh = [
  SearchListItem(
    title: 'Restaurants',
    value: 'restaurant',
    img:
        'https://cdn.pixabay.com/photo/2014/09/17/20/26/restaurant-449952_960_720.jpg',
    //icon: Icon(Icons.restaurant),
    color: const Color.fromARGB(255, 194, 152, 1),
  ),
  SearchListItem(
    title: 'Cafe',
    value: 'cafe',
    img:
        'https://cdn.pixabay.com/photo/2015/06/25/16/51/coffee-821490_960_720.jpg',
    color: Colors.brown,
  ),
  SearchListItem(
    title: 'Bar',
    value: 'bar',
    img:
        'https://cdn.pixabay.com/photo/2017/04/07/01/01/bar-2209813_960_720.jpg',
    color: Colors.black,
  ),
  SearchListItem(
    title: 'Park',
    value: 'park',
    img:
        'https://cdn.pixabay.com/photo/2012/08/06/00/53/bridge-53769_960_720.jpg',
    color: Colors.green,
  ),
  SearchListItem(
    title: 'Museum',
    value: 'museum',
    img:
        'https://cdn.pixabay.com/photo/2016/03/27/16/23/woman-1283009_960_720.jpg',
    color: Colors.orange,
  ),
  SearchListItem(
    title: 'Tourist Attraction',
    value: 'tourist_attraction',
    img:
        'https://cdn.pixabay.com/photo/2015/05/02/19/55/foro-romano-750356_960_720.jpg',
    color: Colors.cyan,
  ),
  SearchListItem(
    title: 'Supermarket',
    value: 'supermarket',
    img:
        'https://cdn.pixabay.com/photo/2016/03/02/20/13/grocery-1232944_960_720.jpg',
    color: Colors.red,
  )
];

/*class FilterItem {
  String title;
  Function()? onTap;
  FilterItem({
    required this.title,
    this.onTap,
  });
}*/

/*List<FilterItem> kFilters = [
  FilterItem(
    title: 'Playlist',
  ),
  FilterItem(
    title: 'Artist',
  ),
];*/
