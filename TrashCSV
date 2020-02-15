//Author: Paul Fry - Shaker Heights City Schools
//function to delete previous CSV
function trashCSV() {
  //select the csv file named EMPLOYEE_INFO.csv
var files = DriveApp.getFilesByName('EMPLOYEE_INFO.csv');
  //set selected file to trashed
 while (files.hasNext()) {
   files.next().setTrashed(true);
   }
  }
