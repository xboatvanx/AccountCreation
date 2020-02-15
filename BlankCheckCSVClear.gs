//Author: Paul Fry - Shaker Heights City Schools
//function to check if cell A2 is blank. 
function blank()
{
	{
		{ 
		//Combines Two CSV Export Functions
		function CSV()
		{
			//function to export sheet to CSV
			function saveAsCSV() 
			{
				//Get the current sheets project
			var ss = SpreadsheetApp.getActiveSpreadsheet();
			//Get first and only sheet in project
			var sheet = ss.getSheets()[0];
			//defines the Employee Onboarding folder as the place to export the CSV to 
			var folderX = DriveApp.getFolderById('1RWzPIVXy2qxb8dwmhbHpha1EgwPqDmyv'); 
			// append ".csv" extension to the sheet name
			fileName = "EMPLOYEE_INFO"+".csv";
			// convert all available sheet data to csv format by calling the next function in the script starting on line 19 called convertRangeToCSV
			var csvFile = convertRangeToCSV(fileName, sheet);
			// create a file in the Docs List with the given name and the csv data
			folderX.createFile(fileName, csvFile);
			
		//function to change all data in sheet to be able to export to CSV
            }
		function convertRangeToCSV(csvFileName, sheet) 
		{
		// get available data range in the spreadsheet
		var activeRange = sheet.getDataRange();
			//try 
			{
				var data = activeRange.getValues();
				var csvFile = undefined;

					// loop through the data in the range and build a string with the csv data
					if (data.length > 1) 
					{
						var csv = "";
							for (var row = 0; row < data.length; row++) 
							{
								for (var col = 0; col < data[row].length; col++) 
								{
									if (data[row][col].toString().indexOf(",") != -1) 
									{
										data[row][col] = "\"" + data[row][col] + "\"";
									}
								}
									// add a carriage return to end of each row, except for the last one
									if (row < data.length-1) 
									{
										csv += data[row].join(",") + "\r\n";
									}
									else 
									{
										csv += data[row];
									}
							}
					csvFile = csv;
					}
				return csvFile;
			}

		}
            	saveAsCSV(); 

//error checking?
//catch(err) {
//Logger.log(err);
//Browser.msgBox(err);
	}
	
	//now that both functions are defined/nested, this part actually runs the first function to export the CSV
	//utilities.sleep(200);// pause in the loop for 200 milliseconds 
	}

//function to clear google sheet after CSV export
function clearRange() 
	{
		//select active project in sheets
		var ss = SpreadsheetApp.getActiveSpreadsheet();
		//select page 0 of active project
		var sheet = ss.getSheets()[0];
		//start = row 2 and end = last row with data
		var start, end;
		//select rows 2 - last row with data
			start = 2;
			end = sheet.getLastRow() - 1;
			//delete selected rows
			sheet.deleteRows(start, end);
	}
//calls active Google Sheets project
var ss = SpreadsheetApp.getActiveSpreadsheet();
//calls sheet 0 of project
var sheet = ss.getSheets()[0];
//defines A2 as the cell to look in
var range = sheet.getRange("A2");
//logic to see if there is data in A2 (true=blank false=not blank)
var cell = range.isBlank(); 
  
	//If there is data in A2, continues onto the script that exports CSV
	if (cell == false)
	{CSV(); 
	Utilities.sleep(200);// pause in the loop for 200 milliseconds
	//After waiting 200ms, clear the sheet function
	clearRange();}
	//Or else there is no data in A2, so the script will stop
    {
     return;
    }
    }
}
