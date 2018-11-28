/**
* Name: alagamsglobals
* Author: ligte002
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model Alegams_globals
 global{
	// gobal vars	
 	
 	bool debug <- false; 
 	bool debug1 <- false;
 	bool debug2 <-false;
	bool debug3 <-false; 	
	bool debug4 <-false;	
	bool debug5 <-false;	
	//int  dummy <- 0;
 	//coding of production systems
 	int INT <- 1;
 	int IE <- 2;
 	int IMS <- 3;
 	int INT_IE <- 4;
 	int INT_IMS <- 5;
 	int IE_IMS <- 6;
 	int Abandon <- 7;
 	int unKnown <- 999;
 	
 	//coding of shrimp types
 	int monodon <- 1;
 	int vanamei <- 2;

 	//init probabilities for initial production systems
 	float Prob_INT <- 0.5;
 	float Prob_IE <- 0.5;
 	float Prob_IMS <- 0.1;
 	float Prob_INT_IE <- 0.1;
 	float Prob_INT_IMS <- 0.3;
 	float Prob_IE_IMS <- 0.1;
 	
 	//max number of Cycles:
 	int max_cycle_INT <- 3;

 	//int max_cycle_INT_mono <- 2;
 	//int max_cycle_INT_vana <- 3;
	int max_cycle_IE <- 3;
	int max_cycle_IMS <- 999; 
	
 	//Times to harvest
 	int time_Harvest_INT <- 4;
 	
 	int time_Harvest_INT_mono <- 4 parameter: "time to harvest intensive Monodon (months)" category: "Crop" ;
	int time_Harvest_INT_vana <- 3 parameter: "time to harvest intensive Vannamei (months)" category: "Crop" ;
	int time_Harvest_IE <- 4 parameter: "time to harvest intensive improved extensive (months)" category: "Crop" ;
	int time_Harvest_IMS <- 3 parameter: "time to harvest integrated mangrove (months)" category: "Crop" ;
	
	//In case of disease can harvest after:
	int time_Harvest_fail_INT <- 2;
	
 	int time_Harvest_fail_INT_mono <- 2 parameter: "min. req. period toharvest intensive Monodon (months)" category: "Crop" ;
	int time_Harvest_fail_INT_vana <- 1 parameter: "min. req. period toharvest intensive Vannamei (months)" category: "Crop" ;
	int time_Harvest_fail_IE <- 1 parameter: "min. req. period toharvest improved extensive (months)" category: "Crop" ;
	int time_Harvest_fail_IMS <- 2 parameter: "min. req. period toharvest integrated mangrove (months)" category: "Crop" ;



 	// In case Breakeven harvest time due to disease
 	//Parameter to harvest
 	//int time_Harvest_breakeven_INT_mono <- 3 parameter: "period have to harvest intensive Monodon (months)" category: "Crop" ;
	//int time_Harvest_breakeven_INT_vana <- 2 parameter: "period have to harvest intensive Vannamei (months)" category: "Crop" ;
	//int time_Harvest_breakeven_IE <- 2 parameter: "period have to harvest improved extensive (months)" category: "Crop" ;
 	

 	float farmPlotFailureRate_INT <- 0.4; //parameter: "chance of disease for intensive" category: "Crop" ; //0.2;
 	float farmPlotFailureRate_IE <- 0.3;// parameter: "chance of disease for improved extensive" category: "Crop" ; //0.12;
 	float farmPlotFailureRate_IMS <- 0.1;// parameter: "chance of disease for integrated mangrove" category: "Crop" ; //0.1;

	//In case of reduced farm pond
	float reduce_chance <- 0.9;
	int time_reuse_after_reduce <- 3;
	
	//reducing condition for each system
	int fail_time_to_reduce_INT <-12;
	int fail_time_to_reduce_IE <-2;
	
	//probability to shift
	
	float Prob_shift_IE_INT;  //<- 0.5; //0.5
 	float Prob_shift_IMS_IE ; //<- 0.05;  //0.05
 	float Prob_shift_IMS_INT; // <- 0.001; //0.01
 	float Prob_shift_INT_IE; // <- 0.1; //0.1
 	float Prob_shift_INT_IMS; // <- 0.03; //0.03
 	float Prob_shift_IE_IMS; // <- 0.01; //0.01
 	float Prob_shift_Abandon <- 0.5; //0.5
	
	//crop yields  (kg/ha/cycle) 

	
	int crop_yield_INT_mono <- 5814 parameter: "crop yields intensive Monodon (kg/ha/cycle)" category: "Crop" ; //5814
	int crop_yield_INT_vana <- 8897	parameter: "crop yields intensive Vannamei (kg/ha/cycle)" category: "Crop" ; //8897	
	int crop_yield_IE <- 568 parameter: "crop yields improved extensive (kg/ha/cycle)" category: "Crop" ;	//568
	int crop_yield_IMS <- 308 parameter: "crop yields integrated mangrove (kg/ha/cycle)" category: "Crop" ; //308	
	
	//factor that determines the loss of shrimp in case of disease
	float costLossFactor <- 1.0;

 
	//household related income from aquaculture

	float avg_income <- 150.0; //average income for all systems (only for initialisation)
	float HH_expenses_avg <- 2.5 parameter: "average household expenses (mVnd/pp/month)" category: "Farm" ; //2.5
	 	
	//household related income from other sources
	float HH_2ndincome_avg_INT <-25/12 parameter: "average sec. income intensive Monodon(mVnd/month)" category: "Farm" ;
	float HH_2ndincome_stddev_INT <- 5.00/12;
	float HH_2ndincome_avg_IE <- 11.5/12 parameter: "average sec. income improved extensive (mVnd/month)" category: "Farm" ;
	float HH_2ndincome_stddev_IE <- 2.00/12; 
	float HH_2ndincome_avg_IMS <- 5.6/12 parameter: "average sec. income integrated mangrove (mVnd/month)" category: "Farm" ;
	float HH_2ndincome_stddev_IMS <- 1.00/12 ;
	
	
	//basic pond size
 	float min_INT_size <- 0.1 parameter: "min size of intensive ponds (ha.)" category: "Farm" ;
 	float max_INT_size <- 1.8 parameter: "max size of intensive ponds (ha.)" category: "Farm" ;
 	float min_IE_size <- 0.5 parameter: "min size of improved extensive ponds)" category: "Farm" ;
    float max_IE_size <- 2.0 parameter: "max size of improved extensive ponds)" category: "Farm";
    
    //shifting for new pond
   	float shift_INT_size;
   	float shift_IE_size;
   	float shift_IMS_size;

    reflex update_system_sizes {
    	shift_INT_size <- rnd(0.3,0.6);
    	shift_IE_size <- rnd(0.5,0.8);
    	shift_IMS_size <- rnd(1.0,1.5);
    }
    
    //maximum loan for each system (mvnd/ha)
    int max_loan_INT <- 90;
    int max_loan_IE <-150;
    int max_loan_IMS <-50;
    
	
	//cost to seed new shrimp pond (mVnd/ha)
 	float shrimp_init_INT <- 0.0 parameter: "cost to seed new intensive (mVnd/ha)" category: "Crop" ; //250
 	float shrimp_init_IE <- 0.0 parameter: "cost to seed new improved extensive(mVnd/ha)" category: "Crop" ; //85
 	float shrimp_init_IMS <- 0.0 parameter: "cost to seed new integrated mangrove(mVnd/ha)" category: "Crop" ; //79	 
 	 			
	//crop costs (Mvnd/ha/month)
	//float cropcost_avg_INT_mono <- 122.0 parameter: "crop costs intensive Monodon (mVnd/ha/month)" category: "Crop" ;
	//float cropcost_avg_INT_vana <- 218.0 parameter: "crop costs intensive Vanamei (mVnd/ha/month)" category: "Crop" ;
	//float cropcost_stddev_INT_vana <- 0.0;	
	//float cropcost_avg_IE <- 17.00 parameter: "crop costs improved extensive (mVnd/ha/month)" category: "Crop" ;
	//float cropcost_stddev_IE <- 0.0;	
	//float cropcost_avg_IMS <- 3.0 parameter: "crop costs integrated mangrove (mVnd/ha/month)" category: "Crop" ;
	//float cropcost_stddev_IMS <- 0.0;
	
	// maintance cost
 	float mantain_cost_INT <- 45.0 parameter: "mantain crop cost intensive (mVnd/ha/cycle)" category: "Crop" ;
 	float mantain_cost_IE <- 10.0 parameter: "mantain crop cost improve extensive (mVnd/ha/cycle)" category: "Crop" ;//13
 	float mantain_cost_IMS <- 5.0 parameter: "mantain crop cost integrated mangrove shrimp (mVnd/ha/cycle)" category: "Crop" ;
	
	
 	//cost to feed for 1st month cropping (mvnd/ha)
 	float Cost_1st_month_INT <- 180.0 parameter: "1st crop cost intensive Monodon (mVnd/ha)" category: "Crop" ;
 	float cropcost1st_stddev_INT <- 35.0;
 
 
 	float Cost_1st_month_INT_mono <- 120.0 parameter: "1st crop cost intensive Monodon (mVnd/ha)" category: "Crop" ;
 	float cropcost1st_stddev_INT_mono <- 25.0;
 	float Cost_1st_month_INT_vana <- 240.0 parameter: "1st crop cost intensive  Vanamei (mVnd/ha)" category: "Crop" ;
 	float cropcost1st_stddev_INT_vana <- 50.0;
 	float Cost_1st_month_IE <- 35.0 parameter: "1st crop cost Improved Extensive (mVnd/ha)" category: "Crop" ;
 	float cropcost1st_stddev_IE <- 5.0;
 	float Cost_1st_month_IMS <- 8.0 parameter: "1st crop cost Mangrove Systems (mVnd/ha)" category: "Crop" ;
 	float cropcost1st_stddev_IMS <- 2.0;
 	
 	//cost to feed monthly after 1stmonth cropping
 	float Nomal_cost_INT <- 130 parameter: "monthly crop cost intensive Monodon (mVnd/ha/month)" category: "Crop" ;
 	float Nomal_cost_stddev_INT <- 10.0;
 	
 
 
 	float Nomal_cost_INT_mono <- 95.0 parameter: "monthly crop cost intensive Monodon (mVnd/ha/month)" category: "Crop" ;
 	float Nomal_cost_stddev_INT_mono <- 5.0;
 	float Nomal_cost_INT_vana <- 170.0 parameter: "monthly crop cost intensive Vanamei (mVnd/ha/month)" category: "Crop" ;
 	float Nomal_cost_stddev_INT_vana <- 10.0;
 	float Nomal_cost_IE <- 7.0 parameter: "monthly crop cost improved extensive (mVnd/ha/month)" category: "Crop" ;
 	float Nomal_cost_stddev_IE <- 1.0;
 	float Nomal_cost_IMS <- 1.0 parameter: "monthly crop cost integrated mangrove shrimp (mVnd/ha/month)" category: "Crop" ;
 	float Nomal_cost_stddev_IMS <- 0.2;

	
	//investment cost
	
	float invest_cost_INT <- 260.0;
	
	float invest_cost_INT_mono <- 235.0;
	float invest_cost_INT_vana <- 290.0;
	float invest_cost_IE <- 80.0;
	float invest_cost_IMS <- 50.0;
		
	
	//shrimp prices Mvnc/kg
	
	float shrimp_price_INT <- 0.25;
	float shrimp_price_INT_mono <- 0.25 parameter: "shrimp price intensive Monodon (mVnd/kg)" category: "Market" ; //0.25
	float shrimp_price_INT_vana <- 0.18 parameter: "shrimp price intensive Vannamei (mVnd/kg)" category: "Market" ; //0.12
	float shrimp_price_IE <- 0.25 parameter: "shrimp price improved extensive (mVnd/kg)" category: "Market" ; //0.25
	float shrimp_price_IMS <- 0.25 parameter: "shrimp price integrated mangrove (mVnd/kg)" category: "Market" ; //0.25


	//radius around farmers to scan for neighbors
	int radius_neighbors <- 200;
	
	//weight to give to effects of neighborhood and presence of infrastructure
	//disabled neighborhoodeffect as this  model implemets the cosumat
	//float weight_NB_effect <- 0.0;
	//float weight_Infra_effect <- 0.25;


	//CONSUMAT parameters
	//depth of memory
	int memDepth <- 5;	
	//threshold satisfaction
	float ST <- 0.2;
	//threshold uncertainty;
	float UT <- 0.2;
	float baseUncertainty <-0.0;
//
int number_INT_IE;

	
	
	
 	//file plot_file <- file ('../includes/LongVinhProvinceCorrectFinal3.shp');
 	file plot_file <- file ('../includes/BenTreProvinceCorrectFinal.shp');
 	}
 	


