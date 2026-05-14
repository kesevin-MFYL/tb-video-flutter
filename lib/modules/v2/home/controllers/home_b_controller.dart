import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBController extends BaseController with GetSingleTickerProviderStateMixin {
  var multiStatusType = MultiStatusType.statusLoading;

  late TabController tabController;

  var homeSectionList = <HomeSectionEntity>[];

  @override
  void fetchData() async {
    _getHomeSection();
    // final result = await HomeApi.getHomeSection();
    // if (result.isSuccess) {
    //   final listData = result.responseData?.data;
    //   commonDebugPrint('1111111-------${listData![0].title}');
    // }
  }

  void _getHomeSection() async {
    Future.delayed(Duration(seconds: 5), () {
      homeSectionList = [
        HomeSectionEntity(
          id: 1,
          title: "Featured today",
          kind: "imdb_list",
          dataList: [
            MediaItemEntity(
              id: 1,
              imdbType: "",
              title: "5 Things to Watch This Week",
              cover: "https://m.media-amazon.com/XkFqcGc@._V1_.jpg",
            ),
            MediaItemEntity(
              id: 2,
              imdbType: "",
              title: "5 Things to Watch This Week",
              cover: "https://m.media-amazon.com/XkFqcGc@._V1_.jpg",
            ),
            MediaItemEntity(
              id: 3,
              imdbType: "",
              title: "5 Things to Watch This Week",
              cover: "https://m.media-amazon.com/XkFqcGc@._V1_.jpg",
            ),
            MediaItemEntity(
              id: 4,
              imdbType: "",
              title: "5 Things to Watch This Week",
              cover: "https://m.media-amazon.com/XkFqcGc@._V1_.jpg",
            ),
            MediaItemEntity(
              id: 5,
              imdbType: "",
              title: "5 Things to Watch This Week",
              cover: "https://m.media-amazon.com/XkFqcGc@._V1_.jpg",
            ),
          ],
        ),
        HomeSectionEntity(
          id: 3,
          title: "Top 10 on IMDb this week",
          kind: "media_list",
          dataList: [
            MediaItemEntity(
              id: 20121,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20122,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20123,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20124,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20125,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20126,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20127,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20128,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20129,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
            MediaItemEntity(
              id: 20130,
              title: "Happy Gilmore",
              pubDate: "1996-02-16",
              cover: "http://autoeq.top/m_cover/mc_151189d58845b9d23e2.jpg",
              rate: "7",
              quality: "HD",
              genreList: ["Comedy"],
              type: 1,
              storageTimestamp: 1710141417.3598416,
              trailer: "https://www.youtube.com/embed/M_6q6FV5NcQ",
              certification: "PG-13",
              imdbId: "tt0116483",
            ),
          ],
        ),
        HomeSectionEntity(
          id: 5,
          title: "Popular interests",
          kind: "imdb_interest",
          dataList: [
            MediaItemEntity(
              id: 1,
              title: "Superhero",
              cover: "https://m.media-amazon.com/imBnXkFtZTcwNTg4OTY3Nw@@._V1_.jpg",
            )
          ],
        ),
        HomeSectionEntity(
          id: 10,
          title: "Explore what’s streaming",
          kind: "streaming_media",
          dataList: [
            MediaItemEntity(
              title: "Disney+",
              dataList: [
                MediaItemEntity(
                  id: 12993,
                  title: "Arthur 3: The War of the Two Worlds",
                  pubDate: "2010-08-22",
                  cover: "http://autoeq.top/m_cove6aed4d9534e.jpg",
                  rate: "5.5",
                  quality: "HD",
                  genreList: ["Animation"],
                  type: 1,
                  storageTimestamp: 1710146060.9857771,
                  trailer: "https://www.youtube.com/embed/jc3muhC5HKU",
                  imdbId: "tt11041332",
                )
              ],
            ),
            MediaItemEntity(
              title: "Netflix",
              dataList: [
                MediaItemEntity(
                  id: 12994,
                  title: "Stranger Things",
                  pubDate: "2016-07-15",
                  cover: "https://m.media-amazon.com/images/M/MV5BMDZkYmVhNjUtNDIaMGExOC00MWE1LWEzNDktODhZTI1YTNmZjYxXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg",
                  rate: "8.7",
                  quality: "HD",
                  genreList: ["Drama", "Fantasy", "Horror"],
                  type: 1,
                  trailer: "https://www.youtube.com/embed/b9EkMc79ZSU",
                  imdbId: "tt4574334",
                )
              ],
            )
          ],
        )
      ];
      tabController = TabController(length: homeSectionList.length, vsync: this);
      multiStatusType = MultiStatusType.statusContent;
      update();
    });
    // final result = await HomeApi.getHomeSection();
    // if (result.isSuccess) {
    //   final listData = result.responseData?.data;
    //   homeSectionList = listData ?? [];
    //   multiStatusType = MultiStatusType.statusSuccess;
    // } else {
    //   multiStatusType = MultiStatusType.statusError;
    // }
    // update();
  }

  void viewAll(HomeSectionEntity section) {

  }
}