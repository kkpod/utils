// Assuming you already have a Date object, for example:
var endDate = new Date(date); // 'date' is the value you already have

// Format the date to mm/dd/yy
var formattedDate = (endDate.getMonth() + 1).toString().padStart(2, '0') + '/' + 
                    endDate.getDate().toString().padStart(2, '0') + '/' + 
                    endDate.getFullYear().toString().slice(2);

// Set the value of the text field
$("#start-date").val(formattedDate);
