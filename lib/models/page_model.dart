class PageModel {
  PageModel();

  int page = 1;
  int pageSize = 10;

  void resetPage() {
    page = 1;
  }

  void addPage() {
    page += 1;
  }
}