
//right padding function
String.prototype.rpad = function(padString, length) {
	var str = this;
    while (str.length < length)
        str = str + padString;
    return str;
}

var allColls = db.getCollectionNames();
var eventsColls = allColls.filter(function (coll) {
    return coll.indexOf("events.") == 0
});

print ('');
print('+-----------------------------------------------------------------------+-----------------------------+'); 
print('| Collection                                                            | used/allocated space (MB)   |'); 
print('+-----------------------------------------------------------------------+-----------------------------+'); 

totalUsed = 0;
totalAllocated = 0;
for (var i in eventsColls) {
    used = db[eventsColls[i]].dataSize()/(1024*1024);
    allocated = db[eventsColls[i]].totalSize()/(1024*1024);
    occupation = Math.round(used) + '/' + Math.round(allocated);
    print('| ' + eventsColls[i].rpad(' ', 70) + '| ' + occupation.rpad(' ', 28) + '|');
    totalUsed += used;
    totalAllocated += allocated;
}
totalOccupation = Math.round(totalUsed) + '/' + Math.round(totalAllocated) ;
print('+-----------------------------------------------------------------------+-----------------------------+'); 
print('| Total                                                                 | ' + totalOccupation.rpad(' ', 28) + '|');
print('+-----------------------------------------------------------------------+-----------------------------+'); 
print ('');

