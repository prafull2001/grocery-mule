class ListData{
  String name;
  String description;
  DateTime date;
  String unique_id;

  ListData(String tripTitle, String tripDescription, DateTime tripDate, String id){
    name = tripTitle;
    description = tripDescription;
    date = tripDate;
    unique_id = id;
  }
}