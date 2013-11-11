global class Boothforce_MobileController {
	
	@RemoteAction
	public static User fetchMyUserInfo(String userId){
		List<User> user = [ select id, name, Is_Shift_Manager__c 
							from User 
							where Id = :userId LIMIT 1];
		if(user.isEmpty())
			return null;
		else
			return user[0];
	}
	/*
		Purpose:  retrieve a list of shifts for the current user
	*/
	@RemoteAction
	public static List<Staffing_Assignment__c> fetchMyShifts(String userId){
		List<Staffing_Assignment__c> lsa = new List<Staffing_Assignment__c>();
		//we go look in the Staffing Assignments and find the shifts this user is staffing
		lsa = [ Select s.Id, s.Shift_Time__r.Shift_End_Time__c, s.Is_Shift_Manager_Booth__c,  
					s.Assigned__r.Is_Shift_Manager__c,s.Assigned__r.MobilePhone, s.Assigned__r.Phone, s.Assigned__r.FullPhotoURL, 
        			s.Assigned__r.Email, s.Assigned__r.Name, s.Assigned__c, s.Assigned__r.SmallPhotoURL,
					s.Shift_Time__r.Shift_Start_Time__c, s.Shift_Time__c, s.Shift_Start_Date_short__c, s.Users_Role__c,
					s.Shift_Time__r.Name, s.Booth__r.Zone__c, s.Booth__r.Area_Zone__c, s.Booth__r.Name, s.Booth__c,
					s.Shift_manager_booth_id__c, s.Shift_manager_shift_time_id__c
				From Staffing_Assignment__c s
				Where s.Assigned__c =: userId
				Order By s.Shift_Time__r.Shift_Start_Time__c DESC
				];
		return lsa;
	}


	@RemoteAction
    // Parameter: [Booth__c, Shift_Time__c.Id, Shift_manager_booth_id__c, shift_manager_shift_time_id__c, isShiftManager__c]
	//  myParams[0] = your booth id
	//  myParams[1] = your shift time id
	//  myParams[2] = shift manager's booth Id
	//  myParams[3] = shift manager's shift time id
	//  myParams[4] = are you a manager for this shift
    public static List<Staffing_Assignment__c> fetchShiftStaff(List<String> myParams){
		List<Staffing_Assignment__c> lsa = new List<Staffing_Assignment__c>();
		
		if(myParams[4] == 'true') //if is shift manager
		{	//if shift manager, then get people you going to check in
			//find fellow staffers
			lsa = 	[	Select s.Id, s.Assigned__r.MobilePhone, s.Assigned__r.Phone, s.Assigned__r.FullPhotoURL, 
	                		s.Assigned__r.Email, s.Assigned__r.Name, s.Assigned__c, s.Assigned__r.SmallPhotoURL,
			                s.Check_In__c, s.Is_Shift_Manager_Booth__c, s.LastModifiedDate,
			            	s.Booth__r.Zone__c, s.Booth__r.Area_Zone__c, s.Booth__r.Name, s.Users_Role__c,
			            	s.Shift_Time__r.Name, s.Shift_Time__r.Shift_End_Time__c, s.Shift_Time__r.Shift_Start_Time__c,s.Shift_Start_Date_short__c
		                From Staffing_Assignment__c s
		                Where s.Shift_manager_booth_id__c = :myParams[0]
		                AND s.Shift_manager_shift_time_id__c = :myParams[1]
		                Order By s.Assigned__r.Name ASC
	        		];
		}
		else //otherwise, get people you are working with
		{
			//find fellow staffers
			lsa = 	[	Select s.Id, s.Assigned__r.MobilePhone, s.Assigned__r.Phone, s.Assigned__r.FullPhotoURL, 
	                		s.Assigned__r.Email, s.Assigned__r.Name, s.Assigned__c, s.Assigned__r.SmallPhotoURL,
			                s.Check_In__c, s.Is_Shift_Manager_Booth__c, s.LastModifiedDate,
			            	s.Booth__r.Zone__c, s.Booth__r.Area_Zone__c, s.Booth__r.Name, s.Users_Role__c,
			            	s.Shift_Time__r.Name, s.Shift_Time__r.Shift_End_Time__c, s.Shift_Time__r.Shift_Start_Time__c,s.Shift_Start_Date_short__c,
			            	s.Shift_manager_booth_id__c, s.Shift_manager_shift_time_id__c
		                From Staffing_Assignment__c s
		                Where s.Booth__c = :myParams[0]
		                AND Shift_Time__c = :myParams[1]
		                Order By s.Assigned__r.Name ASC
        			];
		}
		return lsa;
	}

	@RemoteAction
    // Parameter: [Booth__c, Shift_Time__c.Id, Shift_manager_booth_id__c, shift_manager_shift_time_id__c, isShiftManager__c]
	//  myParams[0] = your booth id
	//  myParams[1] = your shift time id
	//  myParams[2] = shift manager's booth Id
	//  myParams[3] = shift manager's shift time id
	//  myParams[4] = are you a manager for this shift
	public static List<Staffing_Assignment__c> fetchShiftManager(List<String> myParams){ //Shift_Time__c.Id, Booth__r.Area_Zone__c.Id
		List<Staffing_Assignment__c> listOfStaffAssignment;
		
		//we go look in the Staffing Assignments and find the shifts this user is staffing
		listOfStaffAssignment =	[	SELECT s.Id, s.Assigned__r.MobilePhone, s.Assigned__r.Phone, s.Assigned__r.FullPhotoURL, 
				                		s.Assigned__r.Email, s.Assigned__r.Name, s.Assigned__c, s.Assigned__r.SmallPhotoURL,
						                s.Check_In__c, s.Is_Shift_Manager_Booth__c, 
						            	s.Booth__r.Zone__c, s.Booth__r.Area_Zone__c, s.Booth__r.Name, s.Users_Role__c,
						            	s.Shift_Time__r.Shift_End_Time__c, s.Shift_Time__r.Shift_Start_Time__c,s.Shift_Start_Date_short__c
					                From Staffing_Assignment__c s
                                    Where s.Booth__c = :myParams[2]
                                    AND Shift_Time__c = :myParams[3]
					                AND s.Is_Shift_Manager_Booth__c = true
					                Order By s.Assigned__r.Name ASC
					                ];
		
		if(listOfStaffAssignment.isEmpty())
			return null;
		else
			return listOfStaffAssignment;
	}

	@RemoteAction
	public static boolean toggleCheckIn(String staffId){
		try
		{
			Staffing_Assignment__c staff = [select id, Check_In__c from Staffing_Assignment__c where id = :staffId Limit 1];
			staff.Check_In__c = !staff.Check_In__c;
			update staff; //the Staffing_assignment__c.Check_In__c is already set before coming to this function
			return true;
		}catch(Exception e)
		{
			System.Debug(e);
			return false;
		}
	}

	@RemoteAction
	public static User fetchUserManager(String userId){
		User me = [select id, managerId from User where id = :userId Limit 1];
		List<User> managers = [ select id, Name, Phone, MobilePhone, email, UserRole.Name, FullPhotoURL 
								from User 
								where id = :me.managerId Limit 1];
		if(managers.isEmpty())
			return null;
		else
			return managers[0];
	}

	@RemoteAction
	public static List<Booth__c> fetchManagerBooths(){
		List<Booth__c> managersBooths = [ 	SELECT id, Name
											FROM Booth__c 
											WHERE Is_Shift_Manager_Booth__c = true
											ORDER BY NAME ASC];
		if(managersBooths.isEmpty())
			return null;
		else
			return managersBooths;
	}

	@RemoteAction
	public static List<Shift_Time__c> fetchManagerShiftTimes(String managerBoothId){
		List<Shift_Time__c> managersShiftTime;
		if(managerBoothId == null) //if no booth area specified
			managersShiftTime = [ 	SELECT id, name, Shift_Start_Time__c, Shift_End_Time__c
									FROM Shift_Time__c 
									WHERE Is_Manager_Shift_Time__c = true
									ORDER BY Shift_Start_Time__c ASC];
		else //get shiftTime in booth's area
		{	
			Booth__c b = [SELECT Area_Zone__c FROM Booth__c WHERE Id = :managerBoothId];
			managersShiftTime = [ 	SELECT id, name, Shift_Start_Time__c, Shift_End_Time__c
									FROM Shift_Time__c 
									WHERE Area_Zone__c = :b.Area_Zone__c
									AND Is_Manager_Shift_Time__c = true
									ORDER BY Shift_Start_Time__c ASC];
		}
		if(managersShiftTime.isEmpty())
			return null;
		else
			return managersShiftTime;
	}

}