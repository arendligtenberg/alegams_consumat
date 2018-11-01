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
	int plotId;
	int nr_Plots;
	int hh_Size;
	float HH_Account;
	//float income <- 0.0;
	float second_Income;
	float loan <- 0.0;
	float costs <- 0.0;	
	float max_loan;
	int age; //years
	float interest_Bank;
	float interest_Commercial;
	int nr_Labour;
	int prob_Shift;
	int time; //month
	int grow_Time_INT; //month
	int grow_Time_IE; //month
	int grow_Time_IMS; //month
	int INT_fail_time;
	int IE_fail_time;
	int INT_sucess_time;
	int IE_sucess_time;
	int cycle_INT_mono;
	int cycle_INT_vana;
	int cycle_IE;
	int cycle_IMS;
	int reduce_time <- 0;
	//int INT_abandon_time <-0;
	float INT_abandoned_area;
	bool reduce_INT <- false;
	bool reduce_IE <- false;
	float crop_cost;
	float income_from_INT_mono;
	float income_from_INT_vana;
	float income_from_IE;
	float income_from_IMS;
	float actual_income;
	float potential_income;
	float second_income;
	float investment_cost;
	float seed_cost;
	bool shifted;
	bool doOnce;
	//int nr_of_Neighbor_whith_intensive;
	//int nr_of_Neighbor;
	list<float> actual_incomeList <- [];
	list<float> potential_incomeList <- [];	
	list<float> delta_incomeList <- [];	
	list<float> costList <- []; 
	list<float> loanList <- [];

	//moved to upper level so these variable can be accessed by alle action/functions (arend 31082017) 
	float int_cost <- 0.0;
	float ie_cost <- 0.0;
	float ims_cost <- 0.0;
	float maintain_cost <- 0.0;
	float hh_cost <- 0.0;

	
	//consumat variables
	float ExistenceNeed <- 0.0;
	float SocialNeed <- 0.0;
	float PersonalNeed <- 0.0;
	float Satisfaction <- 0.0;
	float Uncertainty <- 0.0;
	bool satisFied <- false;
	bool certain <- false;		
	bool buildList <- true;
	list<farm> whoToImmitate <- [];
	
	init
	{
		doOnce <- true;
		hh_Size <- rnd(2, 5);
		age <- rnd(22, 70);
		time <- 1;
		grow_Time_INT <- rnd(0, time_Harvest_INT_mono);
		grow_Time_IE <- rnd(0, time_Harvest_IE);
		grow_Time_IMS <- rnd(0, time_Harvest_IMS);
		cycle_INT_mono <- rnd(0, max_cycle_INT_mono);
		cycle_INT_vana <- rnd(0, max_cycle_INT_vana);
		cycle_IE <- rnd(0, max_cycle_IE);
		cycle_IMS <- rnd(0, max_cycle_IMS);

		//HH_Account <- rnd((-1 * loan), (avg_income));
		HH_Account <- rnd(-1 * avg_income, avg_income);
		//farmPlot.Neighbour <- int((plot) at_distance 100); // when: farmPlot.area_INT > 0;
		grow_Time_IMS <- 0; //month
		INT_fail_time <- 0;
		IE_fail_time <- 0;
		INT_sucess_time <- 0;
		IE_sucess_time <- 0;
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
			whoToImmitate <- getXClosestsFarms(7);
			//write whoToImmitate;
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
			INT_fail_time <- 0;
			IE_fail_time <- 0;
			INT_sucess_time <- 0;
			IE_sucess_time <- 0;
		}

		farmPlot.yield_IE <- 0.0;
		farmPlot.yield_IMS <- 0.0;
		farmPlot.yield_INT_mono <- 0.0;
		farmPlot.yield_INT_vana <- 0.0;
		second_income <- 0.0;
		income_from_INT_mono <- 0.0;
		income_from_INT_vana <- 0.0;
		income_from_IE <- 0.0;
		income_from_IMS <- 0.0;
		crop_cost <- 0.0;
		seed_cost <- 0.0;
		maintain_cost <- 0.0;
		time <- time + 1;
		shifted <- false;
	}

	//	if at the fist time farming in a year, INT farmer failed their crop
	reflex chosing_shrimp_type when: farmPlot.shrimp_Type = monodon and INT_fail_time = 1 and cycle_INT_mono = 1
	{
		if debug
		{
			write "...chosing shrimp larvae";
		}

		farmPlot.shrimp_Type <- vanamei;
	}

	reflex calc_crop_costs
	{
		crop_cost <- 0;
		if debug
		{
			write "...calculating costs";
		}

		//INT
		if farmPlot.area_INT > 0
		{
			if farmPlot.shrimp_Type = monodon
			{
				if grow_Time_INT = 0
				{
					int_cost <- gauss({ Cost_1st_month_INT_mono, cropcost1st_stddev_INT_mono }) * farmPlot.area_INT; //crop cost in the first month for intensive farm with monodon;
				} else
				{
					int_cost <- gauss({ Nomal_cost_INT_mono, Nomal_cost_stddev_INT_mono }) * farmPlot.area_INT;
				}

			}

			if farmPlot.shrimp_Type = vanamei
			{
				if grow_Time_INT = 0
				{
					int_cost <- gauss({ Cost_1st_month_INT_vana, cropcost1st_stddev_INT_vana }) * farmPlot.area_INT; //crop cost in the first month for intensive farm with vanamei;
				} else
				{
					int_cost <- gauss({ Nomal_cost_INT_vana, Nomal_cost_stddev_INT_vana }) * farmPlot.area_INT;
				}

			}

		}
		//IE
		if farmPlot.area_IE > 0
		{
			if grow_Time_IE = 0
			{
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
				ims_cost <- gauss({ Cost_1st_month_IMS, cropcost1st_stddev_IMS }) * farmPlot.area_IMS; //crop cost in the first month for integrated mangrove shrimp farm;
			} else
			{
				ims_cost <- gauss({ Nomal_cost_IMS, Nomal_cost_stddev_IMS }) * farmPlot.area_IMS;
			}

		}

		//Add maintance cost for clean ponds etc. at the end of each cycle (arend 23082017)
		if cycle_INT_mono = max_cycle_INT_mono and farmPlot.shrimp_Type = monodon
		{
			maintain_cost <- maintain_cost + (mantain_cost_INT * farmPlot.area_INT);
			cycle_INT_mono <- 0;
		}

		if cycle_INT_vana = max_cycle_INT_vana and farmPlot.shrimp_Type = vanamei
		{
			maintain_cost <- maintain_cost + (mantain_cost_INT * farmPlot.area_INT);
			cycle_INT_vana <- 0;
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

		crop_cost <- crop_cost + int_cost + ie_cost + ims_cost + maintain_cost; //crop cost is calculate by summing all cost between  amount  of intensive cost, improve extensive and integrated mangrove shrimp	
		//crop_cost <- crop_cost;
	}


	//calculate max income from harvest when nothing goes wrong	
	reflex calculatePotentialIncome{
		let shrimp_price_INT <- 0.0;
		let crop_yield_INT <- 0;
		if (farmPlot.shrimp_Type = monodon){
			shrimp_price_INT <- shrimp_price_INT_mono;
			crop_yield_INT <- crop_yield_INT_mono;
		}else{
			shrimp_price_INT <- shrimp_price_INT_mono;
			crop_yield_INT <- crop_yield_INT_vana;			
		}		 
		 potential_income <- (farmPlot.area_IMS * crop_yield_IMS * shrimp_price_IMS) +  (farmPlot.area_IE * crop_yield_IE * shrimp_price_IE) + (farmPlot.area_INT * crop_yield_INT *shrimp_price_INT);
	}

	// calculate second income for every cycle
	
	reflex calc_second_income
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
	//write grow_Time_INT;
		if debug
		{
			write "...check harvest intensive system";
		}
		//incase of disease
		if flip(farmPlotFailureRate_INT)
		{
		//write "disease at growth time: "+ INT_fail_time;
			if (farmPlot.shrimp_Type = monodon) and grow_Time_INT >= time_Harvest_fail_INT_mono
			{
				farmPlot.yield_INT_mono <- (grow_Time_INT * (1 / time_Harvest_INT_mono)) * crop_yield_INT_mono * farmPlot.area_INT;
				income_from_INT_mono <- farmPlot.yield_INT_mono * shrimp_price_INT_mono;
				if grow_Time_INT >= time_Harvest_fail_INT_mono
				{
					cycle_INT_mono <- cycle_INT_mono + 1;
					INT_fail_time <- INT_fail_time + 1;
				}

			} else if (farmPlot.shrimp_Type = vanamei) and grow_Time_INT >= time_Harvest_fail_INT_vana
			{
				farmPlot.yield_INT_vana <- (grow_Time_INT * (1 / time_Harvest_INT_vana)) * crop_yield_INT_vana * farmPlot.area_INT;
				income_from_INT_vana <- farmPlot.yield_INT_vana * shrimp_price_INT_vana;
				if grow_Time_INT >= time_Harvest_fail_INT_vana
				{
					cycle_INT_vana <- cycle_INT_vana + 1;
					INT_fail_time <- INT_fail_time + 1;
				}

			}
			//grow_Time_INT <- 0;
			seed_cost <- seed_cost + shrimp_init_INT * farmPlot.area_INT;
		} else
		{ //check for harvest incase of no disease
		//write "no disease: "+grow_Time_INT ;
			if farmPlot.shrimp_Type = monodon
			{
				if grow_Time_INT < time_Harvest_INT_mono //  farm can not be harvest

				{
					grow_Time_INT <- grow_Time_INT + 1; //model will check time for harvest in the next time step
				} else //  farm can be harvest

				{
				//write "healthy harvest";
					farmPlot.yield_INT_mono <- crop_yield_INT_mono * farmPlot.area_INT;
					income_from_INT_mono <- farmPlot.yield_INT_mono * shrimp_price_INT_mono;
					cycle_INT_mono <- cycle_INT_mono + 1;
					grow_Time_INT <- 0;
					INT_sucess_time <- INT_sucess_time + 1;
					seed_cost <- seed_cost + shrimp_init_INT * farmPlot.area_INT;
				}

			} else if farmPlot.shrimp_Type = vanamei
			{
				if grow_Time_INT < time_Harvest_INT_vana
				{
					grow_Time_INT <- grow_Time_INT + 1;
				} else //  farm can be harvest

				{
				//write "healthy harvest";
					farmPlot.yield_INT_vana <- crop_yield_INT_vana * farmPlot.area_INT;
					income_from_INT_vana <- farmPlot.yield_INT_vana * shrimp_price_INT_vana;
					cycle_INT_vana <- cycle_INT_vana + 1;
					grow_Time_INT <- 0;
					INT_sucess_time <- INT_sucess_time + 1;
					seed_cost <- seed_cost + shrimp_init_INT * farmPlot.area_INT;
				}

			}

		}

		//if farmPlot.area_IMS > 0 {write grow_Time_INT;}
	}

	reflex check_for_harvest_of_Improved_Extensive when: farmPlot.area_IE > 0
	{
		if debug
		{
			write "...check harvest imporoved extensive system";
		}

		if flip(farmPlotFailureRate_IE)
		{ //in case of the farm get disease when the farm can not be harvest at that moment
			farmPlot.yield_IE <- (grow_Time_IE * (1 / time_Harvest_IE)) * crop_yield_IE * farmPlot.area_IE;
			if grow_Time_IE >= time_Harvest_fail_IE
			{
				cycle_IE <- cycle_IE + 1;
				IE_fail_time <- IE_fail_time + 1;
			}

			grow_Time_IE <- 0;
			seed_cost <- seed_cost + shrimp_init_IE * farmPlot.area_IE;
		} else
		{ //in case of no disease
			if grow_Time_IE < time_Harvest_IE
			{
				grow_Time_IE <- grow_Time_IE + 1;
			} else
			{
				farmPlot.yield_IE <- crop_yield_IE * farmPlot.area_IE;
				cycle_IE <- cycle_IE + 1;
				IE_sucess_time <- IE_sucess_time + 1;
				seed_cost <- seed_cost + shrimp_init_IE * farmPlot.area_IE;
				grow_Time_IE <- 0;
			}

		}

		income_from_IE <- farmPlot.yield_IE * shrimp_price_IE;
	}

	reflex check_for_harvest_of_Integrated_Mangrove when: farmPlot.area_IMS > 0
	{
		if debug
		{
			write "...check harvest mangrove system";
		}

		if flip(farmPlotFailureRate_IMS)
		{
			farmPlot.yield_IMS <- (grow_Time_IMS * (1 / time_Harvest_IMS)) * crop_yield_IMS * farmPlot.area_IMS;
			seed_cost <- seed_cost + shrimp_init_IMS * farmPlot.area_IMS;
			if grow_Time_IMS >= time_Harvest_fail_IMS
			{
				cycle_IMS <- cycle_IMS + 1;
			}

			grow_Time_IMS <- 0;
			seed_cost <- seed_cost + shrimp_init_IMS * farmPlot.area_IMS;
		} else
		{ //in case of no disease
			if grow_Time_IMS < time_Harvest_IMS
			{
				grow_Time_IMS <- grow_Time_IMS + 1;
			} else
			{
				farmPlot.yield_IMS <- crop_yield_IMS * farmPlot.area_IMS;
				seed_cost <- seed_cost + shrimp_init_IMS * farmPlot.area_IMS;
				grow_Time_IMS <- 0;
			}

		}

		income_from_IMS <- farmPlot.yield_IMS * shrimp_price_IMS;
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

		set hh_cost <- hh_Size * HH_expenses_avg;
		actual_income <- income_from_INT_mono + income_from_INT_vana + income_from_IE + income_from_IMS;
		costs <- hh_cost + crop_cost + seed_cost + investment_cost;
		let balance <- (actual_income + second_Income)  - costs;
		let loan_Mutation <- 0.0;
		if (HH_Account + balance) < costs
		{
			loan_Mutation <- costs;
			if (loan + loan_Mutation) > max_loan
			{
				loan_Mutation <- max_loan - loan;
			}

		} else if (HH_Account + balance) > (1.5 * costs)
		{
			if loan > 0
			{
				loan_Mutation <- (-0.1 * loan);
			}

			if loan <= 0
			{
				loan_Mutation <- 0.0;
			}
		}

		set HH_Account <-round(HH_Account + balance + loan_Mutation) with_precision 2;
		set loan <- round(loan + loan_Mutation) with_precision 2;
		if debug2
		{
			write "costs: " + costs;
			write "income: " + actual_income + second_Income;
			write "balance: " + balance;
			write "max loan: " + max_loan;
			write "loan mutation: " + loan_Mutation;
			write "HH_Account after: " + HH_Account;
			write "loan after " + loan;
			write "=====================";
		}

	}

	reflex updateMemory{
		float delta_income;
		if potential_income > 0{
			delta_income <- abs(actual_income - potential_income);	
			//write "pot inc: "+ potential_income+ "act inc: "+actual_income+"delta inc: "+delta_income;
		}else{
			delta_income <- 0.0;
			}
		if length(actual_incomeList) < memDepth{
			add actual_income at: 0 to: actual_incomeList;
			add potential_income at: 0 to: potential_incomeList;
			add delta_income at: 0 to: delta_incomeList;				
			add costs at: 0 to: costList;
			//add loan at: 0 to: loanList;
		}else{
			remove index: memDepth-1 from: actual_incomeList;
			remove index: memDepth-1 from: potential_incomeList;			
			remove index: memDepth-1 from: delta_incomeList;			
			remove index: memDepth-1 from: costList;
			//remove index: memDepth-1 from: loanList;
			add actual_income at: 0 to: actual_incomeList;
			add actual_income at: 0 to: potential_incomeList;
			add delta_income at: 0 to: delta_incomeList;						
			add costs at: 0 to: costList;
			//add loan at: 0 to: loanList;
		}
	}
	
	reflex calculateExistenceNeed when: length(actual_incomeList) = memDepth{
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

	reflex calculateSocialNeed when: length(actual_incomeList) = memDepth {
		// first get average income of peers
		float avgNeigbourIncome <- mean (whoToImmitate collect (mean(each.actual_incomeList)));
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
	
	reflex calculatePersonalNeed when: length(actual_incomeList) = memDepth{
		if age < 30 {
			PersonalNeed  <- 0.8;
		}
		else if age > 50 {
			PersonalNeed <- 0.4;
		} 
		else{
			PersonalNeed <- 0.0;
		}	
	}

	reflex calculateSatisfaction when: length(actual_incomeList) = memDepth{
		float wE <- 0.33;
		float wS <- 0.33;
		float wP <- 0.33;		
		Satisfaction <- (wE * ExistenceNeed) + (wS * SocialNeed) + (wP * PersonalNeed);
	}

	reflex calculateUncertainty  when: length(actual_incomeList) = memDepth{
		float avgDeltaIncome <- mean(delta_incomeList);
		float stdDeltaIncome <- standard_deviation(delta_incomeList);
		//write "avg: "+ avgDeltaIncome+"std: "+stdDeltaIncome;
		if avgDeltaIncome != 0{
			Uncertainty <- (stdDeltaIncome/avgDeltaIncome);	
			//write Uncertainty;
		} 
	}

	reflex chooseBehaviour when: length(actual_incomeList) = memDepth{ 
		//write  "S : "+Satisfaction;
		//write  "U : "+Uncertainty;
		if Satisfaction > ST {satisFied <- true;}else{satisFied <- false;}
		if Uncertainty < UT  {certain <- true;}else{certain <- false;}
		
		if satisFied and certain{
			//write "repetition";
			do repeat;
		}
		if satisFied and !certain{
			//write "imitation";
			do imitate;

		}
		if !satisFied and certain{
			//write "inquire";
			do inquire;
	
		}
		if !satisFied and !certain{
			//write "optimise";
			do optimise;
		}
		
	}


	//shift from INT to other systems
	reflex shift_from_INT when: farmPlot.area_INT > 0 and length(actual_incomeList) = memDepth//and INT_fail_time >= 2
	{
		bool INT_shift <- false;
		investment_cost <- 0.0;
		if farmPlot.area_IMS > 0
		{
			if farmPlot.area_INT < 0.5
			{
				let ic <- invest_cost_IMS * farmPlot.area_INT;
				if HH_Account > ((Cost_1st_month_IMS * farmPlot.area_INT))
				{
					if flip(Prob_shift_INT_IMS)
					{
						if debug5
						{
							write "........shift from int to ims";
						}
						farmPlot.area_IMS <- farmPlot.area_IMS + farmPlot.area_INT;
						farmPlot.area_INT <- 0.0;
						set investment_cost <- ic;
						INT_shift <- true;
					}

				}

			}

		} else if farmPlot.area_IE > 0
		{
			let ic <- investment_cost + (invest_cost_IE * farmPlot.area_INT);
			if HH_Account > (Cost_1st_month_IE * farmPlot.area_INT)
			{
				if flip(Prob_shift_INT_IE)
				{
					if debug
					{
						write "........shift from int to ie";
					}

					farmPlot.area_IE <- farmPlot.area_IE + farmPlot.area_INT;
					farmPlot.area_INT <- 0.0;
					set investment_cost <- ic;
					INT_shift <- true;
				}

			}

		}

		if !INT_shift and flip(reduce_chance)
		{
			if debug4
			{
				write "REDUCING area of intensive...";
			}

			if (farmPlot.area_INT * 0.5) > min_INT_size
			{
				farmPlot.area_Reduced <- farmPlot.area_Reduced + (farmPlot.area_INT * 0.5);
				farmPlot.area_INT <- farmPlot.area_INT * 0.5;
			} else
			{
				farmPlot.area_Reduced <- farmPlot.area_Reduced + farmPlot.area_INT; // - min_INT_size) ;
				farmPlot.area_INT <- 0.0; //min_INT_size;				
			}

			set farmPlot.production_System_Before_Reduce <- INT;
		}

	}



	action shift_IE_to_INT{
			shift_INT_size <- rnd(0.3,0.6);
			let ic <- invest_cost_INT * shift_INT_size;
			if HH_Account > ((Cost_1st_month_INT_mono * shift_INT_size) + ic){
				if farmPlot.area_IE - shift_INT_size > 0{
					farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
					farmPlot.area_IE <- farmPlot.area_IE - shift_INT_size;
					farmPlot.shrimp_Type <- vanamei;
					set investment_cost <- ic;	
				}else{			
						farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_IE;
						farmPlot.area_IE <- 0.0;
						farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)				
						set investment_cost <- ic;					
				}
			}
	}

	action shift_INT_to_IE{
			let ic <- investment_cost + (invest_cost_IE * farmPlot.area_INT);
			if HH_Account > ((Cost_1st_month_IE * farmPlot.area_INT) + ic)
			{
				farmPlot.area_IE <- farmPlot.area_IE + farmPlot.area_INT;
				farmPlot.area_INT <- 0.0;
				set investment_cost <- ic;
			}
	}
	
	action shift_IMS_to_INT{
			shift_INT_size <- rnd(0.3,0.6);
			let ic <- invest_cost_INT * shift_INT_size;
			if HH_Account > ((Cost_1st_month_INT_mono * shift_INT_size) + ic){
				if farmPlot.area_IMS - shift_INT_size > 0{
					farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
					farmPlot.area_IE <- farmPlot.area_IMS - shift_INT_size;
					farmPlot.shrimp_Type <- vanamei;
					set investment_cost <- ic;	
				}else{			
						farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_IMS;
						farmPlot.area_IMS <- 0.0;
						farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)				
						set investment_cost <- ic;					
				}
			}		
	}
	
	action shift_INT_to_IMS{
			let ic <- investment_cost + (invest_cost_IMS * farmPlot.area_INT);
			if HH_Account > ((Cost_1st_month_IMS * farmPlot.area_INT) + ic)
			{
				farmPlot.area_IMS <- farmPlot.area_IMS  + farmPlot.area_INT;
				farmPlot.area_INT <- 0.0;
				set investment_cost <- ic;
			}
	}


	

	reflex shift_from_IE when: farmPlot.area_IE > 0 and length(actual_incomeList) = memDepth
	{
		let Pshift <- calc_change_to_shift(Prob_shift_IE_INT, neighbourhood_effect(), infra_effect());
		//write Pshift;
		bool IE_shift <- false;
		if debug
		{
			write "...analyse shift from IE system";
		}

		investment_cost <- 0.0;
		//if (IE_sucess_time > 0)
		if (IE_fail_time < 3)
		{
			let ic <- invest_cost_INT * shift_INT_size;
			if HH_Account > ((Cost_1st_month_INT_mono * shift_INT_size) + ic)
			{
				if flip(Pshift)
				{
					if farmPlot.area_IE - shift_INT_size > 0
					{
						farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
						farmPlot.area_IE <- farmPlot.area_IE - shift_INT_size;
						farmPlot.shrimp_Type <- vanamei;
						set investment_cost <- ic;
						if debug5
						{
							write "........ shift to INT_IE hybrid";
						}

						IE_shift <- true;
					} else
					{
						farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_IE;
						farmPlot.area_IE <- 0.0;
						farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)				
						set investment_cost <- ic;
						if debug5
						{
							write "........completely shifted from IE to INT";
						}

						IE_shift <- true;
					}

				}

			}

		} else if (IE_fail_time >= 3) and (farmPlot.area_IMS > 0)
		{
			if debug
			{
				write "........shift from IE to IMS";
			}

			farmPlot.area_IMS <- farmPlot.area_IMS + farmPlot.area_IE;
			set investment_cost <- invest_cost_IMS * farmPlot.area_IE;
			farmPlot.area_IE <- 0.0;
			IE_shift <- true;
		} else if (IE_fail_time >= 3) and flip(reduce_chance)
		{
			if debug4
			{
				write "REDUCING area of improved extensive...";
			}

			if (farmPlot.area_IE * 0.5) > min_IE_size
			{
				farmPlot.area_IE <- farmPlot.area_IE * 0.5;
				farmPlot.area_Reduced <- farmPlot.area_Reduced + (farmPlot.area_IE * 0.5);
			} else
			{
				farmPlot.area_IE <- min_IE_size;
				farmPlot.area_Reduced <- farmPlot.area_Reduced + (farmPlot.area_IE - min_IE_size);
			}

			set farmPlot.production_System_Before_Reduce <- IE;
		}

	}

	reflex shift_from_IMS when: (farmPlot.area_IMS > 0 and farmPlot.LU_office != "Protection forest") and length(actual_incomeList) = memDepth
	{
		let Pshift <- calc_change_to_shift(Prob_shift_IMS_INT, neighbourhood_effect(), 0.0);
		//write Pshift;
		if debug
		{
			write "...analyse shift from IMS system";
		}

		investment_cost <- 0.0;
		let ic <- invest_cost_INT * shift_INT_size;
		if HH_Account > ((Cost_1st_month_INT_mono * farmPlot.area_INT) + ic)
		{
			if flip(Pshift) and farmPlot.area_INT < max_INT_size
			{
				if (farmPlot.area_IMS - shift_INT_size) > (0.7 * farmPlot.area_IMS)
				{
					if debug
					{
						write "......increasing INT in hybrid IMS-INT";
					}

					farmPlot.area_INT <- farmPlot.area_INT + shift_INT_size;
					farmPlot.area_IMS <- farmPlot.area_IMS - shift_INT_size;
					farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)
					set investment_cost <- ic;
					//IMS_shift <-true;
				}

			}

		}

	}

	reflex shift_from_reduced when: farmPlot.area_Reduced > 0 and length(actual_incomeList) = memDepth
	{
		if reduce_time >= time_reuse_after_reduce
		{
			if debug4
			{
				write "Recropping reduced area ";
			}

			HH_Account <- rnd(0, (avg_income));
			if farmPlot.production_System_Before_Reduce = INT
			{
				farmPlot.area_INT <- farmPlot.area_INT + farmPlot.area_Reduced;
				set farmPlot.shrimp_Type <- rnd(monodon, vanamei);
				farmPlot.area_Reduced <- 0.0;
			} else
			{
				farmPlot.area_IE <- farmPlot.area_IE + farmPlot.area_Reduced;
				farmPlot.shrimp_Type <- vanamei; //rnd(monodon, vanamei)			
				farmPlot.area_Reduced <- 0.0;
			}

		} else
		{
			reduce_time <- reduce_time + 1;
		}

	}

	//reflex recropabandon when: //abandon
	//	reflex recrop_on_abandoned_farm when: farmPlot.area_Abandon > 0
	//{
	//	if debug{write "...Recrop abandoned pond";}
	//
	//	if INT_abandon_time >= 4
	//	{
	//		if flip(0.5)
	//		{
	//			farmPlot.area_INT <- farmPlot.area_Abandon;
	//			farmPlot.area_Abandon <- 0.0;
	//			crop_cost <- farmPlot.area_INT * Cost_1st_month_INT_vana; // cost to grow the abandoned farm again
	//			grow_Time_INT <- grow_Time_INT + 1;
	//			cycle_INT_vana <- 1;
	//			INT_abandon_time <- 0;
	//		}
	//	} else
	//	{
	//		INT_abandon_time <- INT_abandon_time + 1;
	//	}
	//}
	

	// reflex grow time <- 0 for the systems which has no no area for farming
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

	//	reflex reduce_crop
	//	{
	//		if (INT_fail_time >= fail_time_to_reduce_INT) //INT reduce case requirement
	//		and (INT_sucess_time = 0) and (HH_Account < Cost_1st_month_INT_mono * farmPlot.area_INT) and (farmPlot.area_IMS = 0.0)
	//		{
	//			// 0.9 will be replaced by a parameter
	//			if flip(0.9)
	//			{
	//				if (farmPlot.area_INT - farmPlot.area_INT * 0.5) > min_INT_size
	//				{
	//					farmPlot.area_INT <- farmPlot.area_INT - farmPlot.area_INT * 0.5;
	//				} else
	//				{
	//					farmPlot.area_INT <- min_INT_size;
	//				}
	//
	//				reduce_time <- reduce_time + 1;
	//			}
	//
	//		}

	//		//reduce IE
	//		if (IE_fail_time >= fail_time_to_reduce_IE) and (IE_sucess_time = 0) and (HH_Account < Cost_1st_month_IE * farmPlot.area_IE) and farmPlot.area_IMS > 0.0
	//		{
	//			if flip(0.9)
	//			{
	//				if (farmPlot.area_IE - farmPlot.area_IE * 0.5) > min_IE_size
	//				{
	//					farmPlot.area_IE <- farmPlot.area_IE - farmPlot.area_IE * 0.5;
	//				} else
	//				{
	//					farmPlot.area_IE <- min_IE_size;
	//				}
	//			}
	//
	//		}

	//	} //end of action calculation to reduce crop in case disease


	//action to return # of intensive neighbours

	



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

//actions

	action repeat{

			Prob_shift_IE_INT <- 0.0;
			Prob_shift_IMS_INT<- 0.0;
			Prob_shift_INT_IE <- 0.0;
			Prob_shift_IMS_IE <- 0.0;
			Prob_shift_INT_IMS<- 0.0;
			Prob_shift_IE_IMS <- 0.0;			
	}

	action imitate{
			//write whoToImmitate frequency_of each.farmPlot.production_System;
			map<int,int> prodSystem_frequenties <- whoToImmitate frequency_of each.farmPlot.production_System;
			int productionSystemToMoveTo <- prodSystem_frequenties index_of (max(prodSystem_frequenties));
			if productionSystemToMoveTo = INT{
				Prob_shift_IE_INT <- 1.0;
				Prob_shift_IMS_INT<- 1.0;
				Prob_shift_INT_IE <- 0.0;
				Prob_shift_IMS_IE <- 0.0;
				Prob_shift_INT_IMS<- 0.0;
				Prob_shift_IE_IMS <- 0.0;
				
			}
			if productionSystemToMoveTo = IE{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.8;
				Prob_shift_IMS_IE <- 0.8;
				Prob_shift_INT_IMS<- 0.03;
				Prob_shift_IE_IMS <- 0.05;
			}
			
			if productionSystemToMoveTo = IMS{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.05;
				Prob_shift_IMS_IE <- 0.05;
				Prob_shift_INT_IMS<- 0.8;
				Prob_shift_IE_IMS <- 0.8;
			}				   
	}

	action inquire{
			list<farm> randomFarms <- getXRandomFarms(10); 
			map<int,int> prodSystem_frequenties <- randomFarms frequency_of each.farmPlot.production_System;
			int productionSystemToMoveTo <- prodSystem_frequenties index_of (max(prodSystem_frequenties));
			if productionSystemToMoveTo = INT{
				Prob_shift_IE_INT <- 0.8;
				Prob_shift_IMS_INT<- 0.8;
				Prob_shift_INT_IE <- 0.05;
				Prob_shift_IMS_IE <- 0.05;
				Prob_shift_INT_IMS<- 0.03;
				Prob_shift_IE_IMS <- 0.05;
				
			}
			if productionSystemToMoveTo = IE{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.8;
				Prob_shift_IMS_IE <- 0.8;
				Prob_shift_INT_IMS<- 0.03;
				Prob_shift_IE_IMS <- 0.05;
			}
			
			if productionSystemToMoveTo = IMS{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.05;
				Prob_shift_IMS_IE <- 0.05;
				Prob_shift_INT_IMS<- 0.8;
				Prob_shift_IE_IMS <- 0.8;			
			
			}
		}
		
		action optimise{
			list<farm> allFarms <- (farm collect(each));
			map<int,int> prodSystem_frequenties <- allFarms frequency_of each.farmPlot.production_System;
			int productionSystemToMoveTo <- prodSystem_frequenties index_of (max(prodSystem_frequenties));
				if productionSystemToMoveTo = INT{
				Prob_shift_IE_INT <- 0.8;
				Prob_shift_IMS_INT<- 0.8;
				Prob_shift_INT_IE <- 0.05;
				Prob_shift_IMS_IE <- 0.05;
				Prob_shift_INT_IMS<- 0.03;
				Prob_shift_IE_IMS <- 0.05;
				
			}
			if productionSystemToMoveTo = IE{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.8;
				Prob_shift_IMS_IE <- 0.8;
				Prob_shift_INT_IMS<- 0.03;
				Prob_shift_IE_IMS <- 0.05;
			}
			
			if productionSystemToMoveTo = IMS{
				Prob_shift_IE_INT <- 0.05;
				Prob_shift_IMS_INT<- 0.05;
				Prob_shift_INT_IE <- 0.05;
				Prob_shift_IMS_IE <- 0.05;
				Prob_shift_INT_IMS<- 0.8;
				Prob_shift_IE_IMS <- 0.8;
			}				   
			
				
		}
	

		list getXRandomFarms(int n){
			list<farm>randomFarms <- [];
			loop times: n{
				add (one_of(farm)) to: randomFarms;
				
			}
			return randomFarms;	
		}

	
		list getXClosestsFarms(int n){
//		 list<farm> closestFarms <- [];
//		 list<farm> allFarms <- (farm collect(each));
//		 loop times: n{
//		 	//farm closestFarm <- allFarms closest_to(self);
//		 	farm closestFarm <- allFarms with_min_of (each distance_to self);
//		 	add closestFarm to: closestFarms;
//		 	remove closestFarm from: allFarms; 
//		 }
		//write closestFarms;	

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
	
	float infra_effect
	{
		if (farmPlot.Int_motivat = 1 or farmPlot.Int_motivat = 2)
		{
			return 1.0;
		} else
		{
			return 0.0;
		}

	}	
	
	float calc_change_to_shift (float Pbase, float Pneightbor, float Pinfra)
	{
	//let Ptoto <- Pbase + Pneightbor + Pinfra;
	//let Pshift <- (3-(3*0.25^Ptoto))/3;
		let Pshift <- Pbase + (weight_NB_effect * Pneightbor) + (weight_Infra_effect * Pinfra);
		return Pshift;
	}
} //farm

