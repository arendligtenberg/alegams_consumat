/**
* Name: Alemans_farm
* Author: Ligte002
* Description: 
* Tags: Tag1, Tag2, TagN
*/
model Alegams_farm

import "./Alegams_globals.gaml"
import "./Alegams_plot.gaml"
import "./Alegams_base.gaml"
species farm
{	
	float step <- 1 #month;
	//declaration of the farm characteristics
	plot farmPlot;
	list<farm> neighbours;
	list plot;
	//int plotId;
	//int nr_Plots;
	int hh_Size;
	float HH_Account;
	//float income <- 0.0;
	float loan <- 0.0;
	float costs <- 0.0;	
	float max_loan;
	int age; //years
	//float interest_Bank;
	//float interest_Commercial;
	//int nr_Labour;
	//int prob_Shift;
	//int time; //month
	int grow_Time_INT; //month
	int grow_Time_IE; //month
	int grow_Time_IMS; //month
	//int INT_fail_time;
	//int IE_fail_time;
	//int INT_sucess_time;
	//int IE_sucess_time;
	int cycle_INT;
	int cycle_IE;
	int cycle_IMS;
	int reduce_time <- 0;
	//int INT_abandon_time <-0;
	float INT_abandoned_area;
	bool reduce_INT <- false;
	bool reduce_IE <- false;
	float crop_cost;
	float income_from_INT;
	float income_from_IE;
	float income_from_IMS;
	float actual_Income;
	float potential_Income;
	float second_Income;
	float investment_cost;
	float seed_cost;
	bool shifted;
	bool doOnce;
	//int nr_of_Neighbor_whith_intensive;
	//int nr_of_Neighbor;
	list<float> actual_incomeList <- [];
	list<float> potential_incomeList <- [];	
	list<float> delta_incomeList <- [];	
	list<float> HH_account_List <- [];
	list<float> costList <- []; 
	list<float> loanList <- [];

	//moved to upper level so these variable can be accessed by alle action/functions (arend 31082017) 
	float int_cost <- 0.0;
	float ie_cost <- 0.0;
	float ims_cost <- 0.0;
	float maintain_cost <- 0.0;
	//float hh_cost <- 0.0;

	//consumat variables
	float ExistenceNeed <- 0.0;
	float SocialNeed <- 0.0;
	float PersonalNeed <- 0.0;
	float Satisfaction <- 0.0;
	float Uncertainty <- 0.0;
	float Happyness <- 0.0;
	bool satisFied <- false;
	bool certain <- false;		
	bool buildList <- true;
	list<farm> closeNeighbours <- [];
	list<string> shiftList <- [];
	//int nrOfMutations <- 0;
	string lastBehaviour;
	string changedTo;
	
	init
	{
		doOnce <- true;
		hh_Size <- rnd(2, 5);
		age <- rnd(22, 70);
		time <- rnd(1,12);
		grow_Time_INT <- rnd(0, time_Harvest_INT);
		grow_Time_IE <- rnd(0, time_Harvest_IE);
		grow_Time_IMS <- rnd(0, time_Harvest_IMS);
		cycle_INT <- rnd(0, max_cycle_INT);

		cycle_IE <- rnd(0, max_cycle_IE);
		cycle_IMS <- rnd(0, max_cycle_IMS);
    	HH_Account <- rnd(-400.0, 400.0); 
		grow_Time_IMS <- 0; //month
		//INT_fail_time <- 0;
		//IE_fail_time <- 0;
		//INT_sucess_time <- 0;
		//
		//IE_sucess_time <- 0;
		shifted <- false;
		//INT_abandoned_area <- 0;
		//INT_abandon_time <-0;	
	}

	reflex reinitialize
	{				
		if debug
		{
			write " ";
			write "FARMER: " + name;
			write "----------------------------";
		}


		if buildList{
			//closeNeighbours <- getXClosestsFarms(11);
			closeNeighbours <- farm closest_to(self,11);
			buildList <- false;
		}

		max_loan <- (max_loan_INT * farmPlot.area_INT) + (max_loan_IE * farmPlot.area_IE) + (max_loan_IMS * farmPlot.area_IMS);
		
		if doOnce
		{
			set neighbours <- agents_at_distance(radius_neighbors) of_species (species(self));
			loan <- rnd(0.0, max_loan);
			set doOnce <- false;
		}

		if time = 12
		{
			time <- 0;
			//INT_fail_time <- 0;
			//IE_fail_time <- 0;
			//INT_sucess_time <- 0;
			//IE_sucess_time <- 0;
		}



		time <- time + 1;
		//shifted <- false;
		//investment_cost <- 0.0;
	}

	reflex calc_crop_costs
	{
		crop_cost <- 0.0;
		seed_cost <- 0.0;
		maintain_cost <- 0.0;				
		if debug
		{
			write "...calculating costs";
		}

		//INT
		if farmPlot.area_INT > 0
		{
				if grow_Time_INT = 0
				{
					seed_cost <- seed_cost + shrimp_init_INT * farmPlot.area_INT;
					int_cost <- gauss({ Cost_1st_month_INT, cropcost1st_stddev_INT }) * farmPlot.area_INT;
				} else
				{
					int_cost <- gauss({ Nomal_cost_INT, Nomal_cost_stddev_INT }) * farmPlot.area_INT;
				}
		}
		
		//IE
		if farmPlot.area_IE > 0
		{
			if grow_Time_IE = 0
			{
				seed_cost <- seed_cost + shrimp_init_IE * farmPlot.area_IE;
				ie_cost <- gauss({ Cost_1st_month_IE, cropcost1st_stddev_IE }) * farmPlot.area_IE; //crop cost in the first month for improve extensive farm;
			} else
			{
				ie_cost <- gauss({ Nomal_cost_IE, Nomal_cost_stddev_IE }) * farmPlot.area_IE;
			}
		}

		//IMS
		if farmPlot.area_IMS > 0
		{
			if grow_Time_IMS <= 0
			{
				seed_cost <- seed_cost + shrimp_init_IMS * farmPlot.area_IMS;
				ims_cost <- gauss({ Cost_1st_month_IMS, cropcost1st_stddev_IMS }) * farmPlot.area_IMS; //crop cost in the first month for integrated mangrove shrimp farm;
			} else
			{
				ims_cost <- gauss({ Nomal_cost_IMS, Nomal_cost_stddev_IMS }) * farmPlot.area_IMS;
			}

		}

		//Add maintance cost for clean ponds etc. at the end of each cycle (arend 23082017)
		if cycle_INT = max_cycle_INT 
		{
			maintain_cost <- maintain_cost + (mantain_cost_INT * farmPlot.area_INT);
			cycle_INT <- 0;
		}


		if cycle_IE = max_cycle_IE
		{
			maintain_cost <- maintain_cost + (mantain_cost_IE * farmPlot.area_IE);
			cycle_IE <- 0;
		}

		if cycle_IMS = max_cycle_IMS
		{
			maintain_cost <- maintain_cost + (mantain_cost_IMS * farmPlot.area_IMS);
			cycle_IMS <- 0;
		}

		crop_cost <- crop_cost + int_cost + ie_cost + ims_cost + maintain_cost+ seed_cost; //crop cost is calculate by summing all cost between  amount  of intensive cost, improve extensive and integrated mangrove shrimp	
	}

	//calculate max income from harvest when nothing goes wrong	
	reflex calculatePotentialIncome{
		let shrimp_price_INT <- 0.0;
		let crop_yield_INT <- 0.0;
		potential_Income <- (farmPlot.area_IMS * crop_yield_IMS * shrimp_price_IMS) +  (farmPlot.area_IE * crop_yield_IE * shrimp_price_IE) + (farmPlot.area_INT * crop_yield_INT *shrimp_price_INT);
	}


	// calculate second income for every cycle	
	reflex calc_
	{
		if debug
		{
			write "...calculating second income";
		}
		//reset some stuff
		second_Income <- 0.0;
		float int_second <- 0.0;
		float ie_second <- 0.0;
		float ims_second <- 0.0;
		if farmPlot.area_INT > 0
		{
			int_second <- gauss({ HH_2ndincome_avg_INT, HH_2ndincome_stddev_INT }) * hh_Size;
		}

		//second income from IE
		if farmPlot.area_IE > 0
		{
			ie_second <- gauss({ HH_2ndincome_avg_IE, HH_2ndincome_stddev_IE }) * hh_Size;
		}
		//second income from IIMS
		if farmPlot.area_IMS > 0
		{
			ims_second <- gauss({ HH_2ndincome_avg_IMS, HH_2ndincome_stddev_IMS }) * hh_Size;
		}
		//total second income
		second_Income <- int_second + ie_second + ims_second;
	}

	reflex check_for_harvest_of_Intensive when: farmPlot.area_INT > 0
	{
		income_from_INT <- 0.0;
		farmPlot.yield_INT <- 0.0;		
		if debug
		{
			write "...check harvest intensive system";
		}
		//incase of disease
		if flip(farmPlotFailureRate_INT)
		{
		//write "disease at growth time: "+ INT_fail_time;
			//if  grow_Time_INT >= time_Harvest_fail_INT
			//{
				farmPlot.yield_INT <- ((costLossFactor*grow_Time_INT) / time_Harvest_INT) * crop_yield_INT * farmPlot.area_INT;
				income_from_INT <- farmPlot.yield_INT * shrimp_price_INT;
				if grow_Time_INT >= time_Harvest_fail_INT
				{
					cycle_INT <- cycle_INT + 1;
				}
			//}
			//INT_fail_time <- INT_fail_time + 1;
			grow_Time_INT <- 0;
		} else
		{ //check for harvest incase of no disease
				if grow_Time_INT < time_Harvest_INT //  farm can not be harvest
				{
					grow_Time_INT <- grow_Time_INT + 1; //model will check time for harvest in the next time step
				} else //farm can be harvested
				{
				//write "healthy harvest";
					farmPlot.yield_INT <- crop_yield_INT * farmPlot.area_INT;
					income_from_INT <- farmPlot.yield_INT * shrimp_price_INT;
					cycle_INT <- cycle_INT + 1;
					grow_Time_INT <- 0;
					//INT_sucess_time <- INT_sucess_time + 1;
				}

			}
	}

	reflex check_for_harvest_of_Improved_Extensive when: farmPlot.area_IE > 0
	{
		income_from_IE <- 0.0;	
		farmPlot.yield_IE <- 0.0;

		if debug
		{
			write "...check harvest improved extensive system";
		}

		if flip(farmPlotFailureRate_IE)
		{ //in case of the farm get disease when the farm can not be harvest at that moment
			farmPlot.yield_IE <- ((costLossFactor*grow_Time_IE) / time_Harvest_IE) * crop_yield_IE * farmPlot.area_IE;
			if grow_Time_IE >= time_Harvest_fail_IE
			{
				cycle_IE <- cycle_IE + 1;
			}
			//IE_fail_time <- IE_fail_time + 1;			
			grow_Time_IE <- 0;

		} else
		{ //in case of no disease
			if grow_Time_IE < time_Harvest_IE
			{
				grow_Time_IE <- grow_Time_IE + 1;
			} else
			{
				farmPlot.yield_IE <- crop_yield_IE * farmPlot.area_IE;
				cycle_IE <- cycle_IE + 1;
				//IE_sucess_time <- IE_sucess_time + 1;
				grow_Time_IE <- 0;
			}
		}

		income_from_IE <- farmPlot.yield_IE * shrimp_price_IE;
	}

	reflex check_for_harvest_of_Integrated_Mangrove when: farmPlot.area_IMS > 0
	{
		income_from_IMS <- 0.0;
		farmPlot.yield_IMS <- 0.0;
		if debug
		{
			write "...check harvest mangrove system";
		}

		if flip(farmPlotFailureRate_IMS)
		{
			farmPlot.yield_IMS <- ((costLossFactor*grow_Time_IMS) / time_Harvest_IMS) * crop_yield_IMS * farmPlot.area_IMS;
			if grow_Time_IMS >= time_Harvest_fail_IMS
			{
				cycle_IMS <- cycle_IMS + 1;
			}
			grow_Time_IMS <- 0;
		} else
		{ //in case of no disease
			if grow_Time_IMS < time_Harvest_IMS
			{
				grow_Time_IMS <- grow_Time_IMS + 1;
			} else
			{
				farmPlot.yield_IMS <- crop_yield_IMS * farmPlot.area_IMS;
				grow_Time_IMS <- 0;
			}
		}
		income_from_IMS <- farmPlot.yield_IMS * shrimp_price_IMS;
	}


	
	
	reflex reset_Int_time when: farmPlot.area_INT = 0
	{
		grow_Time_INT <- 0;
	}

	reflex reset_IE_time when: farmPlot.area_IE = 0
	{
		grow_Time_IE <- 0;
	}

	reflex reset_IMS_time when: farmPlot.area_IMS = 0
	{
		grow_Time_IMS <- 0;
	}


	reflex shift_from_reduced when: farmPlot.area_Reduced > 0 and length(actual_incomeList) = memDepth
	{
		//if reduce_time >= time_reuse_after_reduce 
		//if HH_Account > max_loan
		//{
			if debug
			{
				write "Recropping reduced area ";
			}

			HH_Account <- rnd(0, (avg_income));
			if farmPlot.production_System_Before_Reduce = INT and HH_Account < Cost_1st_month_INT * farmPlot.area_INT
			{
				farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_Reduced;
				set farmPlot.shrimp_Type <- rnd(monodon, vanamei);
				farmPlot.area_Reduced <- 0.0;
			} else if HH_Account < Cost_1st_month_IE * farmPlot.area_IE
			{
				farmPlot.area_IE <- farmPlot.area_IE + farmPlot.area_Reduced;
				farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)			
				farmPlot.area_Reduced <- 0.0;
			}
			reduce_time <- 0;
//		} else
//		{
//			reduce_time <- reduce_time + 1;
//		}
	}

	
	reflex updateMemory{
		if debug{
			write "...Update memory";
		}
		float delta_Income;
		if potential_Income > 0{
			delta_Income <- abs(actual_Income - potential_Income);	
			//write "pot inc: "+ potential_income+ " act inc: "+actual_income+" delta inc: "+delta_income;
		}else{
			delta_Income <- 0.0;
			}
		if length(actual_incomeList) < memDepth{
			add actual_Income at: 0 to: actual_incomeList;
			add potential_Income at: 0 to: potential_incomeList;
			add delta_Income at: 0 to: delta_incomeList;
			add HH_Account at: 0 to: HH_account_List;				
			add costs at: 0 to: costList;
			//add loan at: 0 to: loanList;
		}else{
			remove index: memDepth-1 from: actual_incomeList;
			remove index: memDepth-1 from: potential_incomeList;			
			remove index: memDepth-1 from: delta_incomeList;			
			remove index: memDepth-1 from: HH_account_List;			
			remove index: memDepth-1 from: costList;
			//remove index: memDepth-1 from: loanList;
			add actual_Income at: 0 to: actual_incomeList;
			add actual_Income at: 0 to: potential_incomeList;
			add delta_Income at: 0 to: delta_incomeList;
			add HH_Account at: 0 to: HH_account_List;									
			add costs at: 0 to: costList;
			//add loan at: 0 to: loanList;
		}
	}
	
	
	reflex calculateExistenceNeed when: length(actual_incomeList) = memDepth{
		if debug{
			write"...Calculate existence need";
		}
		float avgIncome <- mean(actual_incomeList);	
		float avgCosts <- mean(costList);	
		//float avgLoan <- mean(loanList);
		if (avgCosts) > 0{	
			ExistenceNeed <- (avgIncome - avgCosts) / (avgCosts);
			if ExistenceNeed > 1 { ExistenceNeed <- 1.0; }
			if ExistenceNeed < 0  { ExistenceNeed <- 0.0; }	
			//write "avgIncome: "+avgIncome+" avgCosts: "+ avgCosts + " existenceNeed:  "+ ExistenceNeed;	
		}
	}

	reflex calculateSocialNeed when: length(actual_incomeList) = memDepth{
		if debug{
			write"...Calculate social need";
		}
		
		// first get average income of peers
		float avgNeigbourIncome <- mean (closeNeighbours collect (mean(each.actual_incomeList)));
		//write avgNeigbourIncome;
		float avgIndividualIncome <- mean(actual_incomeList);	
		if avgNeigbourIncome > 0{
			//float IncomeRatio <- HH_Account/avgNeigbourIncome;
			SocialNeed <- avgIndividualIncome / avgNeigbourIncome;
			if SocialNeed > 1 { SocialNeed <- 1.0; }
			if SocialNeed < 0  { SocialNeed <- 0.0; }
			//write	SocialNeed;
		}  		
	}

	
	reflex calculatePersonalNeed{ // when: length(actual_incomeList) = memDepth{
		if debug{
			write"...Calculate personal need";
		}
		
		if age < 30 {
			PersonalNeed  <- 1.0;
		}
		else if age > 50 {
			PersonalNeed <- 0.7;
		} 
		else{
			PersonalNeed <- 0.0;
		}	
	}

	reflex calculateSatisfaction{ //when: length(actual_incomeList) = memDepth{
		if debug{
			write"...Calculate satisfaction level";
		}
		
		float wE <- 0.8;
		float wS <- 0.2;
		float wP <- 0.0;		
		Satisfaction <- (wE * ExistenceNeed) + (wS * SocialNeed) + (wP * PersonalNeed);
		if debug{
			write "      "+Satisfaction;
		}
	}

	reflex calculateUncertainty{  //when: length(actual_incomeList) = memDepth{
		if debug{
			write"...Calculate uncertainty level";
		}
	
		float avgIncome <- mean(HH_account_List);
		float stdIncome <- standard_deviation(HH_account_List);
		//write "avg: "+ avgDeltaIncome+"std: "+stdDeltaIncome;
		if avgIncome != 0{
			Uncertainty <- abs(baseUncertainty + ((stdIncome)/ avgIncome));
		}else{
			Uncertainty <- 0.9;
		}
		if Uncertainty > 1.0{Uncertainty <- 1.0;}	
		if Uncertainty < 0.0 {Uncertainty <- 0.0;}		
			//if debug{
			//	write "      "+Uncertainty;
			//}
	}

	reflex chooseBehaviour when: length(actual_incomeList) = memDepth{ 
		//write  "S : "+Satisfaction;
		//write  "U : "+Uncertainty;
		if Satisfaction > ST {satisFied <- true;}else{satisFied <- false;}
		if Uncertainty  <= UT  {certain <- true;}else{certain <- false;}
		if satisFied and certain{
			if debug{
				write"...Repeating";
			}
			lastBehaviour <- "repeat";
			do repeat;
		}
		if satisFied and !certain{
			if debug{
				write"...Imitating";
			}
			lastBehaviour <- "imitate";			
			do imitate;
		}
		if !satisFied and !certain{
			if debug{
				write"...Inquiring";
			}
			lastBehaviour <- "inquire";			
			do inquire;
		}
		if !satisFied and certain{
			if debug{
				write"...Optimizing";
			}
			lastBehaviour <- "optimise";			
			do optimise;
		}
	}

    reflex update_loan_and_bank
	{
		if debug
		{
			write "...Update bank and loans";
		}

		if debug2
		{
			write "system: " + farmPlot.production_System;
			write "HH_Account before: " + HH_Account;
			write "loan before " + loan;
		}

		float hh_cost <- hh_Size * HH_expenses_avg;
		actual_Income <- income_from_INT + income_from_IE + income_from_IMS;
		costs <- hh_cost + crop_cost + investment_cost;
		let balance <- (actual_Income + second_Income)  - costs;
		let loan_Mutation <- 0.0;
//		if loan > 0{
//			if (HH_Account + balance) < costs
//			{
//				loan_Mutation <- costs;
//				if (loan + loan_Mutation) > max_loan
//				{
//					loan_Mutation <- max_loan - loan;
//				}
//	
//			} else if (HH_Account + balance) > (2 * costs)
//			{
//				if loan > 0
//				{
//					loan_Mutation <- (-0.1 * loan);
//				}
//	
//				if loan <= 0
//				{
//					loan_Mutation <- 0.0;
//				}
//				}
//		}

		//set HH_Account <-round(HH_Account + balance + loan_Mutation) with_precision 2;
		set HH_Account <-round(HH_Account + balance) with_precision 2;		
		//set loan <- round(loan + loan_Mutation) with_precision 2;
		if debug2
		{
			write "costs: " + costs;
			write "income: " + actual_Income + second_Income;
			write "balance: " + balance;
			write "max loan: " + max_loan;
			write "loan mutation: " + loan_Mutation;
			write "HH_Account after: " + HH_Account;
			write "loan after " + loan;
			write "=====================";
		}
		
			//reset investment cost
	}

//actions
	action repeat{
	bool shifted_system <-  false;
	//basically nothing happens, only check if continuing is still vitat
	bool hasINT <- false;
	bool hasIE <- false;
	if farmPlot.area_INT > 0 {hasINT <- true;}
	if farmPlot.area_IE > 0{ hasIE <- true;}
	
	if hasINT and hasIE { 
		shifted_system <- self reduce_cropping(INT);
	}else if hasINT and !hasIE { 
		shifted_system <- self reduce_cropping(INT);
	}else if !hasINT and hasIE {
		shifted_system <- self reduce_cropping(IE);
	}
	if shifted_system{do updateMutationRegistration(shifted_system, "REDUCE");}
 	
 	//if shifted_system {add 'REDUCE' to: shiftList; changedTo <- 'REDUCE';} else{add 'NONE'  to: shiftList; changedTo <- 'NONE';}
	}

	action imitate{
			bool shifted_system <- false;
			map<int,int> prodSystem_frequenties <- closeNeighbours frequency_of each.farmPlot.production_System;
			int productionSystemToMoveTo <- prodSystem_frequenties index_of (max(prodSystem_frequenties));
			if productionSystemToMoveTo = INT{
				if farmPlot.area_IE > min_INT_size{
					shifted_system <-  self shift_IE_to_INT[];
				}else if farmPlot.area_IMS > min_INT_size{
					shifted_system <- self shift_IMS_to_INT[];
				}
				if shifted_system{do updateMutationRegistration(shifted_system, "INT");}
			}
			if productionSystemToMoveTo = IE{
				shifted_system <- self shift_INT_to_IE[];
		 		if shifted_system{do updateMutationRegistration(shifted_system, "IE");}			
			}
			
			if productionSystemToMoveTo = IMS{
				shifted_system <- self shift_INT_to_IMS[];
				if shifted_system{do updateMutationRegistration(shifted_system, "IMS");}										   
			}
			if !shifted_system{
				do inquire;
			}
		}


	action inquire{
			bool shifted_system <- false;
			int productionSystemToMoveTo <- self.farmPlot.production_System;
			list<farm> moreSatisfiedFarms <- getXRandomMoreSatisfiedFarms(10); 
			if length(moreSatisfiedFarms) > 0{				
				map<int,int> prodSystem_frequenties <- moreSatisfiedFarms frequency_of each.farmPlot.production_System;
				int productionSystemToMoveTo <- prodSystem_frequenties index_of (max(prodSystem_frequenties));
			}
			if productionSystemToMoveTo = INT{
				if farmPlot.area_IE > min_INT_size{
					shifted_system <-  self shift_IE_to_INT[];
				}else if farmPlot.area_IMS > min_INT_size{
					shifted_system <- self shift_IMS_to_INT[];
				}
			 	if shifted_system{do updateMutationRegistration(shifted_system, "INT");}								
			}
			if productionSystemToMoveTo = IE{
				shifted_system <- self shift_INT_to_IE[];
			 	if shifted_system{do updateMutationRegistration(shifted_system, "IE");}			
			}
			if productionSystemToMoveTo = IMS{
				shifted_system <- self shift_INT_to_IMS[];
			 	if shifted_system{do updateMutationRegistration(shifted_system, "IMS");}			
			}			
		
			if !shifted_system{
				do updateMutationRegistration(shifted_system, "NONE");
			}
		}
		
	action optimise {
			//optimise in the case means nothing else than moving towards intensive.
			bool shifted_system <- false;
			if farmPlot.area_IE > 0{
				shifted_system <- self shift_IE_to_INT[];
			}
			else if farmPlot.area_IMS > 0{
				shifted_system <-  self shift_IMS_to_INT[];
			}
			if shifted_system{do updateMutationRegistration(shifted_system, "INT");}
				
			if !shifted_system{
				do updateMutationRegistration(shifted_system, "NONE");
			}
		}
	

	bool shift_IE_to_INT {
		bool did_shift <- false;
		set investment_cost <- 0.0;
		shift_INT_size <- rnd(0.3, 0.6);
		float cost_1st_month <- 0.0;		
		int shrimpType <- rnd(monodon,vanamei);
		let ic <- invest_cost_INT * shift_INT_size;
		if HH_Account > (Cost_1st_month_INT * shift_INT_size + (invest_surplus_factor*ic)) and (farmPlot.area_IE > 0) {
			did_shift <- true;
			farmPlot.shrimp_Type <- shrimpType;							
			if farmPlot.area_IE - shift_INT_size > 0 {
				farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
				farmPlot.area_IE <- farmPlot.area_IE - shift_INT_size;
				set investment_cost <- ic;				
			} else {
				farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_IE;
				farmPlot.area_IE <- 0.0;
				set investment_cost <- invest_cost_INT * farmPlot.area_IE ;				
			}
		}
		return did_shift;
	}
	
	bool shift_IMS_to_INT {
		//write "IMS to INT";
	    bool did_shift <- false;
		set investment_cost <- 0.0;	    
		if farmPlot.LU_office != "Protection forest" {
		shift_INT_size <- rnd(0.3, 0.6);
		float cost_1st_month <- 0.0;		
		int shrimpType <- rnd(monodon,vanamei);
			let ic <- invest_cost_INT * shift_INT_size;
			if HH_Account > (Cost_1st_month_INT * shift_INT_size + (invest_surplus_factor*ic)) and (farmPlot.area_IMS > 0) {
				if farmPlot.area_INT < max_INT_size{
					did_shift <- true;
					if farmPlot.area_IMS > shift_INT_size {
						farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
						farmPlot.area_IMS <- farmPlot.area_IMS - shift_INT_size;
						farmPlot.shrimp_Type <- shrimpType;
						set investment_cost <- ic;					
					} else {
						farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_IMS;
						farmPlot.area_IMS <- 0.0;
						farmPlot.shrimp_Type <- shrimpType;
						set investment_cost <- invest_cost_INT* farmPlot.area_IMS;				
					}	
				}
			}
		}
		return did_shift;
	}	
	bool shift_INT_to_IE {
		//write "INT to IE";
		bool did_shift <- false;	
		set investment_cost <- 0.0;		
		let ic <- investment_cost + (invest_cost_IE * farmPlot.area_INT);
		if HH_Account > (Cost_1st_month_IE * farmPlot.area_INT +(invest_surplus_factor*ic)) and (farmPlot.area_INT > 0) {
			farmPlot.area_IE <- farmPlot.area_IE + farmPlot.area_INT;
			farmPlot.area_INT <- 0.0;
			set investment_cost <-  ic;
			did_shift <- true;
		}
		return did_shift; 
	}	

	bool shift_INT_to_IMS{
			//write "INT to IMS";
		    bool did_shift <- false;
			set investment_cost <- 0.0;		     
			let ic <- investment_cost + (invest_cost_IMS * farmPlot.area_INT);
			if HH_Account > (Cost_1st_month_IMS * farmPlot.area_INT + (invest_surplus_factor*ic)) and (farmPlot.area_INT > 0){
				farmPlot.area_IMS <- farmPlot.area_IMS  + farmPlot.area_INT;
				farmPlot.area_INT <- 0.0;
				set investment_cost <- ic;
				did_shift <- true;
			}
			return did_shift;
	}

	
	bool reduce_cropping (int fType) {
		bool did_shift <- false;
		int countLoss <- 0;
			if fType = INT {
				float reduceArea <- farmPlot.area_INT * 0.5;
				if HH_Account < Cost_1st_month_INT * farmPlot.area_INT{
					if reduceArea > min_INT_size {
						farmPlot.area_Reduced <- farmPlot.area_Reduced + reduceArea;
						farmPlot.area_INT <- farmPlot.area_INT - reduceArea;
					} else {
						farmPlot.area_Reduced <- farmPlot.area_Reduced + farmPlot.area_INT; // - min_INT_size) ;
						farmPlot.area_INT <- 0.0; //min_INT_size;				
					}
					set farmPlot.production_System_Before_Reduce <- INT;
					did_shift <- true;
				}				
			}else if fType = IE {
				float reduceArea <- farmPlot.area_IE * 0.5;				
				if HH_Account < Cost_1st_month_IE * farmPlot.area_IE{				
					if  reduceArea > min_IE_size {
						farmPlot.area_Reduced <- farmPlot.area_Reduced + reduceArea;
						farmPlot.area_IE <- farmPlot.area_IE - reduceArea;						
					}else if farmPlot.area_IE > min_IE_size  {
						farmPlot.area_Reduced <- farmPlot.area_Reduced + (farmPlot.area_IE - min_IE_size);
						farmPlot.area_IE <- min_IE_size;						
					}else{
						farmPlot.area_Reduced <- farmPlot.area_Reduced + farmPlot.area_IE;
						farmPlot.area_IE <- 0.0;						
						
					}
					set farmPlot.production_System_Before_Reduce <- IE;
					did_shift <- true;	
				}
			}
		return did_shift;
	}

//HELPER ACTIONS
//=============

	action updateMutationRegistration (bool shift, string shiftType){
		
		 	if shift{
		 		add shiftType to: shiftList; 
		 		set changedTo <- shiftType;
		 	} else{
		 		add 'NONE'  to: shiftList; 
		 		changedTo <- 'NONE';
		 	}
	}

	list getXRandomMoreSatisfiedFarms(int n){
		float ownHappiness <- Happyness;
		list<farm> randomFarms <- 500 among farm where (each.Happyness >= ownHappiness);
		list<farm> randomHappierFarms <- []; 
		if length(randomFarms) > 0{		
			 randomHappierFarms <- n among randomFarms;
		} else{
		}		
		return randomHappierFarms;	
	}
		
	list getXClosestsFarms(int n){
		list<float> farmDistances <- [];
		list<farm> allFarms <- (farm collect(each));
		list<farm> closestFarms <- [];
		loop a over: allFarms{
			add distance_to(self, a) to: farmDistances;
		}
		list sortedDistances <- farmDistances sort_by (each);
		closestFarms <- allFarms at_distance sortedDistances[n];
		farmDistances <- nil;
		allFarms <- nil;

		//write (closestFarms);		
		return closestFarms;
	}
	
	
	float neighbourhood_effect
	{
		let nr_of_neighbours <- length(neighbours);
		let INT_neighbours <- find_INT_neighbours();
		//write nr_of_neighbours;
		if nr_of_neighbours > 0
		{
			return (INT_neighbours / nr_of_neighbours);
		} else
		{
			return 0.0;
		}

	}	
	
	int find_INT_neighbours
	{
		let nr_of_Neighbor_whith_intensive <- 0;
		loop n over: neighbours
		{
			if n.farmPlot.area_INT > 0
			{
				set nr_of_Neighbor_whith_intensive <- nr_of_Neighbor_whith_intensive + 1;
			}

		}
		return nr_of_Neighbor_whith_intensive;
	}


	
//	float infra_effect
//	{
//		if (farmPlot.Int_motivat = 1 or farmPlot.Int_motivat = 2)
//		{
//			return 1.0;
//		} else
//		{
//			return 0.0;
//		}
//
//	}	
		
	
	aspect default
	{
		if HH_Account > 0 and farmPlot.area_Reduced = 0
		{
			draw square(35) color: rgb('white');
		} else if HH_Account < 0 and farmPlot.area_Reduced = 0
		{
			draw square(35) color: rgb('black');
		} else if HH_Account > 0 and farmPlot.area_Reduced > 0
		{
			draw circle(35) color: rgb('white');
		} else
		{
			draw circle(35) color: rgb('black');
		}

	}	
} //farm



