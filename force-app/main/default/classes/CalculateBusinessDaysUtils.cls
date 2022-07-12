public class CalculateBusinessDaysUtils {
    //List<Holiday> holidayList = new List<Holiday>();
    public CalculateBusinessDaysUtils(){
        //Fetch all holiday list from the organization- you can check this from             //setup-->Company Profile-->Holidays
         //holidayList=[Select StartTimeInMinutes, Name, ActivityDate From Holiday];
    }
    public static integer CalculateWorkingDays(date startdt, Date enddt){
        
        List<Holiday> holidayList = new List<Holiday>();
        holidayList=[Select StartTimeInMinutes, Name, ActivityDate From Holiday];
// to include both start and end date in calculation, add 1 with days //difference.
        Integer allDaysBetween = startdt.daysBetween(enddt)+1;
        system.debug('**allDaysBetween'+allDaysBetween);
        Integer allWorkingDays=0;
        //If start date and end date are same, then check is this date not fall in //holiday or weekoff
        if(startdt == enddt){
            system.debug('**startdt'+startdt+'enddt'+enddt);
            boolean isHoliday= false;
            //For excluding weekoff- week starts with Monday,As my week starts               //with sunday subtract 1 from weekstart. 
            Date weekStart = startdt.toStartofWeek().addDays(-1);
            system.debug('**weekStart'+weekStart);
           for(Holiday hDay:holidayList){
                if(startdt.daysBetween(hDay.ActivityDate) == 0){
                    isHoliday= true;
                }
            }
            if(weekStart.daysBetween(startdt) ==7 || weekStart.daysBetween(startdt) == 6){
               isHoliday= true;
            }
            system.debug('**isHoliday'+isHoliday);
            if(isHoliday == false){
                allWorkingDays = 1;
            }
        }
        else{//start date and end date are not same, so need to loop with all //dates to exclude weekoff and holiday list
            for(Integer k=0;k<allDaysBetween ;k++ ){
                if(checkifItisWorkingDay(startdt.addDays(k),holidayList)){
                    system.debug('**working day:'+startdt.addDays(k));
                    allWorkingDays++;//increment working date for each working //date.
                } 
            }
        }
        System.debug('### allWorkingDays:'+ allWorkingDays);
        return allWorkingDays;
    }
    public static boolean checkifItisWorkingDay(Date currentDate,List<Holiday> holidays){
        system.debug('**currentDate'+currentDate);
        Date weekStart = currentDate.toStartofWeek().addDays(-1);

        system.debug('**weekStart'+weekStart);
        for(Holiday hDay:holidays){
            //if date fall inholiday then return false.
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        //if date fall in weeknd return false
        if(weekStart.daysBetween(currentDate) ==7 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else{//if date is not in holiday list and not in weekoff, return true to //indicate as working date.
            return true;
        }
      }

}